import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
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
import '../../data/planned_repository.dart';
import '../../data/recurring_rule_repository.dart';
import '../../data/salary_repository.dart';
import '../../data/savings_reserve.dart';
import '../movements/planned_list_tile.dart';
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
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Historial de movimientos',
            onPressed: () => context.push('/movimientos'),
          ),
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'Informes',
            onPressed: () => context.push('/informes'),
          ),
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
    final salaries = ref.watch(salarySourcesProvider);
    final reserve = ref.watch(savingsReserveProvider);
    final planned = ref.watch(upcomingPlannedProvider);

    final rows = movements.value ?? const <Transaction>[];

    // Lo que de verdad se ha movido este mes, por su fecha real. Contar
    // tambien lo pendiente hincharia las dos cifras con dinero que aun no ha
    // salido ni entrado, y sumaria hasta lo cancelado; lo que falta por
    // ocurrir esta abajo, en Proximos movimientos.
    final realised = rows.where((m) {
      final date = m.actualDate;
      return m.status.isRealised &&
          date != null &&
          !date.isBefore(month) &&
          date.isBefore(Dates.nextMonthStart(month));
    }).toList();

    final income = Money.sum(
      realised.where((m) => m.type.isIncome).map((m) => m.amount),
    );
    final expense = Money.sum(
      realised.where((m) => m.type.isExpense).map((m) => m.amount),
    );

    final upcoming = planned.value ?? const <PlannedItem>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space4,
        0,
        AppTokens.space4,
        AppTokens.space5,
      ),
      children: [
        _BalanceCard(reserve: reserve, accounts: accounts),
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
        if (_featuredGoal(goals.value) case final featured?) ...[
          const SizedBox(height: AppTokens.space3),
          _SavingsCard(goal: featured),
        ],
        const SizedBox(height: AppTokens.space3),
        _ForecastCard(
          accounts: accounts.map((a) => a.account).toList(),
          movements: rows,
          rules: rules.value ?? const [],
          salarySources: salaries.value ?? const [],
        ),
        const SizedBox(height: AppTokens.space5),
        SectionHeader(
          'Proximos movimientos',
          // Lleva al historial, no a «todos los proximos»: esta lista ya son
          // los proximos, y lo que no cabe aqui esta en Gastos e Ingresos.
          trailing: TextButton(
            onPressed: () => context.push('/movimientos'),
            child: const Text('Historial'),
          ),
        ),
        const SizedBox(height: AppTokens.space2),
        if (upcoming.isEmpty)
          const FinanceCard(
            child: Text(
              'No hay nada pendiente ni por repetirse.',
              style: TextStyle(color: AppTokens.textSecondary),
            ),
          )
        else
          // Gastos e ingresos juntos, y con las repeticiones incluidas: lo
          // que interesa desde Inicio es todo lo que va a mover dinero, no
          // solo lo que alguien se acordo de anotar a mano.
          for (final item in upcoming.take(6))
            Padding(
              key: ValueKey(item.key),
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: PlannedListTile(item: item),
            ),
      ],
    );
  }
}

/// Objetivo que se ensena en Inicio.
///
/// Manda el mensual, porque la tarjeta habla del mes en curso; si no hay
/// ninguno, el primero por importe. Ensenar el primero por orden alfabetico
/// era arbitrario.
GoalProgress? _featuredGoal(List<GoalProgress>? goals) {
  if (goals == null || goals.isEmpty) return null;
  return goals.where((g) => g.isMonthly).firstOrNull ?? goals.first;
}

/// Todas las reglas, para la tarjeta de prevision.
final allRulesProvider = StreamProvider<List<RecurringRule>>(
  (ref) => ref.watch(recurringRuleRepositoryProvider).watchRules(),
);

/// Saldo actual, ya descontado lo que esta apartado para ahorrar.
///
/// La cifra grande es lo que se puede gastar sin tocar el ahorro; al lado, en
/// pequeno, cuanto hay apartado. El dinero no se mueve de cuenta: el reparto
/// es solo de lectura, para que un saldo de 500 con 200 comprometidos no se
/// lea como 500 disponibles.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.reserve, required this.accounts});

  final AsyncValue<SavingsReserve> reserve;
  final List<AccountBalance> accounts;

  /// Saldo total de las cuentas vivas.
  int get _total =>
      Money.sum(
        accounts.where((a) => !a.account.isArchived).map((a) => a.balance ?? 0),
      ) ??
      0;

  @override
  Widget build(BuildContext context) {
    final unknown = accounts.any((a) => a.balance == null);
    final split = reserve.value;
    final hasReserve = split != null && split.reserved > 0;
    // Mientras se cargan los objetivos no hay reparto todavia. Ensenar un
    // cero seria peor que ensenar el saldo entero: se leeria como no tener
    // dinero, que es lo contrario de no saberlo aun.
    final shown = split?.available ?? _total;

    return FinanceCard(
      accent: true,
      padding: const EdgeInsets.all(AppTokens.space5),
      onTap: hasReserve ? () => _showReserveSheet(context, split) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(hasReserve ? 'Disponible' : 'Saldo actual'),
          const SizedBox(height: AppTokens.space2),
          if (unknown)
            const Text(
              'Saldo no disponible',
              style: TextStyle(color: AppTokens.textSecondary),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: MoneyText(
                    shown,
                    style: Theme.of(context).textTheme.displaySmall,
                    color: AppTokens.textPrimary,
                  ),
                ),
                if (hasReserve) ...[
                  const SizedBox(width: AppTokens.space2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.savings_outlined,
                          size: 14,
                          color: AppTokens.accentBright,
                        ),
                        const SizedBox(width: 4),
                        MoneyText(
                          split.reserved,
                          compact: true,
                          style: Theme.of(context).textTheme.bodyMedium,
                          color: AppTokens.accentBright,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          const SizedBox(height: AppTokens.space2),
          Text(
            hasReserve
                ? 'de ${Money.format(split.balance)} en '
                      '${_accountLabel(accounts)}'
                : _accountLabel(accounts),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  static String _accountLabel(List<AccountBalance> accounts) =>
      accounts.length == 1
      ? accounts.first.account.name
      : '${accounts.length} cuentas';
}

/// Desglose del ahorro apartado.
///
/// Hace falta porque la cifra grande de Inicio deja de ser el saldo del banco
/// y eso hay que poder comprobarlo: de que objetivo sale cada euro, y si lo
/// apartado cubre lo que los objetivos piden.
void _showReserveSheet(BuildContext context, SavingsReserve reserve) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTokens.surfaceElevated,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader('Ahorro apartado'),
            const SizedBox(height: AppTokens.space3),
            for (final line in reserve.lines)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.space2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        line.goal.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    MoneyText(line.amount, compact: true),
                  ],
                ),
              ),
            const Divider(color: AppTokens.border),
            _SheetRow(label: 'Saldo en cuentas', amount: reserve.balance),
            _SheetRow(label: 'Apartado', amount: reserve.reserved),
            _SheetRow(
              label: 'Disponible',
              amount: reserve.available,
              emphasis: true,
            ),
            if (reserve.missing > 0) ...[
              const SizedBox(height: AppTokens.space3),
              Text(
                'Faltan ${Money.format(reserve.missing)} para tener apartado '
                'todo lo que piden tus objetivos. El saldo no da para mas, '
                'asi que lo disponible es cero y lo que gastes sale del '
                'ahorro.',
                style: const TextStyle(color: AppTokens.textSecondary),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.label,
    required this.amount,
    this.emphasis = false,
  });

  final String label;
  final int amount;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final style = emphasis
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          MoneyText(
            amount,
            style: style,
            color: emphasis ? AppTokens.accentBright : null,
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
          SectionHeader(
            goal.isMonthly ? 'Ahorro de este mes' : 'Objetivo de ahorro',
          ),
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
            Text(
              goal.isMonthly
                  ? 'Declara cuanto has apartado este mes para ver el '
                        'progreso.'
                  : 'Declara cuanto llevas ahorrado para ver el progreso.',
              style: const TextStyle(color: AppTokens.textSecondary),
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
                Text(
                  goal.isMonthly ? '  de  ' : '  de  ',
                  style: const TextStyle(color: AppTokens.textSecondary),
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
    required this.salarySources,
  });

  final List<Account> accounts;
  final List<Transaction> movements;
  final List<RecurringRule> rules;
  final List<SalarySource> salarySources;

  @override
  Widget build(BuildContext context) {
    final result = ForecastEngine.project(
      accounts: accounts,
      movements: movements,
      rules: rules,
      salarySources: salarySources,
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
