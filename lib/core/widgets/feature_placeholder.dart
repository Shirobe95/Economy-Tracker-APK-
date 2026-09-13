import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';

/// Pantalla o bloque todavia sin implementar.
///
/// Indica funcionalidad pendiente de forma explicita. Nunca muestra cifras
/// inventadas ni un cero que parezca un saldo real.
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.construction_outlined,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppTokens.textMuted),
            const SizedBox(height: AppTokens.space4),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.space2),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppTokens.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado vacio dentro de una pantalla ya funcional.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.space6),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppTokens.textMuted),
          const SizedBox(height: AppTokens.space3),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppTokens.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: AppTokens.space4),
            action!,
          ],
        ],
      ),
    );
  }
}
