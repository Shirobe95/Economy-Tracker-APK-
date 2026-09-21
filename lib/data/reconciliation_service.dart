import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_provider.dart';
import '../core/database/enums.dart';
import '../core/utils/dates.dart';
import '../core/utils/money.dart';
import 'account_repository.dart';
import 'movement_repository.dart';

/// Lo que hay que ajustar para que la aplicacion diga lo que dice el banco.
class Reconciliation {
  const Reconciliation({
    required this.account,
    required this.appBalance,
    required this.realBalance,
  });

  final Account account;

  /// Lo que la aplicacion calcula ahora mismo.
  final int appBalance;

  /// Lo que dice el banco.
  final int realBalance;

  /// Diferencia con signo. Positiva si en el banco hay mas de lo que la
  /// aplicacion creia.
  int get delta => realBalance - appBalance;

  bool get matches => delta == 0;

  /// Tope de saldo que se admite al cuadrar, en unidades menores.
  ///
  /// Son mil millones de euros. No es una regla de negocio: es lo que evita
  /// que una resta de enteros de 64 bits desborde y cambie de signo, que
  /// anotaria el ajuste justo al reves.
  static const int maxBalance = 100000000000;

  /// Si el ajuste anade dinero que no estaba anotado.
  bool get isGain => delta > 0;
}

/// Cuadrar el saldo de una cuenta con el del banco.
///
/// El ajuste **no es una correccion invisible: es un movimiento de verdad**,
/// con su categoria, su fecha y su importe, y cuenta como gasto o como
/// ingreso igual que los demas.
///
/// Es deliberado. Si el banco dice que hay 11 € menos de lo que la aplicacion
/// creia, es que esos 11 € se gastaron en algo que no se anoto. Meterlos en
/// un cajon neutro que no aparece en ningun informe dejaria que ese dinero se
/// escapase mes tras mes sin que nadie lo viera, que es justo lo contrario de
/// lo que hace esta aplicacion en todo lo demas (DEC-003). Puestos en su
/// categoria, se ve cuanto dinero se va sin saber a donde.
///
/// Tampoco se toca el saldo inicial de la cuenta: cambiarlo reescribiria el
/// pasado y todos los saldos de meses anteriores dejarian de cuadrar.
class ReconciliationService {
  ReconciliationService(this._db);

  final AppDatabase _db;

  /// Nombre reservado de la categoria donde van los ajustes.
  static const String categoryName = 'Ajuste de saldo';

  /// Calcula la diferencia sin escribir nada.
  Future<Reconciliation> preview({
    required int accountId,
    required int realBalance,
  }) async {
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(accountId))).getSingle();

    final movements = await (_db.select(
      _db.transactions,
    )..where((t) => t.isDeleted.equals(false))).get();

    if (realBalance.abs() > Reconciliation.maxBalance) {
      throw const MovementValidationError(
        'Ese saldo no parece real. Revisa la cifra.',
      );
    }

    final balance = AccountRepository.balanceOf(account, movements);
    if (balance == null) {
      throw const MovementValidationError(
        'El saldo de esta cuenta no se puede calcular, asi que tampoco se '
        'puede cuadrar.',
      );
    }

    return Reconciliation(
      account: account,
      appBalance: balance,
      realBalance: realBalance,
    );
  }

  /// Anota el ajuste. Devuelve `null` si ya cuadraba y no habia nada que hacer.
  Future<int?> reconcile({
    required int accountId,
    required int realBalance,
    DateTime? date,
    String? notes,
  }) async {
    final day = Dates.day(date ?? Dates.today());
    final result = await preview(
      accountId: accountId,
      realBalance: realBalance,
    );
    if (result.matches) return null;

    final categoryId = await _adjustmentCategory();
    final amount = result.delta.abs();
    final type = result.isGain
        ? MovementType.otherIncome
        : MovementType.expense;

    return MovementRepository(_db).save(
      MovementDraft(
        type: type,
        status: MovementRepository.realisedStatusFor(type),
        concept: 'Ajuste de saldo',
        amount: amount,
        accountId: accountId,
        categoryId: categoryId,
        expectedDate: day,
        actualDate: day,
        currency: result.account.currency,
        // La nota guarda contra que cifra se cuadro: dentro de seis meses,
        // eso es lo unico que permite entender de donde salio el ajuste.
        notes:
            notes ??
            'Cuadrado con el banco: '
                '${Money.format(realBalance, currency: result.account.currency)}.',
      ),
    );
  }

  /// La categoria de ajustes, creandola la primera vez.
  ///
  /// Se busca una que **sirva**, no una que se llame asi. El guardado rechaza
  /// las categorias archivadas y las que no admiten la direccion del
  /// movimiento, asi que reutilizar a ciegas una homonima que alguien creo
  /// como «solo gastos» reventaria justo al cuadrar hacia arriba.
  ///
  /// Se leen todas y no `getSingleOrNull`: el nombre no es unico en el
  /// esquema ni hay nada que impida crear dos a mano, y ahi la consulta
  /// fallaba con un «Bad state» que no le dice nada a nadie.
  Future<int> _adjustmentCategory() async {
    final candidates = await (_db.select(
      _db.categories,
    )..where((c) => c.name.equals(categoryName))).get();

    for (final category in candidates) {
      if (!category.isArchived && category.kind == CategoryKind.both) {
        return category.id;
      }
    }

    return _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: categoryName,
            kind: CategoryKind.both,
          ),
        );
  }
}

final reconciliationServiceProvider = Provider<ReconciliationService>(
  (ref) => ReconciliationService(ref.watch(appDatabaseProvider)),
);
