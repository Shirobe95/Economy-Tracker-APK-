import 'package:economy_tracker/app/theme/app_theme.dart';
import 'package:economy_tracker/data/app_lock_service.dart';
import 'package:economy_tracker/features/security/pin_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Teclado del PIN.
///
/// El fallo que arregla: con un campo de texto normal se veian a la vez los
/// puntos, la linea de escritura y el digito recien tecleado, asi que el PIN
/// quedaba medio a la vista mientras se escribia.
void main() {
  Future<String> pumpPad(WidgetTester tester, {String initial = ''}) async {
    var value = initial;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(),
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Center(
              child: PinPad(
                value: value,
                onChanged: (next) => setState(() => value = next),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return value;
  }

  /// Cuantos puntos hay pintados ahora mismo.
  int dots(WidgetTester tester) =>
      tester.widget<PinDots>(find.byType(PinDots)).length;

  testWidgets('el digito tecleado no se ensena en ningun sitio', (
    tester,
  ) async {
    await pumpPad(tester);

    await tester.tap(find.widgetWithText(InkWell, '7'));
    await tester.pumpAndSettle();

    // El «7» del teclado sigue ahi, pero no aparece una segunda vez como
    // texto introducido, ni hay campo de texto donde pudiera verse.
    expect(find.text('7'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(EditableText), findsNothing);
    expect(dots(tester), 1);
  });

  testWidgets('cada pulsacion llena un punto', (tester) async {
    await pumpPad(tester);

    for (final digit in ['1', '2', '3']) {
      await tester.tap(find.widgetWithText(InkWell, digit));
      await tester.pumpAndSettle();
    }

    expect(dots(tester), 3);
  });

  testWidgets('borrar quita el ultimo', (tester) async {
    await pumpPad(tester);

    await tester.tap(find.widgetWithText(InkWell, '1'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, '2'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();

    expect(dots(tester), 1);
  });

  testWidgets('borrar con el PIN vacio no rompe nada', (tester) async {
    await pumpPad(tester);

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pumpAndSettle();

    expect(dots(tester), 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no se puede pasar del maximo', (tester) async {
    await pumpPad(tester);

    // Nueve pulsaciones para un maximo de ocho.
    for (var i = 0; i < 9; i++) {
      await tester.tap(find.widgetWithText(InkWell, '1'));
      await tester.pumpAndSettle();
    }

    expect(dots(tester), AppLockService.maxLength);
  });

  testWidgets('siempre hay cuatro huecos, aunque no se haya tecleado nada', (
    tester,
  ) async {
    await pumpPad(tester);

    // El minimo del PIN es cuatro: ensenar menos huecos daria a entender que
    // vale con menos.
    expect(
      tester.widget<PinDots>(find.byType(PinDots)).slots,
      AppLockService.minLength,
    );
  });

  testWidgets('la huella solo aparece si hay a donde ir', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(),
        home: Scaffold(
          body: PinPad(value: '', onChanged: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.fingerprint), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(),
        home: Scaffold(
          body: PinPad(value: '', onChanged: (_) {}, onBiometric: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.fingerprint), findsOneWidget);
  });

  testWidgets('deshabilitado, las teclas no hacen nada', (tester) async {
    var pulsaciones = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(),
        home: Scaffold(
          body: PinPad(
            value: '',
            enabled: false,
            onChanged: (_) => pulsaciones++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(InkWell, '5'));
    await tester.pumpAndSettle();

    // Mientras se comprueba el PIN, seguir tecleando solo confundiria.
    expect(pulsaciones, 0);
  });

  testWidgets('el teclado cabe dentro de un dialogo en un movil estrecho', (
    tester,
  ) async {
    // 360 dp es el ancho de un movil normal; un AlertDialog deja bastante
    // menos para su contenido. Con teclas de tamano fijo, las de los lados se
    // salian del dialogo y no se podian pulsar.
    tester.view.physicalSize = const Size(360 * 3, 760 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('PIN'),
                  content: PinPad(value: '', onChanged: (_) {}),
                ),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'no debe desbordar');

    // Y las teclas de los extremos siguen respondiendo.
    await tester.tap(find.widgetWithText(InkWell, '1'));
    await tester.tap(find.widgetWithText(InkWell, '3'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
