import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/enums.dart';
import '../../core/widgets/app_shell.dart';
import '../../features/accounts/accounts_screen.dart';
import '../../features/backup/backup_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/expenses/expenses_screen.dart';
import '../../features/expenses/recurring_rule_form_screen.dart';
import '../../features/forecast/forecast_screen.dart';
import '../../features/goals/goal_form_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/income/income_screen.dart';
import '../../features/movements/movement_detail_screen.dart';
import '../../features/movements/movement_form_screen.dart';
import '../../features/movements/new_movement_sheet.dart';
import '../../features/projects/client_form_screen.dart';
import '../../features/projects/project_detail_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/salaries/salaries_screen.dart';
import '../../features/salaries/salary_source_form_screen.dart';
import '../../features/security/security_settings_screen.dart';
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
        path: '/gastos/nuevo',
        builder: (context, state) =>
            const MovementFormScreen(type: MovementType.expense),
      ),
      GoRoute(
        path: '/ingresos/nuevo',
        builder: (context, state) =>
            const MovementFormScreen(type: MovementType.otherIncome),
      ),
      GoRoute(
        path: '/salarios/nuevo',
        builder: (context, state) =>
            const MovementFormScreen(type: MovementType.salary),
      ),
      GoRoute(
        path: '/proyectos/cobros/nuevo',
        builder: (context, state) => MovementFormScreen(
          type: MovementType.projectIncome,
          projectId: int.tryParse(state.uri.queryParameters['proyecto'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/movimientos/transferencia',
        builder: (context, state) =>
            const MovementFormScreen(type: MovementType.transfer),
      ),
      GoRoute(
        path: '/movimientos/:id',
        builder: (context, state) => MovementDetailScreen(
          movementId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/movimientos/:id/editar',
        builder: (context, state) => MovementFormScreen(
          type: state.extra as MovementType? ?? MovementType.expense,
          movementId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/reglas/nueva',
        builder: (context, state) => const RecurringRuleFormScreen(),
      ),
      GoRoute(
        path: '/reglas/:id/editar',
        builder: (context, state) => RecurringRuleFormScreen(
          ruleId: int.parse(state.pathParameters['id']!),
        ),
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
        path: '/salarios/fuentes/nueva',
        builder: (context, state) => const SalarySourceFormScreen(),
      ),
      GoRoute(
        path: '/salarios/fuentes/:id/editar',
        builder: (context, state) => SalarySourceFormScreen(
          sourceId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/proyectos/clientes/nuevo',
        builder: (context, state) => const ClientFormScreen(),
      ),
      GoRoute(
        path: '/proyectos/clientes/:id',
        builder: (context, state) => ClientDetailScreen(
          clientId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/proyectos/clientes/:id/editar',
        builder: (context, state) =>
            ClientFormScreen(clientId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/proyectos/clientes/:id/proyectos/nuevo',
        builder: (context, state) =>
            ProjectFormScreen(clientId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/proyectos/detalle/:id',
        builder: (context, state) => ProjectDetailScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/proyectos/detalle/:id/editar',
        builder: (context, state) => ProjectFormScreen(
          projectId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/objetivos/nuevo',
        builder: (context, state) => const GoalFormScreen(),
      ),
      GoRoute(
        path: '/objetivos/:id/editar',
        builder: (context, state) =>
            GoalFormScreen(goalId: int.parse(state.pathParameters['id']!)),
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
      GoRoute(
        path: '/ajustes/copia',
        builder: (context, state) => const BackupScreen(),
      ),
      GoRoute(
        path: '/ajustes/bloqueo',
        builder: (context, state) => const SecuritySettingsScreen(),
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
      onCreatePressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (context) => const NewMovementSheet(),
      ),
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
