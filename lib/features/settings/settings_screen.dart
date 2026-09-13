import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Ajustes. Pendiente de implementar en su corte.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: const FeaturePlaceholder(
        title: 'Ajustes',
        description: 'Esta seccion todavia no esta implementada.',
      ),
    );
  }
}
