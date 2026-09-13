import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Calendario. Pendiente de implementar en su corte.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      body: const FeaturePlaceholder(
        title: 'Calendario',
        description: 'Esta seccion todavia no esta implementada.',
      ),
    );
  }
}
