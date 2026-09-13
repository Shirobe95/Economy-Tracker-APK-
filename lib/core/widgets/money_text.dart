import 'package:flutter/material.dart';

import '../../app/theme/app_tokens.dart';
import '../utils/money.dart';

/// Importe monetario con el color semantico que le corresponde.
///
/// Los colores son los del Sistema visual v0.1: verde para entradas de
/// dinero, rojo para salidas, gris para importes neutros.
class MoneyText extends StatelessWidget {
  const MoneyText(
    this.amount, {
    super.key,
    this.currency = 'EUR',
    this.signed = false,
    this.style,
    this.color,
    this.compact = false,
  });

  /// Importe en unidades menores. El signo indica la direccion cuando
  /// [signed] esta activo.
  final int amount;
  final String currency;
  final bool signed;
  final TextStyle? style;

  /// Fuerza un color concreto. Sin el, se deduce del signo.
  final Color? color;

  /// Oculta los decimales cuando el importe es redondo.
  final bool compact;

  Color get _semanticColor {
    if (color != null) return color!;
    if (!signed || amount == 0) return AppTokens.textPrimary;
    return amount > 0 ? AppTokens.positive : AppTokens.negative;
  }

  @override
  Widget build(BuildContext context) {
    final text = signed
        ? Money.formatSigned(amount, currency: currency)
        : compact
        ? Money.formatCompact(amount, currency: currency)
        : Money.format(amount, currency: currency);

    return Text(
      text,
      style: (style ?? Theme.of(context).textTheme.titleMedium)?.copyWith(
        color: _semanticColor,
      ),
    );
  }
}
