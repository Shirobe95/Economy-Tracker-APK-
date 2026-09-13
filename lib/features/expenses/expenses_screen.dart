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
import '../../data/account_repository.dart';
import '../../data/movement_repository.dart';
import '../../data/recurring_rule_repository.dart';
import '../movements/movement_list_tile.dart';
import 'recurring_rules_view.dart';

/// Filtro visible del listado de gastos.
enum ExpenseFilter {
  all('Todos'),
  pending('Pendientes'),
  paid('Pagados'),
  recurring('Recurrentes');

  const ExpenseFilter(this.label);

  final String label;
}

/// Gastos del mes, con métricas, resumen por categoría y reglas (UI-03).
class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  DateTime _month = Dates.monthStart(Dates.today());
  ExpenseFilter _filter = ExpenseFilter.all;

  @override
  Widget build(BuildContext context) {
    final movements = ref.watch(monthlyMovementsProvider(_month));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.repeat_rounded),
            tooltip: 'Reglas recurrentes',
            onPressed: () => setState(() => _filter = ExpenseFilter.recurring),
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
            child: FilterChips<ExpenseFilter>(
              options: ExpenseFilter.values,
              selected: _filter,
              labelOf: (f) => f.label,
              onSelected: (value) => setState(() => _filter = value),
            ),
          ),
          const SizedBox(height: AppTokens.space3),
          Expanded(
            child: _filter == ExpenseFilter.recurring
                ? const RecurringRulesView(type: MovementType.expense)
                : movements.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => _RetryBody(
                      message: 'No se han podido cargar los gastos.',
                      detail: '$error',
                      onRetry: () => ref.invalidate(monthlyMovementsProvider),
                    ),
                    data: (rows) => _ExpenseList(
                      month: _month,
                      filter: _filter,
                      movements: rows
                          .where((m) => m.type == MovementType.expense)
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/gastos/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Crear gasto'),
      ),
    );
  }
}

/// Movimientos vivos de un mes.
///
/// La clave es solo el mes, que compara por valor. Pasar un `Set` de tipos
/// como clave de una familia crea un provider nuevo en cada build, porque
/// los conjuntos comparan por identidad: el filtro por tipo se hace sobre
/// la lista ya cargada, que es de un mes y cabe de sobra en memoria.
final monthlyMovementsProvider =
    StreamProvider.family<List<Transaction>, DateTime>(
      (ref, month) =>
          ref.watch(movementRepositoryProvider).watchByMonth(month: month),
    );

final rulesProvider = StreamProvider.family<List<RecurringRule>, MovementType>(
  (ref, type) =>
      ref.watch(recurringRuleRepositoryProvider).watchRules(type: type),
);

class _ExpenseList extends ConsumerWidget {
  const _ExpenseList({
    required this.month,
    required this.filter,
    required this.movements,
  });

  final DateTime month;
  final ExpenseFilter filter;
  final List<Transaction> movements;

  List<Transaction> get _visible => switch (filter) {
    ExpenseFilter.all => movements,
    ExpenseFilter.pending =>
      movements
          .where(
            (m) =>
                m.status == MovementStatus.pendiente ||
                m.status == MovementStatus.previsto,
          )
          .toList(),
    ExpenseFilter.paid =>
      movements.where((m) => m.status == MovementStatus.pagado).toList(),
    ExpenseFilter.recurring => movements,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    if (accounts.value?.isEmpty ?? false) {
      return const FeaturePlaceholder(
        title: 'Todavia no hay cuentas',
        description:
            'Crea una cuenta al registrar tu primer gasto. Sin cuenta no hay '
            'saldo que mostrar.',
        icon: Icons.account_balance_wallet_outlined,
      );
    }

    // Pagados usa la fecha real del mes; pendientes, la fecha prevista.
    final paid = movements
        .where(
          (m) =>
              m.status == MovementStatus.pagado &&
              m.actualDate != null &&
              !m.actualDate!.isBefore(month) &&
              m.actualDate!.isBefore(Dates.nextMonthStart(month)),
        )
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
        _MetricsCard(
          paid: Money.sum(paid) ?? 0,
          pending: Money.sum(pending) ?? 0,
        ),
        const SizedBox(height: AppTokens.space4),
        if (movements.isNotEmpty) ...[
          _CategoryBreakdown(movements: movements),
          const SizedBox(height: AppTokens.space4),
        ],
        const SectionHeader('Gastos'),
        const SizedBox(height: AppTokens.space2),
        if (visible.isEmpty)
          EmptyState(
            message: movements.isEmpty
                ? 'No hay gastos en ${formatMonth(month).toLowerCase()}.'
                : 'Ningun gasto coincide con este filtro.',
            icon: Icons.receipt_long_outlined,
          )
        else
          for (final movement in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: MovementListTile(movement: movement),
            ),
      ],
    );
  }
}

class _MetricsCard extends StatelessWidget {
  const _MetricsCard({required this.paid, required this.pending});

  final int paid;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      child: Row(
        children: [
          Expanded(
            child: _Metric(
              icon: Icons.arrow_downward_rounded,
              color: AppTokens.negative,
              label: 'Pagados',
              amount: paid,
            ),
          ),
          Container(width: 1, height: 52, color: AppTokens.border),
          Expanded(
            child: _Metric(
              icon: Icons.access_time_rounded,
              color: AppTokens.pending,
              label: 'Pendientes',
              amount: pending,
            ),
          ),
        ],
      ),
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

/// Reparto del gasto del mes por categoria.
///
/// Excluye cancelados: no se ha gastado nada en algo que se anulo.
class _CategoryBreakdown extends ConsumerWidget {
  const _CategoryBreakdown({required this.movements});

  final List<Transaction> movements;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(expenseCategoriesProvider);
    final rows = categories.value;
    if (rows == null) return const SizedBox.shrink();

    final counted = movements
        .where((m) => m.status != MovementStatus.cancelado)
        .toList();
    if (counted.isEmpty) return const SizedBox.shrink();

    final byCategory = <int?, int>{};
    for (final movement in counted) {
      byCategory.update(
        movement.categoryId,
        (value) => value + movement.amount,
        ifAbsent: () => movement.amount,
      );
    }

    final total = Money.sum(byCategory.values) ?? 0;
    if (total == 0) return const SizedBox.shrink();

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Resumen por categoria'),
          const SizedBox(height: AppTokens.space3),
          for (final entry in entries.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows.where((c) => c.id == entry.key).firstOrNull?.name ??
                          'Sin categoria',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  MoneyText(entry.value, compact: true),
                  const SizedBox(width: AppTokens.space3),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${(entry.value * 100 / total).round()} %',
                      textAlign: TextAlign.end,
                      style: const TextStyle(color: AppTokens.accentBright),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

final expenseCategoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref
      .watch(accountRepositoryProvider)
      .watchCategories(CategoryKind.expense),
);

class _RetryBody extends StatelessWidget {
  const _RetryBody({
    required this.message,
    required this.detail,
    required this.onRetry,
  });

  final String message;
  final String detail;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTokens.negative,
              size: 40,
            ),
            const SizedBox(height: AppTokens.space3),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTokens.space2),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTokens.textSecondary),
            ),
            const SizedBox(height: AppTokens.space4),
            OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
