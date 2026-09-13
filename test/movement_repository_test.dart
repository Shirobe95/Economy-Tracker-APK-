import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/database_provider.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/account_repository.dart';
import 'package:economy_tracker/data/movement_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MovementRepository movements;
  late AccountRepository accounts;

  setUp(() {
    db = openInMemoryDatabase();
    movements = MovementRepository(db);
    accounts = AccountRepository(db);
  });

  tearDown(() async => db.close());

  Future<int> account({
    String name = 'Cuenta principal',
    int initialBalance = 0,
    String currency = 'EUR',
  }) => accounts.createAccount(
    name: name,
    type: AccountType.bank,
    initialBalance: initialBalance,
    currency: currency,
  );

  Future<int> category({
    String name = 'Vivienda',
    CategoryKind kind = CategoryKind.expense,
  }) => accounts.createCategory(name: name, kind: kind);

  MovementDraft expense({
    int? id,
    required int accountId,
    int amount = 85000,
    MovementStatus status = MovementStatus.pendiente,
    DateTime? actualDate,
    int? categoryId,
    String concept = 'Alquiler',
  }) => MovementDraft(
    id: id,
    type: MovementType.expense,
    status: status,
    concept: concept,
    amount: amount,
    accountId: accountId,
    categoryId: categoryId,
    expectedDate: DateTime.utc(2026, 9, 3),
    actualDate: actualDate,
  );

  Future<Account> reloadAccount(int id) =>
      (db.select(db.accounts)..where((a) => a.id.equals(id))).getSingle();

  Future<int?> balanceOf(int id) async {
    final row = await reloadAccount(id);
    final rows = await db.select(db.transactions).get();
    return AccountRepository.balanceOf(row, rows);
  }

  group('validacion funcional', () {
    test('rechaza un concepto vacio', () async {
      final id = await account();
      await expectLater(
        movements.save(expense(accountId: id, concept: '   ')),
        throwsA(isA<MovementValidationError>()),
      );
    });

    test('rechaza un importe no positivo', () async {
      final id = await account();
      await expectLater(
        movements.save(expense(accountId: id, amount: 0)),
        throwsA(isA<MovementValidationError>()),
      );
    });

    test('rechaza una cuenta inexistente', () async {
      await expectLater(
        movements.save(expense(accountId: 999)),
        throwsA(isA<MovementValidationError>()),
      );
    });

    test('rechaza una cuenta archivada', () async {
      final id = await account();
      await accounts.setAccountArchived(id, true);
      await expectLater(
        movements.save(expense(accountId: id)),
        throwsA(isA<MovementValidationError>()),
      );
    });

    test('rechaza una moneda distinta de la de la cuenta', () async {
      final id = await account(currency: 'USD');
      await expectLater(
        movements.save(expense(accountId: id)),
        throwsA(isA<MovementValidationError>()),
      );
    });

    test('rechaza una categoria que no admite gastos', () async {
      final id = await account();
      final salarios = await category(
        name: 'Salarios',
        kind: CategoryKind.income,
      );
      await expectLater(
        movements.save(expense(accountId: id, categoryId: salarios)),
        throwsA(isA<MovementValidationError>()),
      );
    });

    test('acepta una categoria mixta', () async {
      final id = await account();
      final mixta = await category(name: 'Mixta', kind: CategoryKind.both);
      await expectLater(
        movements.save(expense(accountId: id, categoryId: mixta)),
        completes,
      );
    });

    test('un gasto no puede quedar cobrado', () async {
      final id = await account();
      await expectLater(
        movements.save(
          expense(
            accountId: id,
            status: MovementStatus.cobrado,
            actualDate: DateTime.utc(2026, 9, 3),
          ),
        ),
        throwsA(isA<MovementValidationError>()),
      );
    });

    test('un gasto pagado exige fecha real', () async {
      final id = await account();
      await expectLater(
        movements.save(expense(accountId: id, status: MovementStatus.pagado)),
        throwsA(isA<MovementValidationError>()),
      );
    });

    test('un gasto pendiente no puede llevar fecha real', () async {
      final id = await account();
      await expectLater(
        movements.save(
          expense(accountId: id, actualDate: DateTime.utc(2026, 9, 3)),
        ),
        throwsA(isA<MovementValidationError>()),
      );
    });

    test('los estados ofrecidos dependen del tipo', () {
      expect(
        MovementRepository.statusesFor(MovementType.expense),
        isNot(contains(MovementStatus.cobrado)),
      );
      expect(
        MovementRepository.statusesFor(MovementType.projectIncome),
        isNot(contains(MovementStatus.pagado)),
      );
      expect(
        MovementRepository.statusesFor(MovementType.projectIncome),
        contains(MovementStatus.cobrado),
      );
    });
  });

  group('transferencias', () {
    test('exige cuenta de destino distinta', () async {
      final origin = await account(name: 'Origen');
      final draft = MovementDraft(
        type: MovementType.transfer,
        status: MovementStatus.previsto,
        concept: 'Traspaso',
        amount: 10000,
        accountId: origin,
        destinationAccountId: origin,
        expectedDate: DateTime.utc(2026, 9, 1),
      );
      await expectLater(
        movements.save(draft),
        throwsA(isA<MovementValidationError>()),
      );
    });

    test('rechaza transferir entre monedas distintas', () async {
      final origin = await account(name: 'Euros');
      final destination = await account(name: 'Dolares', currency: 'USD');
      final draft = MovementDraft(
        type: MovementType.transfer,
        status: MovementStatus.previsto,
        concept: 'Traspaso',
        amount: 10000,
        accountId: origin,
        destinationAccountId: destination,
        expectedDate: DateTime.utc(2026, 9, 1),
      );
      await expectLater(
        movements.save(draft),
        throwsA(isA<MovementValidationError>()),
      );
    });

    test('un gasto no admite cuenta de destino', () async {
      final origin = await account(name: 'Origen');
      final destination = await account(name: 'Destino');
      final draft = MovementDraft(
        type: MovementType.expense,
        status: MovementStatus.previsto,
        concept: 'Gasto con destino',
        amount: 10000,
        accountId: origin,
        destinationAccountId: destination,
        expectedDate: DateTime.utc(2026, 9, 1),
      );
      await expectLater(
        movements.save(draft),
        throwsA(isA<MovementValidationError>()),
      );
    });
  });

  group('saldo real', () {
    test('parte del saldo inicial, incluso negativo', () async {
      final id = await account(initialBalance: -25000);
      expect(await balanceOf(id), -25000);
    });

    test('un gasto pendiente no mueve el saldo', () async {
      final id = await account(initialBalance: 100000);
      await movements.save(expense(accountId: id));
      expect(await balanceOf(id), 100000);
    });

    test('un gasto pagado resta', () async {
      final id = await account(initialBalance: 100000);
      await movements.save(
        expense(
          accountId: id,
          status: MovementStatus.pagado,
          actualDate: DateTime.utc(2026, 9, 3),
        ),
      );
      expect(await balanceOf(id), 15000);
    });

    test('un ingreso cobrado suma', () async {
      final id = await account(initialBalance: 100000);
      await movements.save(
        MovementDraft(
          type: MovementType.otherIncome,
          status: MovementStatus.cobrado,
          concept: 'Venta',
          amount: 35000,
          accountId: id,
          expectedDate: DateTime.utc(2026, 9, 5),
          actualDate: DateTime.utc(2026, 9, 5),
        ),
      );
      expect(await balanceOf(id), 135000);
    });

    test('una transferencia pagada suma cero entre las dos cuentas', () async {
      final origin = await account(name: 'Origen', initialBalance: 100000);
      final destination = await account(name: 'Destino');

      await movements.save(
        MovementDraft(
          type: MovementType.transfer,
          status: MovementStatus.pagado,
          concept: 'Traspaso a ahorro',
          amount: 40000,
          accountId: origin,
          destinationAccountId: destination,
          expectedDate: DateTime.utc(2026, 9, 10),
          actualDate: DateTime.utc(2026, 9, 10),
        ),
      );

      expect(await balanceOf(origin), 60000);
      expect(await balanceOf(destination), 40000);
    });

    test(
      'un movimiento borrado sale del saldo aunque estuviera pagado',
      () async {
        final id = await account(initialBalance: 100000);
        final movementId = await movements.save(
          expense(
            accountId: id,
            status: MovementStatus.pagado,
            actualDate: DateTime.utc(2026, 9, 3),
          ),
        );
        expect(await balanceOf(id), 15000);

        await movements.delete(movementId);
        expect(await balanceOf(id), 100000);
      },
    );

    test('editar un gasto pagado recalcula desde las filas actuales', () async {
      final id = await account(initialBalance: 100000);
      final movementId = await movements.save(
        expense(
          accountId: id,
          status: MovementStatus.pagado,
          actualDate: DateTime.utc(2026, 9, 3),
        ),
      );

      await movements.save(
        expense(
          id: movementId,
          accountId: id,
          amount: 20000,
          status: MovementStatus.pagado,
          actualDate: DateTime.utc(2026, 9, 3),
        ),
      );

      expect(await balanceOf(id), 80000);
    });
  });

  group('marcar como realizado', () {
    test('un gasto pasa a pagado con su fecha real', () async {
      final id = await account(initialBalance: 100000);
      final movementId = await movements.save(expense(accountId: id));

      await movements.markRealised(movementId, DateTime.utc(2026, 9, 4));

      final row = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(movementId))).getSingle();
      expect(row.status, MovementStatus.pagado);
      expect(row.actualDate, DateTime.utc(2026, 9, 4));
      expect(await balanceOf(id), 15000);
    });

    test('un ingreso pasa a cobrado, no a pagado', () async {
      final id = await account();
      final movementId = await movements.save(
        MovementDraft(
          type: MovementType.salary,
          status: MovementStatus.pendiente,
          concept: 'Nomina',
          amount: 180000,
          accountId: id,
          expectedDate: DateTime.utc(2026, 9, 1),
        ),
      );

      await movements.markRealised(movementId, DateTime.utc(2026, 9, 2));

      final row = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(movementId))).getSingle();
      expect(row.status, MovementStatus.cobrado);
    });

    test('marcar dos veces no cambia la primera fecha real', () async {
      final id = await account(initialBalance: 100000);
      final movementId = await movements.save(expense(accountId: id));

      await movements.markRealised(movementId, DateTime.utc(2026, 9, 4));
      await movements.markRealised(movementId, DateTime.utc(2026, 9, 20));

      final row = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(movementId))).getSingle();
      expect(row.actualDate, DateTime.utc(2026, 9, 4));
      expect(await balanceOf(id), 15000);
    });
  });

  group('consultas', () {
    test('el listado mensual usa la fecha prevista', () async {
      final id = await account();
      await movements.save(expense(accountId: id));
      await movements.save(
        MovementDraft(
          type: MovementType.expense,
          status: MovementStatus.pendiente,
          concept: 'Gasto de octubre',
          amount: 1000,
          accountId: id,
          expectedDate: DateTime.utc(2026, 10, 2),
        ),
      );

      final september = await movements
          .watchByMonth(month: DateTime.utc(2026, 9, 15))
          .first;
      expect(september.map((t) => t.concept), ['Alquiler']);
    });

    test('un movimiento borrado desaparece del listado', () async {
      final id = await account();
      final movementId = await movements.save(expense(accountId: id));

      await movements.delete(movementId);

      final rows = await movements
          .watchByMonth(month: DateTime.utc(2026, 9, 1))
          .first;
      expect(rows, isEmpty);
    });

    test('se puede filtrar por tipo', () async {
      final id = await account();
      await movements.save(expense(accountId: id));
      await movements.save(
        MovementDraft(
          type: MovementType.salary,
          status: MovementStatus.pendiente,
          concept: 'Nomina',
          amount: 180000,
          accountId: id,
          expectedDate: DateTime.utc(2026, 9, 1),
        ),
      );

      final salaries = await movements
          .watchByMonth(
            month: DateTime.utc(2026, 9, 1),
            types: {MovementType.salary},
          )
          .first;
      expect(salaries.map((t) => t.concept), ['Nomina']);
    });
  });
}
