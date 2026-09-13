import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/enums.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/form_fields.dart';
import '../../data/account_repository.dart';

/// Alta rapida de cuenta desde cualquier formulario.
///
/// Se confirma por si misma: si despues se cancela el movimiento que la
/// necesitaba, la cuenta sigue creada. Es deliberado, no un descuido.
Future<int?> showCreateAccountDialog(BuildContext context, WidgetRef ref) {
  return showDialog<int>(
    context: context,
    builder: (context) => const _CreateAccountDialog(),
  );
}

/// Alta rapida de categoria, con el mismo criterio que la de cuenta.
Future<int?> showCreateCategoryDialog(
  BuildContext context,
  WidgetRef ref,
  CategoryKind kind,
) {
  return showDialog<int>(
    context: context,
    builder: (context) => _CreateCategoryDialog(kind: kind),
  );
}

class _CreateAccountDialog extends ConsumerStatefulWidget {
  const _CreateAccountDialog();

  @override
  ConsumerState<_CreateAccountDialog> createState() =>
      _CreateAccountDialogState();
}

class _CreateAccountDialogState extends ConsumerState<_CreateAccountDialog> {
  final _name = TextEditingController();
  final _balance = TextEditingController(text: '0');
  AccountType _type = AccountType.bank;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Escribe un nombre.');
      return;
    }
    final balance = Money.tryParse(_balance.text);
    if (balance == null) {
      setState(() => _error = 'Saldo inicial no valido.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final id = await ref
          .read(accountRepositoryProvider)
          .createAccount(name: name, type: _type, initialBalance: balance);
      if (!mounted) return;
      Navigator.of(context).pop(id);
    } catch (error) {
      setState(() {
        _saving = false;
        _error = 'No se ha podido crear: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva cuenta'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: AppTokens.space4),
            OptionField<AccountType>(
              label: 'Tipo',
              value: _type,
              items: const [
                DropdownMenuItem(
                  value: AccountType.bank,
                  child: Text('Cuenta bancaria'),
                ),
                DropdownMenuItem(
                  value: AccountType.cash,
                  child: Text('Efectivo'),
                ),
                DropdownMenuItem(
                  value: AccountType.savings,
                  child: Text('Ahorro'),
                ),
                DropdownMenuItem(value: AccountType.other, child: Text('Otra')),
              ],
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: AppTokens.space4),
            AmountField(
              controller: _balance,
              label: 'Saldo inicial',
              allowNegative: true,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppTokens.space3),
              Text(_error!, style: const TextStyle(color: AppTokens.negative)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _create,
          child: const Text('Crear'),
        ),
      ],
    );
  }
}

class _CreateCategoryDialog extends ConsumerStatefulWidget {
  const _CreateCategoryDialog({required this.kind});

  final CategoryKind kind;

  @override
  ConsumerState<_CreateCategoryDialog> createState() =>
      _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends ConsumerState<_CreateCategoryDialog> {
  final _name = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Escribe un nombre.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final id = await ref
          .read(accountRepositoryProvider)
          .createCategory(name: name, kind: widget.kind);
      if (!mounted) return;
      Navigator.of(context).pop(id);
    } catch (error) {
      setState(() {
        _saving = false;
        _error = 'No se ha podido crear: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva categoria'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppTokens.space3),
            Text(_error!, style: const TextStyle(color: AppTokens.negative)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _create,
          child: const Text('Crear'),
        ),
      ],
    );
  }
}
