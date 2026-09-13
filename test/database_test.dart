import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// Comprueba que el esquema declarado defiende de verdad la integridad
/// financiera: no basta con que las tablas existan.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
  });

  tearDown(() async => db.close());

  Future<int> insertAccount({String currency = 'EUR', int initialBalance = 0}) {
    return db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Cuenta',
            type: AccountType.bank,
            currency: currency,
            initialBalance: Value(initialBalance),
          ),
        );
  }

  Future<List<String>> tableNames() async {
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    return rows.map((r) => r.read<String>('name')).toList()..sort();
  }

  test('crea las ocho tablas del modelo financiero', () async {
    expect(await tableNames(), <String>[
      'accounts',
      'categories',
      'clients',
      'projects',
      'recurring_rules',
      'salary_sources',
      'savings_goals',
      'transactions',
    ]);
  });

  test('la version de esquema es 1', () {
    expect(db.schemaVersion, 1);
  });

  test('rechaza una moneda que no sean tres mayusculas', () async {
    await expectLater(
      insertAccount(currency: 'eur'),
      throwsA(isA<Exception>()),
    );
    await expectLater(insertAccount(currency: 'EU'), throwsA(isA<Exception>()));
  });

  test('admite saldo inicial negativo', () async {
    final id = await insertAccount(initialBalance: -1250);
    final account = await (db.select(
      db.accounts,
    )..where((a) => a.id.equals(id))).getSingle();
    expect(account.initialBalance, -1250);
  });

  test('rechaza un importe de movimiento que no sea positivo', () async {
    final account = await insertAccount();
    await expectLater(
      db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: MovementType.expense,
              status: MovementStatus.previsto,
              concept: 'Importe cero',
              amount: 0,
              currency: 'EUR',
              accountId: account,
              expectedDate: DateTime.utc(2026, 9, 1),
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('un gasto pagado exige fecha real', () async {
    final account = await insertAccount();
    await expectLater(
      db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: MovementType.expense,
              status: MovementStatus.pagado,
              concept: 'Sin fecha real',
              amount: 1000,
              currency: 'EUR',
              accountId: account,
              expectedDate: DateTime.utc(2026, 9, 1),
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('un estado no realizado no puede llevar fecha real', () async {
    final account = await insertAccount();
    await expectLater(
      db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: MovementType.expense,
              status: MovementStatus.pendiente,
              concept: 'Pendiente con fecha real',
              amount: 1000,
              currency: 'EUR',
              accountId: account,
              expectedDate: DateTime.utc(2026, 9, 1),
              actualDate: Value(DateTime.utc(2026, 9, 2)),
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('un ingreso no puede quedar pagado, solo cobrado', () async {
    final account = await insertAccount();
    await expectLater(
      db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: MovementType.otherIncome,
              status: MovementStatus.pagado,
              concept: 'Ingreso pagado',
              amount: 1000,
              currency: 'EUR',
              accountId: account,
              expectedDate: DateTime.utc(2026, 9, 1),
              actualDate: Value(DateTime.utc(2026, 9, 1)),
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('un gasto no puede quedar cobrado', () async {
    final account = await insertAccount();
    await expectLater(
      db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: MovementType.expense,
              status: MovementStatus.cobrado,
              concept: 'Gasto cobrado',
              amount: 1000,
              currency: 'EUR',
              accountId: account,
              expectedDate: DateTime.utc(2026, 9, 1),
              actualDate: Value(DateTime.utc(2026, 9, 1)),
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'un movimiento no puede usar una moneda distinta de su cuenta',
    () async {
      final account = await insertAccount(currency: 'EUR');
      await expectLater(
        db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                type: MovementType.expense,
                status: MovementStatus.previsto,
                concept: 'Gasto en dolares sobre cuenta en euros',
                amount: 1000,
                currency: 'USD',
                accountId: account,
                expectedDate: DateTime.utc(2026, 9, 1),
              ),
            ),
        throwsA(isA<Exception>()),
      );
    },
  );

  test('solo una transferencia admite cuenta destino', () async {
    final origin = await insertAccount();
    final destination = await insertAccount();

    await expectLater(
      db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: MovementType.expense,
              status: MovementStatus.previsto,
              concept: 'Gasto con destino',
              amount: 1000,
              currency: 'EUR',
              accountId: origin,
              destinationAccountId: Value(destination),
              expectedDate: DateTime.utc(2026, 9, 1),
            ),
          ),
      throwsA(isA<Exception>()),
    );

    await expectLater(
      db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: MovementType.transfer,
              status: MovementStatus.previsto,
              concept: 'Transferencia sin destino',
              amount: 1000,
              currency: 'EUR',
              accountId: origin,
              expectedDate: DateTime.utc(2026, 9, 1),
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('una transferencia no puede tener el mismo origen y destino', () async {
    final account = await insertAccount();
    await expectLater(
      db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: MovementType.transfer,
              status: MovementStatus.previsto,
              concept: 'Transferencia a si misma',
              amount: 1000,
              currency: 'EUR',
              accountId: account,
              destinationAccountId: Value(account),
              expectedDate: DateTime.utc(2026, 9, 1),
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test('una categoria no puede ser su propio padre', () async {
    final id = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Vivienda',
            kind: CategoryKind.expense,
          ),
        );
    await expectLater(
      (db.update(db.categories)..where((c) => c.id.equals(id))).write(
        CategoriesCompanion(parentId: Value(id)),
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('una fecha financiera se recupera como el mismo dia civil', () async {
    final account = await insertAccount();
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: MovementType.expense,
            status: MovementStatus.previsto,
            concept: 'Gasto de fin de ano',
            amount: 1000,
            currency: 'EUR',
            accountId: account,
            expectedDate: DateTime.utc(2026, 12, 31),
          ),
        );

    final row = await db.select(db.transactions).getSingle();
    // Guardada como fecha civil: el dia no depende del huso del dispositivo.
    expect(row.expectedDate, DateTime.utc(2026, 12, 31));
    expect(row.expectedDate.isUtc, isTrue);

    final stored = await db
        .customSelect('SELECT expected_date FROM transactions')
        .getSingle();
    expect(stored.read<String>('expected_date'), '2026-12-31');
  });

  group('integridad referencial', () {
    // Drift descarta las FOREIGN KEY generadas por references() cuando la
    // tabla declara customConstraints, asi que conviene comprobar que las
    // relaciones declaradas a mano existen de verdad.
    test('las claves foraneas estan activas en la conexion', () async {
      final row = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(row.read<int>('foreign_keys'), 1);
    });

    test('un proyecto no puede apuntar a un cliente inexistente', () async {
      await expectLater(
        db
            .into(db.projects)
            .insert(
              ProjectsCompanion.insert(
                clientId: 999,
                name: 'Proyecto huerfano',
                currency: 'EUR',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('no se borra un cliente que tiene proyectos', () async {
      final clientId = await db
          .into(db.clients)
          .insert(ClientsCompanion.insert(name: 'Cliente'));
      await db
          .into(db.projects)
          .insert(
            ProjectsCompanion.insert(
              clientId: clientId,
              name: 'Proyecto',
              currency: 'EUR',
            ),
          );

      await expectLater(
        (db.delete(db.clients)..where((c) => c.id.equals(clientId))).go(),
        throwsA(isA<Exception>()),
      );
    });

    test('no se borra una cuenta con movimientos', () async {
      final account = await insertAccount();
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              type: MovementType.expense,
              status: MovementStatus.previsto,
              concept: 'Gasto',
              amount: 1000,
              currency: 'EUR',
              accountId: account,
              expectedDate: DateTime.utc(2026, 9, 1),
            ),
          );

      await expectLater(
        (db.delete(db.accounts)..where((a) => a.id.equals(account))).go(),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'un movimiento no puede apuntar a una categoria inexistente',
      () async {
        final account = await insertAccount();
        await expectLater(
          db
              .into(db.transactions)
              .insert(
                TransactionsCompanion.insert(
                  type: MovementType.expense,
                  status: MovementStatus.previsto,
                  concept: 'Gasto',
                  amount: 1000,
                  currency: 'EUR',
                  accountId: account,
                  categoryId: const Value(999),
                  expectedDate: DateTime.utc(2026, 9, 1),
                ),
              ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('el cliente del cobro debe ser el del proyecto', () async {
      final account = await insertAccount();
      final clientA = await db
          .into(db.clients)
          .insert(ClientsCompanion.insert(name: 'Cliente A'));
      final clientB = await db
          .into(db.clients)
          .insert(ClientsCompanion.insert(name: 'Cliente B'));
      final project = await db
          .into(db.projects)
          .insert(
            ProjectsCompanion.insert(
              clientId: clientA,
              name: 'Proyecto de A',
              currency: 'EUR',
            ),
          );

      await expectLater(
        db
            .into(db.transactions)
            .insert(
              TransactionsCompanion.insert(
                type: MovementType.projectIncome,
                status: MovementStatus.previsto,
                concept: 'Cobro cruzado',
                amount: 1000,
                currency: 'EUR',
                accountId: account,
                projectId: Value(project),
                clientId: Value(clientB),
                expectedDate: DateTime.utc(2026, 9, 1),
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });
  });

  test('un objetivo de ahorro exige importe objetivo positivo', () async {
    await expectLater(
      db
          .into(db.savingsGoals)
          .insert(
            SavingsGoalsCompanion.insert(
              name: 'Fondo',
              targetAmount: 0,
              currency: 'EUR',
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });
}
