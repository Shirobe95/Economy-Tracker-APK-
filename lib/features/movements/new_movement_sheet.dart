import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/enums.dart';
import '../../core/widgets/section_header.dart';

/// Opcion de la hoja de creacion rapida (UI-02).
class _MovementOption {
  const _MovementOption({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });

  final MovementType type;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
}

const _options = <_MovementOption>[
  _MovementOption(
    type: MovementType.expense,
    title: 'Gasto',
    description: 'Anade un gasto o pago',
    icon: Icons.arrow_downward_rounded,
    color: AppTokens.negative,
    route: '/gastos/nuevo',
  ),
  _MovementOption(
    type: MovementType.otherIncome,
    title: 'Ingreso',
    description: 'Anade un ingreso recibido',
    icon: Icons.arrow_upward_rounded,
    color: AppTokens.positive,
    route: '/ingresos/nuevo',
  ),
  _MovementOption(
    type: MovementType.projectIncome,
    title: 'Cobro de proyecto',
    description: 'Registra el cobro de un cliente',
    icon: Icons.euro_rounded,
    color: AppTokens.accent,
    route: '/proyectos/cobros/nuevo',
  ),
  _MovementOption(
    type: MovementType.salary,
    title: 'Salario',
    description: 'Anade una nomina',
    icon: Icons.badge_outlined,
    color: AppTokens.forecast,
    route: '/salarios/nuevo',
  ),
  _MovementOption(
    type: MovementType.transfer,
    title: 'Transferencia',
    description: 'Entre cuentas propias',
    icon: Icons.swap_horiz_rounded,
    color: AppTokens.pending,
    route: '/movimientos/transferencia',
  ),
];

/// Hoja de creacion rapida que abre la accion central.
class NewMovementSheet extends StatelessWidget {
  const NewMovementSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space4,
        0,
        AppTokens.space4,
        AppTokens.space5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.space4),
            child: Text(
              'Nuevo movimiento',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final option in _options) ...[
            _OptionTile(option: option),
            const SizedBox(height: AppTokens.space2),
          ],
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.option});

  final _MovementOption option;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surface,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        onTap: () {
          // Cierra la hoja antes de navegar, para que volver atras deje la
          // pestana de origen y no la hoja.
          Navigator.of(context).pop();
          context.push(option.route);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space3),
          child: Row(
            children: [
              RoundIcon(option.icon, color: option.color),
              const SizedBox(width: AppTokens.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      option.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
