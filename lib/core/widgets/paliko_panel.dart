import 'package:flutter/material.dart';

import '../theme/paliko_colors.dart';
import '../theme/paliko_spacing.dart';

/// Panel base del sistema PALIKO: superficie discreta con borde de bajo
/// contraste, sin sombras ni degradados.
///
/// Es el contenedor por defecto de cualquier bloque de contenido. Cuando
/// [onTap] está definido el panel responde al toque conservando el mismo
/// aspecto en reposo.
class PalikoPanel extends StatelessWidget {
  const PalikoPanel({
    required this.child,
    this.padding = const EdgeInsets.all(PalikoSpacing.lg),
    this.onTap,
    this.accented = false,
    this.borderColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Resalta el panel con el acento cian. Reservado para el elemento
  /// principal de una pantalla; más de uno por vista rompe la jerarquía.
  final bool accented;

  /// Sobrescribe el color del borde, por ejemplo para estados semánticos.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(PalikoRadius.lg);
    final Color resolvedBorder =
        borderColor ??
        (accented ? PalikoColors.accentDim : PalikoColors.border);

    return Material(
      color: accented ? PalikoColors.accentSurface : PalikoColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: resolvedBorder),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
