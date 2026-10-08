import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/feature_placeholder.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/section_header.dart';
import '../../data/recurring_rule_repository.dart';
import '../../data/project_repository.dart';
import '../expenses/recurring_rules_view.dart' show frequencyLabel;
import '../movements/movement_list_tile.dart';

/// Ficha de un proyecto con sus cobros (UI-07).
///
/// El importe de cada cobro es el neto que entra en la cuenta (DEC-006). El
/// importe orientativo del proyecto es una referencia, no se compara solo.
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider(projectId));
    final incomes = ref.watch(projectIncomesProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: Text(project.value?.name ?? 'Proyecto'),
        actions: [
          if (project.value != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'editar') {
                  context.push('/proyectos/detalle/$projectId/editar');
                } else {
                  ref
                      .read(projectRepositoryProvider)
                      .setProjectActive(projectId, !project.value!.isActive);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'editar', child: Text('Editar')),
                PopupMenuItem(
                  value: 'archivar',
                  child: Text(
                    project.value!.isActive ? 'Archivar' : 'Reactivar',
                  ),
                ),
              ],
            ),
        ],
      ),
      body: incomes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (rows) {
          final live = rows.where((t) => !t.isDeleted).toList();
          final collected =
              Money.sum(
                live.where((t) => t.status.isRealised).map((t) => t.amount),
              ) ??
              0;
          final pending =
              Money.sum(
                live
                    .where(
                      (t) =>
                          !t.status.isRealised && t.status.code != 'cancelado',
                    )
                    .map((t) => t.amount),
              ) ??
              0;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space4,
              0,
              AppTokens.space4,
              96,
            ),
            children: [
              FinanceCard(
                accent: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader('Cobrado'),
                    const SizedBox(height: AppTokens.space2),
                    MoneyText(
                      collected,
                      style: Theme.of(context).textTheme.displaySmall,
                      color: AppTokens.positive,
                    ),
                    if (pending > 0) ...[
                      const SizedBox(height: AppTokens.space2),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: AppTokens.pending,
                          ),
                          const SizedBox(width: 6),
                          MoneyText(
                            pending,
                            compact: true,
                            color: AppTokens.pending,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Text(
                            ' pendiente de cobro',
                            style: TextStyle(color: AppTokens.textSecondary),
                          ),
                        ],
                      ),
                    ],
                    if (project.value?.estimatedAmount != null) ...[
                      const Divider(height: AppTokens.space5),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Importe orientativo',
                              style: TextStyle(color: AppTokens.textSecondary),
                            ),
                          ),
                          MoneyText(
                            project.value!.estimatedAmount!,
                            currency: project.value!.currency,
                            compact: true,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space5),
              _FixedIncomeSection(projectId: projectId),
              const SizedBox(height: AppTokens.space5),
              const SectionHeader('Cobros'),
              const SizedBox(height: AppTokens.space2),
              if (live.isEmpty)
                const EmptyState(
                  message: 'Este proyecto no tiene cobros registrados.',
                  icon: Icons.euro_rounded,
                )
              else
                for (final income in live)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.space2),
                    child: MovementListTile(movement: income),
                  ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/proyectos/cobros/nuevo?proyecto=$projectId'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo cobro'),
      ),
    );
  }
}

final projectProvider = StreamProvider.family<Project?, int>(
  (ref, id) => ref.watch(projectRepositoryProvider).watchProject(id),
);

final projectIncomesProvider = StreamProvider.family<List<Transaction>, int>(
  (ref, id) => ref.watch(projectRepositoryProvider).watchIncomes(id),
);

/// Cobros fijos (reglas de tipo `project_income`) de un proyecto.
final projectFixedIncomeProvider =
    StreamProvider.family<List<RecurringRule>, int>(
      (ref, projectId) => ref
          .watch(recurringRuleRepositoryProvider)
          .watchRules(type: MovementType.projectIncome, projectId: projectId),
    );

/// Cobros fijos del proyecto (DEC-016): a diferencia de un cobro suelto, se
/// repiten solos y son los unicos que entran en la previsión.
class _FixedIncomeSection extends ConsumerWidget {
  const _FixedIncomeSection({required this.projectId});

  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(projectFixedIncomeProvider(projectId)).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Cobros fijos'),
        const SizedBox(height: AppTokens.space2),
        if (rules == null)
          const SizedBox.shrink()
        else if (rules.isEmpty)
          const EmptyState(
            message:
                'Sin cobros fijos. Un cobro fijo se repite solo y es el '
                'unico tipo de cobro que entra en la Prevision.',
            icon: Icons.repeat_rounded,
          )
        else
          for (final rule in rules)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: _FixedIncomeCard(rule: rule),
            ),
        const SizedBox(height: AppTokens.space2),
        OutlinedButton.icon(
          onPressed: () =>
              context.push('/proyectos/detalle/$projectId/cobros/fijo/nuevo'),
          icon: const Icon(Icons.add),
          label: const Text('Cobro fijo'),
        ),
      ],
    );
  }
}

class _FixedIncomeCard extends StatelessWidget {
  const _FixedIncomeCard({required this.rule});

  final RecurringRule rule;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      onTap: () => context.push('/reglas/${rule.id}/editar'),
      child: Row(
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
                  frequencyLabel(rule),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          MoneyText(rule.amount, currency: rule.currency),
          if (!rule.isActive) ...[
            const SizedBox(width: AppTokens.space2),
            const Text(
              'Inactiva',
              style: TextStyle(color: AppTokens.textMuted, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
