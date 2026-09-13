import 'package:drift/drift.dart' show Value;
import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/database_provider.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/movement_repository.dart';
import 'package:economy_tracker/data/project_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Cubre lo que el corte ECON-000E dejo sin verificar: clientes, proyectos y
/// cobros, incluida la coherencia entre el cliente del cobro y el del
/// proyecto, que el esquema exige con una clave compuesta.
void main() {
  group('repositorio', () {
    late AppDatabase db;
    late ProjectRepository projects;
    late MovementRepository movements;

    setUp(() {
      db = openTestDatabase();
      projects = ProjectRepository(db);
      movements = MovementRepository(db);
    });

    tearDown(() async => db.close());

    Future<int> account() => db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Cuenta',
            type: AccountType.bank,
            currency: 'EUR',
            initialBalance: const Value(0),
          ),
        );

    test('un proyecto necesita cliente', () async {
      final clientId = await projects.saveClient(name: 'Futon Espai');
      final projectId = await projects.saveProject(
        clientId: clientId,
        name: 'Modulo lectura',
      );

      final project = await projects.watchProject(projectId).first;
      expect(project!.clientId, clientId);
      expect(project.isActive, isTrue);
    });

    test('el cliente del cobro se deriva del proyecto', () async {
      final accountId = await account();
      final clientId = await projects.saveClient(name: 'Futon Espai');
      final projectId = await projects.saveProject(
        clientId: clientId,
        name: 'Modulo lectura',
      );

      final incomeId = await movements.save(
        MovementDraft(
          type: MovementType.projectIncome,
          status: MovementStatus.pendiente,
          concept: 'Modulo de septiembre',
          amount: 35000,
          accountId: accountId,
          projectId: projectId,
          expectedDate: DateTime.utc(2026, 9, 10),
        ),
      );

      final row = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(incomeId))).getSingle();
      // No se elige a mano: si se pudiera, podria no coincidir con el
      // proyecto y la clave compuesta del esquema lo rechazaria.
      expect(row.clientId, clientId);
    });

    test('un cobro no puede quedar pagado, solo cobrado', () async {
      final accountId = await account();
      final clientId = await projects.saveClient(name: 'Cliente');
      final projectId = await projects.saveProject(
        clientId: clientId,
        name: 'Proyecto',
      );

      await expectLater(
        movements.save(
          MovementDraft(
            type: MovementType.projectIncome,
            status: MovementStatus.pagado,
            concept: 'Cobro',
            amount: 35000,
            accountId: accountId,
            projectId: projectId,
            expectedDate: DateTime.utc(2026, 9, 10),
            actualDate: DateTime.utc(2026, 9, 10),
          ),
        ),
        throwsA(isA<MovementValidationError>()),
      );
    });

    test('marcar un cobro lo deja cobrado y suma al saldo', () async {
      final accountId = await account();
      final clientId = await projects.saveClient(name: 'Cliente');
      final projectId = await projects.saveProject(
        clientId: clientId,
        name: 'Proyecto',
      );

      final incomeId = await movements.save(
        MovementDraft(
          type: MovementType.projectIncome,
          status: MovementStatus.pendiente,
          concept: 'Cobro',
          amount: 35000,
          accountId: accountId,
          projectId: projectId,
          expectedDate: DateTime.utc(2026, 9, 10),
        ),
      );

      await movements.markRealised(incomeId, DateTime.utc(2026, 9, 12));

      final row = await (db.select(
        db.transactions,
      )..where((t) => t.id.equals(incomeId))).getSingle();
      expect(row.status, MovementStatus.cobrado);

      final summaries = await projects.watchSummaries().first;
      expect(summaries.single.collected, 35000);
      expect(summaries.single.pending, 0);
    });

    test('los totales separan lo cobrado de lo pendiente', () async {
      final accountId = await account();
      final clientId = await projects.saveClient(name: 'Cliente');
      final projectId = await projects.saveProject(
        clientId: clientId,
        name: 'Proyecto',
      );

      Future<int> income(MovementStatus status, int amount, int day) =>
          movements.save(
            MovementDraft(
              type: MovementType.projectIncome,
              status: status,
              concept: 'Cobro $day',
              amount: amount,
              accountId: accountId,
              projectId: projectId,
              expectedDate: DateTime.utc(2026, 9, day),
              actualDate: status.isRealised ? DateTime.utc(2026, 9, day) : null,
            ),
          );

      await income(MovementStatus.cobrado, 35000, 5);
      await income(MovementStatus.pendiente, 50000, 20);
      await income(MovementStatus.cancelado, 90000, 25);

      final summary = (await projects.watchSummaries().first).single;
      expect(summary.collected, 35000);
      expect(summary.pending, 50000, reason: 'lo cancelado no esta pendiente');
    });

    test('archivar un proyecto no toca sus cobros', () async {
      final accountId = await account();
      final clientId = await projects.saveClient(name: 'Cliente');
      final projectId = await projects.saveProject(
        clientId: clientId,
        name: 'Proyecto',
      );
      await movements.save(
        MovementDraft(
          type: MovementType.projectIncome,
          status: MovementStatus.cobrado,
          concept: 'Cobro',
          amount: 35000,
          accountId: accountId,
          projectId: projectId,
          expectedDate: DateTime.utc(2026, 9, 10),
          actualDate: DateTime.utc(2026, 9, 10),
        ),
      );

      await projects.setProjectActive(projectId, false);

      final summary = (await projects.watchSummaries().first).single;
      expect(summary.project.isActive, isFalse);
      expect(summary.collected, 35000);
    });

    test('un cliente con proyectos no se puede borrar fisicamente', () async {
      final clientId = await projects.saveClient(name: 'Cliente');
      await projects.saveProject(clientId: clientId, name: 'Proyecto');

      await expectLater(
        (db.delete(db.clients)..where((c) => c.id.equals(clientId))).go(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('interfaz', () {
    appTest('sin clientes, invita a crear el primero', (tester, db) async {
      await tapText(tester, 'Ingresos');
      await tester.tap(find.byTooltip('Clientes y proyectos'));
      await tester.pumpAndSettle();

      expect(find.text('Crear cliente'), findsOneWidget);
    });

    appTest('crea un cliente desde la pantalla', (tester, db) async {
      await tapText(tester, 'Ingresos');
      await tester.tap(find.byTooltip('Clientes y proyectos'));
      await tester.pumpAndSettle();

      await tapText(tester, 'Crear cliente');
      await enterInField(tester, 'Nombre', 'Futon Espai');
      await tapText(tester, 'Guardar');

      final clients = await db.select(db.clients).get();
      expect(clients.single.name, 'Futon Espai');
    });
  });
}
