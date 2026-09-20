import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/enums.dart';
import '../../core/utils/dates.dart';
import '../../data/movement_repository.dart';

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
class MovementListTile extends ConsumerWidget {
  const MovementListTile({
    super.key,
    required this.movement,
    this.subtitle,
    this.mixedDirections = false,
    this.quickAction = false,
    this.showActualDate = false,
  });

  final Transaction movement;

  /// Texto secundario: categoria, cliente o fuente, segun la pantalla.
  final String? subtitle;
  final bool mixedDirections;

  /// Anade un boton para darlo por pagado o cobrado sin abrir el detalle.
  final bool quickAction;

  /// Usa la fecha real en vez de la prevista.
  ///
  /// En un historial interesa cuando se movio el dinero; en un listado de
  /// pendientes, cuando toca moverlo.
  final bool showActualDate;

  bool get _canSettle =>
      quickAction &&
      !movement.status.isRealised &&
      movement.status != MovementStatus.cancelado;

  /// Marca el movimiento con la fecha de hoy.
  ///
  /// Para la mayoria de veces es la fecha correcta, y ahorra un formulario.
  /// Si no lo es, el aviso ofrece deshacerlo en el momento.
  Future<void> _settle(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(movementRepositoryProvider);
    final previousStatus = movement.status;

    try {
      await repository.markRealised(movement.id, Dates.today());
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            movement.type.isIncome
                ? '${movement.concept}: cobrado hoy'
                : '${movement.concept}: pagado hoy',
          ),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () =>
                repository.revertToStatus(movement.id, previousStatus),
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se ha podido marcar: $error')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = movement.type.isIncome;
    // Una transferencia mueve dinero propio entre cuentas: no entra ni sale
    // del patrimonio, asi que pintarla en rojo con un menos delante seria
    // contarla como un gasto que no es.
    final signed = mixedDirections && !movement.type.isTransfer;
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
                  formatDay(
                    showActualDate
                        ? (movement.actualDate ?? movement.expectedDate)
                        : movement.expectedDate,
                  ).substring(0, 6),
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
              if (_canSettle)
                IconButton(
                  onPressed: () => _settle(context, ref),
                  visualDensity: VisualDensity.compact,
                  tooltip: isIncome ? 'Marcar cobrado' : 'Marcar pagado',
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppTokens.accentBright,
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(
                    signed ? signedAmount : movement.amount,
                    currency: movement.currency,
                    signed: signed,
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
