import 'package:intl/intl.dart';

/// Importes en unidades menores de la moneda (para EUR, centimos).
///
/// Nunca se usa `double` para dinero. Las sumas de varios importes pasan por
/// [BigInt] para no desbordar al agregar muchos enteros de 64 bits.
abstract final class Money {
  const Money._();

  /// Limite de un entero de 64 bits con signo, que es lo que admite SQLite.
  static final BigInt maxAmount = BigInt.parse('9223372036854775807');
  static final BigInt minAmount = BigInt.parse('-9223372036854775808');

  static final NumberFormat _decimal = NumberFormat('#,##0.00', 'es_ES');

  /// Formatea centimos con dos decimales y el simbolo de la moneda.
  ///
  /// Solo se conoce el simbolo del euro; cualquier otra moneda se muestra con
  /// su codigo, en vez de inventar un simbolo.
  static String format(int amount, {String currency = 'EUR'}) {
    final text = _decimal.format(amount / 100);
    return currency == 'EUR' ? '$text €' : '$text $currency';
  }

  /// Formatea con signo explicito. Util en listas donde conviven entradas y
  /// salidas de dinero.
  static String formatSigned(int amount, {String currency = 'EUR'}) {
    final body = format(amount.abs(), currency: currency);
    if (amount == 0) return body;
    return amount > 0 ? '+$body' : '−$body';
  }

  /// Formatea sin decimales cuando el importe es redondo, para titulares.
  static String formatCompact(int amount, {String currency = 'EUR'}) {
    if (amount % 100 != 0) return format(amount, currency: currency);
    final text = NumberFormat('#,##0', 'es_ES').format(amount ~/ 100);
    return currency == 'EUR' ? '$text €' : '$text $currency';
  }

  /// Convierte texto escrito por una persona a centimos.
  ///
  /// Admite coma o punto como separador decimal y espacios sobrantes.
  /// Rechaza separadores de miles, exponentes, mas de dos decimales y
  /// cualquier valor que no quepa en un entero de 64 bits.
  /// Devuelve `null` si el texto no es un importe valido.
  static int? tryParse(String input) {
    final text = input.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;

    final match = RegExp(r'^(-?)(\d+)(?:\.(\d{1,2}))?$').firstMatch(text);
    if (match == null) return null;

    final negative = match.group(1) == '-';
    final units = BigInt.parse(match.group(2)!);
    final fraction = (match.group(3) ?? '').padRight(2, '0');

    var cents = units * BigInt.from(100) + BigInt.parse(fraction);
    if (negative) cents = -cents;
    if (cents > maxAmount || cents < minAmount) return null;

    return cents.toInt();
  }

  /// Suma una lista de importes protegiendo del desbordamiento.
  ///
  /// Devuelve `null` si el total no cabe en un entero de 64 bits, en vez de
  /// dar la vuelta en silencio.
  static int? sum(Iterable<int> amounts) {
    var total = BigInt.zero;
    for (final amount in amounts) {
      total += BigInt.from(amount);
    }
    if (total > maxAmount || total < minAmount) return null;
    return total.toInt();
  }
}
