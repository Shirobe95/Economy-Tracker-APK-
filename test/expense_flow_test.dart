import 'package:drift/drift.dart' show Value;
import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Recorre el camino real: crear la cuenta, anotar un gasto, verlo en el
/// listado y marcarlo pagado comprobando que el saldo se mueve.
void main() {
  Future<int> seedAccount(AppDatabase db, {int initialBalance = 432000}) {
    return db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Cuenta principal',
            type: AccountType.bank,
            currency: 'EUR',
            initialBalance: Value(initialBalance),
          ),
        );
  }

  appTest('la primera pantalla ofrece crear una cuenta y la crea', (
    tester,
    db,
  ) async {
    expect(find.text('Empieza por tu cuenta'), findsOneWidget);

    await tapText(tester, 'Crear mi primera cuenta');
    expect(find.text('Nueva cuenta'), findsOneWidget);

    await enterInField(tester, 'Nombre', 'Cuenta principal');
    await enterInField(tester, 'Saldo inicial', '4320');
    await tapText(tester, 'Crear');

    final accounts = await db.select(db.accounts).get();
    expect(accounts.single.name, 'Cuenta principal');
    expect(accounts.single.initialBalance, 432000);
  });

  appTest('con una cuenta, Inicio muestra el saldo real', (tester, db) async {
    await seedAccount(db);
    await tester.pumpAndSettle();

    expect(find.text('4.320,00 €'), findsOneWidget);
    expect(find.text('Empieza por tu cuenta'), findsNothing);
  });

  appTest('anota un gasto y aparece en el listado del mes', (tester, db) async {
    await seedAccount(db);
    await tester.pumpAndSettle();

    await tapLabel(tester, 'Nuevo movimiento');
    await tapText(tester, 'Gasto');

    expect(find.text('Nuevo gasto'), findsOneWidget);
    await enterInField(tester, 'Concepto', 'Alquiler');
    await enterInField(tester, 'Importe', '850');
    await tapText(tester, 'Guardar');

    final rows = await db.select(db.transactions).get();
    expect(rows.single.concept, 'Alquiler');
    expect(rows.single.amount, 85000);
    expect(rows.single.type, MovementType.expense);
    expect(rows.single.status, MovementStatus.pendiente);

    await tapText(tester, 'Gastos');
    expect(find.text('Alquiler'), findsOneWidget);
  });

  appTest('un gasto pendiente no mueve el saldo hasta que se paga', (
    tester,
    db,
  ) async {
    final accountId = await seedAccount(db);
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: MovementType.expense,
            status: MovementStatus.pendiente,
            concept: 'Alquiler',
            amount: 85000,
            currency: 'EUR',
            accountId: accountId,
            expectedDate: DateTime.utc(2026, 9, 3),
          ),
        );
    await tester.pumpAndSettle();

    // Sigue siendo el saldo inicial: pendiente no es dinero que se haya ido.
    expect(find.text('4.320,00 €'), findsOneWidget);

    await tapText(tester, 'Gastos');
    await tapText(tester, 'Alquiler');
    expect(find.text('Detalle'), findsOneWidget);

    await tapText(tester, 'Marcar como pagado');

    expect(
      find.text('Fecha en la que se pago'),
      findsOneWidget,
      reason: 'deberia pedir la fecha real en vez de inferirla',
    );
    await tapText(tester, 'ACEPTAR');

    final row = await db.select(db.transactions).getSingle();
    expect(row.status, MovementStatus.pagado);
    expect(row.actualDate, isNotNull);
  });

  appTest('el estado ofrecido para un gasto nunca incluye cobrado', (
    tester,
    db,
  ) async {
    await seedAccount(db);
    await tester.pumpAndSettle();

    await tapLabel(tester, 'Nuevo movimiento');
    await tapText(tester, 'Gasto');

    await tester.tap(find.text('Pendiente').last);
    await tester.pumpAndSettle();

    expect(find.text('Pagado'), findsWidgets);
    expect(find.text('Cobrado'), findsNothing);
  });

  appTest('sin concepto, el formulario avisa y no guarda', (tester, db) async {
    await seedAccount(db);
    await tester.pumpAndSettle();

    await tapLabel(tester, 'Nuevo movimiento');
    await tapText(tester, 'Gasto');
    await enterInField(tester, 'Importe', '20');
    await tapText(tester, 'Guardar');

    expect(find.text('Escribe un concepto.'), findsOneWidget);
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  appTest('un importe con tres decimales se rechaza', (tester, db) async {
    await seedAccount(db);
    await tester.pumpAndSettle();

    await tapLabel(tester, 'Nuevo movimiento');
    await tapText(tester, 'Gasto');
    await enterInField(tester, 'Concepto', 'Cafe');
    await enterInField(tester, 'Importe', '1,239');
    await tapText(tester, 'Guardar');

    expect(
      find.text('Importe no valido. Usa como mucho dos decimales.'),
      findsOneWidget,
    );
    expect(await db.select(db.transactions).get(), isEmpty);
  });
}
