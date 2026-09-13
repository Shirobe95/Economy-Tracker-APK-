import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Objetivos. Pendiente de implementar en su corte.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Objetivos')),
      body: const FeaturePlaceholder(
        title: 'Objetivos',
        description: 'Esta seccion todavia no esta implementada.',
      ),
    );
  }
}
