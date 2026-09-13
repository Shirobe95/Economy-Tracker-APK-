import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/database/enums.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/status_indicator.dart';
import '../../data/account_repository.dart';
import '../../data/movement_repository.dart';
import '../../data/project_repository.dart';
import '../../data/salary_repository.dart';
import 'quick_create_dialogs.dart';

/// Formulario de alta y edicion de un movimiento.
///
/// Sirve para los cinco tipos: los campos que sobran para un tipo no se
/// muestran, en vez de aparecer deshabilitados.
class MovementFormScreen extends ConsumerStatefulWidget {
  const MovementFormScreen({
    super.key,
    required this.type,
    this.movementId,
    this.projectId,
    this.initialConcept,
    this.initialAmount,
    this.initialCategoryId,
    this.initialDate,
  });

  final MovementType type;

  /// Identificador del movimiento a editar, o `null` para un alta.
  final int? movementId;

  /// Proyecto al que pertenece el cobro, si viene desde su ficha.
  final int? projectId;

  /// Valores traidos del borrador rapido de la hoja de nuevo movimiento.
  final String? initialConcept;
  final int? initialAmount;
  final int? initialCategoryId;
  final DateTime? initialDate;

  @override
  ConsumerState<MovementFormScreen> createState() => _MovementFormScreenState();
}

class _MovementFormScreenState extends ConsumerState<MovementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _concept = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();

  int? _accountId;
  int? _destinationAccountId;
  int? _categoryId;
  int? _projectId;
  int? _salarySourceId;
  late MovementStatus _status;
  late DateTime _expectedDate;
  DateTime? _actualDate;

  bool _saving = false;
  bool _loaded = false;
  String? _error;

  bool get _isEditing => widget.movementId != null;

  @override
  void initState() {
    super.initState();
    _status = MovementStatus.pendiente;
    _expectedDate = widget.initialDate ?? Dates.today();
    _projectId = widget.projectId;
    _categoryId = widget.initialCategoryId;
    _concept.text = widget.initialConcept ?? '';
    if (widget.initialAmount != null) {
      _amount.text = (widget.initialAmount! / 100).toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _concept.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  /// Carga los valores del movimiento que se esta editando, una sola vez.
  void _loadExisting(Transaction movement) {
    if (_loaded) return;
    _loaded = true;
    _concept.text = movement.concept;
    _amount.text = (movement.amount / 100).toStringAsFixed(2);
    _notes.text = movement.notes ?? '';
    _accountId = movement.accountId;
    _destinationAccountId = movement.destinationAccountId;
    _categoryId = movement.categoryId;
    _projectId = movement.projectId;
    _salarySourceId = movement.salarySourceId;
    _status = movement.status;
    _expectedDate = movement.expectedDate;
    _actualDate = movement.actualDate;
  }

  String get _title => switch (widget.type) {
    MovementType.expense => _isEditing ? 'Editar gasto' : 'Nuevo gasto',
    MovementType.salary => _isEditing ? 'Editar nomina' : 'Nueva nomina',
    MovementType.projectIncome => _isEditing ? 'Editar cobro' : 'Nuevo cobro',
    MovementType.otherIncome => _isEditing ? 'Editar ingreso' : 'Nuevo ingreso',
    MovementType.transfer =>
      _isEditing ? 'Editar transferencia' : 'Nueva transferencia',
  };

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    final accountId = _accountId;
    if (accountId == null) {
      setState(() => _error = 'Elige una cuenta.');
      return;
    }
    if (widget.type == MovementType.projectIncome && _projectId == null) {
      setState(() => _error = 'Elige el proyecto al que pertenece el cobro.');
      return;
    }
    if (_status.isRealised && _actualDate == null) {
      setState(() => _error = 'Elige la fecha real en la que ocurrio.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(movementRepositoryProvider)
          .save(
            MovementDraft(
              id: widget.movementId,
              type: widget.type,
              status: _status,
              concept: _concept.text,
              amount: Money.tryParse(_amount.text) ?? 0,
              accountId: accountId,
              destinationAccountId: _destinationAccountId,
              categoryId: _categoryId,
              projectId: _projectId,
              salarySourceId: _salarySourceId,
              expectedDate: _expectedDate,
              actualDate: _status.isRealised ? _actualDate : null,
              notes: _notes.text,
            ),
          );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on MovementValidationError catch (error) {
      // Conserva lo escrito para poder corregir y reintentar.
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

    if (_isEditing) {
      final movement = ref.watch(_movementProvider(widget.movementId!));
      final value = movement.value;
      if (value != null) _loadExisting(value);
    }

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorBody(
          message: 'No se han podido cargar las cuentas.',
          detail: '$error',
        ),
        data: (rows) {
          if (rows.isEmpty) return const _NoAccountsBody();
          _accountId ??= rows.first.id;
          return _form(rows);
        },
      ),
    );
  }

  Widget _form(List<Account> accounts) {
    final statuses = MovementRepository.statusesFor(widget.type);

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
          _accountSelector(accounts),
          if (widget.type == MovementType.transfer) ...[
            const SizedBox(height: AppTokens.space4),
            _destinationSelector(accounts),
          ],
          if (widget.type == MovementType.projectIncome) ...[
            const SizedBox(height: AppTokens.space4),
            _projectSelector(),
          ],
          if (widget.type == MovementType.salary) ...[
            const SizedBox(height: AppTokens.space4),
            _salarySourceSelector(),
          ],
          if (widget.type != MovementType.transfer) ...[
            const SizedBox(height: AppTokens.space4),
            _categorySelector(),
          ],
          const SizedBox(height: AppTokens.space4),
          DateField(
            label: 'Fecha prevista',
            value: _expectedDate,
            onChanged: (value) => setState(() => _expectedDate = value),
          ),
          const SizedBox(height: AppTokens.space4),
          OptionField<MovementStatus>(
            label: 'Estado',
            value: _status,
            items: [
              for (final status in statuses)
                DropdownMenuItem(value: status, child: Text(status.label)),
            ],
            onChanged: (value) => setState(() {
              _status = value ?? _status;
              // Un estado no realizado no conserva fecha real.
              if (!_status.isRealised) _actualDate = null;
            }),
          ),
          if (_status.isRealised) ...[
            const SizedBox(height: AppTokens.space4),
            DateField(
              label: _status == MovementStatus.cobrado
                  ? 'Fecha de cobro'
                  : 'Fecha de pago',
              value: _actualDate,
              helper: 'La fecha en la que el dinero se movio de verdad.',
              onChanged: (value) => setState(() => _actualDate = value),
            ),
          ],
          const SizedBox(height: AppTokens.space4),
          TextFormField(
            controller: _notes,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Notas',
              alignLabelWithHint: true,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTokens.space4),
            _ErrorBanner(message: _error!),
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
          const SizedBox(height: AppTokens.space5),
        ],
      ),
    );
  }

  Widget _accountSelector(List<Account> accounts) {
    return Row(
      children: [
        Expanded(
          child: OptionField<int>(
            label: 'Cuenta',
            value: _accountId,
            items: [
              for (final account in accounts)
                DropdownMenuItem(value: account.id, child: Text(account.name)),
            ],
            onChanged: (value) => setState(() => _accountId = value),
          ),
        ),
        IconButton(
          onPressed: () => showCreateAccountDialog(context, ref),
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Nueva cuenta',
        ),
      ],
    );
  }

  Widget _destinationSelector(List<Account> accounts) {
    final options = accounts.where((a) => a.id != _accountId).toList();
    return OptionField<int>(
      label: 'Cuenta de destino',
      value: options.any((a) => a.id == _destinationAccountId)
          ? _destinationAccountId
          : null,
      hint: options.isEmpty ? 'Necesitas una segunda cuenta' : null,
      items: [
        for (final account in options)
          DropdownMenuItem(value: account.id, child: Text(account.name)),
      ],
      onChanged: (value) => setState(() => _destinationAccountId = value),
    );
  }

  Widget _categorySelector() {
    final kind = widget.type.isIncome
        ? CategoryKind.income
        : CategoryKind.expense;
    final categories = ref.watch(_categoriesProvider(kind));

    return categories.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const SizedBox.shrink(),
      data: (rows) => Row(
        children: [
          Expanded(
            child: OptionField<int?>(
              label: 'Categoria',
              value: rows.any((c) => c.id == _categoryId) ? _categoryId : null,
              hint: 'Opcional',
              items: [
                const DropdownMenuItem(value: null, child: Text('Sin asignar')),
                for (final category in rows)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
          ),
          IconButton(
            onPressed: () => showCreateCategoryDialog(context, ref, kind),
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Nueva categoria',
          ),
        ],
      ),
    );
  }

  Widget _projectSelector() {
    final projects = ref.watch(activeProjectsProvider);
    return projects.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const SizedBox.shrink(),
      data: (rows) {
        if (rows.isEmpty) {
          return const _InlineNotice(
            message:
                'Todavia no hay proyectos. Crea uno en Clientes y proyectos '
                'antes de registrar un cobro.',
          );
        }
        return OptionField<int>(
          label: 'Proyecto',
          value: rows.any((p) => p.project.id == _projectId)
              ? _projectId
              : null,
          items: [
            for (final summary in rows)
              DropdownMenuItem(
                value: summary.project.id,
                child: Text(
                  '${summary.client.name} · ${summary.project.name}',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) => setState(() => _projectId = value),
        );
      },
    );
  }

  Widget _salarySourceSelector() {
    final sources = ref.watch(salarySourcesProvider);
    return sources.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, _) => const SizedBox.shrink(),
      data: (rows) => OptionField<int?>(
        label: 'Fuente salarial',
        value: rows.any((s) => s.id == _salarySourceId)
            ? _salarySourceId
            : null,
        hint: rows.isEmpty ? 'Aun no hay fuentes' : 'Opcional',
        items: [
          const DropdownMenuItem(value: null, child: Text('Sin asignar')),
          for (final source in rows)
            DropdownMenuItem(value: source.id, child: Text(source.name)),
        ],
        onChanged: (value) => setState(() => _salarySourceId = value),
      ),
    );
  }
}

final _movementProvider = StreamProvider.family<Transaction?, int>(
  (ref, id) => ref.watch(movementRepositoryProvider).watchById(id),
);

final _categoriesProvider = StreamProvider.family<List<Category>, CategoryKind>(
  (ref, kind) => ref.watch(accountRepositoryProvider).watchCategories(kind),
);

class _NoAccountsBody extends ConsumerWidget {
  const _NoAccountsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: AppTokens.textMuted,
            ),
            const SizedBox(height: AppTokens.space4),
            Text(
              'Necesitas una cuenta',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppTokens.space2),
            const Text(
              'Todo movimiento pertenece a una cuenta. Crea la primera con '
              'el saldo que tengas ahora mismo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTokens.textSecondary),
            ),
            const SizedBox(height: AppTokens.space5),
            FilledButton(
              onPressed: () => showCreateAccountDialog(context, ref),
              child: const Text('Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.detail});

  final String message;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTokens.negative,
              size: 40,
            ),
            const SizedBox(height: AppTokens.space3),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppTokens.space2),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTokens.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.space3),
      decoration: BoxDecoration(
        color: AppTokens.negativeSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusControl),
        border: Border.all(color: AppTokens.negative.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTokens.negative, size: 20),
          const SizedBox(width: AppTokens.space3),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTokens.negative),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTokens.space3),
      decoration: BoxDecoration(
        color: AppTokens.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTokens.radiusControl),
        border: Border.all(color: AppTokens.border),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppTokens.textSecondary),
      ),
    );
  }
}
