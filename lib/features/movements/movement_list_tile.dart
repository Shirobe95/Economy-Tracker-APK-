import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/status_indicator.dart';

/// Fila de movimiento en un listado.
///
/// Cuando la lista mezcla entradas y salidas de dinero, el importe lleva
/// signo y color; cuando es de un solo tipo, el color va en el indicador de
/// estado y el importe queda neutro. Es el criterio de DEC-007 ante la
/// divergencia que reporta el Pack visual.
class MovementListTile extends StatelessWidget {
  const MovementListTile({
    super.key,
    required this.movement,
    this.subtitle,
    this.mixedDirections = false,
  });

  final Transaction movement;

  /// Texto secundario: categoria, cliente o fuente, segun la pantalla.
  final String? subtitle;
  final bool mixedDirections;

  @override
  Widget build(BuildContext context) {
    final isIncome = movement.type.isIncome;
    final signedAmount = isIncome ? movement.amount : -movement.amount;

    return Material(
      color: AppTokens.surface,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        onTap: () => context.push('/movimientos/${movement.id}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            border: Border.all(color: AppTokens.border),
          ),
          padding: const EdgeInsets.all(AppTokens.space3),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  formatDay(movement.expectedDate).substring(0, 6),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movement.concept,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.space2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(
                    mixedDirections ? signedAmount : movement.amount,
                    currency: movement.currency,
                    signed: mixedDirections,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        movement.status.icon,
                        size: 14,
                        color: movement.status.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        movement.status.label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: movement.status.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
