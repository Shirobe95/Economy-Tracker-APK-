import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migrar no puede costarle los datos a nadie.
///
/// El test levanta una base con el esquema v1 escrito a mano, mete datos, y
/// la abre con la aplicacion actual para que corra la migracion de verdad.
void main() {
  /// Esquema v1 de `savings_goals`, antes de distinguir tipo de objetivo.
  const savingsGoalsV1 = '''
    CREATE TABLE "savings_goals" (
      "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      "created_at" INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
      "updated_at" INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
      "name" TEXT NOT NULL,
      "target_amount" INTEGER NOT NULL,
      "current_amount" INTEGER NULL,
      "monthly_contribution" INTEGER NULL,
      "currency" TEXT NOT NULL,
      "target_date" TEXT NULL,
      "is_archived" INTEGER NOT NULL DEFAULT 0 CHECK ("is_archived" IN (0, 1)),
      CHECK (currency GLOB '[A-Z][A-Z][A-Z]'),
      CHECK (target_amount > 0),
      CHECK (current_amount IS NULL OR current_amount >= 0),
      CHECK (monthly_contribution IS NULL OR monthly_contribution >= 0)
    )
  ''';

  /// Esquema v3 de `savings_goals`, ya con tipo pero sin mes de inicio.
  const savingsGoalsV3 = '''
    CREATE TABLE "savings_goals" (
      "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      "created_at" INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
      "updated_at" INTEGER NOT NULL DEFAULT (CAST(strftime('%s', CURRENT_TIMESTAMP) AS INTEGER)),
      "name" TEXT NOT NULL,
      "kind" TEXT NOT NULL DEFAULT 'amount',
      "target_amount" INTEGER NOT NULL,
      "current_amount" INTEGER NULL,
      "monthly_contribution" INTEGER NULL,
      "currency" TEXT NOT NULL,
      "target_date" TEXT NULL,
      "is_archived" INTEGER NOT NULL DEFAULT 0 CHECK ("is_archived" IN (0, 1)),
      CHECK (currency GLOB '[A-Z][A-Z][A-Z]'),
      CHECK (kind IN ('amount', 'monthly')),
      CHECK (target_amount > 0),
      CHECK (current_amount IS NULL OR current_amount >= 0),
      CHECK (monthly_contribution IS NULL OR monthly_contribution >= 0)
    )
  ''';

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
    await setup.customStatement('DROP INDEX IF EXISTS idx_tx_rule_occurrence');
    await setup.customStatement('DROP TABLE savings_goals');
    await setup.customStatement(savingsGoalsV1);
    await setup.customStatement(
      "INSERT INTO savings_goals (name, target_amount, current_amount, currency) "
      "VALUES ('Fondo de emergencia', 600000, 325000, 'EUR')",
    );
    await setup.customStatement('PRAGMA user_version = 1');
    await setup.close();

    return AppDatabase(DatabaseConnection(NativeDatabase(file)));
  }

  test('la version de esquema es 4', () {
    final db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    expect(db.schemaVersion, 4);
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

  test('migrar de v1 conserva los objetivos y les pone tipo', () async {
    final db = await migratedFromV1();
    addTearDown(db.close);

    final goals = await db.select(db.savingsGoals).get();
    expect(goals.single.name, 'Fondo de emergencia');
    expect(goals.single.targetAmount, 600000);
    expect(goals.single.currentAmount, 325000);
    // Lo que ya existia es un objetivo por importe: nadie habia pedido otra
    // cosa, asi que ese es el unico valor honesto.
    expect(goals.single.kind, SavingsGoalKind.amount);
    // Y por eso no lleva mes de inicio: un objetivo por importe no acumula.
    expect(goals.single.startMonth, isNull);
  });

  test('migrar de v3 fecha los objetivos mensuales que ya existian', () async {
    final file = File('${workspace.path}/economy_tracker.sqlite');

    final setup = AppDatabase(DatabaseConnection(NativeDatabase(file)));
    await setup.customStatement('SELECT 1');
    await setup.customStatement('DROP TABLE savings_goals');
    await setup.customStatement(savingsGoalsV3);
    // Creado en marzo de 2026: 1772582400 son las 00:00 UTC del 2026-03-04.
    await setup.customStatement(
      "INSERT INTO savings_goals "
      "(created_at, updated_at, name, kind, target_amount, currency) "
      "VALUES (1772582400, 1772582400, 'Ahorro del mes', 'monthly', 20000, 'EUR')",
    );
    await setup.customStatement(
      "INSERT INTO savings_goals "
      "(created_at, updated_at, name, kind, target_amount, currency) "
      "VALUES (1772582400, 1772582400, 'Viaje', 'amount', 150000, 'EUR')",
    );
    await setup.customStatement('PRAGMA user_version = 3');
    await setup.close();

    final db = AppDatabase(DatabaseConnection(NativeDatabase(file)));
    addTearDown(db.close);

    final goals = await (db.select(
      db.savingsGoals,
    )..orderBy([(g) => OrderingTerm.asc(g.name)])).get();

    final mensual = goals.firstWhere((g) => g.kind.isMonthly);
    // El mes en que se creo, no el dia: la reserva cuenta por meses enteros.
    expect(mensual.startMonth, DateTime.utc(2026, 3));

    // El de importe se queda sin fecha: no hay nada que acumular.
    final porImporte = goals.firstWhere((g) => !g.kind.isMonthly);
    expect(porImporte.startMonth, isNull);
  });

  test('la base migrada impide duplicar una ocurrencia recurrente', () async {
    final db = await migratedFromV1();
    addTearDown(db.close);

    final accountId = await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Cuenta',
            type: AccountType.bank,
            currency: 'EUR',
          ),
        );
    final ruleId = await db
        .into(db.recurringRules)
        .insert(
          RecurringRulesCompanion.insert(
            concept: 'Seguro',
            type: MovementType.expense,
            accountId: accountId,
            amount: 5000,
            currency: 'EUR',
            frequency: RecurrenceFrequency.monthly,
            startDate: DateTime.utc(2026, 9, 25),
          ),
        );

    Future<int> insertOccurrence() => db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: MovementType.expense,
            status: MovementStatus.previsto,
            concept: 'Seguro',
            amount: 5000,
            currency: 'EUR',
            accountId: accountId,
            recurringRuleId: Value(ruleId),
            expectedDate: DateTime.utc(2026, 9, 25),
          ),
        );

    await insertOccurrence();
    // El indice unico tiene que existir tambien en una base migrada.
    await expectLater(insertOccurrence(), throwsA(isA<Exception>()));
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
