import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/database_provider.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/goal_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dos formas de plantear el ahorro: juntar una cantidad, o apartar un
/// importe cada mes. La segunda no tiene meta final, y todo lo que dependa
/// de una meta tiene que desaparecer, no valer cero.
void main() {
  late AppDatabase db;
  late GoalRepository goals;

  setUp(() {
    db = openTestDatabase();
    goals = GoalRepository(db);
  });

  tearDown(() async => db.close());

  test('por defecto un objetivo es de importe', () async {
    await goals.saveGoal(name: 'Fondo', targetAmount: 600000);
    final progress = (await goals.watchGoals().first).single;

    expect(progress.goal.kind, SavingsGoalKind.amount);
    expect(progress.isMonthly, isFalse);
  });

  test('un objetivo mensual guarda su importe como objetivo del mes', () async {
    await goals.saveGoal(
      name: 'Ahorro del mes',
      kind: SavingsGoalKind.monthly,
      targetAmount: 20000,
    );
    final progress = (await goals.watchGoals().first).single;

    expect(progress.isMonthly, isTrue);
    expect(progress.monthlyTarget, 20000);
  });

  test(
    'un objetivo mensual no guarda aporte aparte ni fecha de llegada',
    () async {
      await goals.saveGoal(
        name: 'Ahorro del mes',
        kind: SavingsGoalKind.monthly,
        targetAmount: 20000,
        monthlyContribution: 99999,
        targetDate: DateTime.utc(2027, 1, 1),
      );
      final progress = (await goals.watchGoals().first).single;

      expect(progress.goal.monthlyContribution, isNull);
      expect(progress.goal.targetDate, isNull);
      expect(progress.monthsToTarget, isNull);
      expect(progress.estimatedDate, isNull);
    },
  );

  test('el progreso mensual se mide contra el importe del mes', () async {
    final id = await goals.saveGoal(
      name: 'Ahorro del mes',
      kind: SavingsGoalKind.monthly,
      targetAmount: 20000,
    );
    await goals.declareCurrentAmount(id, 15000);

    final progress = (await goals.watchGoals().first).single;
    expect(progress.ratio, closeTo(0.75, 0.001));
    expect(progress.remaining, 5000);
  });

  test('sin declarar nada, un objetivo mensual no inventa un cero', () async {
    await goals.saveGoal(
      name: 'Ahorro del mes',
      kind: SavingsGoalKind.monthly,
      targetAmount: 20000,
    );
    final progress = (await goals.watchGoals().first).single;

    expect(progress.current, isNull);
    expect(progress.ratio, isNull);
  });

  test('un objetivo de importe sigue calculando cuando llegara', () async {
    final id = await goals.saveGoal(
      name: 'Portatil',
      targetAmount: 150000,
      monthlyContribution: 15000,
    );
    await goals.declareCurrentAmount(id, 45000);

    final progress = (await goals.watchGoals().first).single;
    expect(progress.monthlyTarget, 15000);
    expect(progress.monthsToTarget, 7);
    expect(progress.estimatedDate, isNotNull);
  });

  test('cambiar un objetivo a mensual limpia lo que ya no aplica', () async {
    final id = await goals.saveGoal(
      name: 'Portatil',
      targetAmount: 150000,
      monthlyContribution: 15000,
      targetDate: DateTime.utc(2027, 4, 1),
    );

    await goals.saveGoal(
      id: id,
      name: 'Ahorro del mes',
      kind: SavingsGoalKind.monthly,
      targetAmount: 20000,
    );

    final progress = (await goals.watchGoals().first).single;
    expect(progress.isMonthly, isTrue);
    expect(progress.goal.monthlyContribution, isNull);
    expect(progress.goal.targetDate, isNull);
  });
}
