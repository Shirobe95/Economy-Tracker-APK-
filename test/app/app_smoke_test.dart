import 'package:economy_tracker/app/app.dart';
import 'package:economy_tracker/core/theme/paliko_colors.dart';
import 'package:economy_tracker/core/theme/paliko_theme.dart';
import 'package:economy_tracker/core/widgets/paliko_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la app arranca con el tema PALIKO', (WidgetTester tester) async {
    await tester.pumpWidget(const EconomyTrackerApp());

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.theme?.scaffoldBackgroundColor, PalikoColors.background);
    expect(app.theme?.colorScheme.primary, PalikoColors.accent);
  });

  testWidgets('la pantalla de referencia se renderiza sin overflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EconomyTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('Sistema visual'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el tema es siempre oscuro', (WidgetTester tester) async {
    expect(PalikoTheme.dark.brightness, Brightness.dark);
    expect(PalikoTheme.dark.colorScheme.brightness, Brightness.dark);
  });

  group('PalikoAmount', () {
    testWidgets('pinta los ingresos en positivo', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PalikoTheme.dark,
          home: const Scaffold(body: PalikoAmount(cents: 1000)),
        ),
      );

      final Text text = tester.widget(find.byType(Text));
      expect(text.style?.color, PalikoColors.positive);
      expect(text.data, startsWith('+'));
    });

    testWidgets('pinta los gastos en negativo', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PalikoTheme.dark,
          home: const Scaffold(body: PalikoAmount(cents: -1000)),
        ),
      );

      final Text text = tester.widget(find.byType(Text));
      expect(text.style?.color, PalikoColors.negative);
      expect(text.data, startsWith('−'));
    });

    testWidgets('el modo neutro ignora el signo', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: PalikoTheme.dark,
          home: const Scaffold(
            body: PalikoAmount(cents: 1000, neutral: true, showSign: false),
          ),
        ),
      );

      final Text text = tester.widget(find.byType(Text));
      expect(text.style?.color, PalikoColors.textPrimary);
      expect(text.data, isNot(startsWith('+')));
    });
  });
}
