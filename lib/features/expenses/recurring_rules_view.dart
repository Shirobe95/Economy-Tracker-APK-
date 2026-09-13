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
import '../../data/recurrence_schedule.dart';
import '../../data/recurring_rule_repository.dart';
import 'expenses_screen.dart';

/// Listado de reglas recurrentes con sus proximas fechas.
///
/// Estas fechas son un calendario, no movimientos: no existen en la base y
/// consultarlas no crea nada.
class RecurringRulesView extends ConsumerWidget {
  const RecurringRulesView({super.key, required this.type});

  final MovementType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(rulesProvider(type));

    return rules.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('No se han podido cargar las reglas: $error')),
      data: (rows) {
        if (rows.isEmpty) {
          return Center(
            child: EmptyState(
              message:
                  'No hay reglas recurrentes.\nUna regla repite un gasto sin '
                  'tener que anotarlo cada mes.',
              icon: Icons.repeat_rounded,
              action: FilledButton(
                onPressed: () => context.push('/reglas/nueva'),
                child: const Text('Crear regla'),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.space4,
            0,
            AppTokens.space4,
            96,
          ),
          children: [
            for (final rule in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.space3),
                child: _RuleCard(rule: rule),
              ),
            const SizedBox(height: AppTokens.space3),
            OutlinedButton.icon(
              onPressed: () => context.push('/reglas/nueva'),
              icon: const Icon(Icons.add),
              label: const Text('Nueva regla'),
            ),
          ],
        );
      },
    );
  }
}

class _RuleCard extends ConsumerWidget {
  const _RuleCard({required this.rule});

  final RecurringRule rule;

  String get _frequencyLabel {
    final every = rule.intervalCount;
    return switch (rule.frequency) {
      RecurrenceFrequency.daily => every == 1 ? 'Cada dia' : 'Cada $every dias',
      RecurrenceFrequency.weekly =>
        every == 1 ? 'Cada semana' : 'Cada $every semanas',
      RecurrenceFrequency.monthly =>
        every == 1 ? 'Cada mes' : 'Cada $every meses',
      RecurrenceFrequency.yearly =>
        every == 1 ? 'Cada ano' : 'Cada $every anos',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = RecurrenceSchedule.fromRule(rule)
        .upcoming(from: Dates.today(), count: 6);

    return FinanceCard(
      onTap: () => context.push('/reglas/${rule.id}/editar'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rule.concept,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      _frequencyLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              MoneyText(rule.amount, currency: rule.currency),
              Switch(
                value: rule.isActive,
                onChanged: (value) => ref
                    .read(recurringRuleRepositoryProvider)
                    .setActive(rule.id, value),
              ),
            ],
          ),
          if (rule.isActive && upcoming.isNotEmpty) ...[
            const Divider(height: AppTokens.space5),
            const SectionHeader('Proximas fechas'),
            const SizedBox(height: AppTokens.space2),
            Wrap(
              spacing: AppTokens.space2,
              runSpacing: AppTokens.space2,
              children: [
                for (final date in upcoming)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space3,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTokens.surfaceSubtle,
                      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                      border: Border.all(color: AppTokens.border),
                    ),
                    child: Text(
                      formatDay(date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ],
          if (!rule.isActive)
            Padding(
              padding: const EdgeInsets.only(top: AppTokens.space2),
              child: Text(
                'Inactiva: no genera proximas fechas.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

/// Ocurrencias ya registradas de una regla, por fecha prevista.
final settledOccurrencesProvider =
    StreamProvider.family<Map<String, Transaction>, int>(
      (ref, ruleId) =>
          ref.watch(recurringRuleRepositoryProvider).watchSettled(ruleId),
    );

/// Una fecha de la regla, pulsable para darla por pagada.
class _OccurrenceChip extends ConsumerStatefulWidget {
  const _OccurrenceChip({
    required this.rule,
    required this.date,
    required this.settled,
  });

  final RecurringRule rule;
  final DateTime date;

  /// El movimiento que ya existe para esa fecha, si lo hay.
  final Transaction? settled;

  @override
  ConsumerState<_OccurrenceChip> createState() => _OccurrenceChipState();
}

class _OccurrenceChipState extends ConsumerState<_OccurrenceChip> {
  bool _working = false;

  bool get _isPaid => widget.settled?.status.isRealised ?? false;

  Future<void> _settle() async {
    if (_working || _isPaid) return;

    final result = await showModalBottomSheet<({DateTime date, int amount})>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _SettleSheet(rule: widget.rule, occurrence: widget.date),
    );
    if (result == null || !mounted) return;

    setState(() => _working = true);
    try {
      await ref
          .read(recurringRuleRepositoryProvider)
          .settleOccurrence(
            rule: widget.rule,
            occurrence: widget.date,
            actualDate: result.date,
            amount: result.amount,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.rule.concept} marcado como pagado')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se ha podido marcar: $error')));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paid = _isPaid;

    return Material(
      color: paid ? AppTokens.positiveSurface : AppTokens.surfaceSubtle,
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      child: InkWell(
        onTap: paid ? null : _settle,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTokens.space3,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
            border: Border.all(
              color: paid ? AppTokens.positive : AppTokens.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_working)
                const SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  paid
                      ? Icons.check_circle_outline_rounded
                      : Icons.radio_button_unchecked,
                  size: 14,
                  color: paid ? AppTokens.positive : AppTokens.textMuted,
                ),
              const SizedBox(width: 6),
              Text(
                formatDay(widget.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: paid ? AppTokens.positive : AppTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirma una ocurrencia: cuando se pago de verdad y por cuanto.
class _SettleSheet extends StatefulWidget {
  const _SettleSheet({required this.rule, required this.occurrence});

  final RecurringRule rule;
  final DateTime occurrence;

  @override
  State<_SettleSheet> createState() => _SettleSheetState();
}

class _SettleSheetState extends State<_SettleSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: (widget.rule.amount / 100).toStringAsFixed(2),
  );
  late DateTime _date = Dates.today();
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _confirm() {
    final amount = Money.tryParse(_amount.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Importe no valido.');
      return;
    }
    Navigator.of(context).pop((date: _date, amount: amount));
  }

  @override
  Widget build(BuildContext context) {
    final income = widget.rule.type.isIncome;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTokens.space4,
        0,
        AppTokens.space4,
        MediaQuery.of(context).viewInsets.bottom + AppTokens.space5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.rule.concept,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTokens.space1),
          Text(
            'Previsto para el ${formatDay(widget.occurrence)}.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppTokens.space5),
          DateField(
            label: income ? 'Fecha de cobro' : 'Fecha de pago',
            value: _date,
            helper: 'El dia en que el dinero se movio de verdad.',
            onChanged: (value) => setState(() => _date = value),
          ),
          const SizedBox(height: AppTokens.space4),
          AmountField(controller: _amount, label: 'Importe'),
          const SizedBox(height: AppTokens.space2),
          Text(
            'Si el recibo no vino por lo de siempre, cambialo aqui: la regla '
            'se queda como esta.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppTokens.textMuted),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTokens.space3),
            Text(_error!, style: const TextStyle(color: AppTokens.negative)),
          ],
          const SizedBox(height: AppTokens.space5),
          FilledButton.icon(
            onPressed: _confirm,
            icon: const Icon(Icons.check_circle_outline),
            label: Text(income ? 'Marcar como cobrado' : 'Marcar como pagado'),
          ),
        ],
      ),
    );
  }
}
