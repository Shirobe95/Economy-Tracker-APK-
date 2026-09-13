/// Utilidades de fecha para importes financieros sin hora.
///
/// Las fechas se guardan como timestamps Unix. Se normalizan a medianoche
/// UTC antes de persistir para que un movimiento no cambie de dia segun la
/// zona horaria del dispositivo.
abstract final class Dates {
  const Dates._();

  /// Dia sin hora, en UTC.
  static DateTime day(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);

  /// Hoy, normalizado.
  static DateTime today() => day(DateTime.now());

  /// Primer dia del mes al que pertenece [value].
  static DateTime monthStart(DateTime value) =>
      DateTime.utc(value.year, value.month);

  /// Primer dia del mes siguiente: limite superior exclusivo de un mes.
  static DateTime nextMonthStart(DateTime value) =>
      DateTime.utc(value.year, value.month + 1);

  /// Numero de dias del mes de [value].
  static int daysInMonth(int year, int month) =>
      DateTime.utc(year, month + 1, 0).day;

  /// Mismo dia nominal en el mes indicado, limitado al ultimo dia valido.
  ///
  /// Es la regla de DEC-005: 31 de enero en febrero da el 28 o el 29, sin
  /// alterar el dia nominal de las siguientes ocurrencias.
  static DateTime clampToMonth(int year, int month, int nominalDay) {
    final normalisedYear = year + (month - 1) ~/ 12;
    final normalisedMonth = (month - 1) % 12 + 1;
    final lastDay = daysInMonth(normalisedYear, normalisedMonth);
    final day = nominalDay < lastDay ? nominalDay : lastDay;
    return DateTime.utc(normalisedYear, normalisedMonth, day);
  }

  /// Meses completos entre dos fechas, contando solo ano y mes.
  static int monthsBetween(DateTime from, DateTime to) =>
      (to.year - from.year) * 12 + (to.month - from.month);
}

/// Texto `YYYY-MM-DD` de un dia, tal como se guarda en la base.
///
/// Se usa para comparar rangos de fecha en consultas SQL, donde el orden
/// lexicografico del texto ISO coincide con el orden cronologico.
String isoDay(DateTime value) {
  final utc = value.isUtc ? value : value.toUtc();
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '${utc.year.toString().padLeft(4, '0')}-$month-$day';
}
