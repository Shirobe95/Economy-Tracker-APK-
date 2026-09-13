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
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/section_header.dart';
import '../expenses/expenses_screen.dart';
import '../movements/movement_list_tile.dart';

/// Filtro visible del listado de ingresos.
enum IncomeFilter {
  all('Todos'),
  collected('Cobrados'),
  pending('Pendientes');

  const IncomeFilter(this.label);

  final String label;
}

/// Ingresos del mes: salarios, cobros de proyecto y otros (UI-05).
class IncomeScreen extends ConsumerStatefulWidget {
  const IncomeScreen({super.key});

  @override
  ConsumerState<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends ConsumerState<IncomeScreen> {
  DateTime _month = Dates.monthStart(Dates.today());
  IncomeFilter _filter = IncomeFilter.all;

  @override
  Widget build(BuildContext context) {
    final movements = ref.watch(monthlyMovementsProvider(_month));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.badge_outlined),
            tooltip: 'Salarios',
            onPressed: () => context.push('/salarios'),
          ),
          IconButton(
            icon: const Icon(Icons.folder_shared_outlined),
            tooltip: 'Clientes y proyectos',
            onPressed: () => context.push('/proyectos'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space4,
              AppTokens.space2,
              AppTokens.space4,
              AppTokens.space3,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: MonthSelector(
                month: _month,
                onChanged: (value) => setState(() => _month = value),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.space4),
            child: FilterChips<IncomeFilter>(
              options: IncomeFilter.values,
              selected: _filter,
              labelOf: (f) => f.label,
              onSelected: (value) => setState(() => _filter = value),
            ),
          ),
          const SizedBox(height: AppTokens.space3),
          Expanded(
            child: movements.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('No se ha podido cargar: $error')),
              data: (rows) => _IncomeList(
                month: _month,
                filter: _filter,
                movements: rows.where((m) => m.type.isIncome).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ingresos/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo ingreso'),
      ),
    );
  }
}

class _IncomeList extends StatelessWidget {
  const _IncomeList({
    required this.month,
    required this.filter,
    required this.movements,
  });

  final DateTime month;
  final IncomeFilter filter;
  final List<Transaction> movements;

  List<Transaction> get _visible => switch (filter) {
    IncomeFilter.all => movements,
    IncomeFilter.collected =>
      movements.where((m) => m.status == MovementStatus.cobrado).toList(),
    IncomeFilter.pending =>
      movements
          .where(
            (m) =>
                m.status == MovementStatus.pendiente ||
                m.status == MovementStatus.previsto,
          )
          .toList(),
  };

  String _subtitleFor(Transaction movement) => switch (movement.type) {
    MovementType.salary => 'Salario',
    MovementType.projectIncome => 'Cobro de proyecto',
    _ => 'Ingreso',
  };

  @override
  Widget build(BuildContext context) {
    final collected = movements
        .where((m) => m.status == MovementStatus.cobrado)
        .map((m) => m.amount);
    final pending = movements
        .where(
          (m) =>
              m.status == MovementStatus.pendiente ||
              m.status == MovementStatus.previsto,
        )
        .map((m) => m.amount);

    final visible = _visible;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space4,
        0,
        AppTokens.space4,
        96,
      ),
      children: [
        FinanceCard(
          child: Row(
            children: [
              Expanded(
                child: _Metric(
                  icon: Icons.check_circle_outline_rounded,
                  color: AppTokens.positive,
                  label: 'Cobrados',
                  amount: Money.sum(collected) ?? 0,
                ),
              ),
              Container(width: 1, height: 52, color: AppTokens.border),
              Expanded(
                child: _Metric(
                  icon: Icons.access_time_rounded,
                  color: AppTokens.pending,
                  label: 'Pendientes',
                  amount: Money.sum(pending) ?? 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space4),
        const SectionHeader('Ingresos'),
        const SizedBox(height: AppTokens.space2),
        if (visible.isEmpty)
          EmptyState(
            message: movements.isEmpty
                ? 'No hay ingresos en ${formatMonth(month).toLowerCase()}.'
                : 'Ningun ingreso coincide con este filtro.',
            icon: Icons.arrow_upward_rounded,
          )
        else
          for (final movement in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: MovementListTile(
                movement: movement,
                subtitle: _subtitleFor(movement),
              ),
            ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.color,
    required this.label,
    required this.amount,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundIcon(icon, color: color, size: 40),
        const SizedBox(width: AppTokens.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 2),
              MoneyText(
                amount,
                compact: true,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
