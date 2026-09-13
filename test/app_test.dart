import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  appTest('arranca en Inicio con las cuatro pestanas y la accion central', (
    tester,
    db,
  ) async {
    expect(find.text('Inicio'), findsWidgets);
    expect(find.text('Gastos'), findsWidgets);
    expect(find.text('Ingresos'), findsWidgets);
    expect(find.text('Prevision'), findsWidgets);
    expect(find.bySemanticsLabel('Nuevo movimiento'), findsOneWidget);
  });

  appTest('cambia de pestana al pulsar en la barra inferior', (
    tester,
    db,
  ) async {
    await tapText(tester, 'Gastos');
    expect(find.widgetWithText(AppBar, 'Gastos'), findsOneWidget);

    await tapText(tester, 'Prevision');
    expect(find.widgetWithText(AppBar, 'Prevision'), findsOneWidget);
  });

  appTest('la accion central abre las opciones de nuevo movimiento', (
    tester,
    db,
  ) async {
    await tapLabel(tester, 'Nuevo movimiento');

    expect(find.text('Gasto'), findsOneWidget);
    expect(find.text('Cobro de proyecto'), findsOneWidget);
    expect(find.text('Salario'), findsOneWidget);
    expect(find.text('Transferencia'), findsOneWidget);
  });

  appTest('sin cuentas invita a crear la primera, sin cifras inventadas', (
    tester,
    db,
  ) async {
    expect(find.text('Empieza por tu cuenta'), findsOneWidget);
    // Un cero que parezca un saldo real seria peor que no mostrar nada.
    expect(find.textContaining('€'), findsNothing);
  });
}
