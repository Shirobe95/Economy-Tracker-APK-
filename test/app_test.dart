import 'package:economy_tracker/app/economy_tracker_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EconomyTrackerApp()));
    await tester.pumpAndSettle();
  }

  testWidgets('arranca en Inicio con las cuatro pestanas y la accion central', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('Inicio'), findsWidgets);
    expect(find.text('Gastos'), findsWidgets);
    expect(find.text('Ingresos'), findsWidgets);
    expect(find.text('Prevision'), findsWidgets);
    expect(find.bySemanticsLabel('Nuevo movimiento'), findsOneWidget);
  });

  testWidgets('cambia de pestana al pulsar en la barra inferior', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Gastos').last);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Gastos'), findsOneWidget);
  });

  testWidgets('no muestra ninguna cifra monetaria inventada', (tester) async {
    await pumpApp(tester);

    expect(find.textContaining('€'), findsNothing);
  });
}
