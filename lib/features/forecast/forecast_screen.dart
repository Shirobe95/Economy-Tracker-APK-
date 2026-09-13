import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/feature_placeholder.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/section_header.dart';
import '../../data/account_repository.dart';
import '../../data/forecast_engine.dart';
import '../../data/goal_repository.dart';
import '../../data/movement_repository.dart';
import '../../data/salary_repository.dart';
import '../dashboard/dashboard_screen.dart';
import 'forecast_chart.dart';

/// Prevision de saldo a 3, 6, 12 y 24 meses (UI-11).
class ForecastScreen extends ConsumerStatefulWidget {
  const ForecastScreen({super.key});

  @override
  ConsumerState<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends ConsumerState<ForecastScreen> {
  int _months = 12;

  @override
  Widget build(BuildContext context) {
    final balances = ref.watch(accountBalancesProvider);
    final movements = ref.watch(allMovementsProvider);
    final rules = ref.watch(allRulesProvider);
    final goals = ref.watch(goalsProvider);
    final salaries = ref.watch(salarySourcesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prevision'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Como se calcula',
            onPressed: _explain,
          ),
        ],
      ),
      body: balances.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (accounts) {
          final live = accounts.where((a) => !a.account.isArchived).toList();
          if (live.isEmpty) {
            return const FeaturePlaceholder(
              title: 'Todavia no hay nada que prever',
              description:
                  'Crea una cuenta y registra tus gastos e ingresos. Con eso '
                  'la prevision empieza a tener sentido.',
              icon: Icons.show_chart_rounded,
            );
          }

          final result = ForecastEngine.project(
            accounts: live.map((a) => a.account).toList(),
            movements: movements.value ?? const [],
            rules: rules.value ?? const [],
            salarySources: salaries.value ?? const [],
            from: Dates.today(),
            months: _months,
          );

          return _Body(
            result: result,
            months: _months,
            onMonthsChanged: (value) => setState(() => _months = value),
            monthlyTarget: goals.value
                ?.map((g) => g.goal.monthlyContribution ?? 0)
                .fold<int>(0, (a, b) => a + b),
          );
        },
      ),
    );
  }

  void _explain() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como se calcula'),
        content: const SingleChildScrollView(
          child: Text(
            'La proyeccion parte del saldo real de tus cuentas y le suma tres '
            'cosas: los movimientos que ya tienes anotados con fecha futura, '
            'las repeticiones que tocan segun tus reglas recurrentes, y las '
            'nominas de tus fuentes salariales activas.\n\n'
            'Una fuente salarial solo se proyecta si tiene importe, '
            'frecuencia y dia de cobro. Si le falta alguno, no aparece: '
            'preferimos que eches en falta un ingreso a inventarnoslo.\n\n'
            'No estima gastos variables por tu media de meses anteriores, y '
            'no da por cobrado lo que solo esta previsto. Si una fecha ya '
            'esta anotada como movimiento de una regla, no se cuenta dos '
            'veces.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.result,
    required this.months,
    required this.onMonthsChanged,
    required this.monthlyTarget,
  });

  final ForecastResult result;
  final int months;
  final ValueChanged<int> onMonthsChanged;
  final int? monthlyTarget;

  @override
  Widget build(BuildContext context) {
    final hasProjection = result.milestones.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.space4,
        0,
        AppTokens.space4,
        AppTokens.space5,
      ),
      children: [
        FinanceCard(
          accent: true,
          padding: const EdgeInsets.all(AppTokens.space5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader('Proyeccion a $months meses'),
              const SizedBox(height: AppTokens.space2),
              if (!hasProjection)
                const Text(
                  'Sin movimientos futuros ni reglas recurrentes, la '
                  'proyeccion seria tu saldo de hoy repetido. No es una '
                  'prevision, asi que no se dibuja.',
                  style: TextStyle(color: AppTokens.textSecondary),
                )
              else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: MoneyText(
                        result.endingBalance,
                        compact: true,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space1),
                Text(
                  '${Money.formatSigned(result.delta)} respecto a hoy',
                  style: TextStyle(
                    color: result.delta >= 0
                        ? AppTokens.positive
                        : AppTokens.negative,
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                _HorizonSelector(months: months, onChanged: onMonthsChanged),
                const SizedBox(height: AppTokens.space5),
                ForecastChart(
                  points: result.points,
                  startingBalance: result.startingBalance,
                ),
              ],
            ],
          ),
        ),
        if (hasProjection) ...[
          const SizedBox(height: AppTokens.space3),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Saldo actual',
                  amount: result.startingBalance,
                  color: AppTokens.accent,
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
              const SizedBox(width: AppTokens.space3),
              Expanded(
                child: _StatCard(
                  label: 'Capacidad mensual',
                  amount: result.monthlyCapacity,
                  color: AppTokens.positive,
                  icon: Icons.trending_up_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space3),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Gastos previstos',
                  amount: result.totalExpense,
                  color: AppTokens.negative,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: AppTokens.space3),
              Expanded(
                child: _StatCard(
                  label: 'Objetivo mensual',
                  amount: (monthlyTarget ?? 0) == 0 ? null : monthlyTarget,
                  color: AppTokens.forecast,
                  icon: Icons.adjust_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space5),
          const SectionHeader('Proximos hitos'),
          const SizedBox(height: AppTokens.space2),
          for (final milestone in result.milestones.take(8))
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: _MilestoneTile(milestone: milestone),
            ),
        ],
      ],
    );
  }
}

class _HorizonSelector extends StatelessWidget {
  const _HorizonSelector({required this.months, required this.onChanged});

  final int months;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTokens.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        border: Border.all(color: AppTokens.border),
      ),
      child: Row(
        children: [
          for (final horizon in ForecastEngine.horizons)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(horizon),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: horizon == months
                        ? AppTokens.accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  ),
                  child: Text(
                    '${horizon}m',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: horizon == months
                          ? Colors.white
                          : AppTokens.textSecondary,
                      fontWeight: horizon == months
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;

  /// `null` cuando el dato no existe todavia. No se sustituye por cero.
  final int? amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RoundIcon(icon, color: color, size: 36),
          const SizedBox(height: AppTokens.space3),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTokens.space1),
          if (amount == null)
            const Text(
              'Sin definir',
              style: TextStyle(color: AppTokens.textMuted),
            )
          else
            MoneyText(
              amount!,
              compact: true,
              style: Theme.of(context).textTheme.titleLarge,
            ),
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  const _MilestoneTile({required this.milestone});

  final ForecastMilestone milestone;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      padding: const EdgeInsets.all(AppTokens.space3),
      child: Row(
        children: [
          RoundIcon(
            milestone.isIncome
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: milestone.isIncome ? AppTokens.positive : AppTokens.negative,
            size: 36,
          ),
          const SizedBox(width: AppTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.concept,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      formatDay(milestone.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (milestone.fromRule) ...[
                      const SizedBox(width: AppTokens.space2),
                      Text(
                        '· recurrente',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppTokens.textMuted),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          MoneyText(
            milestone.isIncome ? milestone.amount : -milestone.amount,
            signed: true,
          ),
        ],
      ),
    );
  }
}
