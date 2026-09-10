import 'package:flutter/material.dart';

import '../format/money.dart';
import '../theme/paliko_colors.dart';
import '../theme/paliko_typography.dart';

/// Tamaños de importe disponibles, alineados con la jerarquía tipográfica.
enum PalikoAmountSize { large, medium, small }

/// Importe monetario con color semántico y cifras tabulares.
///
/// El color lo decide el signo salvo que se fuerce con [color]: los ingresos
/// se pintan en verde, los gastos en rojo y el cero en el gris secundario,
/// de modo que una columna de importes se lea sin necesidad de iconos.
class PalikoAmount extends StatelessWidget {
  const PalikoAmount({
    required this.cents,
    this.size = PalikoAmountSize.medium,
    this.showSign = true,
    this.color,
    this.neutral = false,
    super.key,
  });

  /// Importe en céntimos. El signo determina ingreso (positivo) o gasto.
  final int cents;

  final PalikoAmountSize size;

  /// Muestra `+` / `−` delante del importe.
  final bool showSign;

  /// Fuerza un color concreto, por ejemplo para importes proyectados.
  final Color? color;

  /// Ignora la semántica de signo y usa el color de texto principal. Útil en
  /// totales que no son ni ingreso ni gasto, como un saldo objetivo.
  final bool neutral;

  Color get _semanticColor {
    if (color != null) return color!;
    if (neutral) return PalikoColors.textPrimary;
    if (cents > 0) return PalikoColors.positive;
    if (cents < 0) return PalikoColors.negative;
    return PalikoColors.textSecondary;
  }

  TextStyle get _baseStyle => switch (size) {
    PalikoAmountSize.large => PalikoTypography.amountLarge,
    PalikoAmountSize.medium => PalikoTypography.amountMedium,
    PalikoAmountSize.small => PalikoTypography.amountSmall,
  };

  @override
  Widget build(BuildContext context) {
    final String text = showSign
        ? Money.formatSigned(cents)
        : Money.format(cents);
    return Text(
      text,
      style: _baseStyle.copyWith(color: _semanticColor),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
