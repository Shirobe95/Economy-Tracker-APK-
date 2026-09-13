import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/feature_placeholder.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/section_header.dart';
import '../../data/movement_repository.dart';
import '../../data/salary_repository.dart';
import '../movements/movement_list_tile.dart';

/// Salarios: fuentes y nominas (UI-09).
class SalariesScreen extends ConsumerWidget {
  const SalariesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sources = ref.watch(salarySourcesProvider);
    final movements = ref.watch(allMovementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nueva fuente salarial',
            onPressed: () => context.push('/salarios/fuentes/nueva'),
          ),
        ],
      ),
      body: sources.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (rows) {
          final salaries =
              (movements.value ?? const <Transaction>[])
                  .where((m) => m.type == MovementType.salary)
                  .toList()
                ..sort((a, b) => b.expectedDate.compareTo(a.expectedDate));

          if (rows.isEmpty && salaries.isEmpty) {
            return Center(
              child: EmptyState(
                message:
                    'Todavia no hay salarios.\nUna fuente salarial guarda el '
                    'importe esperado y cada cuanto cobras.',
                icon: Icons.badge_outlined,
                action: FilledButton(
                  onPressed: () => context.push('/salarios/fuentes/nueva'),
                  child: const Text('Crear fuente salarial'),
                ),
              ),
            );
          }

          final month = Dates.monthStart(Dates.today());
          final thisMonth = salaries.where(
            (m) =>
                !m.expectedDate.isBefore(month) &&
                m.expectedDate.isBefore(Dates.nextMonthStart(month)),
          );

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
                    const SectionHeader('Total del mes'),
                    const SizedBox(height: AppTokens.space2),
                    MoneyText(
                      Money.sum(thisMonth.map((m) => m.amount)) ?? 0,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ],
                ),
              ),
              if (rows.isNotEmpty) ...[
                const SizedBox(height: AppTokens.space5),
                const SectionHeader('Fuentes'),
                const SizedBox(height: AppTokens.space2),
                for (final source in rows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.space2),
                    child: _SourceCard(source: source),
                  ),
              ],
              const SizedBox(height: AppTokens.space5),
              const SectionHeader('Nominas'),
              const SizedBox(height: AppTokens.space2),
              if (salaries.isEmpty)
                const EmptyState(
                  message: 'No hay nominas registradas.',
                  icon: Icons.receipt_long_outlined,
                )
              else
                for (final salary in salaries.take(12))
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTokens.space2),
                    child: MovementListTile(movement: salary),
                  ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/salarios/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva nomina'),
      ),
    );
  }
}

class _SourceCard extends ConsumerWidget {
  const _SourceCard({required this.source});

  final SalarySource source;

  /// Lo que le falta a la fuente para poder proyectarse.
  List<String> get _missingForForecast => [
    if (source.expectedAmount == null || source.expectedAmount! <= 0)
      'el importe',
    if (source.frequency == null) 'la frecuencia',
    if (source.paymentDay == null) 'el dia de cobro',
  ];

  bool get _entersForecast => _missingForForecast.isEmpty;

  String? get _frequencyLabel => switch (source.frequency) {
    RecurrenceFrequency.daily => 'Cada dia',
    RecurrenceFrequency.weekly => 'Cada semana',
    RecurrenceFrequency.monthly => 'Cada mes',
    RecurrenceFrequency.yearly => 'Cada ano',
    null => null,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FinanceCard(
      onTap: () => context.push('/salarios/fuentes/${source.id}/editar'),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    ?_frequencyLabel,
                    if (source.paymentDay != null) 'dia ${source.paymentDay}',
                    if (!source.isActive) 'Inactiva',
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (source.isActive && !_entersForecast) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 13,
                        color: AppTokens.pending,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'No entra en la prevision: le falta '
                          '${_missingForForecast.join(' y ')}.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTokens.pending,
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (source.expectedAmount != null)
            MoneyText(
              source.expectedAmount!,
              currency: source.currency,
              compact: true,
            )
          else
            const Text(
              'Sin importe',
              style: TextStyle(color: AppTokens.textMuted),
            ),
        ],
      ),
    );
  }
}
