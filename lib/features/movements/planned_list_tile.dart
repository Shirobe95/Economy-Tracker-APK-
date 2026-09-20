import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/enums.dart';
import '../../core/utils/dates.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/status_indicator.dart';
import '../../data/movement_repository.dart';
import '../../data/planned_repository.dart';
import '../../data/recurring_rule_repository.dart';

/// Fila de un compromiso previsto, venga de un movimiento o de una regla.
///
/// Las dos procedencias se pintan igual a proposito: quien mira lo que le
/// queda por pagar este mes no necesita saber cual de las dos es. La
/// diferencia se reduce a una etiqueta «Recurrente» y a donde lleva el toque.
class PlannedListTile extends ConsumerWidget {
  const PlannedListTile({
    super.key,
    required this.item,
    this.mixedDirections = true,
    this.quickAction = true,
  });

  final PlannedItem item;

  /// La lista mezcla entradas y salidas: el importe lleva signo y color.
  final bool mixedDirections;

  /// Anade el boton de darlo por pagado o cobrado hoy.
  final bool quickAction;

  Future<void> _settle(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final today = Dates.today();
    final verbo = item.type.isIncome ? 'cobrado' : 'pagado';

    try {
      final movement = item.movement;
      if (movement != null) {
        final previous = movement.status;
        await ref
            .read(movementRepositoryProvider)
            .markRealised(movement.id, today);

        messenger.showSnackBar(
          SnackBar(
            content: Text('${item.concept}: $verbo hoy'),
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () => ref
                  .read(movementRepositoryProvider)
                  .revertToStatus(movement.id, previous),
            ),
          ),
        );
        return;
      }

      // Ocurrencia de regla sin fila propia: se crea ya marcada y enlazada a
      // su regla, que es lo que evita que la prevision la cuente otra vez.
      final id = await ref
          .read(recurringRuleRepositoryProvider)
          .settleOccurrence(
            rule: item.rule!,
            occurrence: item.date,
            actualDate: today,
          );

      messenger.showSnackBar(
        SnackBar(
          content: Text('${item.concept}: $verbo hoy'),
          action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () => ref.read(movementRepositoryProvider).purge(id),
          ),
        ),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se ha podido marcar: $error')),
      );
    }
  }

  void _open(BuildContext context) {
    final movement = item.movement;
    if (movement != null) {
      context.push('/movimientos/${movement.id}');
    } else {
      context.push('/reglas/${item.rule!.id}/editar');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = item.type.isIncome;
    final overdue = item.isOverdue(Dates.today());
    // Una transferencia no entra ni sale del patrimonio: va sin signo.
    final withSign = mixedDirections && !item.type.isTransfer;
    final signedAmount = isIncome ? item.amount : -item.amount;

    return Material(
      color: AppTokens.surface,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        onTap: () => _open(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            // Un recibo vencido y sin pagar se marca en el borde: es lo unico
            // de esta lista sobre lo que hay que hacer algo ya.
            border: Border.all(
              color: overdue ? AppTokens.negative : AppTokens.border,
            ),
          ),
          padding: const EdgeInsets.all(AppTokens.space3),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                child: Text(
                  formatDay(item.date).substring(0, 6),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.concept,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.isProjected)
                      Row(
                        children: [
                          const Icon(
                            Icons.repeat_rounded,
                            size: 12,
                            color: AppTokens.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Recurrente',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.space2),
              if (quickAction)
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
                    withSign ? signedAmount : item.amount,
                    currency: item.currency,
                    signed: withSign,
                  ),
                  const SizedBox(height: 2),
                  _StatusLine(item: item, overdue: overdue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.item, required this.overdue});

  final PlannedItem item;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    final status = item.movement?.status ?? MovementStatus.previsto;
    final color = overdue ? AppTokens.negative : status.color;
    final label = overdue ? 'Vencido' : status.label;
    final icon = overdue ? Icons.error_outline_rounded : status.icon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: color, fontSize: 12),
        ),
      ],
    );
  }
}
