import 'package:drift/drift.dart' show Value;
import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/database_provider.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/account_repository.dart';
import 'package:economy_tracker/data/reconciliation_service.dart';
import 'package:economy_tracker/data/movement_repository.dart';
import 'package:economy_tracker/data/report_engine.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cuadrar el saldo con el del banco.
///
/// La decision que se prueba aqui no es aritmetica: el ajuste se anota como un
/// movimiento normal, con su categoria, en vez de esconderse en un cajon
/// neutro. Si el banco dice que hay 11 € menos, esos 11 € se gastaron en algo
/// que no se anoto, y eso tiene que verse en los informes.
void main() {
  late AppDatabase db;
  late ReconciliationService service;
  late int accountId;

  setUp(() async {
    db = openTestDatabase();
    service = ReconciliationService(db);
    accountId = await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Caixa',
            type: AccountType.bank,
            currency: 'EUR',
            initialBalance: const Value(52711),
          ),
        );
  });

  tearDown(() => db.close());

  Future<int?> balance() async {
    final rows = await AccountRepository(db).watchBalances().first;
    return rows.single.balance;
  }

  Future<void> spend(int amount, DateTime date) async {
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: MovementType.expense,
            status: MovementStatus.pagado,
            concept: 'Compra',
            amount: amount,
            currency: 'EUR',
            accountId: accountId,
            expectedDate: date,
            actualDate: Value(date),
          ),
        );
  }

  group('calculo', () {
    test('sin movimientos, la diferencia es contra el saldo inicial', () async {
      final preview = await service.preview(
        accountId: accountId,
        realBalance: 50000,
      );

      expect(preview.appBalance, 52711);
      expect(preview.delta, -2711);
      expect(preview.isGain, isFalse);
    });

    test('calcular no escribe nada', () async {
      await service.preview(accountId: accountId, realBalance: 1);

      expect(await db.select(db.transactions).get(), isEmpty);
      expect(await db.select(db.categories).get(), isEmpty);
    });

    test('si ya cuadra, lo dice y no anota nada', () async {
      final id = await service.reconcile(
        accountId: accountId,
        realBalance: 52711,
      );

      expect(id, isNull);
      expect(await db.select(db.transactions).get(), isEmpty);
    });
  });

  group('ajuste', () {
    test('el saldo pasa a ser exactamente el del banco', () async {
      await spend(18814, DateTime.utc(2026, 9, 20));
      expect(await balance(), 33897);

      await service.reconcile(accountId: accountId, realBalance: 29927);

      expect(await balance(), 29927);
    });

    test('si falta dinero se anota como gasto', () async {
      await service.reconcile(accountId: accountId, realBalance: 51611);

      final row = (await db.select(db.transactions).get()).single;
      expect(row.type, MovementType.expense);
      expect(row.status, MovementStatus.pagado);
      expect(row.amount, 1100);
      expect(row.concept, 'Ajuste de saldo');
    });

    test('si sobra dinero se anota como ingreso', () async {
      await service.reconcile(accountId: accountId, realBalance: 53811);

      final row = (await db.select(db.transactions).get()).single;
      expect(row.type, MovementType.otherIncome);
      expect(row.status, MovementStatus.cobrado);
      expect(row.amount, 1100);
    });

    test('lleva fecha real, no solo prevista', () async {
      final dia = DateTime.utc(2026, 9, 21);
      await service.reconcile(
        accountId: accountId,
        realBalance: 50000,
        date: dia,
      );

      final row = (await db.select(db.transactions).get()).single;
      expect(row.actualDate, dia);
      expect(row.expectedDate, dia);
    });

    test('la nota deja escrito contra que cifra se cuadro', () async {
      await service.reconcile(accountId: accountId, realBalance: 29927);

      final row = (await db.select(db.transactions).get()).single;
      // Dentro de seis meses, esto es lo unico que explica el ajuste.
      expect(row.notes, contains('299,27'));
    });

    test('un saldo en numeros rojos tambien se puede cuadrar', () async {
      await service.reconcile(accountId: accountId, realBalance: -4000);

      expect(await balance(), -4000);
    });
  });

  group('categoria', () {
    test('se crea sola la primera vez y admite las dos direcciones', () async {
      await service.reconcile(accountId: accountId, realBalance: 50000);

      final category = (await db.select(db.categories).get()).single;
      expect(category.name, ReconciliationService.categoryName);
      // Un ajuste va en las dos direcciones segun de que lado caiga.
      expect(category.kind, CategoryKind.both);
    });

    test('cuadrar dos veces no crea dos categorias', () async {
      await service.reconcile(accountId: accountId, realBalance: 50000);
      await service.reconcile(accountId: accountId, realBalance: 48000);

      expect(await db.select(db.categories).get(), hasLength(1));
      expect(await db.select(db.transactions).get(), hasLength(2));
    });

    test(
      'no reutiliza una homonima que no admita las dos direcciones',
      () async {
        // Alguien pudo crear a mano una categoria «Ajuste de saldo» solo de
        // gastos. Reutilizarla reventaria al cuadrar hacia arriba, porque el
        // guardado rechaza una categoria que no admite ingresos.
        await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                name: ReconciliationService.categoryName,
                kind: CategoryKind.expense,
              ),
            );

        await service.reconcile(accountId: accountId, realBalance: 53811);

        final row = (await db.select(db.transactions).get()).single;
        final used = (await db.select(db.categories).get()).firstWhere(
          (c) => c.id == row.categoryId,
        );
        expect(used.kind, CategoryKind.both);
      },
    );

    test('no reutiliza una homonima archivada', () async {
      final archived = await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              name: ReconciliationService.categoryName,
              kind: CategoryKind.both,
              isArchived: const Value(true),
            ),
          );

      await service.reconcile(accountId: accountId, realBalance: 50000);

      final row = (await db.select(db.transactions).get()).single;
      // El guardado rechaza las archivadas: usar esa dejaba el ajuste roto.
      expect(row.categoryId, isNot(archived));
    });

    test('con dos homonimas no falla, coge una que sirva', () async {
      for (var i = 0; i < 2; i++) {
        await db
            .into(db.categories)
            .insert(
              CategoriesCompanion.insert(
                name: ReconciliationService.categoryName,
                kind: CategoryKind.both,
              ),
            );
      }

      // El nombre no es unico en el esquema: antes esto reventaba con un
      // «Bad state: Too many elements».
      await service.reconcile(accountId: accountId, realBalance: 50000);

      expect(await db.select(db.transactions).get(), hasLength(1));
    });

    test('reutiliza una categoria que ya exista con ese nombre', () async {
      final existing = await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              name: ReconciliationService.categoryName,
              kind: CategoryKind.both,
            ),
          );

      await service.reconcile(accountId: accountId, realBalance: 50000);

      final row = (await db.select(db.transactions).get()).single;
      expect(row.categoryId, existing);
      expect(await db.select(db.categories).get(), hasLength(1));
    });
  });

  test('un saldo absurdo se rechaza en vez de desbordar', () async {
    // Sin esta cota, la resta de enteros de 64 bits puede cambiar de signo y
    // anotar el ajuste justo al reves.
    await expectLater(
      service.preview(
        accountId: accountId,
        realBalance: Reconciliation.maxBalance + 1,
      ),
      throwsA(isA<MovementValidationError>()),
    );
  });

  test('el ajuste se ve en los informes, no se esconde', () async {
    await service.reconcile(
      accountId: accountId,
      realBalance: 51611,
      date: DateTime.utc(2026, 9, 21),
    );

    final movements = await db.select(db.transactions).get();
    final categories = await db.select(db.categories).get();
    final report = ReportEngine.build(
      movements: movements,
      categories: categories,
      reference: DateTime.utc(2026, 9, 21),
      range: ReportRange.halfYear,
    );

    // Es la razon de ser de esta decision: 11 € se han ido sin saber a donde
    // y el informe lo dice, en vez de dejarlos desaparecer en silencio.
    expect(report.expense, 1100);
    final byName = {
      for (final slice in report.byCategory) slice.name: slice.amount,
    };
    expect(byName[ReconciliationService.categoryName], 1100);
  });
}
