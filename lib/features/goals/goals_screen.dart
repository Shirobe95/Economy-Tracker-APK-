import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/feature_placeholder.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/section_header.dart';
import '../../core/utils/dates.dart';
import '../../data/movement_repository.dart';
import '../../data/report_engine.dart';
import '../../data/goal_repository.dart';

/// Objetivos de ahorro (UI-12).
///
/// Distingue lo que quieres alcanzar, lo que llevas ahorrado de verdad y a
/// que ritmo aportas. No convierte el dinero sobrante en ahorro por su
/// cuenta: el ahorro real lo declaras tu (DEC-003).
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Objetivos')),
      body: goals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(
              child: EmptyState(
                message:
                    'Todavia no tienes objetivos.\nUn objetivo es una meta de '
                    'ahorro concreta: un fondo de emergencia, un viaje, un '
                    'portatil.',
                icon: Icons.adjust_rounded,
                action: FilledButton(
                  onPressed: () => context.push('/objetivos/nuevo'),
                  child: const Text('Crear objetivo'),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space4,
              0,
              AppTokens.space4,
              96,
            ),
            children: [
              for (final goal in rows)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.space3),
                  child: _GoalCard(goal: goal),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/objetivos/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo objetivo'),
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});

  final GoalProgress goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratio = goal.ratio;
    final months = goal.monthsToTarget;

    return FinanceCard(
      onTap: () => context.push('/objetivos/${goal.goal.id}/editar'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RoundIcon(
                goal.isMonthly
                    ? Icons.event_repeat_outlined
                    : Icons.savings_outlined,
                color: AppTokens.accent,
              ),
              const SizedBox(width: AppTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.goal.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          goal.isMonthly ? 'Cada mes ' : 'Objetivo ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        MoneyText(
                          goal.goal.targetAmount,
                          currency: goal.goal.currency,
                          compact: true,
                          style: Theme.of(context).textTheme.bodySmall,
                          color: AppTokens.accentBright,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (ratio != null)
                Text(
                  '${(ratio * 100).round()} %',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(color: AppTokens.accentBright),
                ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          if (goal.current == null)
            _DeclareSavings(goal: goal)
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                MoneyText(
                  goal.current!,
                  currency: goal.goal.currency,
                  compact: true,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(width: AppTokens.space2),
                Text(
                  goal.isMonthly ? 'este mes' : 'ahorrado',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppTokens.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space3),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              child: LinearProgressIndicator(value: ratio, minHeight: 8),
            ),
            const SizedBox(height: AppTokens.space3),
            if (goal.isMonthly)
              _MonthlyFooter(goal: goal)
            else
              Row(
                children: [
                  if (goal.goal.monthlyContribution != null) ...[
                    Expanded(
                      child: _Detail(
                        icon: Icons.savings_outlined,
                        label: 'Aporte mensual',
                        value: goal.goal.monthlyContribution!,
                        currency: goal.goal.currency,
                      ),
                    ),
                    Container(width: 1, height: 36, color: AppTokens.border),
                  ],
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppTokens.space3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            months == null
                                ? 'Fecha estimada'
                                : months == 0
                                ? 'Objetivo alcanzado'
                                : 'Te faltan',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            months == null
                                ? 'Define un aporte mensual'
                                : months == 0
                                ? '¡Enhorabuena!'
                                : '$months ${months == 1 ? "mes" : "meses"}',
                            style: TextStyle(
                              color: months == null
                                  ? AppTokens.textMuted
                                  : AppTokens.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.icon,
    required this.label,
    required this.value,
    required this.currency,
  });

  final IconData icon;
  final String label;
  final int value;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        MoneyText(value, currency: currency, compact: true),
      ],
    );
  }
}

/// El objetivo existe pero nadie ha dicho cuanto lleva ahorrado.
///
/// No se rellena con cero: no saberlo y tener cero son cosas distintas.
class _DeclareSavings extends ConsumerWidget {
  const _DeclareSavings({required this.goal});

  final GoalProgress goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          goal.isMonthly
              ? 'Aun no has dicho cuanto has apartado este mes.'
              : 'Aun no has declarado cuanto llevas ahorrado para este '
                    'objetivo.',
          style: const TextStyle(color: AppTokens.textSecondary),
        ),
        const SizedBox(height: AppTokens.space3),
        OutlinedButton(
          onPressed: () => _declare(context, ref),
          child: Text(
            goal.isMonthly
                ? 'Declarar lo apartado este mes'
                : 'Declarar ahorro actual',
          ),
        ),
      ],
    );
  }

  Future<void> _declare(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final amount = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ahorro actual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cuanto tienes apartado ahora mismo para este objetivo.',
              style: TextStyle(color: AppTokens.textSecondary),
            ),
            const SizedBox(height: AppTokens.space4),
            AmountField(controller: controller, autofocus: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            // El importe pasa por el parser de dinero: nunca por un double.
            onPressed: () =>
                Navigator.of(context).pop(Money.tryParse(controller.text)),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (amount == null) return;

    await ref
        .read(goalRepositoryProvider)
        .declareCurrentAmount(goal.goal.id, amount);
  }
}

/// Pie de un objetivo mensual.
///
/// Enseña lo que ha sobrado este mes junto a lo apartado, pero sin sumarlo:
/// que sobre dinero no significa que se haya ahorrado (DEC-003). Es una
/// referencia para decidir cuanto apartar, no el dato del objetivo.
class _MonthlyFooter extends ConsumerWidget {
  const _MonthlyFooter({required this.goal});

  final GoalProgress goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movements = ref.watch(allMovementsProvider).value;
    if (movements == null) return const SizedBox.shrink();

    final report = ReportEngine.build(
      movements: movements,
      categories: const [],
      reference: Dates.today(),
      range: ReportRange.month,
    );
    if (!report.hasData) return const SizedBox.shrink();

    final leftover = report.net;

    return Row(
      children: [
        Icon(
          leftover >= 0
              ? Icons.trending_up_rounded
              : Icons.trending_down_rounded,
          size: 16,
          color: leftover >= 0 ? AppTokens.positive : AppTokens.negative,
        ),
        const SizedBox(width: 6),
        Text(
          'Este mes te ha sobrado ',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        MoneyText(
          leftover,
          compact: true,
          signed: true,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
