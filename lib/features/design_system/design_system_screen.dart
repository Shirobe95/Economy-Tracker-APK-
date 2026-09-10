import 'package:flutter/material.dart';

import '../../core/theme/paliko_colors.dart';
import '../../core/theme/paliko_spacing.dart';
import '../../core/theme/paliko_typography.dart';
import '../../core/widgets/paliko_amount.dart';
import '../../core/widgets/paliko_empty_state.dart';
import '../../core/widgets/paliko_panel.dart';
import '../../core/widgets/paliko_section_header.dart';

/// Pantalla de referencia del sistema visual PALIKO.
///
/// Sirve para validar el estilo en el dispositivo antes de construir las
/// pantallas reales. Los importes son de muestra y están marcados como tales;
/// esta pantalla desaparecerá cuando la navegación definitiva ocupe su lugar.
class DesignSystemScreen extends StatefulWidget {
  const DesignSystemScreen({super.key});

  @override
  State<DesignSystemScreen> createState() => _DesignSystemScreenState();
}

class _DesignSystemScreenState extends State<DesignSystemScreen> {
  int _selectedPeriod = 0;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema visual'),
        actions: <Widget>[
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ajustes',
          ),
          const SizedBox(width: PalikoSpacing.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          PalikoSpacing.screenPadding,
          PalikoSpacing.sm,
          PalikoSpacing.screenPadding,
          PalikoSpacing.xxxl,
        ),
        children: <Widget>[
          const PalikoSectionHeader(label: 'Saldo del periodo'),
          PalikoPanel(
            accented: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Septiembre 2026', style: text.bodySmall),
                const SizedBox(height: PalikoSpacing.sm),
                const PalikoAmount(
                  cents: 128450,
                  size: PalikoAmountSize.large,
                  showSign: false,
                  neutral: true,
                ),
                const SizedBox(height: PalikoSpacing.lg),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _MiniStat(
                        label: 'Ingresos',
                        cents: 245000,
                        color: PalikoColors.positive,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: PalikoColors.border,
                      margin: const EdgeInsets.symmetric(
                        horizontal: PalikoSpacing.lg,
                      ),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: 'Gastos',
                        cents: -116550,
                        color: PalikoColors.negative,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: PalikoSpacing.sectionGap),

          const PalikoSectionHeader(label: 'Periodo'),
          SegmentedButton<int>(
            segments: const <ButtonSegment<int>>[
              ButtonSegment<int>(value: 0, label: Text('Mes')),
              ButtonSegment<int>(value: 1, label: Text('Trimestre')),
              ButtonSegment<int>(value: 2, label: Text('Año')),
            ],
            selected: <int>{_selectedPeriod},
            showSelectedIcon: false,
            onSelectionChanged: (Set<int> selection) {
              setState(() => _selectedPeriod = selection.first);
            },
          ),
          const SizedBox(height: PalikoSpacing.sectionGap),

          const PalikoSectionHeader(label: 'Movimientos', action: 'Ver todo'),
          PalikoPanel(
            padding: const EdgeInsets.symmetric(vertical: PalikoSpacing.xs),
            child: Column(
              children: const <Widget>[
                _MovementRow(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Supermercado',
                  subtitle: 'Alimentación · Hoy',
                  cents: -4235,
                ),
                Divider(indent: PalikoSpacing.lg, endIndent: PalikoSpacing.lg),
                _MovementRow(
                  icon: Icons.work_outline,
                  title: 'Cobro proyecto',
                  subtitle: 'Freelance · Ayer',
                  cents: 90000,
                ),
                Divider(indent: PalikoSpacing.lg, endIndent: PalikoSpacing.lg),
                _MovementRow(
                  icon: Icons.home_outlined,
                  title: 'Alquiler',
                  subtitle: 'Vivienda · 1 sept',
                  cents: -75000,
                ),
              ],
            ),
          ),
          const SizedBox(height: PalikoSpacing.sectionGap),

          const PalikoSectionHeader(label: 'Previsión'),
          PalikoPanel(
            borderColor: PalikoColors.forecast,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.timeline,
                      size: 18,
                      color: PalikoColors.forecast,
                    ),
                    const SizedBox(width: PalikoSpacing.sm),
                    Text(
                      'Saldo proyectado a 3 meses',
                      style: text.titleSmall?.copyWith(
                        color: PalikoColors.forecast,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: PalikoSpacing.md),
                const PalikoAmount(
                  cents: 341200,
                  size: PalikoAmountSize.large,
                  showSign: false,
                  color: PalikoColors.forecast,
                ),
                const SizedBox(height: PalikoSpacing.sm),
                Text(
                  'Dato simulado a partir de recurrentes y media de gasto',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: PalikoSpacing.sectionGap),

          const PalikoSectionHeader(label: 'Objetivos'),
          PalikoPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Fondo de emergencia',
                        style: text.titleSmall,
                      ),
                    ),
                    Text('68 %', style: PalikoTypography.amountSmall),
                  ],
                ),
                const SizedBox(height: PalikoSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(PalikoRadius.pill),
                  child: const LinearProgressIndicator(
                    value: 0.68,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: PalikoSpacing.sm),
                Text('3.400 € de 5.000 €', style: text.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: PalikoSpacing.sectionGap),

          const PalikoSectionHeader(label: 'Estado vacío'),
          PalikoPanel(
            padding: EdgeInsets.zero,
            child: PalikoEmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'Todavía no hay movimientos en este periodo.',
              actionLabel: 'Añadir movimiento',
              onAction: () {},
            ),
          ),
          const SizedBox(height: PalikoSpacing.sectionGap),

          const PalikoSectionHeader(label: 'Acciones'),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('Guardar'),
                ),
              ),
              const SizedBox(width: PalikoSpacing.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Nuevo movimiento',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.cents,
    required this.color,
  });

  final String label;
  final int cents;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: PalikoSpacing.xxs),
        PalikoAmount(cents: cents, showSign: false, color: color),
      ],
    );
  }
}

class _MovementRow extends StatelessWidget {
  const _MovementRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cents,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final int cents;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: PalikoColors.surfaceElevated,
          borderRadius: BorderRadius.circular(PalikoRadius.md),
          border: Border.all(color: PalikoColors.border),
        ),
        child: Icon(icon, size: 20, color: PalikoColors.textSecondary),
      ),
      title: Text(title, style: text.bodyLarge),
      subtitle: Text(subtitle, style: text.bodySmall),
      trailing: PalikoAmount(cents: cents),
    );
  }
}
