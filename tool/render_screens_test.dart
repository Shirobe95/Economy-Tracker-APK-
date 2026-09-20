import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:economy_tracker/app/theme/app_theme.dart';
import 'package:economy_tracker/core/database/app_database.dart';
import 'package:economy_tracker/core/database/database_provider.dart';
import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/features/calendar/calendar_screen.dart';
import 'package:economy_tracker/features/dashboard/dashboard_screen.dart';
import 'package:economy_tracker/features/expenses/expenses_screen.dart';
import 'package:economy_tracker/features/forecast/forecast_screen.dart';
import 'package:economy_tracker/features/goals/goals_screen.dart';
import 'package:economy_tracker/features/income/income_screen.dart';
import 'package:economy_tracker/features/movements/movements_screen.dart';
import 'package:economy_tracker/features/projects/projects_screen.dart';
import 'package:economy_tracker/features/reports/reports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Renderiza las pantallas principales a PNG para poder revisar el estilo sin
/// instalar la aplicacion.
///
/// Los datos son sinteticos y existen solo aqui: no hay semillas en la
/// aplicacion. Estas imagenes son una ayuda de revision, no sustituyen la
/// prueba en un Android real.
///
/// Se ejecuta a proposito con `flutter test tool/render_screens_test.dart`, y
/// queda fuera de la carpeta test/ para que no corra en cada suite.
void main() {
  late Directory output;

  setUpAll(() async {
    // El historico de objetivos necesita saber desde cuando hay seguimiento,
    // y eso vive en preferencias.
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    await initializeDateFormatting('es_ES');
    await _loadRealFonts();
    output = Directory('docs/screenshots')..createSync(recursive: true);
  });

  Future<AppDatabase> seed() async {
    final db = openInMemoryDatabase();

    final account = await db
        .into(db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Cuenta principal',
            type: AccountType.bank,
            currency: 'EUR',
            initialBalance: const Value(432000),
          ),
        );

    Future<int> category(String name) => db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(name: name, kind: CategoryKind.expense),
        );

    final vivienda = await category('Vivienda');
    final suscripciones = await category('Suscripciones');
    final servicios = await category('Servicios');
    final alimentacion = await category('Alimentacion');

    final now = DateTime.now();
    DateTime day(int d) => DateTime.utc(now.year, now.month, d);

    // La regla del alquiler se crea antes que su gasto para poder enlazarlos.
    // Sin enlazar, la ocurrencia de este mes saldria como pendiente al lado
    // del alquiler ya pagado: el mismo recibo contado dos veces.
    final reglaAlquiler = await db
        .into(db.recurringRules)
        .insert(
          RecurringRulesCompanion.insert(
            concept: 'Alquiler',
            type: MovementType.expense,
            accountId: account,
            amount: 85000,
            currency: 'EUR',
            frequency: RecurrenceFrequency.monthly,
            startDate: day(3),
            categoryId: Value(vivienda),
            intervalCount: const Value(1),
          ),
        );

    Future<void> expense(
      String concept,
      int amount,
      int d,
      MovementStatus status,
      int? categoryId, {
      int? ruleId,
    }) => db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: MovementType.expense,
            status: status,
            concept: concept,
            amount: amount,
            currency: 'EUR',
            accountId: account,
            categoryId: Value(categoryId),
            recurringRuleId: Value(ruleId),
            expectedDate: day(d),
            actualDate: Value(status == MovementStatus.pagado ? day(d) : null),
          ),
        );

    await expense(
      'Alquiler',
      85000,
      3,
      MovementStatus.pagado,
      vivienda,
      ruleId: reglaAlquiler,
    );
    await expense('Spotify', 1199, 12, MovementStatus.pagado, suscripciones);
    await expense('Internet', 3200, 14, MovementStatus.pagado, servicios);
    await expense(
      'Supermercado',
      18600,
      16,
      MovementStatus.pendiente,
      alimentacion,
    );
    await expense('Gimnasio', 3900, 18, MovementStatus.pendiente, null);

    Future<void> income(
      String concept,
      int amount,
      int d,
      MovementType type,
      MovementStatus status,
    ) => db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            type: type,
            status: status,
            concept: concept,
            amount: amount,
            currency: 'EUR',
            accountId: account,
            expectedDate: day(d),
            actualDate: Value(status == MovementStatus.cobrado ? day(d) : null),
          ),
        );

    await income(
      'Nomina',
      180000,
      1,
      MovementType.salary,
      MovementStatus.cobrado,
    );
    await income(
      'Mensualidad',
      5000,
      5,
      MovementType.otherIncome,
      MovementStatus.pendiente,
    );

    final clientId = await db
        .into(db.clients)
        .insert(ClientsCompanion.insert(name: 'Futon Espai'));
    final projectId = await db
        .into(db.projects)
        .insert(
          ProjectsCompanion.insert(
            clientId: clientId,
            name: 'Modulo lectura',
            currency: 'EUR',
            estimatedAmount: const Value(140000),
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
            accountId: account,
            projectId: Value(projectId),
            clientId: Value(clientId),
            expectedDate: day(22),
          ),
        );
    await db
        .into(db.clients)
        .insert(ClientsCompanion.insert(name: 'Estudio Kaiba'));

    await db
        .into(db.recurringRules)
        .insert(
          RecurringRulesCompanion.insert(
            concept: 'Nomina',
            type: MovementType.salary,
            accountId: account,
            amount: 180000,
            currency: 'EUR',
            frequency: RecurrenceFrequency.monthly,
            startDate: day(1),
            intervalCount: const Value(1),
          ),
        );

    await db
        .into(db.savingsGoals)
        .insert(
          SavingsGoalsCompanion.insert(
            name: 'Fondo de emergencia',
            targetAmount: 600000,
            currency: 'EUR',
            currentAmount: const Value(325000),
            monthlyContribution: const Value(50000),
          ),
        );
    await db
        .into(db.savingsGoals)
        .insert(
          SavingsGoalsCompanion.insert(
            name: 'Portatil',
            targetAmount: 150000,
            currency: 'EUR',
            currentAmount: const Value(45000),
            monthlyContribution: const Value(15000),
          ),
        );
    await db
        .into(db.savingsGoals)
        .insert(
          SavingsGoalsCompanion.insert(
            name: 'Ahorro del mes',
            kind: const Value(SavingsGoalKind.monthly),
            targetAmount: 20000,
            currency: 'EUR',
            currentAmount: const Value(12000),
            // Dos meses acumulados, para que la captura de Inicio ensene el
            // reparto entre disponible y apartado.
            startMonth: Value(DateTime.utc(now.year, now.month - 1)),
          ),
        );

    return db;
  }

  Future<void> capture(WidgetTester tester, String name, Widget screen) async {
    final db = await seed();
    final key = GlobalKey();

    tester.view.physicalSize = const Size(1080, 2160);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.build(),
            locale: const Locale('es', 'ES'),
            home: screen,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = boundary.toImageSync(pixelRatio: 2);
    // La codificacion a PNG es trabajo asincrono real: dentro del reloj
    // simulado del test no completaria nunca.
    final bytes = await tester.runAsync(
      () => image.toByteData(format: ui.ImageByteFormat.png),
    );
    File('${output.path}/$name.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
    image.dispose();

    await tester.pumpWidget(const SizedBox.shrink());
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
    await db.close();
  }

  testWidgets(
    'inicio',
    (t) => capture(t, '01-inicio', const DashboardScreen()),
  );
  testWidgets('gastos', (t) => capture(t, '02-gastos', const ExpensesScreen()));
  testWidgets(
    'ingresos',
    (t) => capture(t, '03-ingresos', const IncomeScreen()),
  );
  testWidgets(
    'prevision',
    (t) => capture(t, '04-prevision', const ForecastScreen()),
  );
  testWidgets(
    'objetivos',
    (t) => capture(t, '05-objetivos', const GoalsScreen()),
  );
  testWidgets(
    'clientes',
    (t) => capture(t, '06-clientes', const ProjectsScreen()),
  );
  testWidgets(
    'calendario',
    (t) => capture(t, '07-calendario', const CalendarScreen()),
  );
  testWidgets(
    'informes',
    (t) => capture(t, '08-informes', const ReportsScreen()),
  );
  testWidgets(
    'movimientos',
    (t) => capture(t, '09-movimientos', const MovementsScreen()),
  );
}

/// Carga Roboto y los iconos de Material desde el propio SDK de Flutter.
///
/// Sin esto, `flutter test` dibuja cada glifo como un rectangulo y la captura
/// no sirve para revisar nada.
Future<void> _loadRealFonts() async {
  // Sube desde el ejecutable de Dart hasta dar con el cache del SDK: la
  // profundidad exacta cambia entre versiones de Flutter.
  Directory? fonts;
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 8; i++) {
    final candidate = Directory('${dir.path}/artifacts/material_fonts');
    if (candidate.existsSync()) {
      fonts = candidate;
      break;
    }
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }
  final fontsDir = fonts;
  if (fontsDir == null) {
    throw StateError(
      'No encuentro material_fonts subiendo desde '
      '${Platform.resolvedExecutable}',
    );
  }

  ByteData read(String name) =>
      File('${fontsDir.path}/$name').readAsBytesSync().buffer.asByteData();

  final roboto = FontLoader('Roboto');
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    roboto.addFont(Future.value(read('Roboto-$weight.ttf')));
  }
  await roboto.load();

  final icons = FontLoader('MaterialIcons')
    ..addFont(Future.value(read('MaterialIcons-Regular.otf')));
  await icons.load();
}
