import 'package:flutter/material.dart';

/// Rotulo de seccion en mayusculas, sin subtitulos ornamentales.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.label, {super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Icono circular sobre un velo de color, como en los mockups.
class RoundIcon extends StatelessWidget {
  const RoundIcon(this.icon, {super.key, required this.color, this.size = 44});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
