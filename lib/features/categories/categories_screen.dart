import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Categorias. Pendiente de implementar en su corte.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      body: const FeaturePlaceholder(
        title: 'Categorias',
        description: 'Esta seccion todavia no esta implementada.',
      ),
    );
  }
}
