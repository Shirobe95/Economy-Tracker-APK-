import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/core/utils/dates.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Baja hasta el final de Inicio.
///
/// La ventana de test es mas corta que la pantalla de un movil: sin esto,
/// «Proximos movimientos» queda fuera del arbol construido y no se encuentra
/// nada aunque la lista sea correcta.
Future<void> scrollToEnd(WidgetTester tester) async {
  await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
  await tester.pumpAndSettle();
}

/// Lo que se ve en Inicio y en el historial.
///
/// Los repositorios ya estan probados por su cuenta; lo que falla aqui es el
/// cableado: una cifra calculada bien que la pantalla no ensena, o ensena en
/// el sitio equivocado, esta igual de mal que calcularla mal.
void main() {
  Future<int> seedAccount(AppDatabase db, {int initialBalance = 50000}) {
    return db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Cuenta',
            type: AccountType.bank,
            currency: 'EUR',
            initialBalance: Value(initialBalance),
          ),
        );
  }

  appTest('el saldo de Inicio descuenta el ahorro mensual apartado', (
    tester,
    db,
  ) async {
    await seedAccount(db);
    await db
        .into(db.savingsGoals)
        .insert(
          SavingsGoalsCompanion.insert(
            name: 'Ahorro del mes',
            kind: const Value(SavingsGoalKind.monthly),
            targetAmount: 20000,
            currency: 'EUR',
            startMonth: Value(Dates.monthStart(Dates.today())),
          ),
        );
    await tester.pumpAndSettle();

    // 500 de saldo, 200 apartados: la cifra grande es lo que queda.
    expect(find.text('DISPONIBLE'), findsOneWidget);
    expect(find.text('300,00 €'), findsOneWidget);
    expect(find.textContaining('de 500,00 €'), findsOneWidget);
  });

  appTest('sin objetivos, Inicio ensena el saldo entero', (tester, db) async {
    await seedAccount(db);
    await tester.pumpAndSettle();

    expect(find.text('SALDO ACTUAL'), findsOneWidget);
    expect(find.text('500,00 €'), findsOneWidget);
  });

  appTest('Proximos movimientos ensena los gastos, no solo los ingresos', (
    tester,
    db,
  ) async {
    final accountId = await seedAccount(db);
    final today = Dates.today();

    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: MovementType.expense,
            status: MovementStatus.pendiente,
            concept: 'Seguro del coche',
            amount: 12000,
            currency: 'EUR',
            accountId: accountId,
            expectedDate: today.add(const Duration(days: 3)),
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: MovementType.projectIncome,
            status: MovementStatus.pendiente,
            concept: 'Modulo de septiembre',
            amount: 35000,
            currency: 'EUR',
            accountId: accountId,
            expectedDate: today.add(const Duration(days: 5)),
          ),
        );
    await tester.pumpAndSettle();
    await scrollToEnd(tester);

    expect(find.text('Seguro del coche'), findsOneWidget);
    expect(find.text('Modulo de septiembre'), findsOneWidget);
  });

  appTest('Proximos movimientos incluye las repeticiones sin anotar', (
    tester,
    db,
  ) async {
    final accountId = await seedAccount(db);

    await db
        .into(db.recurringRules)
        .insert(
          RecurringRulesCompanion.insert(
            concept: 'Alquiler',
            type: MovementType.expense,
            accountId: accountId,
            amount: 85000,
            currency: 'EUR',
            frequency: RecurrenceFrequency.monthly,
            startDate: Dates.today(),
          ),
        );
    await tester.pumpAndSettle();
    await scrollToEnd(tester);

    // La regla no crea ninguna fila: si no sale aqui, el alquiler no aparece
    // en ningun sitio hasta que alguien lo apunta a mano. Sale una vez por
    // cada mes de la ventana, no una sola.
    expect(find.text('Alquiler'), findsWidgets);
    expect(find.text('Recurrente'), findsWidgets);
  });

  appTest('el historial deja fuera lo que todavia no ha ocurrido', (
    tester,
    db,
  ) async {
    final accountId = await seedAccount(db);
    final today = Dates.today();

    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: MovementType.expense,
            status: MovementStatus.pagado,
            concept: 'Compra hecha',
            amount: 5000,
            currency: 'EUR',
            accountId: accountId,
            expectedDate: today,
            actualDate: Value(today),
          ),
        );
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: MovementType.expense,
            status: MovementStatus.pendiente,
            concept: 'Compra por hacer',
            amount: 5000,
            currency: 'EUR',
            accountId: accountId,
            expectedDate: today.add(const Duration(days: 4)),
          ),
        );
    await tester.pumpAndSettle();
    await scrollToEnd(tester);

    await tapText(tester, 'Historial');

    expect(find.text('Compra hecha'), findsOneWidget);
    expect(find.text('Compra por hacer'), findsNothing);
  });
}
