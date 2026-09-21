import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_tokens.dart';
import '../../data/app_lock_service.dart';

/// Puntos del PIN que se van llenando al teclear.
///
/// No se ensena el numero, ni una linea de escritura, ni un punto de relleno
/// al lado de la cifra: con un campo de texto normal se veian las tres cosas a
/// la vez y el PIN quedaba medio a la vista. Aqui lo unico que sale es cuantos
/// digitos llevas.
class PinDots extends StatelessWidget {
  const PinDots({super.key, required this.length, this.slots = 4});

  /// Digitos introducidos.
  final int length;

  /// Huecos que se dibujan siempre, aunque esten vacios.
  final int slots;

  @override
  Widget build(BuildContext context) {
    final total = length > slots ? length : slots;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: _Dot(filled: i < length),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    // El punto crece un poco al llenarse. Es la unica senal de que la pulsacion
    // se ha registrado, porque el digito no se ensena.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutBack,
      width: filled ? 15 : 12,
      height: filled ? 15 : 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? AppTokens.accentBright : Colors.transparent,
        border: Border.all(
          color: filled ? AppTokens.accentBright : AppTokens.borderStrong,
          width: 1.5,
        ),
      ),
    );
  }
}

/// Teclado numerico propio.
///
/// El del sistema tapaba media pantalla y peleaba con el dialogo de huella,
/// que aparece solo al abrir. Este ocupa un sitio fijo y no se mueve.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onBiometric,
    this.enabled = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  /// Si se pasa, el hueco de abajo a la izquierda lleva a la huella.
  final VoidCallback? onBiometric;

  final bool enabled;

  /// Lado de tecla comodo, y el minimo por debajo del cual no se baja.
  static const double _preferredKey = 68;
  static const double _minKey = 48;
  static const double _gap = AppTokens.space2;

  @override
  Widget build(BuildContext context) {
    // El teclado tiene que caber tanto a pantalla completa como dentro de un
    // dialogo, que en un movil estrecho deja bastante menos ancho. Sin esto
    // las teclas de los lados se salian y no se podian pulsar.
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : _preferredKey * 3 + _gap * 6;
        final fitted = (available - _gap * 6) / 3;
        final size = fitted.clamp(_minKey, _preferredKey).toDouble();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final row in const [
              ['1', '2', '3'],
              ['4', '5', '6'],
              ['7', '8', '9'],
            ])
              _Row(
                children: [
                  for (final digit in row)
                    _Key(
                      label: digit,
                      size: size,
                      onPressed: enabled ? () => onDigit(digit) : null,
                    ),
                ],
              ),
            _Row(
              children: [
                if (onBiometric != null)
                  _Key(
                    icon: Icons.fingerprint,
                    size: size,
                    tooltip: 'Usar huella',
                    onPressed: enabled ? onBiometric : null,
                  )
                else
                  _Key(size: size),
                _Key(
                  label: '0',
                  size: size,
                  onPressed: enabled ? () => onDigit('0') : null,
                ),
                _Key(
                  icon: Icons.backspace_outlined,
                  size: size,
                  tooltip: 'Borrar',
                  onPressed: enabled ? onBackspace : null,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.space1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final child in children)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.space2),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    this.label,
    this.icon,
    this.tooltip,
    this.onPressed,
    required this.size,
  });

  final String? label;
  final IconData? icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (label == null && icon == null) {
      return SizedBox(width: size, height: size);
    }

    final button = Material(
      color: label != null ? AppTokens.surface : Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed == null
            ? null
            : () {
                // Un golpecito por tecla: sin numero a la vista, el tacto es
                // parte de saber que has pulsado.
                HapticFeedback.selectionClick();
                onPressed!();
              },
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: label != null
                ? Text(
                    label!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTokens.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : Icon(icon, color: AppTokens.textSecondary, size: 24),
          ),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Puntos + teclado, con el temblor de PIN incorrecto ya montado.
///
/// Lo usan tanto la pantalla de bloqueo como los dialogos de poner o cambiar
/// el PIN: tecleandolo siempre igual, no hay una pantalla donde el PIN se vea
/// y otra donde no.
class PinPad extends StatefulWidget {
  const PinPad({
    super.key,
    required this.value,
    required this.onChanged,
    this.onBiometric,
    this.enabled = true,
    this.shake = 0,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onBiometric;
  final bool enabled;

  /// Se incrementa desde fuera para provocar un temblor. Un booleano no
  /// valdria: dos fallos seguidos tienen que temblar dos veces.
  final int shake;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(PinPad old) {
    super.didUpdateWidget(old);
    if (widget.shake != old.shake) {
      _controller.forward(from: 0);
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _digit(String digit) {
    if (widget.value.length >= AppLockService.maxLength) return;
    widget.onChanged(widget.value + digit);
  }

  void _backspace() {
    if (widget.value.isEmpty) return;
    widget.onChanged(widget.value.substring(0, widget.value.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Tres idas y venidas que se van apagando: se lee como un «no»
            // sin necesidad de texto.
            final t = _controller.value;
            final offset = t == 0
                ? 0.0
                : 10 * (1 - t) * math.sin(t * 3 * 2 * math.pi);
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: PinDots(length: widget.value.length),
        ),
        const SizedBox(height: AppTokens.space6),
        PinKeypad(
          onDigit: _digit,
          onBackspace: _backspace,
          onBiometric: widget.onBiometric,
          enabled: widget.enabled,
        ),
      ],
    );
  }
}
