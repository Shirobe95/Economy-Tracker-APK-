import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/feature_placeholder.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/section_header.dart';
import '../../data/movement_repository.dart';
import 'movement_list_tile.dart';

/// Que movimientos se ven.
enum MovementFilter {
  all('Todos'),
  pending('Pendientes'),
  expenses('Gastos'),
  income('Ingresos');

  const MovementFilter(this.label);

  final String label;

  bool matches(Transaction movement) => switch (this) {
    MovementFilter.all => true,
    MovementFilter.pending =>
      !movement.status.isRealised &&
          movement.status != MovementStatus.cancelado,
    MovementFilter.expenses => movement.type.isExpense,
    MovementFilter.income => movement.type.isIncome,
  };
}

/// Todos los movimientos, de todas las secciones y todos los meses.
///
/// Las pestañas separan gastos de ingresos porque casi siempre se mira una
/// cosa u otra; esta pantalla es para cuando lo que hace falta es verlo todo
/// junto y buscar algo concreto.
class MovementsScreen extends ConsumerStatefulWidget {
  const MovementsScreen({super.key});

  @override
  ConsumerState<MovementsScreen> createState() => _MovementsScreenState();
}

class _MovementsScreenState extends ConsumerState<MovementsScreen> {
  final _search = TextEditingController();
  MovementFilter _filter = MovementFilter.all;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final movements = ref.watch(allMovementsProvider);
    final query = _search.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Movimientos')),
      body: movements.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (rows) {
          final visible =
              rows
                  .where(_filter.matches)
                  .where(
                    (m) =>
                        query.isEmpty ||
                        m.concept.toLowerCase().contains(query),
                  )
                  .toList()
                // Lo mas reciente primero: al buscar algo, casi siempre es
                // de hace poco.
                ..sort((a, b) => b.expectedDate.compareTo(a.expectedDate));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTokens.space4,
                  0,
                  AppTokens.space4,
                  AppTokens.space3,
                ),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar por concepto',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(_search.clear),
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space4,
                ),
                child: FilterChips<MovementFilter>(
                  options: MovementFilter.values,
                  selected: _filter,
                  labelOf: (f) => f.label,
                  onSelected: (value) => setState(() => _filter = value),
                ),
              ),
              const SizedBox(height: AppTokens.space3),
              Expanded(
                child: visible.isEmpty
                    ? FeaturePlaceholder(
                        title: rows.isEmpty
                            ? 'Todavia no hay movimientos'
                            : 'Nada coincide',
                        description: rows.isEmpty
                            ? 'Cuando anotes tu primer gasto o ingreso, '
                                  'aparecera aqui.'
                            : 'Prueba con otro texto u otro filtro.',
                        icon: Icons.receipt_long_outlined,
                      )
                    : _GroupedList(movements: visible),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Lista agrupada por mes, con el total de cada uno.
class _GroupedList extends StatelessWidget {
  const _GroupedList({required this.movements});

  final List<Transaction> movements;

  @override
  Widget build(BuildContext context) {
    final byMonth = <DateTime, List<Transaction>>{};
    for (final movement in movements) {
      final month = DateTime.utc(
        movement.expectedDate.year,
        movement.expectedDate.month,
      );
      byMonth.putIfAbsent(month, () => []).add(movement);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space4,
        0,
        AppTokens.space4,
        AppTokens.space5,
      ),
      children: [
        for (final entry in byMonth.entries) ...[
          _MonthHeader(month: entry.key, movements: entry.value),
          const SizedBox(height: AppTokens.space2),
          for (final movement in entry.value)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: MovementListTile(
                movement: movement,
                mixedDirections: true,
                quickAction: true,
              ),
            ),
          const SizedBox(height: AppTokens.space3),
        ],
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.month, required this.movements});

  final DateTime month;
  final List<Transaction> movements;

  @override
  Widget build(BuildContext context) {
    final net =
        (Money.sum(
              movements.where((m) => m.type.isIncome).map((m) => m.amount),
            ) ??
            0) -
        (Money.sum(
              movements.where((m) => m.type.isExpense).map((m) => m.amount),
            ) ??
            0);

    return SectionHeader(
      formatMonth(month),
      trailing: MoneyText(
        net,
        signed: true,
        compact: true,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
