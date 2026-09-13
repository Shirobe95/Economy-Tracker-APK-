import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/database_provider.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/account_repository.dart';
import 'package:economy_tracker/data/movement_repository.dart';
import 'package:economy_tracker/data/project_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un saldo correcto que la pantalla no vuelve a leer es un saldo
/// equivocado. Estas pruebas miran el stream, no la funcion de calculo: el
/// fallo que cubren era exactamente ese, un calculo bien hecho que nadie
/// recalculaba porque el watch solo observaba una de las dos tablas.
void main() {
  late AppDatabase db;
  late AccountRepository accounts;
  late MovementRepository movements;
  late ProjectRepository projects;

  setUp(() {
    db = openTestDatabase();
    accounts = AccountRepository(db);
    movements = MovementRepository(db);
    projects = ProjectRepository(db);
  });

  tearDown(() async => db.close());

  /// Recoge lo que emite un stream mientras corre [action].
  Future<List<T>> collect<T>(
    Stream<T> stream,
    Future<void> Function() action,
  ) async {
    final emitted = <T>[];
    final subscription = stream.listen(emitted.add);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await action();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await subscription.cancel();
    return emitted;
  }

  Future<int> account({int initialBalance = 100000}) => accounts.createAccount(
    name: 'Cuenta principal',
    type: AccountType.bank,
    initialBalance: initialBalance,
  );

  group('saldo observado', () {
    test('baja al pagar un gasto', () async {
      final accountId = await account();

      final emitted = await collect(
        accounts.watchBalances(),
        () => movements.save(
          MovementDraft(
            type: MovementType.expense,
            status: MovementStatus.pagado,
            concept: 'Alquiler',
            amount: 85000,
            accountId: accountId,
            expectedDate: DateTime.utc(2026, 9, 3),
            actualDate: DateTime.utc(2026, 9, 3),
          ),
        ),
      );

      expect(emitted.last.single.balance, 15000);
    });

    test('sube al cobrar un ingreso', () async {
      final accountId = await account();

      final emitted = await collect(
        accounts.watchBalances(),
        () => movements.save(
          MovementDraft(
            type: MovementType.salary,
            status: MovementStatus.cobrado,
            concept: 'Nomina',
            amount: 170000,
            accountId: accountId,
            expectedDate: DateTime.utc(2026, 9, 1),
            actualDate: DateTime.utc(2026, 9, 1),
          ),
        ),
      );

      expect(emitted.last.single.balance, 270000);
    });

    test('reacciona al marcar como pagado algo ya guardado', () async {
      final accountId = await account();
      final movementId = await movements.save(
        MovementDraft(
          type: MovementType.expense,
          status: MovementStatus.pendiente,
          concept: 'Alquiler',
          amount: 85000,
          accountId: accountId,
          expectedDate: DateTime.utc(2026, 9, 3),
        ),
      );

      final emitted = await collect(
        accounts.watchBalances(),
        () => movements.markRealised(movementId, DateTime.utc(2026, 9, 4)),
      );

      expect(emitted.first.single.balance, 100000);
      expect(emitted.last.single.balance, 15000);
    });

    test('vuelve atras al eliminar un gasto pagado', () async {
      final accountId = await account();
      final movementId = await movements.save(
        MovementDraft(
          type: MovementType.expense,
          status: MovementStatus.pagado,
          concept: 'Alquiler',
          amount: 85000,
          accountId: accountId,
          expectedDate: DateTime.utc(2026, 9, 3),
          actualDate: DateTime.utc(2026, 9, 3),
        ),
      );

      final emitted = await collect(
        accounts.watchBalances(),
        () => movements.delete(movementId),
      );

      expect(emitted.last.single.balance, 100000);
    });
  });

  group('totales de proyecto observados', () {
    test('cuentan un cobro nuevo en cuanto se registra', () async {
      final accountId = await account();
      final clientId = await projects.saveClient(name: 'Futon Espai');
      final projectId = await projects.saveProject(
        clientId: clientId,
        name: 'Modulo lectura',
      );

      final emitted = await collect(
        projects.watchSummaries(),
        () => movements.save(
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
        ),
      );

      expect(emitted.last.single.collected, 35000);
    });
  });
}
