import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Clientes y proyectos. Pendiente de implementar en su corte.
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes y proyectos')),
      body: const FeaturePlaceholder(
        title: 'Clientes y proyectos',
        description: 'Esta seccion todavia no esta implementada.',
      ),
    );
  }
}
