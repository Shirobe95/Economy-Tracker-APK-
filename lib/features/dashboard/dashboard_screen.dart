import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Inicio. Pendiente de implementar en su corte.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: const FeaturePlaceholder(
        title: 'Inicio',
        description: 'Esta seccion todavia no esta implementada.',
      ),
    );
  }
}
