import 'package:flutter/material.dart';

/// Aparicion suave de un elemento de lista.
///
/// Se anima **una sola vez, al entrar**, no en cada reconstruccion. Las listas
/// de esta aplicacion cuelgan de streams y se reconstruyen a cada cambio de la
/// base: animar en cada build convertiria pagar un gasto en un parpadeo de
/// toda la pantalla.
///
/// Para que funcione, cada fila necesita una clave estable —`ValueKey` con el
/// id del movimiento, por ejemplo—. Sin ella Flutter reutiliza el estado de
/// otra fila y la animacion se salta o se repite donde no toca.
class FadeIn extends StatefulWidget {
  const FadeIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 8,
  });

  final Widget child;

  /// Retraso, para escalonar una lista.
  final Duration delay;

  /// Cuanto sube el elemento al entrar, en pixeles.
  final double offset;

  @override
  State<FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  /// Se crea una sola vez, no en `build`.
  ///
  /// CurvedAnimation se suscribe al controlador al construirse. Estas listas
  /// cuelgan de streams y se reconstruyen con cada cambio de la base, asi que
  /// crearla en build iba dejando un oyente por fila y por reconstruccion.
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        // La lista puede haber cambiado mientras se esperaba.
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    // El orden importa: la curva se desengancha del controlador antes de que
    // este desaparezca.
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: AnimatedBuilder(
        animation: _curve,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, widget.offset * (1 - _curve.value)),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Escalona la aparicion de una lista corta.
///
/// Se corta a los pocos elementos: con veinte filas, el ultimo tardaria casi
/// un segundo en aparecer y eso ya no es sutil, es lento.
Duration staggerDelay(int index, {int max = 6}) =>
    Duration(milliseconds: 40 * (index < max ? index : max));
