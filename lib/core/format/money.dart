import 'package:intl/intl.dart';

/// Formateo de importes en euros con convenciones españolas.
///
/// Los importes se manejan internamente en céntimos (enteros) para evitar los
/// errores de redondeo de coma flotante en sumas y previsiones.
abstract final class Money {
  static const String locale = 'es_ES';

  static final NumberFormat _currency = NumberFormat.currency(
    locale: locale,
    symbol: '€',
    decimalDigits: 2,
  );

  static final NumberFormat _compact = NumberFormat.currency(
    locale: locale,
    symbol: '€',
    decimalDigits: 0,
  );

  /// Formatea céntimos como importe con dos decimales: `1.234,56 €`.
  static String format(int cents) => _currency.format(cents / 100);

  /// Formatea céntimos sin decimales, para cifras grandes en gráficos y
  /// resúmenes: `1.235 €`.
  static String formatRounded(int cents) => _compact.format(cents / 100);

  /// Formatea con signo explícito, para diferenciar ingreso de gasto en una
  /// misma columna: `+1.234,56 €` / `−1.234,56 €`.
  ///
  /// Usa el signo menos tipográfico (U+2212), que se alinea con las cifras
  /// tabulares mejor que el guion.
  static String formatSigned(int cents) {
    if (cents == 0) return format(0);
    final String sign = cents > 0 ? '+' : '−';
    return '$sign${format(cents.abs())}';
  }

  /// Convierte a céntimos un importe escrito por el usuario, aceptando coma o
  /// punto como separador decimal y separadores de millar.
  ///
  /// Devuelve `null` si el texto no es un importe válido.
  static int? parse(String input) {
    final String trimmed = input.trim().replaceAll('€', '').trim();
    if (trimmed.isEmpty) return null;

    final bool negative = trimmed.startsWith('-') || trimmed.startsWith('−');
    String digits = trimmed.replaceAll(RegExp(r'[+\-−\s]'), '');

    final int lastComma = digits.lastIndexOf(',');
    final int lastDot = digits.lastIndexOf('.');
    final int decimalSeparator = lastComma > lastDot ? lastComma : lastDot;

    String integerPart;
    String decimalPart;
    if (decimalSeparator == -1) {
      integerPart = digits;
      decimalPart = '';
    } else {
      // Solo es separador decimal si deja como mucho dos cifras a la derecha;
      // en otro caso se trata de un separador de millar (p. ej. «1.234»).
      final String right = digits.substring(decimalSeparator + 1);
      if (right.length > 2) {
        integerPart = digits;
        decimalPart = '';
      } else {
        integerPart = digits.substring(0, decimalSeparator);
        decimalPart = right;
      }
    }

    integerPart = integerPart.replaceAll(RegExp(r'[.,]'), '');
    if (integerPart.isEmpty) integerPart = '0';

    if (!RegExp(r'^\d+$').hasMatch(integerPart) ||
        (decimalPart.isNotEmpty && !RegExp(r'^\d+$').hasMatch(decimalPart))) {
      return null;
    }

    final int units = int.parse(integerPart);
    final int cents = decimalPart.isEmpty
        ? 0
        : int.parse(decimalPart.padRight(2, '0'));

    final int total = units * 100 + cents;
    return negative ? -total : total;
  }
}
