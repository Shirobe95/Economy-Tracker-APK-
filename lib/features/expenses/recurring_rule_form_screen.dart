import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/form_fields.dart';
import '../../data/account_repository.dart';
import '../../data/movement_repository.dart';
import '../../data/recurring_rule_repository.dart';
import '../movements/quick_create_dialogs.dart';
import 'expenses_screen.dart';

/// Alta y edicion de una regla recurrente.
class RecurringRuleFormScreen extends ConsumerStatefulWidget {
  const RecurringRuleFormScreen({
    super.key,
    this.ruleId,
    this.type = MovementType.expense,
  });

  final int? ruleId;
  final MovementType type;

  @override
  ConsumerState<RecurringRuleFormScreen> createState() =>
      _RecurringRuleFormScreenState();
}

class _RecurringRuleFormScreenState
    extends ConsumerState<RecurringRuleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _concept = TextEditingController();
  final _amount = TextEditingController();
  final _interval = TextEditingController(text: '1');

  int? _accountId;
  int? _categoryId;
  RecurrenceFrequency _frequency = RecurrenceFrequency.monthly;
  DateTime _startDate = Dates.today();
  DateTime? _endDate;
  bool _active = true;
  bool _saving = false;
  bool _loaded = false;
  String? _error;

  @override
  void dispose() {
    _concept.dispose();
    _amount.dispose();
    _interval.dispose();
    super.dispose();
  }

  void _loadExisting(RecurringRule rule) {
    if (_loaded) return;
    _loaded = true;
    _concept.text = rule.concept;
    _amount.text = (rule.amount / 100).toStringAsFixed(2);
    _interval.text = '${rule.intervalCount}';
    _accountId = rule.accountId;
    _categoryId = rule.categoryId;
    _frequency = rule.frequency;
    _startDate = rule.startDate;
    _endDate = rule.endDate;
    _active = rule.isActive;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final accountId = _accountId;
    if (accountId == null) {
      setState(() => _error = 'Elige una cuenta.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(recurringRuleRepositoryProvider)
          .saveRule(
            id: widget.ruleId,
            concept: _concept.text,
            type: widget.type,
            accountId: accountId,
            categoryId: _categoryId,
            amount: Money.tryParse(_amount.text) ?? 0,
            frequency: _frequency,
            intervalCount: int.tryParse(_interval.text) ?? 1,
            startDate: _startDate,
            endDate: _endDate,
            isActive: _active,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on MovementValidationError catch (error) {
      setState(() {
        _saving = false;
        _error = error.message;
      });
    } catch (error) {
      setState(() {
        _saving = false;
        _error = 'No se ha podido guardar: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final categories = ref.watch(expenseCategoriesProvider);

    if (widget.ruleId != null) {
      final rule = ref.watch(_ruleProvider(widget.ruleId!)).value;
      if (rule != null) _loadExisting(rule);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ruleId == null ? 'Nueva regla' : 'Editar regla'),
        actions: [
          if (widget.ruleId != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Eliminar regla',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (rows) {
          if (rows.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Necesitas una cuenta antes de crear una regla.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTokens.textSecondary),
                    ),
                    const SizedBox(height: AppTokens.space4),
                    FilledButton(
                      onPressed: () => showCreateAccountDialog(context, ref),
                      child: const Text('Crear cuenta'),
                    ),
                  ],
                ),
              ),
            );
          }
          _accountId ??= rows.first.id;
          return _form(rows, categories.value ?? const []);
        },
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar regla'),
        content: const Text(
          'Se dejaran de calcular sus proximas fechas. Los gastos ya '
          'registrados no se tocan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTokens.negative),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(recurringRuleRepositoryProvider).deleteRule(widget.ruleId!);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Widget _form(List<Account> accounts, List<Category> categories) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppTokens.space4),
        children: [
          TextFormField(
            controller: _concept,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Concepto'),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Escribe un concepto.'
                : null,
          ),
          const SizedBox(height: AppTokens.space4),
          AmountField(controller: _amount),
          const SizedBox(height: AppTokens.space4),
          OptionField<int>(
            label: 'Cuenta',
            value: _accountId,
            items: [
              for (final account in accounts)
                DropdownMenuItem(value: account.id, child: Text(account.name)),
            ],
            onChanged: (value) => setState(() => _accountId = value),
          ),
          const SizedBox(height: AppTokens.space4),
          OptionField<int?>(
            label: 'Categoria',
            value: categories.any((c) => c.id == _categoryId)
                ? _categoryId
                : null,
            hint: 'Opcional',
            items: [
              const DropdownMenuItem(value: null, child: Text('Sin asignar')),
              for (final category in categories)
                DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
            ],
            onChanged: (value) => setState(() => _categoryId = value),
          ),
          const SizedBox(height: AppTokens.space4),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OptionField<RecurrenceFrequency>(
                  label: 'Frecuencia',
                  value: _frequency,
                  items: const [
                    DropdownMenuItem(
                      value: RecurrenceFrequency.daily,
                      child: Text('Dias'),
                    ),
                    DropdownMenuItem(
                      value: RecurrenceFrequency.weekly,
                      child: Text('Semanas'),
                    ),
                    DropdownMenuItem(
                      value: RecurrenceFrequency.monthly,
                      child: Text('Meses'),
                    ),
                    DropdownMenuItem(
                      value: RecurrenceFrequency.yearly,
                      child: Text('Anos'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _frequency = value ?? _frequency),
                ),
              ),
              const SizedBox(width: AppTokens.space3),
              Expanded(
                child: TextFormField(
                  controller: _interval,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Cada'),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed < 1 || parsed > 120) {
                      return 'Entre 1 y 120';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space4),
          DateField(
            label: 'Fecha de inicio',
            value: _startDate,
            helper:
                'Fija el dia de referencia. Si un mes no lo tiene, se usa el '
                'ultimo dia valido sin perderlo en los siguientes.',
            onChanged: (value) => setState(() => _startDate = value),
          ),
          const SizedBox(height: AppTokens.space4),
          DateField(
            label: 'Fecha de fin',
            value: _endDate,
            helper: 'Opcional.',
            onChanged: (value) => setState(() => _endDate = value),
          ),
          const SizedBox(height: AppTokens.space3),
          SwitchListTile(
            value: _active,
            onChanged: (value) => setState(() => _active = value),
            title: const Text('Regla activa'),
            contentPadding: EdgeInsets.zero,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTokens.space3),
            Text(_error!, style: const TextStyle(color: AppTokens.negative)),
          ],
          const SizedBox(height: AppTokens.space4),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
          const SizedBox(height: AppTokens.space5),
        ],
      ),
    );
  }
}

final _ruleProvider = StreamProvider.family<RecurringRule?, int>(
  (ref, id) => ref.watch(recurringRuleRepositoryProvider).watchRule(id),
);
