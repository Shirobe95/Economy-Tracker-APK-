import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_tokens.dart';
import '../../core/widgets/section_header.dart';
import '../../data/app_lock_service.dart';

/// Pantalla de desbloqueo por PIN.
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
  final _controller = TextEditingController();
  bool _checking = false;
  String? _error;
  int _failures = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_checking) return;
    final pin = _controller.text;
    if (pin.isEmpty) return;

    setState(() {
      _checking = true;
      _error = null;
    });

    final ok = await ref.read(appLockServiceProvider).verify(pin);
    if (!mounted) return;

    if (ok) {
      widget.onUnlocked();
      return;
    }

    setState(() {
      _checking = false;
      _failures++;
      _error = 'PIN incorrecto.';
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTokens.spacePage),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const RoundIcon(
                Icons.lock_outline,
                color: AppTokens.accent,
                size: 72,
              ),
              const SizedBox(height: AppTokens.space5),
              Text(
                'Economy Tracker',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTokens.space2),
              const Text(
                'Introduce tu PIN para continuar.',
                style: TextStyle(color: AppTokens.textSecondary),
              ),
              const SizedBox(height: AppTokens.space6),
              TextField(
                controller: _controller,
                autofocus: true,
                obscureText: true,
                enabled: !_checking,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(AppLockService.maxLength),
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 12),
                decoration: const InputDecoration(hintText: '••••'),
                onSubmitted: (_) => _unlock(),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppTokens.space3),
                Text(
                  _error!,
                  style: const TextStyle(color: AppTokens.negative),
                ),
              ],
              const SizedBox(height: AppTokens.space5),
              FilledButton(
                onPressed: _checking ? null : _unlock,
                child: _checking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Desbloquear'),
              ),
              if (_failures >= 3) ...[
                const SizedBox(height: AppTokens.space5),
                Container(
                  padding: const EdgeInsets.all(AppTokens.space3),
                  decoration: BoxDecoration(
                    color: AppTokens.surface,
                    borderRadius: BorderRadius.circular(
                      AppTokens.radiusControl,
                    ),
                    border: Border.all(color: AppTokens.border),
                  ),
                  child: const Text(
                    'No hay forma de recuperar el PIN: la aplicacion no tiene '
                    'servidor ni cuenta. Si lo has olvidado, tendras que '
                    'reinstalar y restaurar una copia de seguridad.',
                    style: TextStyle(color: AppTokens.textSecondary),
                  ),
                ),
              ],
            ],
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
