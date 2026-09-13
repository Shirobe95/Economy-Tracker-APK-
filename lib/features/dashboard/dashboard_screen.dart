import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/section_header.dart';
import '../../data/account_repository.dart';
import '../../data/forecast_engine.dart';
import '../../data/goal_repository.dart';
import '../../data/movement_repository.dart';
import '../../data/recurring_rule_repository.dart';
import '../movements/movement_list_tile.dart';
import '../movements/quick_create_dialogs.dart';

/// Inicio: el estado de las finanzas de un vistazo (UI-01).
///
/// Ninguna tarjeta muestra una cifra hasta que hay datos reales que la
/// sostengan. Un cero en una casilla vacia se leeria como un saldo de cero,
/// que no es lo mismo que no tener datos.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balances = ref.watch(accountBalancesProvider);
    final month = Dates.monthStart(Dates.today());

    return Scaffold(
      appBar: AppBar(
        title: Text(formatMonth(month)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ajustes',
            onPressed: () => context.push('/ajustes'),
          ),
        ],
      ),
      body: balances.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('No se ha podido cargar: $error')),
        data: (accounts) {
          if (accounts.where((a) => !a.account.isArchived).isEmpty) {
            return const _WelcomeBody();
          }
          return _DashboardBody(accounts: accounts, month: month);
        },
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.accounts, required this.month});

  final List<AccountBalance> accounts;
  final DateTime month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movements = ref.watch(allMovementsProvider);
    final rules = ref.watch(allRulesProvider);
    final goals = ref.watch(goalsProvider);

    final total =
        Money.sum(
          accounts
              .where((a) => !a.account.isArchived)
              .map((a) => a.balance ?? 0),
        ) ??
        0;

    final rows = movements.value ?? const <Transaction>[];
    final thisMonth = rows
        .where(
          (m) =>
              !m.expectedDate.isBefore(month) &&
              m.expectedDate.isBefore(Dates.nextMonthStart(month)),
        )
        .toList();

    final income = Money.sum(
      thisMonth.where((m) => m.type.isIncome).map((m) => m.amount),
    );
    final expense = Money.sum(
      thisMonth.where((m) => m.type.isExpense).map((m) => m.amount),
    );

    final upcoming =
        rows
            .where(
              (m) =>
                  !m.status.isRealised &&
                  m.status != MovementStatus.cancelado &&
                  !m.expectedDate.isBefore(Dates.today()),
            )
            .toList()
          ..sort((a, b) => a.expectedDate.compareTo(b.expectedDate));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space4,
        0,
        AppTokens.space4,
        AppTokens.space5,
      ),
      children: [
        _BalanceCard(total: total, accounts: accounts),
        const SizedBox(height: AppTokens.space3),
        Row(
          children: [
            Expanded(
              child: _DirectionCard(
                label: 'Ingresos',
                amount: income ?? 0,
                color: AppTokens.positive,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: _DirectionCard(
                label: 'Gastos',
                amount: expense ?? 0,
                color: AppTokens.negative,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
          ],
        ),
        if (goals.value?.isNotEmpty ?? false) ...[
          const SizedBox(height: AppTokens.space3),
          _SavingsCard(goal: goals.value!.first),
        ],
        const SizedBox(height: AppTokens.space3),
        _ForecastCard(
          accounts: accounts.map((a) => a.account).toList(),
          movements: rows,
          rules: rules.value ?? const [],
        ),
        const SizedBox(height: AppTokens.space5),
        SectionHeader(
          'Proximos movimientos',
          trailing: TextButton(
            onPressed: () => context.push('/calendario'),
            child: const Text('Ver calendario'),
          ),
        ),
        const SizedBox(height: AppTokens.space2),
        if (upcoming.isEmpty)
          const FinanceCard(
            child: Text(
              'No hay movimientos pendientes.',
              style: TextStyle(color: AppTokens.textSecondary),
            ),
          )
        else
          for (final movement in upcoming.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: MovementListTile(
                movement: movement,
                mixedDirections: true,
              ),
            ),
      ],
    );
  }
}

/// Todas las reglas, para la tarjeta de prevision.
final allRulesProvider = StreamProvider<List<RecurringRule>>(
  (ref) => ref.watch(recurringRuleRepositoryProvider).watchRules(),
);

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.total, required this.accounts});

  final int total;
  final List<AccountBalance> accounts;

  @override
  Widget build(BuildContext context) {
    final unknown = accounts.any((a) => a.balance == null);

    return FinanceCard(
      accent: true,
      padding: const EdgeInsets.all(AppTokens.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Saldo actual'),
          const SizedBox(height: AppTokens.space2),
          if (unknown)
            const Text(
              'Saldo no disponible',
              style: TextStyle(color: AppTokens.textSecondary),
            )
          else
            MoneyText(
              total,
              style: Theme.of(context).textTheme.displaySmall,
              color: AppTokens.textPrimary,
            ),
          const SizedBox(height: AppTokens.space2),
          Text(
            accounts.length == 1
                ? accounts.first.account.name
                : '${accounts.length} cuentas',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DirectionCard extends StatelessWidget {
  const _DirectionCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final int amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RoundIcon(icon, color: color, size: 36),
              const SizedBox(width: AppTokens.space2),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space3),
          MoneyText(
            amount,
            compact: true,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  const _SavingsCard({required this.goal});

  final GoalProgress goal;

  @override
  Widget build(BuildContext context) {
    final ratio = goal.ratio;

    return FinanceCard(
      onTap: () => context.push('/objetivos'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Objetivo de ahorro'),
          const SizedBox(height: AppTokens.space2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  goal.goal.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: AppTokens.space3),
          if (ratio == null)
            const Text(
              'Declara cuanto llevas ahorrado para ver el progreso.',
              style: TextStyle(color: AppTokens.textSecondary),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              child: LinearProgressIndicator(value: ratio, minHeight: 8),
            ),
            const SizedBox(height: AppTokens.space2),
            Row(
              children: [
                MoneyText(
                  goal.current!,
                  compact: true,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Text(
                  '  de  ',
                  style: TextStyle(color: AppTokens.textSecondary),
                ),
                MoneyText(
                  goal.goal.targetAmount,
                  compact: true,
                  style: Theme.of(context).textTheme.bodyMedium,
                  color: AppTokens.textSecondary,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  const _ForecastCard({
    required this.accounts,
    required this.movements,
    required this.rules,
  });

  final List<Account> accounts;
  final List<Transaction> movements;
  final List<RecurringRule> rules;

  @override
  Widget build(BuildContext context) {
    final result = ForecastEngine.project(
      accounts: accounts,
      movements: movements,
      rules: rules,
      from: Dates.today(),
      months: 12,
    );

    final horizons = <int>[3, 6, 12];

    return FinanceCard(
      onTap: () => context.push('/prevision'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Prevision'),
          const SizedBox(height: AppTokens.space3),
          if (result.milestones.isEmpty)
            const Text(
              'Sin movimientos futuros ni reglas, no hay nada que proyectar.',
              style: TextStyle(color: AppTokens.textSecondary),
            )
          else
            for (final months in horizons)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.space2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$months meses',
                        style: const TextStyle(color: AppTokens.textSecondary),
                      ),
                    ),
                    MoneyText(result.points[months - 1].balance, compact: true),
                    const SizedBox(width: AppTokens.space3),
                    SizedBox(
                      width: 88,
                      child: Text(
                        Money.formatSigned(
                          result.points[months - 1].balance -
                              result.startingBalance,
                        ),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: AppTokens.accentBright,
                          fontSize: 13,
                        ),
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

/// Primera pantalla cuando todavia no hay ninguna cuenta.
class _WelcomeBody extends ConsumerWidget {
  const _WelcomeBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RoundIcon(
              Icons.account_balance_wallet_outlined,
              color: AppTokens.accent,
              size: 72,
            ),
            const SizedBox(height: AppTokens.space5),
            Text(
              'Empieza por tu cuenta',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.space3),
            const Text(
              'Crea la cuenta donde tienes tu dinero y anota el saldo que '
              'hay ahora mismo. A partir de ahi, cada gasto y cada cobro '
              'actualizan el saldo solos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTokens.textSecondary),
            ),
            const SizedBox(height: AppTokens.space6),
            FilledButton(
              onPressed: () => showCreateAccountDialog(context, ref),
              child: const Text('Crear mi primera cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}
