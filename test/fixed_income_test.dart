import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/database_provider.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/account_repository.dart';
import 'package:economy_tracker/data/movement_repository.dart';
import 'package:economy_tracker/data/project_repository.dart';
import 'package:economy_tracker/data/recurring_rule_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cobro de proyecto fijo (DEC-016): un cliente que paga una cuota
/// recurrente, a diferencia del cobro suelto de un trabajo puntual que ya
/// cubria ECON-000E.
void main() {
  late AppDatabase db;
  late ProjectRepository projects;
  late RecurringRuleRepository rules;
  late AccountRepository accounts;

  setUp(() {
    db = openTestDatabase();
    projects = ProjectRepository(db);
    rules = RecurringRuleRepository(db);
    accounts = AccountRepository(db);
  });

  tearDown(() async => db.close());

  Future<int> account() =>
      accounts.createAccount(name: 'Cuenta', type: AccountType.bank);

  test('un cobro fijo exige proyecto', () async {
    final accountId = await account();

    await expectLater(
      rules.saveRule(
        concept: 'Mantenimiento mensual',
        type: MovementType.projectIncome,
        accountId: accountId,
        amount: 30000,
        frequency: RecurrenceFrequency.monthly,
        intervalCount: 1,
        startDate: DateTime.utc(2026, 9, 1),
      ),
      throwsA(isA<MovementValidationError>()),
    );
  });

  test('una regla de gasto no puede llevar proyecto', () async {
    final accountId = await account();
    final clientId = await projects.saveClient(name: 'Cliente');
    final projectId = await projects.saveProject(
      clientId: clientId,
      name: 'Proyecto',
    );

    await expectLater(
      rules.saveRule(
        concept: 'Gasto con proyecto por error',
        type: MovementType.expense,
        accountId: accountId,
        projectId: projectId,
        amount: 5000,
        frequency: RecurrenceFrequency.monthly,
        intervalCount: 1,
        startDate: DateTime.utc(2026, 9, 1),
      ),
      throwsA(isA<MovementValidationError>()),
    );
  });

  test('el cliente del cobro fijo se deriva del proyecto', () async {
    final accountId = await account();
    final clientId = await projects.saveClient(name: 'Futon Espai');
    final projectId = await projects.saveProject(
      clientId: clientId,
      name: 'Mantenimiento web',
    );

    final ruleId = await rules.saveRule(
      concept: 'Cuota mensual',
      type: MovementType.projectIncome,
      accountId: accountId,
      projectId: projectId,
      amount: 30000,
      frequency: RecurrenceFrequency.monthly,
      intervalCount: 1,
      startDate: DateTime.utc(2026, 9, 1),
    );

    final rule = await rules.watchRule(ruleId).first;
    expect(rule!.projectId, projectId);
    // No se elige a mano: si se pudiera, podria no coincidir con el
    // proyecto y la clave compuesta del esquema lo rechazaria.
    expect(rule.clientId, clientId);
  });

  test(
    'liquidar la ocurrencia de un cobro fijo lo deja ligado al proyecto',
    () async {
      final accountId = await account();
      final clientId = await projects.saveClient(name: 'Cliente');
      final projectId = await projects.saveProject(
        clientId: clientId,
        name: 'Proyecto',
      );
      final ruleId = await rules.saveRule(
        concept: 'Cuota mensual',
        type: MovementType.projectIncome,
        accountId: accountId,
        projectId: projectId,
        amount: 30000,
        frequency: RecurrenceFrequency.monthly,
        intervalCount: 1,
        startDate: DateTime.utc(2026, 9, 1),
      );
      final rule = await rules.watchRule(ruleId).first;

      await rules.settleOccurrence(
        rule: rule!,
        occurrence: DateTime.utc(2026, 9, 1),
        actualDate: DateTime.utc(2026, 9, 2),
      );

      // Sin el projectId en la ocurrencia liquidada, el cobro no apareceria
      // ni en la ficha del proyecto ni en sus totales.
      final incomes = await projects.watchIncomes(projectId).first;
      expect(incomes.single.amount, 30000);
      expect(incomes.single.status, MovementStatus.cobrado);

      final summary = (await projects.watchSummaries().first).single;
      expect(summary.collected, 30000);
    },
  );

  test('watchRules filtra las reglas de un proyecto', () async {
    final accountId = await account();
    final clientId = await projects.saveClient(name: 'Cliente');
    final projectA = await projects.saveProject(
      clientId: clientId,
      name: 'Proyecto A',
    );
    final projectB = await projects.saveProject(
      clientId: clientId,
      name: 'Proyecto B',
    );

    await rules.saveRule(
      concept: 'Cuota A',
      type: MovementType.projectIncome,
      accountId: accountId,
      projectId: projectA,
      amount: 10000,
      frequency: RecurrenceFrequency.monthly,
      intervalCount: 1,
      startDate: DateTime.utc(2026, 9, 1),
    );
    await rules.saveRule(
      concept: 'Cuota B',
      type: MovementType.projectIncome,
      accountId: accountId,
      projectId: projectB,
      amount: 20000,
      frequency: RecurrenceFrequency.monthly,
      intervalCount: 1,
      startDate: DateTime.utc(2026, 9, 1),
    );

    final rulesOfA = await rules
        .watchRules(type: MovementType.projectIncome, projectId: projectA)
        .first;
    expect(rulesOfA.single.concept, 'Cuota A');
  });

  test('editar un cobro fijo no lo convierte en gasto', () async {
    // El bug real que esto evita: la pantalla de edicion de reglas usaba
    // siempre el tipo del constructor (gasto, por defecto) en vez del de la
    // regla que se estaba editando. Aqui se prueba el repositorio: guardar
    // de nuevo con el mismo tipo que ya tenia la regla debe conservarlo.
    final accountId = await account();
    final clientId = await projects.saveClient(name: 'Cliente');
    final projectId = await projects.saveProject(
      clientId: clientId,
      name: 'Proyecto',
    );
    final ruleId = await rules.saveRule(
      concept: 'Cuota mensual',
      type: MovementType.projectIncome,
      accountId: accountId,
      projectId: projectId,
      amount: 30000,
      frequency: RecurrenceFrequency.monthly,
      intervalCount: 1,
      startDate: DateTime.utc(2026, 9, 1),
    );

    await rules.saveRule(
      id: ruleId,
      concept: 'Cuota mensual revisada',
      type: MovementType.projectIncome,
      accountId: accountId,
      projectId: projectId,
      amount: 32000,
      frequency: RecurrenceFrequency.monthly,
      intervalCount: 1,
      startDate: DateTime.utc(2026, 9, 1),
    );

    final rule = await rules.watchRule(ruleId).first;
    expect(rule!.type, MovementType.projectIncome);
    expect(rule.projectId, projectId);
    expect(rule.amount, 32000);
  });
}
