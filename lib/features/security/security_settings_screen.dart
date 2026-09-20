import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/widgets/finance_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/app_lock_service.dart';
import '../../data/biometric_service.dart';

/// Ajustes de bloqueo local.
class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(appLockEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bloqueo')),
      body: enabled.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (isEnabled) => ListView(
          padding: const EdgeInsets.all(AppTokens.space4),
          children: [
            FinanceCard(
              accent: true,
              child: Row(
                children: [
                  RoundIcon(
                    isEnabled ? Icons.lock_outline : Icons.lock_open_outlined,
                    color: isEnabled ? AppTokens.positive : AppTokens.textMuted,
                  ),
                  const SizedBox(width: AppTokens.space4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEnabled
                              ? 'Bloqueo activado'
                              : 'Bloqueo desactivado',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          isEnabled
                              ? 'Se pide el PIN al abrir la aplicacion.'
                              : 'Cualquiera que coja el movil puede abrirla.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            if (isEnabled) ...[
              OutlinedButton.icon(
                onPressed: () => _setPin(context, ref, changing: true),
                icon: const Icon(Icons.password_outlined),
                label: const Text('Cambiar PIN'),
              ),
              const SizedBox(height: AppTokens.space3),
              OutlinedButton.icon(
                onPressed: () => _removePin(context, ref),
                icon: const Icon(
                  Icons.lock_open_outlined,
                  color: AppTokens.negative,
                ),
                label: const Text(
                  'Quitar el bloqueo',
                  style: TextStyle(color: AppTokens.negative),
                ),
              ),
            ] else
              FilledButton.icon(
                onPressed: () => _setPin(context, ref),
                icon: const Icon(Icons.lock_outline),
                label: const Text('Activar bloqueo con PIN'),
              ),
            // La huella solo tiene sentido con un PIN detras: es un atajo
            // para no teclearlo, no un secreto aparte.
            if (isEnabled) ...[
              const SizedBox(height: AppTokens.space5),
              const SectionHeader('Huella'),
              const SizedBox(height: AppTokens.space2),
              const _BiometricCard(),
            ],
            const SizedBox(height: AppTokens.space5),
            const SectionHeader('Que protege y que no'),
            const SizedBox(height: AppTokens.space2),
            const FinanceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'El PIN impide que alguien que coja tu movil desbloqueado '
                    'abra la aplicacion y vea tus cuentas.',
                    style: TextStyle(color: AppTokens.textSecondary),
                  ),
                  SizedBox(height: AppTokens.space3),
                  Text(
                    'No cifra la base de datos. Quien tenga acceso al '
                    'almacenamiento del telefono, por ejemplo con el '
                    'dispositivo rooteado, puede leer los datos sin pasar por '
                    'el PIN. El cifrado en reposo no esta implementado.',
                    style: TextStyle(color: AppTokens.textMuted),
                  ),
                  SizedBox(height: AppTokens.space3),
                  Text(
                    'No hay forma de recuperar el PIN si lo olvidas: no hay '
                    'servidor ni cuenta desde donde restablecerlo.',
                    style: TextStyle(color: AppTokens.pending),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setPin(
    BuildContext context,
    WidgetRef ref, {
    bool changing = false,
  }) async {
    if (changing) {
      final current = await _askPin(
        context,
        title: 'PIN actual',
        confirmLabel: 'Continuar',
      );
      if (current == null) return;
      if (!context.mounted) return;
      if (!await ref.read(appLockServiceProvider).verify(current)) {
        if (!context.mounted) return;
        _toast(context, 'El PIN actual no es correcto.');
        return;
      }
    }

    if (!context.mounted) return;
    final pin = await _askPin(
      context,
      title: changing ? 'PIN nuevo' : 'Elige un PIN',
      confirmLabel: 'Guardar',
      helper: 'Entre 4 y 8 digitos. No podras recuperarlo si lo olvidas.',
    );
    if (pin == null || !context.mounted) return;

    final repeat = await _askPin(
      context,
      title: 'Repite el PIN',
      confirmLabel: 'Confirmar',
    );
    if (repeat == null || !context.mounted) return;

    if (pin != repeat) {
      _toast(context, 'Los dos PIN no coinciden.');
      return;
    }

    try {
      await ref.read(appLockServiceProvider).setPin(pin);
      ref.invalidate(appLockEnabledProvider);
      if (!context.mounted) return;
      _toast(context, 'Bloqueo activado.');
    } on ArgumentError catch (error) {
      if (!context.mounted) return;
      _toast(context, '${error.message}');
    }
  }

  Future<void> _removePin(BuildContext context, WidgetRef ref) async {
    final pin = await _askPin(
      context,
      title: 'Confirma tu PIN',
      confirmLabel: 'Quitar bloqueo',
      helper: 'La aplicacion dejara de pedirlo al abrirse.',
    );
    if (pin == null || !context.mounted) return;

    final removed = await ref.read(appLockServiceProvider).removePin(pin);
    ref.invalidate(appLockEnabledProvider);
    if (!context.mounted) return;
    _toast(
      context,
      removed ? 'Bloqueo desactivado.' : 'El PIN no es correcto.',
    );
  }

  Future<String?> _askPin(
    BuildContext context, {
    required String title,
    required String confirmLabel,
    String? helper,
  }) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (helper != null) ...[
              Text(
                helper,
                style: const TextStyle(color: AppTokens.textSecondary),
              ),
              const SizedBox(height: AppTokens.space4),
            ],
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(AppLockService.maxLength),
              ],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 10),
              onSubmitted: (value) => Navigator.of(context).pop(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(confirmLabel),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }
}

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Interruptor de desbloqueo por huella.
///
/// Solo aparece con el PIN puesto. Si el movil no admite huella, en vez de
/// esconder la opcion se dice por que: buscarla y no encontrarla es peor que
/// leer que este telefono no la tiene.
class _BiometricCard extends ConsumerWidget {
  const _BiometricCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(biometricServiceProvider);

    return FutureBuilder<BiometricUnavailable?>(
      future: service.unavailableReason(),
      builder: (context, snapshot) {
        if (!snapshot.hasData &&
            snapshot.connectionState != ConnectionState.done) {
          return const FinanceCard(child: LinearProgressIndicator());
        }

        final reason = snapshot.data;
        if (reason != null) {
          return FinanceCard(
            child: Row(
              children: [
                const RoundIcon(Icons.fingerprint, color: AppTokens.textMuted),
                const SizedBox(width: AppTokens.space4),
                Expanded(
                  child: Text(
                    reason.message,
                    style: const TextStyle(color: AppTokens.textSecondary),
                  ),
                ),
              ],
            ),
          );
        }

        final enabled = ref.watch(biometricEnabledProvider).value ?? false;

        return FinanceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RoundIcon(
                    Icons.fingerprint,
                    color: enabled ? AppTokens.positive : AppTokens.textMuted,
                  ),
                  const SizedBox(width: AppTokens.space4),
                  Expanded(
                    child: Text(
                      'Desbloquear con huella',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Switch(
                    value: enabled,
                    onChanged: (value) => _toggle(context, ref, value),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.space3),
              const Text(
                'El PIN sigue funcionando siempre. La huella solo te ahorra '
                'teclearlo: si el sensor falla, entras igual con el PIN.',
                style: TextStyle(color: AppTokens.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool value) async {
    final result = await ref.read(biometricServiceProvider).setEnabled(value);
    ref.invalidate(biometricEnabledProvider);
    if (!context.mounted) return;

    switch (result) {
      case BiometricSuccess():
        _toast(
          context,
          value ? 'Desbloqueo por huella activado.' : 'Huella desactivada.',
        );
      case BiometricCancelled():
        break;
      case BiometricFailure(:final message):
        _toast(context, message);
    }
  }
}
