import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_provider.dart';
import '../core/database/enums.dart';
import '../core/utils/dates.dart';
import 'account_repository.dart';
import 'movement_repository.dart';
import 'recurrence_schedule.dart';

/// Reglas de repeticion.
///
/// Una regla es una plantilla con un calendario, no una lista de movimientos.
/// No se materializa ninguna ocurrencia en `transactions`, `autoGenerate`
/// permanece en false y no hay planificador en segundo plano: consultar las
/// proximas fechas no escribe nada y no puede duplicar un gasto.
///
/// Si algun dia se materializan, hara falta antes una clave de unicidad y una
/// generacion transaccional idempotente.
class RecurringRuleRepository {
  RecurringRuleRepository(this._db);

  final AppDatabase _db;

  Stream<List<RecurringRule>> watchRules({int? accountId, MovementType? type}) {
    final query = _db.select(_db.recurringRules)
      ..orderBy([(r) => OrderingTerm.asc(r.concept)]);
    if (accountId != null) {
      query.where((r) => r.accountId.equals(accountId));
    }
    if (type != null) {
      query.where((r) => r.type.equals(type.code));
    }
    return query.watch();
  }

  Stream<RecurringRule?> watchRule(int id) {
    final query = _db.select(_db.recurringRules)..where((r) => r.id.equals(id));
    return query.watchSingleOrNull();
  }

  /// Guarda una regla y deja calculada su proxima fecha.
  ///
  /// La fecha de inicio es el ancla nominal: cambiar el importe no la mueve,
  /// cambiarla expresamente establece una nueva.
  Future<int> saveRule({
    int? id,
    required String concept,
    required MovementType type,
    required int accountId,
    int? categoryId,
    int? destinationAccountId,
    required int amount,
    required RecurrenceFrequency frequency,
    required int intervalCount,
    required DateTime startDate,
    DateTime? endDate,
    bool isActive = true,
    String currency = kDefaultCurrency,
  }) async {
    if (concept.trim().isEmpty) {
      throw const MovementValidationError(
        'Escribe un concepto.',
        field: 'concept',
      );
    }
    if (amount <= 0) {
      throw const MovementValidationError(
        'El importe debe ser mayor que cero.',
        field: 'amount',
      );
    }
    if (intervalCount < 1 || intervalCount > 120) {
      throw const MovementValidationError(
        'El intervalo debe estar entre 1 y 120.',
        field: 'intervalCount',
      );
    }
    if (endDate != null && endDate.isBefore(startDate)) {
      throw const MovementValidationError(
        'La fecha de fin no puede ser anterior a la de inicio.',
        field: 'endDate',
      );
    }

    final anchor = Dates.day(startDate);
    final schedule = RecurrenceSchedule(
      anchor: anchor,
      frequency: frequency,
      intervalCount: intervalCount,
      endDate: endDate == null ? null : Dates.day(endDate),
      isActive: isActive,
    );
    final upcoming = schedule.upcoming(from: Dates.today(), count: 1);

    final companion = RecurringRulesCompanion(
      concept: Value(concept.trim()),
      type: Value(type),
      accountId: Value(accountId),
      destinationAccountId: Value(destinationAccountId),
      categoryId: Value(categoryId),
      amount: Value(amount),
      currency: Value(currency),
      frequency: Value(frequency),
      intervalCount: Value(intervalCount),
      startDate: Value(anchor),
      endDate: Value(endDate == null ? null : Dates.day(endDate)),
      monthDay: Value(
        frequency == RecurrenceFrequency.monthly ||
                frequency == RecurrenceFrequency.yearly
            ? anchor.day
            : null,
      ),
      weekday: Value(
        frequency == RecurrenceFrequency.weekly ? anchor.weekday : null,
      ),
      nextDate: Value(upcoming.isEmpty ? null : upcoming.first),
      isActive: Value(isActive),
      updatedAt: Value(DateTime.now()),
    );

    if (id == null) {
      return _db.into(_db.recurringRules).insert(companion);
    }
    await (_db.update(
      _db.recurringRules,
    )..where((r) => r.id.equals(id))).write(companion);
    return id;
  }

  Future<void> setActive(int id, bool active) async {
    await _db.transaction(() async {
      final rule = await (_db.select(
        _db.recurringRules,
      )..where((r) => r.id.equals(id))).getSingleOrNull();
      if (rule == null) return;

      final schedule = RecurrenceSchedule.fromRule(rule).copyWithActive(active);
      final upcoming = schedule.upcoming(from: Dates.today(), count: 1);

      await (_db.update(
        _db.recurringRules,
      )..where((r) => r.id.equals(id))).write(
        RecurringRulesCompanion(
          isActive: Value(active),
          nextDate: Value(upcoming.isEmpty ? null : upcoming.first),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> deleteRule(int id) {
    return (_db.delete(_db.recurringRules)..where((r) => r.id.equals(id))).go();
  }
}

final recurringRuleRepositoryProvider = Provider<RecurringRuleRepository>(
  (ref) => RecurringRuleRepository(ref.watch(appDatabaseProvider)),
);
