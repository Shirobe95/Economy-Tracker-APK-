import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/section_header.dart';
import '../../data/goal_repository.dart';

/// Alta y edicion de un objetivo de ahorro.
class GoalFormScreen extends ConsumerStatefulWidget {
  const GoalFormScreen({super.key, this.goalId});

  final int? goalId;

  @override
  ConsumerState<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends ConsumerState<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _target = TextEditingController();
  final _current = TextEditingController();
  final _monthlyContribution = TextEditingController();

  SavingsGoalKind _kind = SavingsGoalKind.amount;
  DateTime? _targetDate;
  bool _saving = false;
  bool _loaded = false;
  String? _error;

  bool get _monthly => _kind.isMonthly;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _current.dispose();
    _monthlyContribution.dispose();
    super.dispose();
  }

  void _loadExisting(SavingsGoal goal) {
    if (_loaded) return;
    _loaded = true;
    _name.text = goal.name;
    _kind = goal.kind;
    _target.text = (goal.targetAmount / 100).toStringAsFixed(2);
    if (goal.currentAmount != null) {
      _current.text = (goal.currentAmount! / 100).toStringAsFixed(2);
    }
    if (goal.monthlyContribution != null) {
      _monthlyContribution.text = (goal.monthlyContribution! / 100)
          .toStringAsFixed(2);
    }
    _targetDate = goal.targetDate;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final target = Money.tryParse(_target.text);
    if (target == null || target <= 0) {
      setState(() => _error = 'El objetivo debe ser mayor que cero.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(goalRepositoryProvider)
          .saveGoal(
            id: widget.goalId,
            name: _name.text,
            kind: _kind,
            targetAmount: target,
            // Vacio significa "no lo se", no cero.
            currentAmount: _current.text.trim().isEmpty
                ? null
                : Money.tryParse(_current.text),
            monthlyContribution: _monthlyContribution.text.trim().isEmpty
                ? null
                : Money.tryParse(_monthlyContribution.text),
            targetDate: _targetDate,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      setState(() {
        _saving = false;
        _error = 'No se ha podido guardar: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.goalId != null) {
      final goal = ref.watch(_goalProvider(widget.goalId!)).value;
      if (goal != null) _loadExisting(goal);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.goalId == null ? 'Nuevo objetivo' : 'Editar objetivo',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            _KindSelector(
              value: _kind,
              onChanged: (value) => setState(() => _kind = value),
            ),
            const SizedBox(height: AppTokens.space4),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nombre',
                hintText: _monthly
                    ? 'Ahorro del mes, colchon...'
                    : 'Fondo de emergencia, viaje, portatil...',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Escribe un nombre.'
                  : null,
            ),
            const SizedBox(height: AppTokens.space4),
            AmountField(
              controller: _target,
              label: _monthly ? 'Cuanto quieres apartar al mes' : 'Objetivo',
            ),
            const SizedBox(height: AppTokens.space4),
            TextFormField(
              controller: _current,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: _monthly ? 'Apartado este mes' : 'Ahorro actual',
                suffixText: '€',
                helperText: 'Dejalo vacio si todavia no lo sabes.',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                return Money.tryParse(value) == null
                    ? 'Importe no valido.'
                    : null;
              },
            ),
            // Un objetivo mensual no lleva aporte aparte ni fecha de
            // llegada: el objetivo ya es el aporte, y no hay meta final.
            if (!_monthly) ...[
              const SizedBox(height: AppTokens.space4),
              TextFormField(
                controller: _monthlyContribution,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Aporte mensual',
                  suffixText: '€',
                  helperText: 'Con esto se estima cuando llegaras.',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return Money.tryParse(value) == null
                      ? 'Importe no valido.'
                      : null;
                },
              ),
              const SizedBox(height: AppTokens.space4),
              DateField(
                label: 'Fecha deseada',
                value: _targetDate,
                helper: 'Opcional.',
                onChanged: (value) => setState(() => _targetDate = value),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppTokens.space3),
              Text(_error!, style: const TextStyle(color: AppTokens.negative)),
            ],
            const SizedBox(height: AppTokens.space5),
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
          ],
        ),
      ),
    );
  }
}

final _goalProvider = StreamProvider.family<SavingsGoal?, int>(
  (ref, id) => ref.watch(goalRepositoryProvider).watchGoal(id),
);

/// Elige entre juntar una cantidad o apartar un importe cada mes.
class _KindSelector extends StatelessWidget {
  const _KindSelector({required this.value, required this.onChanged});

  final SavingsGoalKind value;
  final ValueChanged<SavingsGoalKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader('Que clase de objetivo'),
        const SizedBox(height: AppTokens.space3),
        _Option(
          selected: value == SavingsGoalKind.amount,
          icon: Icons.flag_outlined,
          title: 'Juntar una cantidad',
          description: 'Un total al que llegar: un fondo, un viaje, un movil.',
          onTap: () => onChanged(SavingsGoalKind.amount),
        ),
        const SizedBox(height: AppTokens.space2),
        _Option(
          selected: value == SavingsGoalKind.monthly,
          icon: Icons.event_repeat_outlined,
          title: 'Apartar cada mes',
          description: 'Sin meta final: se cumple o no se cumple mes a mes.',
          onTap: () => onChanged(SavingsGoalKind.monthly),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.selected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTokens.accentSurface : AppTokens.surface,
      borderRadius: BorderRadius.circular(AppTokens.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(AppTokens.space3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            border: Border.all(
              color: selected ? AppTokens.accent : AppTokens.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? AppTokens.accentBright : AppTokens.textMuted,
              ),
              const SizedBox(width: AppTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  color: AppTokens.accent,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
