import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/form_fields.dart';
import '../../data/project_repository.dart';
import 'projects_screen.dart';

/// Alta y edicion de un cliente.
class ClientFormScreen extends ConsumerStatefulWidget {
  const ClientFormScreen({super.key, this.clientId});

  final int? clientId;

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  bool _saving = false;
  bool _loaded = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    super.dispose();
  }

  void _loadExisting(Client client) {
    if (_loaded) return;
    _loaded = true;
    _name.text = client.name;
    _contact.text = client.contact ?? '';
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(projectRepositoryProvider)
          .saveClient(
            id: widget.clientId,
            name: _name.text,
            contact: _contact.text,
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
    if (widget.clientId != null) {
      final client = ref.watch(clientProvider(widget.clientId!)).value;
      if (client != null) _loadExisting(client);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.clientId == null ? 'Nuevo cliente' : 'Editar cliente',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Escribe un nombre.'
                  : null,
            ),
            const SizedBox(height: AppTokens.space4),
            TextFormField(
              controller: _contact,
              decoration: const InputDecoration(
                labelText: 'Contacto',
                helperText: 'Opcional: correo, telefono o persona de contacto.',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppTokens.space3),
              Text(_error!, style: const TextStyle(color: AppTokens.negative)),
            ],
            const SizedBox(height: AppTokens.space5),
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

/// Alta y edicion de un proyecto de un cliente.
class ProjectFormScreen extends ConsumerStatefulWidget {
  const ProjectFormScreen({super.key, this.projectId, this.clientId});

  final int? projectId;
  final int? clientId;

  @override
  ConsumerState<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends ConsumerState<ProjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _estimated = TextEditingController();

  int? _clientId;
  BillingType? _billingType;
  bool _saving = false;
  bool _loaded = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _clientId = widget.clientId;
  }

  @override
  void dispose() {
    _name.dispose();
    _estimated.dispose();
    super.dispose();
  }

  void _loadExisting(Project project) {
    if (_loaded) return;
    _loaded = true;
    _name.text = project.name;
    _clientId = project.clientId;
    _billingType = project.billingType;
    if (project.estimatedAmount != null) {
      _estimated.text = (project.estimatedAmount! / 100).toStringAsFixed(2);
    }
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final clientId = _clientId;
    if (clientId == null) {
      setState(() => _error = 'Elige un cliente.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(projectRepositoryProvider)
          .saveProject(
            id: widget.projectId,
            clientId: clientId,
            name: _name.text,
            billingType: _billingType,
            estimatedAmount: _estimated.text.trim().isEmpty
                ? null
                : Money.tryParse(_estimated.text),
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
    final clients = ref.watch(clientsProvider);

    if (widget.projectId != null) {
      final project = ref.watch(projectFormProvider(widget.projectId!)).value;
      if (project != null) _loadExisting(project);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.projectId == null ? 'Nuevo proyecto' : 'Editar proyecto',
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
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Escribe un nombre.'
                  : null,
            ),
            const SizedBox(height: AppTokens.space4),
            OptionField<int>(
              label: 'Cliente',
              value: _clientId,
              items: [
                for (final client in clients.value ?? const <Client>[])
                  DropdownMenuItem(value: client.id, child: Text(client.name)),
              ],
              onChanged: (value) => setState(() => _clientId = value),
            ),
            const SizedBox(height: AppTokens.space4),
            OptionField<BillingType?>(
              label: 'Modalidad',
              value: _billingType,
              hint: 'Opcional',
              items: const [
                DropdownMenuItem(value: null, child: Text('Sin definir')),
                DropdownMenuItem(
                  value: BillingType.fixed,
                  child: Text('Precio cerrado'),
                ),
                DropdownMenuItem(
                  value: BillingType.hourly,
                  child: Text('Por horas'),
                ),
                DropdownMenuItem(
                  value: BillingType.monthly,
                  child: Text('Mensualidad'),
                ),
                DropdownMenuItem(
                  value: BillingType.perUnit,
                  child: Text('Por unidad'),
                ),
              ],
              onChanged: (value) => setState(() => _billingType = value),
            ),
            const SizedBox(height: AppTokens.space4),
            TextFormField(
              controller: _estimated,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Importe orientativo',
                suffixText: '€',
                helperText:
                    'Solo como referencia. Lo que cuenta es el importe real '
                    'de cada cobro.',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                return Money.tryParse(value) == null
                    ? 'Importe no valido.'
                    : null;
              },
            ),
            if (_error != null) ...[
              const SizedBox(height: AppTokens.space3),
              Text(_error!, style: const TextStyle(color: AppTokens.negative)),
            ],
            const SizedBox(height: AppTokens.space5),
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

final projectFormProvider = StreamProvider.family<Project?, int>(
  (ref, id) => ref.watch(projectRepositoryProvider).watchProject(id),
);
