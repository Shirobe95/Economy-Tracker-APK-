import 'package:flutter/material.dart';

import '../theme/paliko_colors.dart';
import '../theme/paliko_spacing.dart';

/// Encabezado de sección: etiqueta en versales y, opcionalmente, una acción
/// alineada a la derecha.
///
/// No admite subtítulos decorativos: si un bloque necesita explicación, el
/// texto va dentro del panel, no en la cabecera.
class PalikoSectionHeader extends StatelessWidget {
  const PalikoSectionHeader({
    required this.label,
    this.action,
    this.onActionTap,
    super.key,
  });

  final String label;

  /// Texto de la acción secundaria, p. ej. «Ver todo».
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: PalikoSpacing.md),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label.toUpperCase(), style: text.labelSmall)),
          if (action != null)
            GestureDetector(
              onTap: onActionTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    action!,
                    style: text.labelMedium?.copyWith(
                      color: PalikoColors.accent,
                    ),
                  ),
                  const SizedBox(width: PalikoSpacing.xxs),
                  const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: PalikoColors.accent,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
