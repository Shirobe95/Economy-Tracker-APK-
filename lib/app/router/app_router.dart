import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_shell.dart';
import '../../features/accounts/accounts_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/expenses/expenses_screen.dart';
import '../../features/forecast/forecast_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/income/income_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/salaries/salaries_screen.dart';
import '../../features/settings/settings_screen.dart';

/// Rutas de la aplicacion.
///
/// Las cuatro pestanas principales viven en el shell y se cambian con `go`.
/// Las pantallas secundarias y la creacion rapida se abren con `push`, para
/// que volver atras conserve la pestana de origen.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => _Shell(state: state, child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/gastos',
            builder: (context, state) => const ExpensesScreen(),
          ),
          GoRoute(
            path: '/ingresos',
            builder: (context, state) => const IncomeScreen(),
          ),
          GoRoute(
            path: '/prevision',
            builder: (context, state) => const ForecastScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/proyectos',
        builder: (context, state) => const ProjectsScreen(),
      ),
      GoRoute(
        path: '/salarios',
        builder: (context, state) => const SalariesScreen(),
      ),
      GoRoute(
        path: '/calendario',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/objetivos',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/cuentas',
        builder: (context, state) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/informes',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/categorias',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/ajustes',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => _RouteNotFound(location: state.uri.path),
  );
}

class _Shell extends StatelessWidget {
  const _Shell({required this.state, required this.child});

  final GoRouterState state;
  final Widget child;

  int get _currentIndex {
    final location = state.uri.path;
    final index = shellDestinations.indexWhere(
      (d) => d.route != '/' && location.startsWith(d.route),
    );
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: _currentIndex,
      onDestinationSelected: (index) =>
          context.go(shellDestinations[index].route),
      onCreatePressed: () => context.push('/nuevo-movimiento'),
      child: child,
    );
  }
}

/// Ruta desconocida: siempre con una salida visible hacia Inicio.
class _RouteNotFound extends StatelessWidget {
  const _RouteNotFound({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagina no encontrada')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No existe la ruta $location'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Volver a Inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
