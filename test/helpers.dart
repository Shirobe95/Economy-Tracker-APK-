import 'package:economy_tracker/app/economy_tracker_app.dart';
import 'package:economy_tracker/app/theme/app_theme.dart';
import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test de interfaz contra una base en memoria.
///
/// El desmontaje va dentro del cuerpo del test, no en un tearDown: al
/// cancelar sus streams Drift programa un temporizador de duracion cero, y
/// la comprobacion de temporizadores pendientes de Flutter corre antes que
/// los tearDown. Sin este orden, todo test que lea la base falla.
void appTest(
  String description,
  Future<void> Function(WidgetTester tester, AppDatabase db) body, {
  Widget? screen,
}) {
  testWidgets(description, (tester) async {
    final db = openInMemoryDatabase();
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: screen == null
              ? const EconomyTrackerApp()
              : MaterialApp(theme: AppTheme.build(), home: screen),
        ),
      );
      await tester.pumpAndSettle();
      await body(tester, db);
    } finally {
      // Desmonta el arbol y deja correr el temporizador que Drift programa
      // al cancelar sus streams. La base en memoria muere con el test, asi
      // que no hace falta cerrarla: esperar a su cierre dentro del reloj
      // simulado del test no termina nunca.
      await tester.pumpWidget(const SizedBox.shrink());
      // Cancelar un stream programa el temporizador, y ejecutarlo puede
      // cancelar el siguiente: hacen falta varias vueltas para vaciarlos.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 1));
      }
    }
  });
}

/// Pulsa por texto y espera a que la interfaz se estabilice.
Future<void> tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

/// Pulsa un widget por su etiqueta de accesibilidad.
Future<void> tapLabel(WidgetTester tester, String label) async {
  await tester.tap(find.bySemanticsLabel(label));
  await tester.pumpAndSettle();
}

/// Escribe en el campo cuya etiqueta coincide.
Future<void> enterInField(
  WidgetTester tester,
  String label,
  String value,
) async {
  final field = find.ancestor(
    of: find.text(label),
    matching: find.byType(TextField),
  );
  await tester.enterText(field.first, value);
  await tester.pumpAndSettle();
}
