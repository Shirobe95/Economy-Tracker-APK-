import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/database/app_database.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/money_text.dart';
import '../../data/reconciliation_service.dart';

/// Cuadrar el saldo de una cuenta con el del banco.
///
/// Se pregunta una sola cosa —cuanto dice el banco— y se ensena la diferencia
/// antes de anotar nada. Cuadrar escribe un movimiento de verdad, asi que es
/// una operacion que se confirma, no un campo que se edita.
Future<void> showReconcileDialog(
  BuildContext context,
  WidgetRef ref,
  Account account,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => _ReconcileDialog(account: account),
  );
}

class _ReconcileDialog extends ConsumerStatefulWidget {
  const _ReconcileDialog({required this.account});

  final Account account;

  @override
  ConsumerState<_ReconcileDialog> createState() => _ReconcileDialogState();
}

class _ReconcileDialogState extends ConsumerState<_ReconcileDialog> {
  final _controller = TextEditingController();
  Reconciliation? _preview;
  bool _working = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Cuenta las peticiones lanzadas.
  ///
  /// Se escribe mas rapido de lo que responde la base: sin esto, la respuesta
  /// de un texto antiguo puede llegar despues de la de uno nuevo y dejar en
  /// pantalla una diferencia que ya no corresponde a lo escrito.
  int _request = 0;

  /// Recalcula la diferencia segun se escribe.
  Future<void> _refresh() async {
    final token = ++_request;
    final real = Money.tryParse(_controller.text);

    if (real == null) {
      setState(() {
        _preview = null;
        _error = null;
      });
      return;
    }

    try {
      final result = await ref
          .read(reconciliationServiceProvider)
          .preview(accountId: widget.account.id, realBalance: real);
      if (!mounted || token != _request) return;
      setState(() {
        _preview = result;
        _error = null;
      });
    } catch (error) {
      if (!mounted || token != _request) return;
      // Se tira tambien la vista previa anterior: un error junto a una
      // diferencia vieja invita a confirmar algo que ya no es cierto.
      setState(() {
        _preview = null;
        _error = '$error';
      });
    }
  }

  Future<void> _confirm() async {
    final preview = _preview;
    if (preview == null || _working) return;

    // Se cuadra contra la cifra que la pantalla esta ensenando, no contra lo
    // que ponga el campo ahora mismo: si llega una respuesta a medias, lo que
    // se escribe tiene que ser lo que la persona ha visto y aprobado.
    final target = preview.realBalance;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _working = true;
      _error = null;
    });

    try {
      final id = await ref
          .read(reconciliationServiceProvider)
          .reconcile(accountId: widget.account.id, realBalance: target);

      // El aviso se manda con el messenger cogido antes de cerrar: despues
      // del pop, este contexto ya no sirve para encontrarlo.
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            id == null
                ? 'Ya cuadraba: no ha hecho falta ajustar nada.'
                : 'Saldo cuadrado.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _working = false;
        _error = '$error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _preview;

    return AlertDialog(
      backgroundColor: AppTokens.surfaceElevated,
      title: const Text('Cuadrar con el banco'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mira el saldo de ${widget.account.name} en tu banco y '
              'escribelo aqui.',
              style: const TextStyle(color: AppTokens.textSecondary),
            ),
            const SizedBox(height: AppTokens.space4),
            AmountField(
              controller: _controller,
              label: 'Saldo en el banco',
              // Un saldo puede estar en numeros rojos: si el banco dice −40,
              // no cuadrar por no poder escribirlo seria absurdo.
              allowNegative: true,
              autofocus: true,
              onChanged: (_) => _refresh(),
            ),
            if (preview != null) ...[
              const SizedBox(height: AppTokens.space4),
              _Difference(preview: preview),
            ],
            if (_error != null) ...[
              const SizedBox(height: AppTokens.space3),
              Text(_error!, style: const TextStyle(color: AppTokens.negative)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _working ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: preview == null || _working ? null : _confirm,
          child: Text(
            preview != null && preview.matches ? 'Ya cuadra' : 'Cuadrar',
          ),
        ),
      ],
    );
  }
}

/// Que va a pasar si se confirma.
class _Difference extends StatelessWidget {
  const _Difference({required this.preview});

  final Reconciliation preview;

  @override
  Widget build(BuildContext context) {
    if (preview.matches) {
      return const Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: AppTokens.positive,
          ),
          SizedBox(width: AppTokens.space2),
          Expanded(
            child: Text(
              'Ya cuadra. No hay nada que ajustar.',
              style: TextStyle(color: AppTokens.positive),
            ),
          ),
        ],
      );
    }

    final currency = preview.account.currency;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Line(
          label: 'La aplicacion dice',
          amount: preview.appBalance,
          currency: currency,
        ),
        _Line(
          label: 'El banco dice',
          amount: preview.realBalance,
          currency: currency,
        ),
        const Divider(color: AppTokens.border),
        _Line(
          label: 'Diferencia',
          amount: preview.delta,
          currency: currency,
          signed: true,
          emphasis: true,
        ),
        const SizedBox(height: AppTokens.space3),
        Text(
          preview.isGain
              ? 'Se anotara un ingreso por esa diferencia: entro dinero que '
                    'no estaba apuntado.'
              : 'Se anotara un gasto por esa diferencia: salio dinero que no '
                    'estaba apuntado.',
          style: const TextStyle(color: AppTokens.textSecondary),
        ),
        const SizedBox(height: AppTokens.space2),
        const Text(
          'Va en la categoria «Ajuste de saldo» y cuenta como cualquier otro '
          'movimiento. Asi se ve cuanto dinero se mueve sin que sepas en que.',
          style: TextStyle(color: AppTokens.textMuted),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.label,
    required this.amount,
    required this.currency,
    this.signed = false,
    this.emphasis = false,
  });

  final String label;
  final int amount;
  final String currency;
  final bool signed;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final style = emphasis
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          MoneyText(amount, currency: currency, signed: signed, style: style),
        ],
      ),
    );
  }
}
