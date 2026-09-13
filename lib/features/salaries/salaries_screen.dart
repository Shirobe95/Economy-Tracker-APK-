import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Salarios. Pendiente de implementar en su corte.
class SalariesScreen extends StatelessWidget {
  const SalariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salarios')),
      body: const FeaturePlaceholder(
        title: 'Salarios',
        description: 'Esta seccion todavia no esta implementada.',
      ),
    );
  }
}
