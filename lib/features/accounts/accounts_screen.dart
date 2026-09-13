import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Cuentas. Pendiente de implementar en su corte.
class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuentas')),
      body: const FeaturePlaceholder(
        title: 'Cuentas',
        description: 'Esta seccion todavia no esta implementada.',
      ),
    );
  }
}
