import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Informes. Pendiente de implementar en su corte.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Informes')),
      body: const FeaturePlaceholder(
        title: 'Informes',
        description: 'Esta seccion todavia no esta implementada.',
      ),
    );
  }
}
