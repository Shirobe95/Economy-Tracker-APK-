import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/widgets/section_header.dart';
import '../../data/app_lock_service.dart';
import '../../data/biometric_service.dart';
import 'pin_pad.dart';

/// Pantalla de desbloqueo.
///
/// No hay forma de saltarsela ni de recuperar el PIN: no hay servidor ni
/// cuenta desde donde restablecerlo. Quien lo olvide tendra que reinstalar y
/// restaurar una copia, y eso se avisa aqui mismo.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key, required this.onUnlocked});

  final VoidCallback onUnlocked;

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _pin = '';
  bool _checking = false;
  String? _error;
  int _failures = 0;
  int _shake = 0;
  bool _biometricTried = false;

  @override
  void initState() {
    super.initState();
    // Se pide la huella nada mas abrir: es el camino normal, y tener que
    // pulsar un boton antes para que salga el dialogo del sistema sobra.
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  /// Ofrece la huella, si esta activada.
  ///
  /// Un fallo aqui nunca cierra la puerta: se cae al PIN, que es el secreto
  /// de verdad. Cancelar no dice nada; solo se cuenta lo que la persona
  /// tendria que arreglar en los ajustes de Android.
  Future<void> _tryBiometric({bool manual = false}) async {
    if (_biometricTried && !manual) return;
    _biometricTried = true;

    final service = ref.read(biometricServiceProvider);
    if (!await service.isEnabled()) return;

    final result = await service.authenticate(
      reason: 'Desbloquea Economy Tracker',
    );
    if (!mounted) return;

    switch (result) {
      case BiometricSuccess():
        widget.onUnlocked();
      case BiometricCancelled():
        break;
      case BiometricFailure(:final message):
        setState(() => _error = message);
    }
  }

  Future<void> _unlock() async {
    if (_checking || _pin.length < AppLockService.minLength) return;

    setState(() {
      _checking = true;
      _error = null;
    });

    final ok = await ref.read(appLockServiceProvider).verify(_pin);
    if (!mounted) return;

    if (ok) {
      widget.onUnlocked();
      return;
    }

    setState(() {
      _checking = false;
      _failures++;
      _shake++;
      _error = 'PIN incorrecto.';
      _pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final biometricEnabled = ref.watch(biometricEnabledProvider).value ?? false;
    final ready = _pin.length >= AppLockService.minLength;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space4,
              vertical: AppTokens.space5,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const RoundIcon(
                  Icons.lock_outline,
                  color: AppTokens.accent,
                  size: 64,
                ),
                const SizedBox(height: AppTokens.space4),
                Text(
                  'Economy Tracker',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppTokens.space2),
                // Se reserva la altura de una linea para que un «PIN
                // incorrecto» no empuje el teclado y mueva la tecla que ibas
                // a pulsar. Pero solo el minimo: los avisos de la huella
                // ocupan tres lineas, y recortarlos dejaria a la vista un
                // trozo de frase que no se entiende.
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 22),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Text(
                      _error ?? 'Introduce tu PIN',
                      key: ValueKey(_error),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _error == null
                            ? AppTokens.textSecondary
                            : AppTokens.negative,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTokens.space5),
                PinPad(
                  value: _pin,
                  enabled: !_checking,
                  shake: _shake,
                  onBiometric: biometricEnabled
                      ? () => _tryBiometric(manual: true)
                      : null,
                  onChanged: (value) => setState(() {
                    _pin = value;
                    _error = null;
                  }),
                ),
                const SizedBox(height: AppTokens.space5),
                SizedBox(
                  width: 232,
                  child: FilledButton(
                    onPressed: ready && !_checking ? _unlock : null,
                    child: _checking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Desbloquear'),
                  ),
                ),
                // El aviso aparece cuando ya se ha intentado unas cuantas
                // veces: antes solo seria ruido.
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: _failures < 3
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: AppTokens.space5),
                          child: Container(
                            padding: const EdgeInsets.all(AppTokens.space3),
                            decoration: BoxDecoration(
                              color: AppTokens.surface,
                              borderRadius: BorderRadius.circular(
                                AppTokens.radiusControl,
                              ),
                              border: Border.all(color: AppTokens.border),
                            ),
                            child: const Text(
                              'No hay forma de recuperar el PIN: la '
                              'aplicacion no tiene servidor ni cuenta. Si lo '
                              'has olvidado, tendras que reinstalar y '
                              'restaurar una copia de seguridad.',
                              style: TextStyle(color: AppTokens.textSecondary),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Envuelve la aplicacion y exige el PIN si el bloqueo esta activado.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    final enabled = ref.watch(appLockEnabledProvider);

    return enabled.when(
      // Mientras se consulta no se enseña nada de la aplicación: un destello
      // del saldo antes de pedir el PIN haría inútil el bloqueo.
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => widget.child,
      data: (isEnabled) {
        if (!isEnabled || _unlocked) return widget.child;
        return LockScreen(onUnlocked: () => setState(() => _unlocked = true));
      },
    );
  }
}
