import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Ingresos. Pendiente de implementar en su corte.
class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresos')),
      body: const FeaturePlaceholder(
        title: 'Ingresos',
        description: 'Esta seccion todavia no esta implementada.',
      ),
    );
  }
}
