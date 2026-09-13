import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:economy_tracker/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migrar no puede costarle los datos a nadie.
///
/// El test levanta una base con el esquema v1 escrito a mano, mete datos, y
/// la abre con la aplicacion actual para que corra la migracion de verdad.
void main() {
  /// Esquema v1 de `salary_sources`, tal como se instalo antes de anadir el
  /// dia de cobro.
  const salarySourcesV1 = '''
    CREATE TABLE "salary_sources" (
      "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      "created_at" INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
      "updated_at" INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
      "name" TEXT NOT NULL,
      "expected_amount" INTEGER NULL,
      "currency" TEXT NOT NULL,
      "frequency" TEXT NULL,
      "is_active" INTEGER NOT NULL DEFAULT 1 CHECK ("is_active" IN (0, 1)),
      CHECK (currency GLOB '[A-Z][A-Z][A-Z]'),
      CHECK (expected_amount IS NULL OR expected_amount >= 0),
      CHECK (frequency IS NULL OR frequency IN ('daily', 'weekly', 'monthly', 'yearly'))
    )
  ''';

  late Directory workspace;

  setUp(() => workspace = Directory.systemTemp.createTempSync('econ-mig'));
  tearDown(() => workspace.deleteSync(recursive: true));

  /// Deja en disco una base con el esquema v1 y una nomina dentro, y la
  /// vuelve a abrir con la aplicacion actual para que migre de verdad.
  ///
  /// Tiene que ser un archivo: una base en memoria desaparece al cerrarla, y
  /// entonces no habria nada que migrar.
  Future<AppDatabase> migratedFromV1() async {
    final file = File('${workspace.path}/economy_tracker.sqlite');

    final setup = AppDatabase(DatabaseConnection(NativeDatabase(file)));
    await setup.customStatement('SELECT 1');
    await setup.customStatement('DROP TABLE salary_sources');
    await setup.customStatement(salarySourcesV1);
    await setup.customStatement(
      "INSERT INTO salary_sources (name, expected_amount, currency, frequency) "
      "VALUES ('Nomina', 170000, 'EUR', 'monthly')",
    );
    await setup.customStatement('PRAGMA user_version = 1');
    await setup.close();

    return AppDatabase(DatabaseConnection(NativeDatabase(file)));
  }

  test('la version de esquema es 2', () {
    final db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    expect(db.schemaVersion, 2);
  });

  test('migrar de v1 conserva las nominas ya guardadas', () async {
    final db = await migratedFromV1();
    addTearDown(db.close);

    final sources = await db.select(db.salarySources).get();
    expect(sources.single.name, 'Nomina');
    expect(sources.single.expectedAmount, 170000);
    expect(sources.single.isActive, isTrue);
    // La columna nueva existe y empieza vacia: nadie ha dicho que dia cobra.
    expect(sources.single.paymentDay, isNull);
  });

  test('la tabla migrada acepta un dia de cobro valido', () async {
    final db = await migratedFromV1();
    addTearDown(db.close);

    await (db.update(db.salarySources))
        .write(const SalarySourcesCompanion(paymentDay: Value(25)));

    final sources = await db.select(db.salarySources).get();
    expect(sources.single.paymentDay, 25);
  });

  test('la tabla migrada conserva las restricciones del esquema', () async {
    final db = await migratedFromV1();
    addTearDown(db.close);

    // Si la migracion hubiera usado ADD COLUMN, este CHECK no existiria en
    // una base migrada y si en una recien instalada.
    await expectLater(
      db
          .update(db.salarySources)
          .write(const SalarySourcesCompanion(paymentDay: Value(45))),
      throwsA(isA<Exception>()),
    );
  });

  test('una version futura falla en vez de abrir a medias', () async {
    final file = File('${workspace.path}/futura.sqlite');
    final setup = AppDatabase(DatabaseConnection(NativeDatabase(file)));
    await setup.customStatement('SELECT 1');
    await setup.customStatement('PRAGMA user_version = 99');
    await setup.close();

    final db = AppDatabase(DatabaseConnection(NativeDatabase(file)));
    addTearDown(() async {
      try {
        await db.close();
      } catch (_) {
        // Cerrar una base que no llego a abrirse puede fallar; da igual.
      }
    });

    // UnsupportedError es un Error, no un Exception: el matcher tiene que
    // mirar Error o el fallo pasa por delante sin que nadie lo vea.
    await expectLater(
      db.select(db.salarySources).get(),
      throwsA(
        isA<UnsupportedError>().having(
          (e) => '${e.message}',
          'mensaje',
          contains('version mas nueva'),
        ),
      ),
    );
  });
}
