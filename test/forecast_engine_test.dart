import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/forecast_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime.utc(2026, 9, 13);

  Account account({int id = 1, int initialBalance = 432000}) => Account(
    id: id,
    name: 'Cuenta principal',
    type: AccountType.bank,
    currency: 'EUR',
    initialBalance: initialBalance,
    isArchived: false,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );

  Transaction movement({
    int id = 1,
    required MovementType type,
    required MovementStatus status,
    required int amount,
    required DateTime expectedDate,
    DateTime? actualDate,
    int? recurringRuleId,
    bool isDeleted = false,
    String concept = 'Movimiento',
  }) => Transaction(
    id: id,
    type: type,
    status: status,
    concept: concept,
    amount: amount,
    currency: 'EUR',
    accountId: 1,
    expectedDate: expectedDate,
    actualDate: actualDate,
    recurringRuleId: recurringRuleId,
    isDeleted: isDeleted,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );

  RecurringRule rule({
    int id = 1,
    required int amount,
    required MovementType type,
    required DateTime startDate,
    bool isActive = true,
    RecurrenceFrequency frequency = RecurrenceFrequency.monthly,
    String concept = 'Regla',
  }) => RecurringRule(
    id: id,
    concept: concept,
    type: type,
    accountId: 1,
    amount: amount,
    currency: 'EUR',
    frequency: frequency,
    intervalCount: 1,
    startDate: startDate,
    isActive: isActive,
    autoGenerate: false,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
  );

  ForecastResult project({
    List<Account>? accounts,
    List<Transaction> movements = const [],
    List<RecurringRule> rules = const [],
    int months = 3,
  }) => ForecastEngine.project(
    accounts: accounts ?? [account()],
    movements: movements,
    rules: rules,
    from: today,
    months: months,
  );

  group('punto de partida', () {
    test('parte del saldo real de las cuentas', () {
      final result = project();
      expect(result.startingBalance, 432000);
    });

    test('sin cuentas no hay datos que proyectar', () {
      final result = project(accounts: []);
      expect(result.hasData, isFalse);
      expect(result.startingBalance, 0);
    });

    test('una cuenta archivada no cuenta en el saldo de partida', () {
      final archived = Account(
        id: 2,
        name: 'Antigua',
        type: AccountType.bank,
        currency: 'EUR',
        initialBalance: 1000000,
        isArchived: true,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );
      final result = project(accounts: [account(), archived]);
      expect(result.startingBalance, 432000);
    });
  });

  group('movimientos comprometidos', () {
    test('un gasto pendiente futuro baja la proyeccion', () {
      final result = project(
        movements: [
          movement(
            type: MovementType.expense,
            status: MovementStatus.pendiente,
            amount: 85000,
            expectedDate: DateTime.utc(2026, 10, 3),
          ),
        ],
      );
      expect(result.points[1].expense, 85000);
      expect(result.endingBalance, 432000 - 85000);
    });

    test('un ingreso pendiente futuro sube la proyeccion', () {
      final result = project(
        movements: [
          movement(
            type: MovementType.projectIncome,
            status: MovementStatus.pendiente,
            amount: 50000,
            expectedDate: DateTime.utc(2026, 10, 5),
          ),
        ],
      );
      expect(result.endingBalance, 432000 + 50000);
    });

    test('lo ya cobrado no se cuenta dos veces', () {
      // Ya esta dentro del saldo real, no puede volver a sumar.
      final result = project(
        movements: [
          movement(
            type: MovementType.salary,
            status: MovementStatus.cobrado,
            amount: 180000,
            expectedDate: DateTime.utc(2026, 9, 1),
            actualDate: DateTime.utc(2026, 9, 1),
          ),
        ],
      );
      expect(result.startingBalance, 432000 + 180000);
      expect(result.endingBalance, result.startingBalance);
    });

    test('lo cancelado no entra en la proyeccion', () {
      final result = project(
        movements: [
          movement(
            type: MovementType.expense,
            status: MovementStatus.cancelado,
            amount: 85000,
            expectedDate: DateTime.utc(2026, 10, 3),
          ),
        ],
      );
      expect(result.endingBalance, 432000);
    });

    test('lo borrado no entra en la proyeccion', () {
      final result = project(
        movements: [
          movement(
            type: MovementType.expense,
            status: MovementStatus.pendiente,
            amount: 85000,
            expectedDate: DateTime.utc(2026, 10, 3),
            isDeleted: true,
          ),
        ],
      );
      expect(result.endingBalance, 432000);
    });

    test('un gasto pasado pendiente no se proyecta hacia delante', () {
      final result = project(
        movements: [
          movement(
            type: MovementType.expense,
            status: MovementStatus.pendiente,
            amount: 85000,
            expectedDate: DateTime.utc(2026, 8, 3),
          ),
        ],
      );
      expect(result.endingBalance, 432000);
    });

    test('una transferencia no cambia el patrimonio proyectado', () {
      final result = project(
        movements: [
          movement(
            type: MovementType.transfer,
            status: MovementStatus.previsto,
            amount: 100000,
            expectedDate: DateTime.utc(2026, 10, 1),
          ),
        ],
      );
      expect(result.endingBalance, 432000);
    });
  });

  group('reglas recurrentes', () {
    test('una regla mensual activa se repite cada mes', () {
      final result = project(
        rules: [
          rule(
            type: MovementType.expense,
            amount: 5000,
            startDate: DateTime.utc(2026, 9, 20),
          ),
        ],
        months: 3,
      );
      // Septiembre, octubre y noviembre.
      expect(result.totalExpense, 15000);
      expect(result.endingBalance, 432000 - 15000);
    });

    test('una regla inactiva no proyecta nada', () {
      final result = project(
        rules: [
          rule(
            type: MovementType.expense,
            amount: 5000,
            startDate: DateTime.utc(2026, 9, 20),
            isActive: false,
          ),
        ],
      );
      expect(result.endingBalance, 432000);
    });

    test('no cuenta dos veces la ocurrencia ya registrada', () {
      // El gasto de octubre ya existe como movimiento de esa misma regla.
      final result = project(
        movements: [
          movement(
            type: MovementType.expense,
            status: MovementStatus.pendiente,
            amount: 5000,
            expectedDate: DateTime.utc(2026, 10, 20),
            recurringRuleId: 1,
          ),
        ],
        rules: [
          rule(
            type: MovementType.expense,
            amount: 5000,
            startDate: DateTime.utc(2026, 9, 20),
          ),
        ],
        months: 3,
      );
      expect(result.totalExpense, 15000, reason: 'tres meses, no cuatro');
    });

    test('respeta la regla de dia inexistente al proyectar', () {
      final result = project(
        rules: [
          rule(
            type: MovementType.expense,
            amount: 1000,
            startDate: DateTime.utc(2026, 1, 31),
          ),
        ],
        months: 3,
      );
      final dates = result.milestones.map((m) => m.date).toList();
      expect(dates, [
        DateTime.utc(2026, 9, 30),
        DateTime.utc(2026, 10, 31),
        DateTime.utc(2026, 11, 30),
      ]);
    });
  });

  group('resultado', () {
    test('devuelve un punto por mes proyectado', () {
      expect(project(months: 12).points.length, 12);
      expect(project(months: 24).points.length, 24);
    });

    test('el saldo se acumula mes a mes', () {
      final result = project(
        rules: [
          rule(
            type: MovementType.salary,
            amount: 100000,
            startDate: DateTime.utc(2026, 9, 25),
          ),
        ],
        months: 3,
      );
      expect(result.points.map((p) => p.balance), [532000, 632000, 732000]);
    });

    test('la diferencia respecto a hoy es la del horizonte completo', () {
      final result = project(
        rules: [
          rule(
            type: MovementType.salary,
            amount: 100000,
            startDate: DateTime.utc(2026, 9, 25),
          ),
        ],
        months: 3,
      );
      expect(result.delta, 300000);
    });

    test('la capacidad de ahorro es la media mensual que sobra', () {
      final result = project(
        rules: [
          rule(
            id: 1,
            type: MovementType.salary,
            amount: 200000,
            startDate: DateTime.utc(2026, 9, 25),
          ),
          rule(
            id: 2,
            type: MovementType.expense,
            amount: 150000,
            startDate: DateTime.utc(2026, 9, 20),
          ),
        ],
        months: 3,
      );
      expect(result.monthlyCapacity, 50000);
    });

    test('los hitos van ordenados por fecha', () {
      final result = project(
        movements: [
          movement(
            id: 1,
            type: MovementType.expense,
            status: MovementStatus.pendiente,
            amount: 1000,
            expectedDate: DateTime.utc(2026, 11, 1),
            concept: 'Tarde',
          ),
          movement(
            id: 2,
            type: MovementType.expense,
            status: MovementStatus.pendiente,
            amount: 1000,
            expectedDate: DateTime.utc(2026, 9, 20),
            concept: 'Pronto',
          ),
        ],
      );
      expect(result.milestones.map((m) => m.concept), ['Pronto', 'Tarde']);
    });

    test('distingue lo comprometido de lo que solo es repeticion esperada', () {
      final result = project(
        movements: [
          movement(
            type: MovementType.expense,
            status: MovementStatus.pendiente,
            amount: 1000,
            expectedDate: DateTime.utc(2026, 9, 20),
          ),
        ],
        rules: [
          rule(
            id: 2,
            type: MovementType.expense,
            amount: 2000,
            startDate: DateTime.utc(2026, 9, 25),
          ),
        ],
      );
      expect(result.milestones.where((m) => m.fromRule).length, 3);
      expect(result.milestones.where((m) => !m.fromRule).length, 1);
    });
  });
}
