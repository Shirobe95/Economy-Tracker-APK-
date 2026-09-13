import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/utils/dates.dart';
import '../../core/widgets/feature_placeholder.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/section_header.dart';
import '../../data/recurrence_schedule.dart';
import '../../data/recurring_rule_repository.dart';
import 'expenses_screen.dart';

/// Listado de reglas recurrentes con sus proximas fechas.
///
/// Estas fechas son un calendario, no movimientos: no existen en la base y
/// consultarlas no crea nada.
class RecurringRulesView extends ConsumerWidget {
  const RecurringRulesView({super.key, required this.type});

  final MovementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(rulesProvider(type));

    return rules.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('No se han podido cargar las reglas: $error')),
      data: (rows) {
        if (rows.isEmpty) {
          return Center(
            child: EmptyState(
              message:
                  'No hay reglas recurrentes.\nUna regla repite un gasto sin '
                  'tener que anotarlo cada mes.',
              icon: Icons.repeat_rounded,
              action: FilledButton(
                onPressed: () => context.push('/reglas/nueva'),
                child: const Text('Crear regla'),
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
            for (final rule in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.space3),
                child: _RuleCard(rule: rule),
              ),
            const SizedBox(height: AppTokens.space3),
            OutlinedButton.icon(
              onPressed: () => context.push('/reglas/nueva'),
              icon: const Icon(Icons.add),
              label: const Text('Nueva regla'),
            ),
          ],
        );
      },
    );
  }
}

class _RuleCard extends ConsumerWidget {
  const _RuleCard({required this.rule});

  final RecurringRule rule;

  String get _frequencyLabel {
    final every = rule.intervalCount;
    return switch (rule.frequency) {
      RecurrenceFrequency.daily => every == 1 ? 'Cada dia' : 'Cada $every dias',
      RecurrenceFrequency.weekly =>
        every == 1 ? 'Cada semana' : 'Cada $every semanas',
      RecurrenceFrequency.monthly =>
        every == 1 ? 'Cada mes' : 'Cada $every meses',
      RecurrenceFrequency.yearly =>
        every == 1 ? 'Cada ano' : 'Cada $every anos',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = RecurrenceSchedule.fromRule(rule)
        .upcoming(from: Dates.today(), count: 6);

    return FinanceCard(
      onTap: () => context.push('/reglas/${rule.id}/editar'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.concept,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      _frequencyLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              MoneyText(rule.amount, currency: rule.currency),
              Switch(
                value: rule.isActive,
                onChanged: (value) => ref
                    .read(recurringRuleRepositoryProvider)
                    .setActive(rule.id, value),
              ),
            ],
          ),
          if (rule.isActive && upcoming.isNotEmpty) ...[
            const Divider(height: AppTokens.space5),
            const SectionHeader('Proximas fechas'),
            const SizedBox(height: AppTokens.space2),
            Wrap(
              spacing: AppTokens.space2,
              runSpacing: AppTokens.space2,
              children: [
                for (final date in upcoming)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space3,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTokens.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                      border: Border.all(color: AppTokens.border),
                    ),
                    child: Text(
                      formatDay(date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ],
          if (!rule.isActive)
            Padding(
              padding: const EdgeInsets.only(top: AppTokens.space2),
              child: Text(
                'Inactiva: no genera proximas fechas.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}
