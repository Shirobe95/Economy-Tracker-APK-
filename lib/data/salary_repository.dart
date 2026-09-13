import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_provider.dart';
import '../core/database/enums.dart';
import 'account_repository.dart';

/// Fuentes salariales y sus nominas.
///
/// El importe esperado de una fuente es orientativo: sirve para prever, no
/// sustituye al importe real de cada nomina cobrada.
class SalaryRepository {
  SalaryRepository(this._db);

  final AppDatabase _db;

  Stream<List<SalarySource>> watchSources({bool activeOnly = false}) {
    final query = _db.select(_db.salarySources)
      ..orderBy([(s) => OrderingTerm.asc(s.name)]);
    if (activeOnly) {
      query.where((s) => s.isActive.equals(true));
    }
    return query.watch();
  }

  /// Nominas de una fuente, de la mas reciente a la mas antigua.
  Stream<List<Transaction>> watchPayments(int sourceId) {
    final query = _db.select(_db.transactions)
      ..where((t) => t.salarySourceId.equals(sourceId))
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.expectedDate)]);
    return query.watch();
  }

  Future<int> saveSource({
    int? id,
    required String name,
    int? expectedAmount,
    RecurrenceFrequency? frequency,
    String currency = kDefaultCurrency,
  }) {
    final companion = SalarySourcesCompanion(
      name: Value(name.trim()),
      expectedAmount: Value(expectedAmount),
      frequency: Value(frequency),
      currency: Value(currency),
      updatedAt: Value(DateTime.now()),
    );

    if (id == null) {
      return _db.into(_db.salarySources).insert(companion);
    }
    return (_db.update(
      _db.salarySources,
    )..where((s) => s.id.equals(id))).write(companion).then((_) => id);
  }

  Future<void> setSourceActive(int id, bool active) {
    return (_db.update(_db.salarySources)..where((s) => s.id.equals(id))).write(
      SalarySourcesCompanion(
        isActive: Value(active),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

final salaryRepositoryProvider = Provider<SalaryRepository>(
  (ref) => SalaryRepository(ref.watch(appDatabaseProvider)),
);

final salarySourcesProvider = StreamProvider<List<SalarySource>>(
  (ref) => ref.watch(salaryRepositoryProvider).watchSources(),
);
