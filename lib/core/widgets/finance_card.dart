import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

/// Tarjeta base del sistema visual: plana, sin contorno, con una sombra
/// minima que la delimita.
///
/// Todas las agrupaciones de contenido usan esta tarjeta para que la
/// jerarquia y los radios sean consistentes en toda la aplicacion. Hasta
/// DEC-017 llevaba un borde; se quito a favor de una sombra suave, que
/// separa sin el ruido de un contorno duro.
class FinanceCard extends StatelessWidget {
  const FinanceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTokens.space4),
    this.onTap,
    this.accent = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Destaca la tarjeta con el acento, para la metrica principal de una
  /// pantalla. Se usa como mucho una vez por pantalla.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppTokens.radiusCard);
    return Material(
      color: accent ? AppTokens.surfaceElevated : AppTokens.surface,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: const Color(0x33000000),
                blurRadius: accent ? 20 : 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: padding,
          width: double.infinity,
          child: child,
        ),
      ),
    );
  }
}
