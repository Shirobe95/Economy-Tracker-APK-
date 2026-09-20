import 'package:drift/drift.dart' show Value;
import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/database_provider.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/planned_repository.dart';
import 'package:economy_tracker/data/recurring_rule_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo que queda por pagar incluye las repeticiones.
///
/// El fallo que arregla: una regla recurrente no crea filas, asi que un
/// alquiler de 850 al mes no salia en ningun listado de pendientes y
/// «Pendientes» daba una cifra que no se parecia al mes real.
void main() {
  late AppDatabase db;
  late PlannedRepository planned;
  late int accountId;

  setUp(() async {
    db = openTestDatabase();
    planned = PlannedRepository(db);
    accountId = await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Cuenta',
            type: AccountType.bank,
            currency: 'EUR',
          ),
        );
  });

  tearDown(() => db.close());

  Future<int> insertRule({
    String concept = 'Alquiler',
    MovementType type = MovementType.expense,
    int amount = 85000,
    required DateTime startDate,
    bool isActive = true,
  }) {
    return db
        .into(db.recurringRules)
        .insert(
          RecurringRulesCompanion.insert(
            concept: concept,
            type: type,
            accountId: accountId,
            amount: amount,
            currency: 'EUR',
            frequency: RecurrenceFrequency.monthly,
            startDate: startDate,
            isActive: Value(isActive),
          ),
        );
  }

  Future<int> insertMovement({
    String concept = 'Compra',
    MovementType type = MovementType.expense,
    MovementStatus status = MovementStatus.pendiente,
    int amount = 5000,
    required DateTime expectedDate,
    DateTime? actualDate,
  }) {
    return db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: type,
            status: status,
            concept: concept,
            amount: amount,
            currency: 'EUR',
            accountId: accountId,
            expectedDate: expectedDate,
            actualDate: Value(actualDate),
          ),
        );
  }

  final septiembre = PlannedWindow(
    from: DateTime.utc(2026, 9),
    to: DateTime.utc(2026, 10),
  );

  group('repeticiones', () {
    test('una regla mensual aporta su ocurrencia del mes', () async {
      await insertRule(startDate: DateTime.utc(2026, 3, 5));

      final items = await planned.watchPlanned(septiembre).first;

      expect(items, hasLength(1));
      expect(items.single.concept, 'Alquiler');
      expect(items.single.amount, 85000);
      expect(items.single.date, DateTime.utc(2026, 9, 5));
      // No tiene fila propia: sale del calendario de la regla.
      expect(items.single.isProjected, isTrue);
    });

    test('una regla inactiva no aporta nada', () async {
      await insertRule(startDate: DateTime.utc(2026, 3, 5), isActive: false);

      expect(await planned.watchPlanned(septiembre).first, isEmpty);
    });

    test('una ocurrencia ya pagada deja de estar pendiente', () async {
      final ruleId = await insertRule(startDate: DateTime.utc(2026, 3, 5));
      final rule = await (db.select(
        db.recurringRules,
      )..where((r) => r.id.equals(ruleId))).getSingle();

      await RecurringRuleRepository(db).settleOccurrence(
        rule: rule,
        occurrence: DateTime.utc(2026, 9, 5),
        actualDate: DateTime.utc(2026, 9, 3),
      );

      // Ni como repeticion ni como movimiento: esta pagada, y contarla seria
      // pedir dos veces el mismo alquiler.
      expect(await planned.watchPlanned(septiembre).first, isEmpty);
    });

    test('una ocurrencia anotada pero sin pagar cuenta una sola vez', () async {
      final ruleId = await insertRule(startDate: DateTime.utc(2026, 3, 5));
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: MovementType.expense,
              status: MovementStatus.pendiente,
              concept: 'Alquiler',
              amount: 85000,
              currency: 'EUR',
              accountId: accountId,
              recurringRuleId: Value(ruleId),
              expectedDate: DateTime.utc(2026, 9, 5),
            ),
          );

      final items = await planned.watchPlanned(septiembre).first;

      expect(items, hasLength(1));
      // Gana la fila: es la que se puede editar y marcar.
      expect(items.single.isProjected, isFalse);
    });
  });

  group('movimientos anotados', () {
    test('lo pendiente entra, lo pagado no', () async {
      await insertMovement(expectedDate: DateTime.utc(2026, 9, 12));
      await insertMovement(
        concept: 'Internet',
        status: MovementStatus.pagado,
        expectedDate: DateTime.utc(2026, 9, 14),
        actualDate: DateTime.utc(2026, 9, 14),
      );

      final items = await planned.watchPlanned(septiembre).first;

      expect(items.map((i) => i.concept), ['Compra']);
    });

    test('lo cancelado no entra', () async {
      await insertMovement(
        status: MovementStatus.cancelado,
        expectedDate: DateTime.utc(2026, 9, 12),
      );

      expect(await planned.watchPlanned(septiembre).first, isEmpty);
    });

    test('lo borrado no entra', () async {
      final id = await insertMovement(expectedDate: DateTime.utc(2026, 9, 12));
      await (db.update(db.transactions)..where((t) => t.id.equals(id))).write(
        const TransactionsCompanion(isDeleted: Value(true)),
      );

      expect(await planned.watchPlanned(septiembre).first, isEmpty);
    });

    test('los ingresos entran igual que los gastos', () async {
      await insertMovement(
        concept: 'Modulo',
        type: MovementType.projectIncome,
        expectedDate: DateTime.utc(2026, 9, 22),
      );
      await insertMovement(expectedDate: DateTime.utc(2026, 9, 12));

      final items = await planned.watchPlanned(septiembre).first;

      // Inicio tiene que ver las dos direcciones: lo que entra y lo que sale.
      expect(items.map((i) => i.type.isIncome), containsAll([true, false]));
    });
  });

  group('ventana', () {
    test('la de Inicio alcanza el mes pasado, para ver lo vencido', () async {
      final window = PlannedWindow.around(DateTime.utc(2026, 9, 20));
      await insertMovement(
        concept: 'Recibo atrasado',
        expectedDate: DateTime.utc(2026, 8, 25),
      );

      final items = await planned.watchPlanned(window).first;

      expect(items.single.concept, 'Recibo atrasado');
      expect(items.single.isOverdue(DateTime.utc(2026, 9, 20)), isTrue);
    });

    test('lo de dentro de un ano se queda fuera', () async {
      final window = PlannedWindow.around(DateTime.utc(2026, 9, 20));
      await insertMovement(expectedDate: DateTime.utc(2027, 9, 12));

      expect(await planned.watchPlanned(window).first, isEmpty);
    });

    test('todo sale ordenado por fecha', () async {
      await insertRule(startDate: DateTime.utc(2026, 3, 25));
      await insertMovement(expectedDate: DateTime.utc(2026, 9, 12));
      await insertMovement(
        concept: 'Gimnasio',
        expectedDate: DateTime.utc(2026, 9, 2),
      );

      final items = await planned.watchPlanned(septiembre).first;

      expect(items.map((i) => i.date.day), [2, 12, 25]);
    });
  });

  test('el stream reacciona a una regla nueva', () async {
    final emissions = <int>[];
    final subscription = planned
        .watchPlanned(septiembre)
        .listen((items) => emissions.add(items.length));

    await pumpEventQueue();
    expect(emissions.last, 0);

    await insertRule(startDate: DateTime.utc(2026, 9, 5));
    await pumpEventQueue();

    // Sin esto, crear una regla no refrescaria lo que queda por pagar.
    expect(emissions.last, 1);
    await subscription.cancel();
  });
}
