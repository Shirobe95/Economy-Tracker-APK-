import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

/// Tarjeta base del sistema visual: superficie discreta con borde suave.
///
/// Todas las agrupaciones de contenido usan esta tarjeta para que la
/// jerarquia y los radios sean consistentes en toda la aplicacion.
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
            border: Border.all(
              color: accent ? AppTokens.borderStrong : AppTokens.border,
            ),
          ),
          padding: padding,
          width: double.infinity,
          child: child,
        ),
      ),
    );
  }
}
