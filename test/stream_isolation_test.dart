import 'package:drift/drift.dart' show Value;
import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/database_provider.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/account_repository.dart';
import 'package:economy_tracker/data/project_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dos vistas reactivas distintas no pueden pisarse.
///
/// Cubre un fallo que por separado era invisible: ambos repositorios
/// disparaban su recalculo observando `SELECT 1` con las tablas que les
/// interesaban. Drift cachea los streams por su SQL, asi que compartian uno
/// solo y el segundo en suscribirse acababa escuchando las tablas del
/// primero. La ficha de un cliente no se enteraba de sus propios proyectos.
void main() {
  late AppDatabase db;
  late AccountRepository accounts;
  late ProjectRepository projects;

  setUp(() {
    db = openTestDatabase();
    accounts = AccountRepository(db);
    projects = ProjectRepository(db);
  });

  tearDown(() async => db.close());

  test(
    'la lista de proyectos reacciona aunque el saldo escuche primero',
    () async {
      final clientId = await projects.saveClient(name: 'Futon Espai');

      // El orden importa: es justo el que provocaba el fallo.
      final balanceEmissions = <int>[];
      final balanceSub = accounts.watchBalances().listen(
        (rows) => balanceEmissions.add(rows.length),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final projectEmissions = <int>[];
      final projectSub = projects
          .watchSummaries(clientId: clientId)
          .listen((rows) => projectEmissions.add(rows.length));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await projects.saveProject(clientId: clientId, name: 'Modulo lectura');
      await Future<void>.delayed(const Duration(milliseconds: 300));

      await balanceSub.cancel();
      await projectSub.cancel();

      expect(
        projectEmissions.last,
        1,
        reason: 'la ficha tiene que ver su proyecto nuevo',
      );
    },
  );

  test(
    'el saldo sigue reaccionando aunque los proyectos escuchen primero',
    () async {
      final accountId = await accounts.createAccount(
        name: 'Cuenta',
        type: AccountType.bank,
        initialBalance: 100000,
      );

      final projectSub = projects.watchSummaries().listen((_) {});
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final balances = <int?>[];
      final balanceSub = accounts.watchBalances().listen(
        (rows) => balances.add(rows.single.balance),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

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
      await Future<void>.delayed(const Duration(milliseconds: 300));

      await projectSub.cancel();
      await balanceSub.cancel();

      expect(balances.last, 15000);
    },
  );

  test(
    'un cambio en proyectos no obliga a recalcular saldos ni al reves',
    () async {
      // No es solo correccion: cada vista observa lo suyo.
      final clientId = await projects.saveClient(name: 'Cliente');
      await accounts.createAccount(name: 'Cuenta', type: AccountType.bank);

      final balanceEmissions = <int>[];
      final sub = accounts.watchBalances().listen(
        (rows) => balanceEmissions.add(rows.length),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final before = balanceEmissions.length;

      await projects.saveProject(clientId: clientId, name: 'Proyecto');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await sub.cancel();

      expect(balanceEmissions.length, before);
    },
  );
}
