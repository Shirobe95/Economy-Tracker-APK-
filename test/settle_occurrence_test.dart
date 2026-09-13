import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/database_provider.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/account_repository.dart';
import 'package:economy_tracker/data/forecast_engine.dart';
import 'package:economy_tracker/data/movement_repository.dart';
import 'package:economy_tracker/data/recurring_rule_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// El atajo para el recibo que se adelanta: marcar una ocurrencia concreta
/// como ya pagada sin anotar un gasto suelto que luego se cuente dos veces.
void main() {
  late AppDatabase db;
  late RecurringRuleRepository rules;
  late AccountRepository accounts;
  late MovementRepository movements;

  setUp(() {
    db = openTestDatabase();
    rules = RecurringRuleRepository(db);
    accounts = AccountRepository(db);
    movements = MovementRepository(db);
  });

  tearDown(() async => db.close());

  Future<RecurringRule> monthlyRule({int amount = 5000}) async {
    final accountId = await accounts.createAccount(
      name: 'Cuenta',
      type: AccountType.bank,
      initialBalance: 100000,
    );
    final id = await rules.saveRule(
      concept: 'Seguro moto',
      type: MovementType.expense,
      accountId: accountId,
      amount: amount,
      frequency: RecurrenceFrequency.monthly,
      intervalCount: 1,
      startDate: DateTime.utc(2026, 9, 25),
    );
    return (await rules.watchRule(id).first)!;
  }

  test('registra el pago con la fecha real que se adelanto', () async {
    final rule = await monthlyRule();

    await rules.settleOccurrence(
      rule: rule,
      occurrence: DateTime.utc(2026, 9, 25),
      actualDate: DateTime.utc(2026, 9, 20),
    );

    final movement = (await db.select(db.transactions).get()).single;
    expect(movement.concept, 'Seguro moto');
    expect(movement.status, MovementStatus.pagado);
    expect(movement.expectedDate, DateTime.utc(2026, 9, 25));
    expect(movement.actualDate, DateTime.utc(2026, 9, 20));
    expect(movement.recurringRuleId, rule.id);
  });

  test('el saldo baja al marcarla', () async {
    final rule = await monthlyRule();

    await rules.settleOccurrence(
      rule: rule,
      occurrence: DateTime.utc(2026, 9, 25),
      actualDate: DateTime.utc(2026, 9, 20),
    );

    final account = (await db.select(db.accounts).get()).single;
    final rows = await db.select(db.transactions).get();
    expect(AccountRepository.balanceOf(account, rows), 95000);
  });

  test('marcarla dos veces no duplica el gasto', () async {
    final rule = await monthlyRule();

    final first = await rules.settleOccurrence(
      rule: rule,
      occurrence: DateTime.utc(2026, 9, 25),
      actualDate: DateTime.utc(2026, 9, 20),
    );
    final second = await rules.settleOccurrence(
      rule: rule,
      occurrence: DateTime.utc(2026, 9, 25),
      actualDate: DateTime.utc(2026, 9, 21),
    );

    expect(first, second);
    expect((await db.select(db.transactions).get()).length, 1);
    // Y no cambia la fecha en la que se pago de verdad la primera vez.
    final movement = (await db.select(db.transactions).get()).single;
    expect(movement.actualDate, DateTime.utc(2026, 9, 20));
  });

  test(
    'si ya estaba anotada sin pagar, la completa en vez de duplicar',
    () async {
      final rule = await monthlyRule();
      await movements.save(
        MovementDraft(
          type: MovementType.expense,
          status: MovementStatus.pendiente,
          concept: 'Seguro moto',
          amount: 5000,
          accountId: rule.accountId,
          recurringRuleId: rule.id,
          expectedDate: DateTime.utc(2026, 9, 25),
        ),
      );

      await rules.settleOccurrence(
        rule: rule,
        occurrence: DateTime.utc(2026, 9, 25),
        actualDate: DateTime.utc(2026, 9, 20),
      );

      final rows = await db.select(db.transactions).get();
      expect(rows.length, 1);
      expect(rows.single.status, MovementStatus.pagado);
      expect(rows.single.actualDate, DateTime.utc(2026, 9, 20));
    },
  );

  test('admite corregir el importe sin tocar la regla', () async {
    final rule = await monthlyRule(amount: 5000);

    await rules.settleOccurrence(
      rule: rule,
      occurrence: DateTime.utc(2026, 9, 25),
      actualDate: DateTime.utc(2026, 9, 20),
      amount: 5250,
    );

    expect((await db.select(db.transactions).get()).single.amount, 5250);
    expect((await rules.watchRule(rule.id).first)!.amount, 5000);
  });

  test('la prevision no cuenta dos veces una ocurrencia ya pagada', () async {
    final rule = await monthlyRule();
    await rules.settleOccurrence(
      rule: rule,
      occurrence: DateTime.utc(2026, 9, 25),
      actualDate: DateTime.utc(2026, 9, 20),
    );

    final result = ForecastEngine.project(
      accounts: await db.select(db.accounts).get(),
      movements: await db.select(db.transactions).get(),
      rules: [rule],
      from: DateTime.utc(2026, 9, 22),
      months: 3,
    );

    // Septiembre ya esta pagado: solo quedan octubre y noviembre.
    expect(result.totalExpense, 10000);
  });

  test('el esquema impide duplicar una ocurrencia por otra via', () async {
    final rule = await monthlyRule();
    await rules.settleOccurrence(
      rule: rule,
      occurrence: DateTime.utc(2026, 9, 25),
      actualDate: DateTime.utc(2026, 9, 20),
    );

    await expectLater(
      movements.save(
        MovementDraft(
          type: MovementType.expense,
          status: MovementStatus.pendiente,
          concept: 'Seguro moto otra vez',
          amount: 5000,
          accountId: rule.accountId,
          recurringRuleId: rule.id,
          expectedDate: DateTime.utc(2026, 9, 25),
        ),
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('las ocurrencias ya liquidadas se pueden consultar por fecha', () async {
    final rule = await monthlyRule();
    await rules.settleOccurrence(
      rule: rule,
      occurrence: DateTime.utc(2026, 10, 25),
      actualDate: DateTime.utc(2026, 10, 24),
    );

    final settled = await rules.watchSettled(rule.id).first;
    expect(settled.keys, ['2026-10-25']);
    expect(settled['2026-10-25']!.status, MovementStatus.pagado);
  });
}
