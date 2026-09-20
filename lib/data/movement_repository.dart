import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_provider.dart';
import '../core/database/enums.dart';
import '../core/utils/dates.dart';
import 'account_repository.dart';

/// Error de validacion funcional de un movimiento.
///
/// Se lanza antes de tocar la base: el esquema es la ultima defensa, no la
/// primera, y un CHECK de SQLite no da un mensaje util a quien rellena el
/// formulario.
class MovementValidationError implements Exception {
  const MovementValidationError(this.message, {this.field});

  final String message;

  /// Campo del formulario al que corresponde, si aplica.
  final String? field;

  @override
  String toString() => message;
}

/// Datos de un movimiento antes de guardarlo.
class MovementDraft {
  const MovementDraft({
    this.id,
    required this.type,
    required this.status,
    required this.concept,
    required this.amount,
    required this.accountId,
    required this.expectedDate,
    this.actualDate,
    this.destinationAccountId,
    this.categoryId,
    this.projectId,
    this.salarySourceId,
    this.savingsGoalId,
    this.recurringRuleId,
    this.notes,
    this.currency = kDefaultCurrency,
  });

  /// `null` para un alta; el identificador existente para una edicion.
  final int? id;
  final MovementType type;
  final MovementStatus status;
  final String concept;

  /// Importe positivo en unidades menores. El tipo marca la direccion.
  final int amount;
  final int accountId;
  final DateTime expectedDate;
  final DateTime? actualDate;
  final int? destinationAccountId;
  final int? categoryId;
  final int? projectId;
  final int? salarySourceId;
  final int? savingsGoalId;
  final int? recurringRuleId;
  final String? notes;
  final String currency;

  MovementDraft copyWith({
    MovementStatus? status,
    DateTime? actualDate,
    bool clearActualDate = false,
  }) {
    return MovementDraft(
      id: id,
      type: type,
      status: status ?? this.status,
      concept: concept,
      amount: amount,
      accountId: accountId,
      expectedDate: expectedDate,
      actualDate: clearActualDate ? null : (actualDate ?? this.actualDate),
      destinationAccountId: destinationAccountId,
      categoryId: categoryId,
      projectId: projectId,
      salarySourceId: salarySourceId,
      savingsGoalId: savingsGoalId,
      recurringRuleId: recurringRuleId,
      notes: notes,
      currency: currency,
    );
  }
}

/// Alta, edicion, borrado y consulta de movimientos.
///
/// Toda escritura pasa por [_validate] y por una transaccion: o se guarda
/// entera o no se guarda nada.
class MovementRepository {
  MovementRepository(this._db);

  final AppDatabase _db;

  /// Estados validos para cada tipo de movimiento.
  ///
  /// Un gasto se paga, un ingreso se cobra. No al reves.
  static List<MovementStatus> statusesFor(MovementType type) => [
    MovementStatus.previsto,
    MovementStatus.pendiente,
    if (type.isExpense || type.isTransfer) MovementStatus.pagado,
    if (type.isIncome) MovementStatus.cobrado,
    MovementStatus.cancelado,
  ];

  /// Estado realizado que corresponde al tipo: pagado o cobrado.
  static MovementStatus realisedStatusFor(MovementType type) =>
      type.isIncome ? MovementStatus.cobrado : MovementStatus.pagado;

  /// Guarda un movimiento nuevo o actualiza uno existente.
  ///
  /// Devuelve el identificador de la fila. Actualiza `updatedAt` de forma
  /// explicita: el valor por defecto solo cubre la insercion.
  Future<int> save(MovementDraft draft) async {
    return _db.transaction(() async {
      final resolved = await _validate(draft);
      final now = DateTime.now();

      final companion = TransactionsCompanion(
        type: Value(resolved.type),
        status: Value(resolved.status),
        concept: Value(resolved.concept.trim()),
        amount: Value(resolved.amount),
        currency: Value(resolved.currency),
        accountId: Value(resolved.accountId),
        destinationAccountId: Value(resolved.destinationAccountId),
        categoryId: Value(resolved.categoryId),
        clientId: Value(resolved.clientId),
        projectId: Value(resolved.projectId),
        salarySourceId: Value(resolved.salarySourceId),
        savingsGoalId: Value(resolved.savingsGoalId),
        recurringRuleId: Value(resolved.recurringRuleId),
        expectedDate: Value(Dates.day(resolved.expectedDate)),
        actualDate: Value(
          resolved.actualDate == null ? null : Dates.day(resolved.actualDate!),
        ),
        notes: Value(_trimToNull(resolved.notes)),
        updatedAt: Value(now),
      );

      final id = draft.id;
      if (id == null) {
        return _db.into(_db.transactions).insert(companion);
      }

      final updated = await (_db.update(
        _db.transactions,
      )..where((t) => t.id.equals(id))).write(companion);
      if (updated == 0) {
        throw const MovementValidationError(
          'El movimiento ya no existe. Puede que se haya eliminado.',
        );
      }
      return id;
    });
  }

  /// Marca un movimiento como realizado en la fecha indicada.
  ///
  /// Volver a marcar uno ya realizado no cambia su primera fecha real: el
  /// dinero se movio una sola vez.
  Future<void> markRealised(int id, DateTime actualDate) async {
    await _db.transaction(() async {
      final movement = await (_db.select(
        _db.transactions,
      )..where((t) => t.id.equals(id))).getSingleOrNull();

      if (movement == null) {
        throw const MovementValidationError('El movimiento ya no existe.');
      }
      if (movement.status.isRealised) return;

      await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          status: Value(realisedStatusFor(movement.type)),
          actualDate: Value(Dates.day(actualDate)),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  /// Devuelve un movimiento a un estado no realizado.
  ///
  /// Existe para poder deshacer un "pagado" marcado sin querer: al dejar de
  /// estar realizado pierde la fecha real, porque el dinero ya no se movio.
  Future<void> revertToStatus(int id, MovementStatus status) async {
    if (status.isRealised) {
      throw const MovementValidationError(
        'Para volver a un estado realizado hace falta su fecha real.',
      );
    }

    await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        status: Value(status),
        actualDate: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Borrado real, sin dejar fila.
  ///
  /// Solo para deshacer una ocurrencia recurrente recien marcada desde un
  /// listado: esa fila nacio de un toque y deshacerlo no deberia dejar
  /// historia que conservar. Ademas, el borrado logico no serviria: la fila
  /// seguiria ocupando su hueco en el indice unico de (regla, fecha
  /// prevista) y no se podria volver a marcar esa misma ocurrencia.
  Future<void> purge(int id) {
    return (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Borrado logico: sale del listado y del saldo, conserva la historia.
  Future<void> delete(int id) {
    return (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Movimientos vivos de un tipo cuya fecha prevista cae en un mes.
  Stream<List<Transaction>> watchByMonth({
    required DateTime month,
    Set<MovementType>? types,
    int? accountId,
  }) {
    final start = Dates.monthStart(month);
    final end = Dates.nextMonthStart(month);

    final query = _db.select(_db.transactions)
      ..where((t) => t.isDeleted.equals(false))
      ..where((t) => t.expectedDate.isBiggerOrEqualValue(isoDay(start)))
      ..where((t) => t.expectedDate.isSmallerThanValue(isoDay(end)))
      ..orderBy([
        (t) => OrderingTerm.asc(t.expectedDate),
        (t) => OrderingTerm.asc(t.id),
      ]);

    if (accountId != null) {
      query.where((t) => t.accountId.equals(accountId));
    }
    if (types != null && types.isNotEmpty) {
      query.where((t) => t.type.isIn(types.map((e) => e.code)));
    }
    return query.watch();
  }

  /// Todos los movimientos vivos, para saldos y previsión.
  Stream<List<Transaction>> watchAll() {
    final query = _db.select(_db.transactions)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.asc(t.expectedDate)]);
    return query.watch();
  }

  /// Un movimiento concreto, o `null` si se elimino.
  Stream<Transaction?> watchById(int id) {
    final query = _db.select(_db.transactions)
      ..where((t) => t.id.equals(id))
      ..where((t) => t.isDeleted.equals(false));
    return query.watchSingleOrNull();
  }

  /// Comprueba el borrador y resuelve los campos derivados.
  Future<_ResolvedMovement> _validate(MovementDraft draft) async {
    if (draft.concept.trim().isEmpty) {
      throw const MovementValidationError(
        'Escribe un concepto.',
        field: 'concept',
      );
    }
    if (draft.amount <= 0) {
      throw const MovementValidationError(
        'El importe debe ser mayor que cero.',
        field: 'amount',
      );
    }

    final account = await _requireAccount(draft.accountId);
    if (account.currency != draft.currency) {
      throw MovementValidationError(
        'La cuenta ${account.name} esta en ${account.currency} y el '
        'movimiento en ${draft.currency}.',
        field: 'account',
      );
    }
    if (account.isArchived) {
      throw MovementValidationError(
        'La cuenta ${account.name} esta archivada.',
        field: 'account',
      );
    }

    if (!statusesFor(draft.type).contains(draft.status)) {
      throw MovementValidationError(
        'El estado ${draft.status.code} no es valido para este tipo de '
        'movimiento.',
        field: 'status',
      );
    }

    if (draft.status.isRealised && draft.actualDate == null) {
      throw const MovementValidationError(
        'Elige la fecha real en la que ocurrio.',
        field: 'actualDate',
      );
    }
    if (!draft.status.isRealised && draft.actualDate != null) {
      throw const MovementValidationError(
        'Solo un movimiento pagado o cobrado tiene fecha real.',
        field: 'actualDate',
      );
    }

    await _validateCategory(draft);
    final clientId = await _resolveClient(draft);
    await _validateTransfer(draft, account);

    return _ResolvedMovement(draft, clientId);
  }

  Future<Account> _requireAccount(int id) async {
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (account == null) {
      throw const MovementValidationError(
        'Elige una cuenta.',
        field: 'account',
      );
    }
    return account;
  }

  Future<void> _validateCategory(MovementDraft draft) async {
    final categoryId = draft.categoryId;
    if (categoryId == null) return;

    final category = await (_db.select(
      _db.categories,
    )..where((c) => c.id.equals(categoryId))).getSingleOrNull();

    if (category == null) {
      throw const MovementValidationError(
        'Esa categoria ya no existe.',
        field: 'category',
      );
    }
    if (category.isArchived) {
      throw MovementValidationError(
        'La categoria ${category.name} esta archivada.',
        field: 'category',
      );
    }

    final accepted = draft.type.isExpense
        ? category.kind.acceptsExpense()
        : draft.type.isIncome
        ? category.kind.acceptsIncome()
        : false;

    if (!accepted) {
      throw MovementValidationError(
        'La categoria ${category.name} no admite este tipo de movimiento.',
        field: 'category',
      );
    }
  }

  /// El cliente de un cobro no se elige: es el del proyecto.
  Future<int?> _resolveClient(MovementDraft draft) async {
    final projectId = draft.projectId;
    if (projectId == null) return null;

    final project = await (_db.select(
      _db.projects,
    )..where((p) => p.id.equals(projectId))).getSingleOrNull();

    if (project == null) {
      throw const MovementValidationError(
        'Ese proyecto ya no existe.',
        field: 'project',
      );
    }
    return project.clientId;
  }

  Future<void> _validateTransfer(MovementDraft draft, Account origin) async {
    if (!draft.type.isTransfer) {
      if (draft.destinationAccountId != null) {
        throw const MovementValidationError(
          'Solo una transferencia tiene cuenta de destino.',
          field: 'destinationAccount',
        );
      }
      return;
    }

    final destinationId = draft.destinationAccountId;
    if (destinationId == null) {
      throw const MovementValidationError(
        'Elige la cuenta de destino.',
        field: 'destinationAccount',
      );
    }
    if (destinationId == draft.accountId) {
      throw const MovementValidationError(
        'El origen y el destino no pueden ser la misma cuenta.',
        field: 'destinationAccount',
      );
    }

    final destination = await _requireAccount(destinationId);
    if (destination.currency != origin.currency) {
      throw MovementValidationError(
        'No se puede transferir entre cuentas en monedas distintas '
        '(${origin.currency} y ${destination.currency}).',
        field: 'destinationAccount',
      );
    }
  }

  static String? _trimToNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

/// Borrador ya validado, con el cliente resuelto a partir del proyecto.
class _ResolvedMovement {
  const _ResolvedMovement(this._draft, this.clientId);

  final MovementDraft _draft;
  final int? clientId;

  MovementType get type => _draft.type;
  MovementStatus get status => _draft.status;
  String get concept => _draft.concept;
  int get amount => _draft.amount;
  String get currency => _draft.currency;
  int get accountId => _draft.accountId;
  int? get destinationAccountId => _draft.destinationAccountId;
  int? get categoryId => _draft.categoryId;
  int? get projectId => _draft.projectId;
  int? get salarySourceId => _draft.salarySourceId;
  int? get savingsGoalId => _draft.savingsGoalId;
  int? get recurringRuleId => _draft.recurringRuleId;
  DateTime get expectedDate => _draft.expectedDate;
  DateTime? get actualDate => _draft.actualDate;
  String? get notes => _draft.notes;
}

final movementRepositoryProvider = Provider<MovementRepository>(
  (ref) => MovementRepository(ref.watch(appDatabaseProvider)),
);

final allMovementsProvider = StreamProvider<List<Transaction>>(
  (ref) => ref.watch(movementRepositoryProvider).watchAll(),
);
