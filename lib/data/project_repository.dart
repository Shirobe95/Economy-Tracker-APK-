import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_provider.dart';
import '../core/database/enums.dart';
import '../core/utils/money.dart';
import 'account_repository.dart';

/// Un proyecto con los totales de sus cobros ya calculados.
class ProjectSummary {
  const ProjectSummary({
    required this.project,
    required this.client,
    required this.collected,
    required this.pending,
  });

  final Project project;
  final Client client;

  /// Cobrado de verdad, en unidades menores.
  final int collected;

  /// Previsto o pendiente, todavia no en la cuenta.
  final int pending;
}

/// Clientes, proyectos y sus cobros.
///
/// Un cobro no es una entidad propia: es un movimiento de tipo
/// `project_income` con proyecto. El importe que se registra es siempre el
/// neto que entra en la cuenta (DEC-006): sin bruto ni retencion.
class ProjectRepository {
  ProjectRepository(this._db);

  final AppDatabase _db;

  Stream<List<Client>> watchClients({bool includeArchived = false}) {
    final query = _db.select(_db.clients)
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);
    if (!includeArchived) {
      query.where((c) => c.isArchived.equals(false));
    }
    return query.watch();
  }

  Stream<Client?> watchClient(int id) {
    final query = _db.select(_db.clients)..where((c) => c.id.equals(id));
    return query.watchSingleOrNull();
  }

  Stream<List<Project>> watchProjects({
    int? clientId,
    bool activeOnly = false,
  }) {
    final query = _db.select(_db.projects)
      ..orderBy([(p) => OrderingTerm.asc(p.name)]);
    if (clientId != null) {
      query.where((p) => p.clientId.equals(clientId));
    }
    if (activeOnly) {
      query.where((p) => p.isActive.equals(true));
    }
    return query.watch();
  }

  Stream<Project?> watchProject(int id) {
    final query = _db.select(_db.projects)..where((p) => p.id.equals(id));
    return query.watchSingleOrNull();
  }

  /// Cobros de un proyecto, del mas reciente al mas antiguo.
  Stream<List<Transaction>> watchIncomes(int projectId) {
    final query = _db.select(_db.transactions)
      ..where((t) => t.projectId.equals(projectId))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.expectedDate)]);
    return query.watch();
  }

  /// Proyectos con cliente y totales, para las listas.
  /// Proyectos con cliente y totales, para las listas.
  ///
  /// Observa tambien `transactions`: los totales dependen de los cobros, y
  /// un watch solo sobre projects no reaccionaria al registrar uno.
  Stream<List<ProjectSummary>> watchSummaries({int? clientId}) {
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {_db.projects, _db.clients, _db.transactions},
        )
        .watch()
        .asyncMap((_) async {
          final projects = _db.select(_db.projects);
          if (clientId != null) {
            projects.where((p) => p.clientId.equals(clientId));
          }

          final rows = await projects.join([
            innerJoin(
              _db.clients,
              _db.clients.id.equalsExp(_db.projects.clientId),
            ),
          ]).get();

          final incomes =
              await (_db.select(_db.transactions)
                    ..where((t) => t.isDeleted.equals(false))
                    ..where((t) => t.projectId.isNotNull()))
                  .get();

          return [
            for (final row in rows)
              () {
                final project = row.readTable(_db.projects);
                final own = incomes.where((t) => t.projectId == project.id);
                return ProjectSummary(
                  project: project,
                  client: row.readTable(_db.clients),
                  collected:
                      Money.sum(
                        own
                            .where((t) => t.status.isRealised)
                            .map((t) => t.amount),
                      ) ??
                      0,
                  pending:
                      Money.sum(
                        own
                            .where(
                              (t) =>
                                  !t.status.isRealised &&
                                  t.status != MovementStatus.cancelado,
                            )
                            .map((t) => t.amount),
                      ) ??
                      0,
                );
              }(),
          ]..sort((a, b) => a.project.name.compareTo(b.project.name));
        });
  }

  Future<int> saveClient({int? id, required String name, String? contact}) {
    final trimmedContact = contact?.trim();
    final companion = ClientsCompanion(
      name: Value(name.trim()),
      contact: Value(
        trimmedContact == null || trimmedContact.isEmpty
            ? null
            : trimmedContact,
      ),
      updatedAt: Value(DateTime.now()),
    );

    if (id == null) {
      return _db.into(_db.clients).insert(companion);
    }
    return (_db.update(
      _db.clients,
    )..where((c) => c.id.equals(id))).write(companion).then((_) => id);
  }

  Future<void> setClientArchived(int id, bool archived) {
    return (_db.update(_db.clients)..where((c) => c.id.equals(id))).write(
      ClientsCompanion(
        isArchived: Value(archived),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> saveProject({
    int? id,
    required int clientId,
    required String name,
    BillingType? billingType,
    int? estimatedAmount,
    String currency = kDefaultCurrency,
  }) {
    final companion = ProjectsCompanion(
      clientId: Value(clientId),
      name: Value(name.trim()),
      billingType: Value(billingType),
      estimatedAmount: Value(estimatedAmount),
      currency: Value(currency),
      updatedAt: Value(DateTime.now()),
    );

    if (id == null) {
      return _db.into(_db.projects).insert(companion);
    }
    return (_db.update(
      _db.projects,
    )..where((p) => p.id.equals(id))).write(companion).then((_) => id);
  }

  /// Archiva o reactiva un proyecto. Sus cobros historicos no se tocan.
  Future<void> setProjectActive(int id, bool active) {
    return (_db.update(_db.projects)..where((p) => p.id.equals(id))).write(
      ProjectsCompanion(
        isActive: Value(active),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) => ProjectRepository(ref.watch(appDatabaseProvider)),
);

final clientsProvider = StreamProvider<List<Client>>(
  (ref) => ref.watch(projectRepositoryProvider).watchClients(),
);

final activeProjectsProvider = StreamProvider<List<ProjectSummary>>(
  (ref) => ref.watch(projectRepositoryProvider).watchSummaries(),
);
