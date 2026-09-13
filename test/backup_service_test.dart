import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/database_provider.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sin backend ni sincronizacion, la copia es lo unico que separa los datos
/// de un cambio de movil: conviene probarla en serio.
void main() {
  late AppDatabase db;
  late BackupService backup;

  setUp(() {
    db = openTestDatabase();
    backup = BackupService(db);
  });

  tearDown(() async => db.close());

  Future<int> seed() async {
    final accountId = await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Cuenta principal',
            type: AccountType.bank,
            currency: 'EUR',
            initialBalance: const Value(432000),
          ),
        );
    final parentId = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(name: 'Hogar', kind: CategoryKind.expense),
        );
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Vivienda',
            kind: CategoryKind.expense,
            parentId: Value(parentId),
          ),
        );
    final clientId = await db
        .into(db.clients)
        .insert(ClientsCompanion.insert(name: 'Futon Espai'));
    final projectId = await db
        .into(db.projects)
        .insert(
          ProjectsCompanion.insert(
            clientId: clientId,
            name: 'Modulo lectura',
            currency: 'EUR',
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: MovementType.projectIncome,
            status: MovementStatus.cobrado,
            concept: 'Cobro de septiembre',
            amount: 35000,
            currency: 'EUR',
            accountId: accountId,
            projectId: Value(projectId),
            clientId: Value(clientId),
            expectedDate: DateTime.utc(2026, 9, 10),
            actualDate: Value(DateTime.utc(2026, 9, 12)),
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: MovementType.expense,
            status: MovementStatus.pagado,
            concept: 'Alquiler',
            amount: 85000,
            currency: 'EUR',
            accountId: accountId,
            expectedDate: DateTime.utc(2026, 9, 3),
            actualDate: Value(DateTime.utc(2026, 9, 3)),
          ),
        );
    return accountId;
  }

  group('exportacion', () {
    test('incluye las ocho tablas y la version de datos', () async {
      await seed();
      final decoded = jsonDecode(await backup.export()) as Map<String, dynamic>;

      expect(decoded['format'], 'economy_tracker_backup');
      expect(decoded['schemaVersion'], db.schemaVersion);
      final data = decoded['data'] as Map<String, dynamic>;
      expect(data.keys.toSet(), BackupService.tableOrder.toSet());
    });

    test('una base vacia produce una copia valida', () async {
      final content = await backup.export();
      expect(backup.preview(content).totalRows, 0);
    });

    test('es legible a mano', () async {
      await seed();
      final content = await backup.export();
      // El formato es JSON con sangrado a proposito: si la aplicacion deja
      // de arrancar, los datos se siguen pudiendo leer.
      expect(content, contains('Cobro de septiembre'));
      expect(content, contains('\n  '));
    });
  });

  group('vista previa', () {
    test('cuenta las filas de cada tabla sin tocar la base', () async {
      await seed();
      final content = await backup.export();

      final preview = backup.preview(content);
      expect(preview.counts['accounts'], 1);
      expect(preview.counts['categories'], 2);
      expect(preview.counts['transactions'], 2);
      expect(preview.totalRows, 7);
      // La base sigue intacta.
      expect((await db.select(db.transactions).get()).length, 2);
    });

    test('rechaza un archivo que no es una copia', () async {
      expect(
        () => backup.preview('{"hola": true}'),
        throwsA(isA<BackupError>()),
      );
      expect(() => backup.preview('no soy json'), throwsA(isA<BackupError>()));
    });

    test('rechaza una copia de una version mas nueva', () async {
      final content = jsonEncode({
        'format': 'economy_tracker_backup',
        'schemaVersion': db.schemaVersion + 1,
        'data': <String, dynamic>{},
      });
      expect(() => backup.preview(content), throwsA(isA<BackupError>()));
    });
  });

  group('restauracion', () {
    test('deja la base igual que estaba al exportar', () async {
      await seed();
      final content = await backup.export();
      final before = await db.select(db.transactions).get();

      await backup.restore(content);

      final after = await db.select(db.transactions).get();
      expect(after.length, before.length);
      expect(after.map((t) => t.concept), before.map((t) => t.concept));
      expect(after.first.amount, before.first.amount);
      expect(after.first.expectedDate, before.first.expectedDate);
      expect(after.first.actualDate, before.first.actualDate);
    });

    test('sustituye lo que hubiera, no lo acumula', () async {
      await seed();
      final content = await backup.export();

      await backup.restore(content);
      await backup.restore(content);

      expect((await db.select(db.transactions).get()).length, 2);
      expect((await db.select(db.accounts).get()).length, 1);
    });

    test('restaurar en una base con otros datos los reemplaza', () async {
      await seed();
      final content = await backup.export();

      final otherDb = openTestDatabase();
      addTearDown(otherDb.close);
      await otherDb
          .into(otherDb.accounts)
          .insert(
            AccountsCompanion.insert(
              name: 'Cuenta ajena',
              type: AccountType.cash,
              currency: 'EUR',
            ),
          );

      await BackupService(otherDb).restore(content);

      final accounts = await otherDb.select(otherDb.accounts).get();
      expect(accounts.single.name, 'Cuenta principal');
      expect(accounts.single.initialBalance, 432000);
    });

    test('conserva la jerarquia de categorias', () async {
      await seed();
      final content = await backup.export();

      await backup.restore(content);

      final categories = await db.select(db.categories).get();
      final hija = categories.firstWhere((c) => c.name == 'Vivienda');
      final padre = categories.firstWhere((c) => c.name == 'Hogar');
      expect(hija.parentId, padre.id);
    });

    test('conserva el vinculo entre cobro, proyecto y cliente', () async {
      await seed();
      final content = await backup.export();

      await backup.restore(content);

      final cobro = (await db.select(db.transactions).get()).firstWhere(
        (t) => t.type == MovementType.projectIncome,
      );
      final project = (await db.select(db.projects).get()).single;
      expect(cobro.projectId, project.id);
      expect(cobro.clientId, project.clientId);
    });

    test('una copia corrupta no deja la base a medias', () async {
      await seed();
      final good = jsonDecode(await backup.export()) as Map<String, dynamic>;

      // Un movimiento que apunta a una cuenta inexistente: las claves
      // foraneas deben rechazarlo y deshacer toda la restauracion.
      final data = good['data'] as Map<String, dynamic>;
      (data['transactions'] as List<dynamic>).add({
        'id': 999,
        'type': 'expense',
        'status': 'previsto',
        'concept': 'Huerfano',
        'amount': 100,
        'currency': 'EUR',
        'account_id': 12345,
        'expected_date': '2026-09-01',
        'is_deleted': 0,
        'created_at': 1757000000,
        'updated_at': 1757000000,
      });

      await expectLater(
        backup.restore(jsonEncode(good)),
        throwsA(isA<Exception>()),
      );

      // Los datos originales siguen ahi.
      expect((await db.select(db.transactions).get()).length, 2);
      expect((await db.select(db.accounts).get()).length, 1);
    });

    test('los importes enteros no se convierten en decimales', () async {
      await seed();
      // JSON no distingue entero de decimal: un exportador o un editor
      // externo puede devolver 85000.0 donde habia 85000.
      final decoded = jsonDecode(await backup.export()) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>;
      for (final row in data['transactions'] as List<dynamic>) {
        (row as Map<String, dynamic>)['amount'] = (row['amount'] as int)
            .toDouble();
      }

      await backup.restore(jsonEncode(decoded));

      final amounts =
          (await db.select(db.transactions).get()).map((t) => t.amount).toList()
            ..sort();
      expect(amounts, [35000, 85000]);
    });
  });
}
