import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/utils/money.dart';
import '../../data/report_engine.dart';

/// Barras agrupadas de ingreso y gasto por mes.
///
/// Una sola escala para las dos series: son euros las dos, y dos ejes
/// distintos dejarian comparar alturas que no son comparables.
///
/// Los colores son los tokens semanticos del proyecto. Validados contra el
/// fondo oscuro: separacion para daltonismo ΔE 15.1 en deuteranopia, muy por
/// encima del minimo de 8, y contraste sobre superficie por encima de 3:1.
/// Aun asi la identidad nunca depende solo del color: hay leyenda y las
/// barras van siempre en el mismo orden dentro de cada mes.
class MonthlyBars extends StatelessWidget {
  const MonthlyBars({super.key, required this.months, this.height = 180});

  final List<MonthlyTotals> months;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) return const SizedBox.shrink();

    final maxValue = months
        .map((m) => m.income > m.expense ? m.income : m.expense)
        .fold<int>(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _LegendItem(color: AppTokens.positive, label: 'Ingresos'),
            const SizedBox(width: AppTokens.space4),
            _LegendItem(color: AppTokens.negative, label: 'Gastos'),
            const Spacer(),
            Text(
              maxValue == 0 ? '' : 'max ${Money.formatCompact(maxValue)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppTokens.space4),
        SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final month in months)
                Expanded(
                  child: _MonthColumn(
                    totals: month,
                    maxValue: maxValue,
                    showLabel: months.length <= 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthColumn extends StatelessWidget {
  const _MonthColumn({
    required this.totals,
    required this.maxValue,
    required this.showLabel,
  });

  final MonthlyTotals totals;
  final int maxValue;
  final bool showLabel;

  static const _initials = [
    'E',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Bar(
                value: totals.income,
                maxValue: maxValue,
                color: AppTokens.positive,
              ),
              // Separacion entre barras adyacentes: sin ella, dos colores
              // contiguos se leen como una sola forma.
              const SizedBox(width: 2),
              _Bar(
                value: totals.expense,
                maxValue: maxValue,
                color: AppTokens.negative,
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: AppTokens.space2),
          Text(
            _initials[totals.month.month - 1],
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = maxValue == 0 ? 0.0 : value / maxValue;

    return Flexible(
      child: FractionallySizedBox(
        heightFactor: fraction.clamp(0.0, 1.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 14, minHeight: 2),
          decoration: BoxDecoration(
            color: color,
            // Extremo redondeado arriba, anclado a la linea base.
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        // El rotulo va en tinta de texto, no en el color de la serie: el
        // cuadrado de al lado ya lleva la identidad.
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
