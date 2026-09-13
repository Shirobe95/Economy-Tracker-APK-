import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Raiz de la aplicacion.
class EconomyTrackerApp extends StatefulWidget {
  const EconomyTrackerApp({super.key});

  @override
  State<EconomyTrackerApp> createState() => _EconomyTrackerAppState();
}

class _EconomyTrackerAppState extends State<EconomyTrackerApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Economy Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      // Interfaz y selectores de fecha en espanol.
      locale: const Locale('es', 'ES'),
      supportedLocales: const [Locale('es', 'ES')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: _router,
    );
  }
}
