import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/form_fields.dart';
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
  final _monthly = TextEditingController();

  DateTime? _targetDate;
  bool _saving = false;
  bool _loaded = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _current.dispose();
    _monthly.dispose();
    super.dispose();
  }

  void _loadExisting(SavingsGoal goal) {
    if (_loaded) return;
    _loaded = true;
    _name.text = goal.name;
    _target.text = (goal.targetAmount / 100).toStringAsFixed(2);
    if (goal.currentAmount != null) {
      _current.text = (goal.currentAmount! / 100).toStringAsFixed(2);
    }
    if (goal.monthlyContribution != null) {
      _monthly.text = (goal.monthlyContribution! / 100).toStringAsFixed(2);
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
            targetAmount: target,
            // Vacio significa "no lo se", no cero.
            currentAmount: _current.text.trim().isEmpty
                ? null
                : Money.tryParse(_current.text),
            monthlyContribution: _monthly.text.trim().isEmpty
                ? null
                : Money.tryParse(_monthly.text),
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
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Fondo de emergencia, viaje, portatil...',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Escribe un nombre.'
                  : null,
            ),
            const SizedBox(height: AppTokens.space4),
            AmountField(controller: _target, label: 'Objetivo'),
            const SizedBox(height: AppTokens.space4),
            TextFormField(
              controller: _current,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Ahorro actual',
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
            const SizedBox(height: AppTokens.space4),
            TextFormField(
              controller: _monthly,
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
