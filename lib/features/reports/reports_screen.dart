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
import '../../data/movement_repository.dart';
import '../../data/report_engine.dart';
import '../expenses/expenses_screen.dart';
import 'monthly_bars.dart';

/// Informes sobre lo que ya ha pasado (UI-14).
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportRange _range = ReportRange.quarter;

  @override
  Widget build(BuildContext context) {
    final movements = ref.watch(allMovementsProvider);
    final categories = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Informes')),
      body: movements.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (rows) {
          final report = ReportEngine.build(
            movements: rows,
            categories: categories.value ?? const [],
            reference: Dates.today(),
            range: _range,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.space4,
              0,
              AppTokens.space4,
              AppTokens.space5,
            ),
            children: [
              // Los filtros van arriba, en una sola fila.
              FilterChips<ReportRange>(
                options: ReportRange.values,
                selected: _range,
                labelOf: (r) => r.label,
                onSelected: (value) => setState(() => _range = value),
              ),
              const SizedBox(height: AppTokens.space4),
              if (!report.hasData)
                const FeaturePlaceholder(
                  title: 'Todavia no hay historia que contar',
                  description:
                      'Los informes cuentan lo que ya ha pasado: movimientos '
                      'pagados o cobrados. Cuando marques alguno, apareceran '
                      'aqui.',
                  icon: Icons.insights_outlined,
                )
              else ...[
                _Headline(report: report),
                const SizedBox(height: AppTokens.space3),
                FinanceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader('Ingresos y gastos por mes'),
                      const SizedBox(height: AppTokens.space4),
                      MonthlyBars(months: report.monthly),
                    ],
                  ),
                ),
                const SizedBox(height: AppTokens.space3),
                _Averages(report: report),
                if (report.byCategory.isNotEmpty) ...[
                  const SizedBox(height: AppTokens.space3),
                  _CategoryRanking(report: report),
                ],
                if (report.pendingExpense > 0 || report.pendingIncome > 0) ...[
                  const SizedBox(height: AppTokens.space3),
                  _Pending(report: report),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.report});

  final ReportResult report;

  @override
  Widget build(BuildContext context) {
    final positive = report.net >= 0;

    return FinanceCard(
      accent: true,
      padding: const EdgeInsets.all(AppTokens.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Balance del periodo'),
          const SizedBox(height: AppTokens.space2),
          MoneyText(
            report.net,
            signed: true,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppTokens.space2),
          Row(
            children: [
              Icon(
                report.netChange >= 0
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 18,
                color: report.netChange >= 0
                    ? AppTokens.positive
                    : AppTokens.negative,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${Money.formatSigned(report.netChange)} frente al periodo '
                  'anterior',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const Divider(height: AppTokens.space5),
          Row(
            children: [
              Expanded(
                child: _Figure(
                  label: 'Cobrado',
                  amount: report.income,
                  color: AppTokens.positive,
                ),
              ),
              Container(width: 1, height: 40, color: AppTokens.border),
              Expanded(
                child: _Figure(
                  label: 'Pagado',
                  amount: report.expense,
                  color: AppTokens.negative,
                ),
              ),
            ],
          ),
          if (report.savingsRate != null) ...[
            const SizedBox(height: AppTokens.space4),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              child: LinearProgressIndicator(
                value: report.savingsRate,
                minHeight: 8,
                color: positive ? AppTokens.positive : AppTokens.negative,
              ),
            ),
            const SizedBox(height: AppTokens.space2),
            Text(
              'Has guardado el ${(report.savingsRate! * 100).round()} % de lo '
              'que ha entrado.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: 4),
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

class _Averages extends StatelessWidget {
  const _Averages({required this.report});

  final ReportResult report;

  @override
  Widget build(BuildContext context) {
    final months = report.monthly.length;

    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(months == 1 ? 'Este mes' : 'Media de $months meses'),
          const SizedBox(height: AppTokens.space3),
          _Line(label: 'Entra al mes', amount: report.averageMonthlyIncome),
          _Line(label: 'Sale al mes', amount: report.averageMonthlyExpense),
          _Line(
            label: 'Queda al mes',
            amount: report.averageMonthlyIncome == null
                ? null
                : report.averageMonthlyIncome! -
                      (report.averageMonthlyExpense ?? 0),
            signed: true,
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.amount, this.signed = false});

  final String label;
  final int? amount;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppTokens.textSecondary),
            ),
          ),
          if (amount == null)
            const Text(
              'Sin datos',
              style: TextStyle(color: AppTokens.textMuted),
            )
          else
            MoneyText(amount!, signed: signed, compact: true),
        ],
      ),
    );
  }
}

/// Reparto del gasto por categoria.
///
/// Barras horizontales ordenadas de mayor a menor, no un grafico de tarta:
/// comparar longitudes es facil, comparar angulos no.
class _CategoryRanking extends StatelessWidget {
  const _CategoryRanking({required this.report});

  final ReportResult report;

  @override
  Widget build(BuildContext context) {
    final top = report.byCategory.take(8).toList();
    final maxAmount = top.first.amount;

    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('En que se ha ido el dinero'),
          const SizedBox(height: AppTokens.space4),
          for (final category in top)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      MoneyText(category.amount, compact: true),
                      const SizedBox(width: AppTokens.space3),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '${(category.share * 100).round()} %',
                          textAlign: TextAlign.end,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: category.amount / maxAmount,
                      minHeight: 6,
                      color: AppTokens.accent,
                      backgroundColor: AppTokens.surfaceSubtle,
                    ),
                  ),
                ],
              ),
            ),
          if (report.byCategory.length > 8)
            Text(
              'Y ${report.byCategory.length - 8} categorias mas.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}

class _Pending extends StatelessWidget {
  const _Pending({required this.report});

  final ReportResult report;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('Comprometido, todavia sin mover'),
          const SizedBox(height: AppTokens.space2),
          const Text(
            'Esto no entra en las cifras de arriba: un informe cuenta lo que '
            'ya ha pasado.',
            style: TextStyle(color: AppTokens.textMuted),
          ),
          const SizedBox(height: AppTokens.space3),
          _Line(label: 'Falta cobrar', amount: report.pendingIncome),
          _Line(label: 'Falta pagar', amount: report.pendingExpense),
        ],
      ),
    );
  }
}
