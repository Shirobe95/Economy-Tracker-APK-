import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Prevision. Pendiente de implementar en su corte.
class ForecastScreen extends StatelessWidget {
  const ForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prevision')),
      body: const FeaturePlaceholder(
        title: 'Prevision',
        description: 'Esta seccion todavia no esta implementada.',
      ),
    );
  }
}
