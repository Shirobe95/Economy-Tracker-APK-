import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Gastos. Pendiente de implementar en su corte.
class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      body: const FeaturePlaceholder(
        title: 'Gastos',
        description: 'Esta seccion todavia no esta implementada.',
      ),
    );
  }
}
