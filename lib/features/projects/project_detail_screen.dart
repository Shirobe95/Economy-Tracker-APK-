import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/feature_placeholder.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/section_header.dart';
import '../../data/project_repository.dart';
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
