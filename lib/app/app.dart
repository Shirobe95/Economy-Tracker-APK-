import 'package:flutter/material.dart';

import '../core/theme/paliko_theme.dart';
import '../features/design_system/design_system_screen.dart';

/// Raíz de la aplicación.
///
/// De momento arranca en la pantalla de referencia del sistema visual; se
/// sustituirá por la navegación principal cuando se cierre el alcance
/// funcional.
class EconomyTrackerApp extends StatelessWidget {
  const EconomyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Economy Tracker',
      debugShowCheckedModeBanner: false,
      theme: PalikoTheme.dark,
      darkTheme: PalikoTheme.dark,
      themeMode: ThemeMode.dark,
      home: const DesignSystemScreen(),
    );
  }
}
