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

  group('copias de versiones anteriores', () {
    /// Copia tal como la exportaba el APK de esquema v3: `savings_goals` sin
    /// `start_month`, porque esa columna todavia no existia.
    String copiaV3() => jsonEncode({
      'format': 'economy_tracker_backup',
      'formatVersion': 1,
      'schemaVersion': 3,
      'exportedAt': '2026-09-18T10:00:00.000Z',
      'data': {
        'accounts': [
          {
            'id': 1,
            'created_at': 1758000000,
            'updated_at': 1758000000,
            'name': 'Cuenta principal',
            'type': 'bank',
            'currency': 'EUR',
            'initial_balance': 432000,
            'is_archived': 0,
          },
        ],
        'categories': <Object?>[],
        'clients': <Object?>[],
        'projects': <Object?>[],
        'salary_sources': <Object?>[],
        'savings_goals': [
          {
            'id': 1,
            // Creado en julio de 2026: 1782864000 son las 00:00 UTC del dia 1.
            'created_at': 1782864000,
            'updated_at': 1782864000,
            'name': 'Ahorro del mes',
            'kind': 'monthly',
            'target_amount': 20000,
            'current_amount': null,
            'monthly_contribution': null,
            'currency': 'EUR',
            'target_date': null,
            'is_archived': 0,
          },
          {
            'id': 2,
            'created_at': 1782864000,
            'updated_at': 1782864000,
            'name': 'Fondo de emergencia',
            'kind': 'amount',
            'target_amount': 600000,
            'current_amount': 325000,
            'monthly_contribution': 50000,
            'currency': 'EUR',
            'target_date': null,
            'is_archived': 0,
          },
        ],
        'recurring_rules': <Object?>[],
        'transactions': <Object?>[],
      },
    });

    test('una copia v3 se restaura tal cual en la aplicacion v4', () async {
      await backup.restore(copiaV3());

      final accounts = await db.select(db.accounts).get();
      expect(accounts.single.name, 'Cuenta principal');
      expect(accounts.single.initialBalance, 432000);

      final goals = await db.select(db.savingsGoals).get();
      expect(goals, hasLength(2));
    });

    test('la vista previa no falla con una copia mas antigua', () {
      final preview = backup.preview(copiaV3());

      expect(preview.schemaVersion, 3);
      expect(preview.counts['savings_goals'], 2);
      expect(preview.totalRows, 3);
    });

    test('los objetivos mensuales recuperan su mes de inicio', () async {
      await backup.restore(copiaV3());

      final mensual = await (db.select(
        db.savingsGoals,
      )..where((g) => g.kind.equalsValue(SavingsGoalKind.monthly))).getSingle();

      // Sin esto, la reserva de ahorro contaria un solo mes en vez de
      // acumular desde julio: la cifra de Inicio saldria mal y en silencio.
      // Es lo mismo que hace la migracion v3 -> v4 sobre una base en disco.
      expect(mensual.startMonth, DateTime.utc(2026, 7));
    });

    test('un objetivo por importe no gana mes de inicio', () async {
      await backup.restore(copiaV3());

      final porImporte = await (db.select(
        db.savingsGoals,
      )..where((g) => g.kind.equalsValue(SavingsGoalKind.amount))).getSingle();

      // No acumula: un mes de inicio ahi no significaria nada.
      expect(porImporte.startMonth, isNull);
    });

    test('una copia mas nueva que la aplicacion se rechaza', () {
      final futura = jsonEncode({
        'format': 'economy_tracker_backup',
        'formatVersion': 1,
        'schemaVersion': 99,
        'exportedAt': '2027-01-01T00:00:00.000Z',
        'data': {'accounts': <Object?>[]},
      });

      expect(() => backup.preview(futura), throwsA(isA<BackupError>()));
    });
  });

  group('acentos y codificacion', () {
    test('un archivo UTF-8 conserva los acentos', () {
      const texto = '{"concepto": "Suscripción", "cliente": "Futón Espai"}';
      final bytes = utf8.encode(texto);

      expect(BackupService.decodeBytes(bytes), texto);
    });

    test('leer los bytes como caracteres es lo que rompia los acentos', () {
      // El fallo que reporto Andy: «Suscripción» llegaba como «SuscripciÃ³n».
      // Se deja escrito para que quede claro que no es una suposicion.
      final bytes = utf8.encode('Suscripción');

      expect(String.fromCharCodes(bytes), 'SuscripciÃ³n');
      expect(BackupService.decodeBytes(bytes), 'Suscripción');
    });

    test('se ignora el BOM que anaden algunos editores', () {
      const texto = '{"a": 1}';
      final bytes = [0xEF, 0xBB, 0xBF, ...utf8.encode(texto)];

      expect(BackupService.decodeBytes(bytes), texto);
    });

    test('un archivo que no es UTF-8 lo dice en vez de meter basura', () {
      // 0xFF no es una secuencia UTF-8 valida en ninguna posicion.
      expect(
        () => BackupService.decodeBytes([0x7B, 0xFF, 0x7D]),
        throwsA(
          isA<BackupError>().having(
            (e) => e.message,
            'mensaje',
            contains('UTF-8'),
          ),
        ),
      );
    });

    test('una copia real con acentos se restaura intacta', () async {
      await db
          .into(db.clients)
          .insert(ClientsCompanion.insert(name: 'Futón Espai'));
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              name: 'Suscripción',
              kind: CategoryKind.expense,
            ),
          );

      // Se exporta, se pasa por bytes como hace el selector de archivos, y se
      // vuelve a entrar: es el viaje completo que hace el archivo de verdad.
      final exported = await backup.export();
      final bytes = utf8.encode(exported);
      await backup.restore(BackupService.decodeBytes(bytes));

      final clients = await db.select(db.clients).get();
      final categories = await db.select(db.categories).get();

      expect(clients.single.name, 'Futón Espai');
      expect(categories.map((c) => c.name), contains('Suscripción'));
    });
  });
}
