import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/money_text.dart';
import '../../core/widgets/section_header.dart';
import '../../data/forecast_engine.dart';

/// Desglose mensual de la proyeccion: un mes por tarjeta, expandible.
///
/// Cada mes se juzga por lo que paso en el -[ForecastPoint.net]-, sin
/// mezclarlo con el saldo acumulado de la cuenta. El saldo acumulado se
/// enseña aparte -arriba de la lista y dentro de cada tarjeta expandida- para
/// responder sin ambiguedad a donde va el sobrante (o el descubierto) de un
/// mes cuando se pasa al siguiente.
class MonthlyBreakdown extends StatefulWidget {
  const MonthlyBreakdown({super.key, required this.result});

  final ForecastResult result;

  @override
  State<MonthlyBreakdown> createState() => _MonthlyBreakdownState();
}

class _MonthlyBreakdownState extends State<MonthlyBreakdown> {
  DateTime? _expanded;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    // Meses cuyo gasto variable incluye (del todo o en parte) la estimacion
    // por media historica, para que la tarjeta lo pueda señalar como tal.
    final estimatedMonths = <String>{
      for (final milestone in result.milestones)
        if (milestone.isEstimate)
          '${milestone.date.year}-${milestone.date.month}',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Analisis mensual'),
        const SizedBox(height: AppTokens.space2),
        const Text(
          'Toca un mes para ver de donde sale su balance: lo que entra, lo '
          'recurrente, lo gastado dia a dia y lo que queda. Cada mes se '
          'juzga solo, por lo que paso en el.',
          style: TextStyle(color: AppTokens.textSecondary),
        ),
        const SizedBox(height: AppTokens.space3),
        FinanceCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space4,
            vertical: AppTokens.space3,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo de tu cuenta, hoy',
                style: TextStyle(color: AppTokens.textSecondary),
              ),
              MoneyText(
                result.startingBalance,
                compact: true,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTokens.accentBright,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTokens.space2),
        for (final point in result.points)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTokens.space2),
            child: _MonthCard(
              point: point,
              isExpanded: _expanded == point.month,
              isEstimated: estimatedMonths.contains(
                '${point.month.year}-${point.month.month}',
              ),
              onToggle: () => setState(
                () =>
                    _expanded = _expanded == point.month ? null : point.month,
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.point,
    required this.isExpanded,
    required this.isEstimated,
    required this.onToggle,
  });

  final ForecastPoint point;
  final bool isExpanded;
  final bool isEstimated;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final positive = point.net >= 0;
    final balanceColor = positive ? AppTokens.positive : AppTokens.negative;

    return FinanceCard(
      padding: EdgeInsets.zero,
      onTap: onToggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTokens.space4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTokens.textMuted,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppTokens.space2),
                    Text(
                      formatMonth(point.month),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MoneyText(
                      point.net,
                      signed: true,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'balance del mes',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTokens.space4,
                0,
                AppTokens.space4,
                AppTokens.space4,
              ),
              child: _MonthDetail(
                point: point,
                isEstimated: isEstimated,
                balanceColor: balanceColor,
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthDetail extends StatelessWidget {
  const _MonthDetail({
    required this.point,
    required this.isEstimated,
    required this.balanceColor,
  });

  final ForecastPoint point;
  final bool isEstimated;
  final Color balanceColor;

  @override
  Widget build(BuildContext context) {
    final totalExpense = point.fixedExpense + point.variableExpense;
    final denom = point.income > totalExpense ? point.income : totalExpense;
    final overspent = point.net < 0;
    final recurringFrac = denom == 0 ? 0.0 : point.fixedExpense / denom;
    final spentFrac = denom == 0 ? 0.0 : point.variableExpense / denom;
    final leftoverFrac = (!overspent && denom > 0) ? point.net / denom : 0.0;
    final markerFrac = denom == 0 ? 0.0 : point.income / denom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: AppTokens.border),
        const SizedBox(height: AppTokens.space4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ENTRADA',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTokens.textMuted,
                letterSpacing: 0.5,
              ),
            ),
            MoneyText(
              point.income,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: AppTokens.space2),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  child: Container(
                    height: 18,
                    color: AppTokens.surfaceSubtle,
                    child: Row(
                      children: [
                        Expanded(
                          flex: (recurringFrac * 1000).round(),
                          child: Container(color: AppTokens.forecast),
                        ),
                        Expanded(
                          flex: (spentFrac * 1000).round(),
                          child: Container(color: AppTokens.negative),
                        ),
                        Expanded(
                          flex: (leftoverFrac * 1000).round(),
                          child: Container(color: AppTokens.positive),
                        ),
                        Expanded(
                          flex:
                              (1000 -
                                      (recurringFrac * 1000).round() -
                                      (spentFrac * 1000).round() -
                                      (leftoverFrac * 1000).round())
                                  .clamp(0, 1000),
                          child: const SizedBox(),
                        ),
                      ],
                    ),
                  ),
                ),
                if (overspent)
                  Positioned(
                    left: (markerFrac.clamp(0.0, 1.0) * width - 1).clamp(
                      0.0,
                      width - 2,
                    ),
                    top: -3,
                    bottom: -3,
                    child: Container(width: 2, color: AppTokens.textPrimary),
                  ),
              ],
            );
          },
        ),
        if (overspent)
          Padding(
            padding: const EdgeInsets.only(top: AppTokens.space1),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '↑ ahi se acaba tu ingreso del mes',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTokens.textSecondary,
                ),
              ),
            ),
          ),
        const SizedBox(height: AppTokens.space4),
        _LegendRow(
          color: AppTokens.forecast,
          label: 'Gastos recurrentes',
          amountText: '-${Money.format(point.fixedExpense)}',
        ),
        const SizedBox(height: AppTokens.space2),
        _LegendRow(
          color: AppTokens.negative,
          label: isEstimated ? 'Gastado (estimado)' : 'Gastado',
          amountText: '-${Money.format(point.variableExpense)}',
        ),
        const SizedBox(height: AppTokens.space3),
        const Divider(height: 1, color: AppTokens.border),
        const SizedBox(height: AppTokens.space3),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Balance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: balanceColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            MoneyText(
              point.net,
              signed: true,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.space3),
        Container(
          padding: const EdgeInsets.only(top: AppTokens.space3),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppTokens.border)),
          ),
          child: Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTokens.textSecondary,
              ),
              children: [
                const TextSpan(text: 'Con esto, tu cuenta llegaria a fin de '),
                TextSpan(text: formatMonth(point.month)),
                const TextSpan(text: ' en torno a los '),
                TextSpan(
                  text: Money.formatCompact(point.balance),
                  style: const TextStyle(
                    color: AppTokens.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.amountText,
  });

  final Color color;
  final String label;
  final String amountText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: AppTokens.space2),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        Text(amountText, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
