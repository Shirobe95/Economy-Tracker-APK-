import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_provider.dart';
import '../core/database/enums.dart';
import '../core/utils/dates.dart';
import 'account_repository.dart';

/// Un objetivo de ahorro con su progreso ya calculado.
///
/// Separa las tres cifras que DEC-003 exige no confundir: lo que se quiere
/// alcanzar, lo que hay ahorrado de verdad y a que ritmo se aporta.
class GoalProgress {
  const GoalProgress({required this.goal});

  final SavingsGoal goal;

  /// Un objetivo mensual no tiene meta final: su exito se mide mes a mes.
  bool get isMonthly => goal.kind.isMonthly;

  /// Lo que hay que apartar cada mes.
  ///
  /// En un objetivo mensual es el propio objetivo; en uno por importe, la
  /// aportacion declarada, si la hay.
  int? get monthlyTarget =>
      isMonthly ? goal.targetAmount : goal.monthlyContribution;

  /// Ahorro real declarado. `null` cuando no se ha declarado ninguno: no es
  /// lo mismo que cero.
  int? get current => goal.currentAmount;

  /// Fraccion completada entre 0 y 1, o `null` si no hay ahorro declarado.
  double? get ratio {
    final amount = current;
    if (amount == null || goal.targetAmount <= 0) return null;
    final value = amount / goal.targetAmount;
    return value > 1 ? 1 : value;
  }

  /// Lo que falta para llegar al objetivo, o para cumplir el mes.
  int? get remaining {
    final amount = current;
    if (amount == null) return null;
    final left = goal.targetAmount - amount;
    return left > 0 ? left : 0;
  }

  /// Meses que faltan al ritmo de la aportacion mensual declarada.
  ///
  /// Devuelve `null` si no hay aportacion o no hay ahorro declarado: una
  /// fecha estimada sin esos datos seria inventada. Un objetivo mensual no
  /// tiene meta final, asi que tampoco tiene fecha de llegada.
  int? get monthsToTarget {
    if (isMonthly) return null;
    final left = remaining;
    final monthly = goal.monthlyContribution;
    if (left == null || monthly == null || monthly <= 0) return null;
    if (left == 0) return 0;
    return (left + monthly - 1) ~/ monthly;
  }

  /// Fecha estimada de llegada, al ritmo actual.
  DateTime? get estimatedDate {
    final months = monthsToTarget;
    if (months == null) return null;
    final today = Dates.today();
    return DateTime.utc(today.year, today.month + months, 1);
  }
}

/// Objetivos de ahorro.
class GoalRepository {
  GoalRepository(this._db);

  final AppDatabase _db;

  Stream<List<GoalProgress>> watchGoals({bool includeArchived = false}) {
    final query = _db.select(_db.savingsGoals)
      ..orderBy([(g) => OrderingTerm.asc(g.name)]);
    if (!includeArchived) {
      query.where((g) => g.isArchived.equals(false));
    }
    return query.watch().map(
      (rows) => [for (final goal in rows) GoalProgress(goal: goal)],
    );
  }

  Stream<SavingsGoal?> watchGoal(int id) {
    final query = _db.select(_db.savingsGoals)..where((g) => g.id.equals(id));
    return query.watchSingleOrNull();
  }

  Future<int> saveGoal({
    int? id,
    required String name,
    required int targetAmount,
    SavingsGoalKind kind = SavingsGoalKind.amount,
    int? currentAmount,
    int? monthlyContribution,
    DateTime? targetDate,
    DateTime? startMonth,
    String currency = kDefaultCurrency,
  }) {
    final monthly = kind.isMonthly;
    final companion = SavingsGoalsCompanion(
      name: Value(name.trim()),
      kind: Value(kind),
      targetAmount: Value(targetAmount),
      currentAmount: Value(currentAmount),
      // Un objetivo mensual no lleva aportacion aparte: el objetivo ya es la
      // aportacion. Ni fecha de llegada, porque no hay meta que alcanzar.
      monthlyContribution: Value(monthly ? null : monthlyContribution),
      targetDate: Value(
        monthly || targetDate == null ? null : Dates.day(targetDate),
      ),
      // Solo los mensuales acumulan: en uno por importe un mes de inicio no
      // significaria nada, porque lo apartado es lo que se declara.
      startMonth: Value(
        monthly ? Dates.monthStart(startMonth ?? Dates.today()) : null,
      ),
      currency: Value(currency),
      updatedAt: Value(DateTime.now()),
    );

    if (id == null) {
      return _db.into(_db.savingsGoals).insert(companion);
    }
    return (_db.update(
      _db.savingsGoals,
    )..where((g) => g.id.equals(id))).write(companion).then((_) => id);
  }

  /// Declara el ahorro real acumulado de un objetivo.
  ///
  /// Es un dato que la persona afirma, no una suma automatica de ingresos:
  /// el dinero sobrante no es ahorro por si solo (DEC-003).
  Future<void> declareCurrentAmount(int id, int? amount) {
    return (_db.update(_db.savingsGoals)..where((g) => g.id.equals(id))).write(
      SavingsGoalsCompanion(
        currentAmount: Value(amount),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setArchived(int id, bool archived) {
    return (_db.update(_db.savingsGoals)..where((g) => g.id.equals(id))).write(
      SavingsGoalsCompanion(
        isArchived: Value(archived),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => GoalRepository(ref.watch(appDatabaseProvider)),
);

final goalsProvider = StreamProvider<List<GoalProgress>>(
  (ref) => ref.watch(goalRepositoryProvider).watchGoals(),
);
