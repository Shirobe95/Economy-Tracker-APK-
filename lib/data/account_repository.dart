import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/app_database.dart';
import '../core/database/database_provider.dart';
import '../core/database/enums.dart';

/// Moneda unica de la interfaz por ahora.
///
/// El modelo de datos es multimoneda, pero ninguna pantalla permite todavia
/// elegir otra: mezclarlas exigiria resolver exponentes y conversion.
const String kDefaultCurrency = 'EUR';

/// Una cuenta con su saldo real ya calculado.
class AccountBalance {
  const AccountBalance({required this.account, required this.balance});

  final Account account;

  /// Saldo real en unidades menores, o `null` si la suma desborda.
  final int? balance;
}

/// Cuentas, categorias y saldos.
///
/// El saldo no se almacena: se deriva cada vez de las filas actuales. Asi,
/// editar un gasto ya pagado recalcula sin dejar un saldo mutable desfasado.
class AccountRepository {
  AccountRepository(this._db);

  final AppDatabase _db;

  /// Saldo real de una cuenta.
  ///
  /// Saldo inicial + ingresos cobrados − gastos pagados − transferencias
  /// pagadas de salida + transferencias pagadas de entrada.
  ///
  /// Lo previsto, lo pendiente, lo cancelado y lo borrado no tienen impacto
  /// real. Una transferencia no es ingreso ni gasto: su efecto entre las dos
  /// cuentas suma cero.
  static int? balanceOf(Account account, List<Transaction> movements) {
    var total = BigInt.from(account.initialBalance);

    for (final movement in movements) {
      if (movement.isDeleted) continue;
      if (!movement.status.isRealised) continue;

      final amount = BigInt.from(movement.amount);
      final isOrigin = movement.accountId == account.id;
      final isDestination = movement.destinationAccountId == account.id;

      if (movement.type.isTransfer) {
        if (isOrigin) total -= amount;
        if (isDestination) total += amount;
      } else if (isOrigin) {
        total += movement.type.isIncome ? amount : -amount;
      }
    }

    if (total > Money64.max || total < Money64.min) return null;
    return total.toInt();
  }

  /// Cuentas no archivadas, ordenadas por nombre.
  Stream<List<Account>> watchAccounts() {
    final query = _db.select(_db.accounts)
      ..where((a) => a.isArchived.equals(false))
      ..orderBy([(a) => OrderingTerm.asc(a.name)]);
    return query.watch();
  }

  /// Cuentas con su saldo real, recalculado ante cualquier cambio.
  Stream<List<AccountBalance>> watchBalances() {
    // El saldo depende de dos tablas, asi que hay que observar las dos.
    // Un `select(accounts).watch()` solo reacciona a cambios en accounts:
    // leer los movimientos dentro del asyncMap no crea ninguna dependencia,
    // y el saldo se quedaba congelado al pagar un gasto.
    return _db
        .customSelect('SELECT 1', readsFrom: {_db.accounts, _db.transactions})
        .watch()
        .asyncMap((_) async {
          final accounts = await _db.select(_db.accounts).get();
          final movements = await (_db.select(
            _db.transactions,
          )..where((t) => t.isDeleted.equals(false))).get();

          return [
            for (final account in accounts)
              AccountBalance(
                account: account,
                balance: balanceOf(account, movements),
              ),
          ];
        });
  }

  /// Categorias activas que admiten el tipo indicado.
  Stream<List<Category>> watchCategories(CategoryKind kind) {
    final query = _db.select(_db.categories)
      ..where((c) => c.isArchived.equals(false))
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);

    return query.watch().map(
      (rows) => rows.where((c) {
        return switch (kind) {
          CategoryKind.expense => c.kind.acceptsExpense(),
          CategoryKind.income => c.kind.acceptsIncome(),
          CategoryKind.both => true,
        };
      }).toList(),
    );
  }

  /// Crea una cuenta. El saldo inicial admite valores negativos.
  Future<int> createAccount({
    required String name,
    required AccountType type,
    int initialBalance = 0,
    String currency = kDefaultCurrency,
  }) {
    return _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: name.trim(),
            type: type,
            currency: currency,
            initialBalance: Value(initialBalance),
          ),
        );
  }

  /// Crea una categoria.
  Future<int> createCategory({
    required String name,
    required CategoryKind kind,
  }) {
    return _db
        .into(_db.categories)
        .insert(CategoriesCompanion.insert(name: name.trim(), kind: kind));
  }

  /// Archiva o reactiva una cuenta. No borra: conserva historia y relaciones.
  Future<void> setAccountArchived(int id, bool archived) {
    return (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(
        isArchived: Value(archived),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

/// Limites de un entero con signo de 64 bits, que es lo que admite SQLite.
abstract final class Money64 {
  static final BigInt max = BigInt.parse('9223372036854775807');
  static final BigInt min = BigInt.parse('-9223372036854775808');
}

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(ref.watch(appDatabaseProvider)),
);

final accountsProvider = StreamProvider<List<Account>>(
  (ref) => ref.watch(accountRepositoryProvider).watchAccounts(),
);

final accountBalancesProvider = StreamProvider<List<AccountBalance>>(
  (ref) => ref.watch(accountRepositoryProvider).watchBalances(),
);
