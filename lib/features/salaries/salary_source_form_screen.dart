import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/form_fields.dart';
import '../../data/salary_repository.dart';

/// Alta y edicion de una fuente salarial.
class SalarySourceFormScreen extends ConsumerStatefulWidget {
  const SalarySourceFormScreen({super.key, this.sourceId});

  final int? sourceId;

  @override
  ConsumerState<SalarySourceFormScreen> createState() =>
      _SalarySourceFormScreenState();
}

class _SalarySourceFormScreenState
    extends ConsumerState<SalarySourceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _expected = TextEditingController();

  RecurrenceFrequency? _frequency = RecurrenceFrequency.monthly;
  bool _active = true;
  bool _saving = false;
  bool _loaded = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _expected.dispose();
    super.dispose();
  }

  void _loadExisting(SalarySource source) {
    if (_loaded) return;
    _loaded = true;
    _name.text = source.name;
    if (source.expectedAmount != null) {
      _expected.text = (source.expectedAmount! / 100).toStringAsFixed(2);
    }
    _frequency = source.frequency;
    _active = source.isActive;
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final repository = ref.read(salaryRepositoryProvider);
      final id = await repository.saveSource(
        id: widget.sourceId,
        name: _name.text,
        expectedAmount: _expected.text.trim().isEmpty
            ? null
            : Money.tryParse(_expected.text),
        frequency: _frequency,
      );
      await repository.setSourceActive(id, _active);
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
    if (widget.sourceId != null) {
      final sources = ref.watch(salarySourcesProvider).value;
      final source = sources?.where((s) => s.id == widget.sourceId).firstOrNull;
      if (source != null) _loadExisting(source);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.sourceId == null ? 'Nueva fuente salarial' : 'Editar fuente',
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
                hintText: 'Nomina, empresa, cliente fijo...',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Escribe un nombre.'
                  : null,
            ),
            const SizedBox(height: AppTokens.space4),
            TextFormField(
              controller: _expected,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Importe esperado',
                suffixText: '€',
                helperText:
                    'Orientativo. Cada nomina registra su importe real.',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                return Money.tryParse(value) == null
                    ? 'Importe no valido.'
                    : null;
              },
            ),
            const SizedBox(height: AppTokens.space4),
            OptionField<RecurrenceFrequency?>(
              label: 'Frecuencia',
              value: _frequency,
              items: const [
                DropdownMenuItem(value: null, child: Text('Sin definir')),
                DropdownMenuItem(
                  value: RecurrenceFrequency.weekly,
                  child: Text('Semanal'),
                ),
                DropdownMenuItem(
                  value: RecurrenceFrequency.monthly,
                  child: Text('Mensual'),
                ),
                DropdownMenuItem(
                  value: RecurrenceFrequency.yearly,
                  child: Text('Anual'),
                ),
              ],
              onChanged: (value) => setState(() => _frequency = value),
            ),
            const SizedBox(height: AppTokens.space3),
            SwitchListTile(
              value: _active,
              onChanged: (value) => setState(() => _active = value),
              title: const Text('Fuente activa'),
              contentPadding: EdgeInsets.zero,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppTokens.space3),
              Text(_error!, style: const TextStyle(color: AppTokens.negative)),
            ],
            const SizedBox(height: AppTokens.space4),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
