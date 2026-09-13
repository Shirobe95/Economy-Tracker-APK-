import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../database/enums.dart';

/// Color y rotulo de cada estado de movimiento.
///
/// Centralizado aqui para que "pendiente" tenga el mismo ambar en todas las
/// pantallas y no se reinterprete pantalla a pantalla.
extension MovementStatusStyle on MovementStatus {
  String get label => switch (this) {
    MovementStatus.previsto => 'Previsto',
    MovementStatus.pendiente => 'Pendiente',
    MovementStatus.pagado => 'Pagado',
    MovementStatus.cobrado => 'Cobrado',
    MovementStatus.cancelado => 'Cancelado',
  };

  Color get color => switch (this) {
    MovementStatus.previsto => AppTokens.forecast,
    MovementStatus.pendiente => AppTokens.pending,
    MovementStatus.pagado => AppTokens.positive,
    MovementStatus.cobrado => AppTokens.positive,
    MovementStatus.cancelado => AppTokens.textMuted,
  };

  IconData get icon => switch (this) {
    MovementStatus.previsto => Icons.schedule_outlined,
    MovementStatus.pendiente => Icons.access_time_rounded,
    MovementStatus.pagado => Icons.check_circle_outline_rounded,
    MovementStatus.cobrado => Icons.check_circle_outline_rounded,
    MovementStatus.cancelado => Icons.block_outlined,
  };
}

/// Punto de color con el nombre del estado.
class StatusIndicator extends StatelessWidget {
  const StatusIndicator(this.status, {super.key});

  final MovementStatus status;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: status.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppTokens.space2),
        Text(
          status.label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: status.color),
        ),
      ],
    );
  }
}

/// Etiqueta con borde, como los chips "Recurrente" y "Pendiente" de UI-03.
class StatusChip extends StatelessWidget {
  const StatusChip(this.label, {super.key, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.55)),
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: color, fontSize: 12),
      ),
    );
  }
}
