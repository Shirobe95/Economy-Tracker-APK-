import 'package:flutter/material.dart';

import '../theme/paliko_colors.dart';
import '../theme/paliko_spacing.dart';

/// Estado vacío estándar: icono contenido, mensaje breve y una única acción.
class PalikoEmptyState extends StatelessWidget {
  const PalikoEmptyState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PalikoSpacing.xl,
        vertical: PalikoSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: PalikoColors.surfaceElevated,
              borderRadius: BorderRadius.circular(PalikoRadius.lg),
              border: Border.all(color: PalikoColors.border),
            ),
            child: Icon(icon, color: PalikoColors.textMuted, size: 26),
          ),
          const SizedBox(height: PalikoSpacing.lg),
          Text(message, style: text.bodyMedium, textAlign: TextAlign.center),
          if (actionLabel != null) ...<Widget>[
            const SizedBox(height: PalikoSpacing.lg),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
