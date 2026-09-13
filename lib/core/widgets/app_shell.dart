import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

/// Destino de la barra de navegacion inferior.
class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

/// Los cuatro destinos principales (DEC-004). La accion central + no es un
/// destino: abre la hoja de creacion rapida y vuelve a la pestana de origen.
const shellDestinations = <ShellDestination>[
  ShellDestination(label: 'Inicio', icon: Icons.home_outlined, route: '/'),
  ShellDestination(
    label: 'Gastos',
    icon: Icons.pie_chart_outline,
    route: '/gastos',
  ),
  ShellDestination(
    label: 'Ingresos',
    icon: Icons.arrow_upward_rounded,
    route: '/ingresos',
  ),
  ShellDestination(
    label: 'Prevision',
    icon: Icons.show_chart_rounded,
    route: '/prevision',
  ),
];

/// Contenedor de las pestanas principales, con la barra inferior y la accion
/// central circular de los mockups.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onCreatePressed,
  });

  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomBar(
        currentIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        onCreatePressed: onCreatePressed,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onCreatePressed,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTokens.background,
        border: Border(top: BorderSide(color: AppTokens.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _tab(0),
              _tab(1),
              Expanded(
                child: Center(child: _CreateButton(onPressed: onCreatePressed)),
              ),
              _tab(2),
              _tab(3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(int index) => Expanded(
    child: _NavTab(
      destination: shellDestinations[index],
      selected: currentIndex == index,
      onTap: () => onDestinationSelected(index),
    ),
  );
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTokens.accentBright : AppTokens.textMuted;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Indicador superior de pestana activa, como en los mockups.
          Container(
            height: 2,
            width: 28,
            color: selected ? AppTokens.accentBright : Colors.transparent,
          ),
          const Spacer(),
          Icon(destination.icon, size: 22, color: color),
          const SizedBox(height: 2),
          Text(
            destination.label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Nuevo movimiento',
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: AppTokens.minTouchTarget,
          height: AppTokens.minTouchTarget,
          decoration: const BoxDecoration(
            color: AppTokens.accent,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
