import '../core/database/app_database.dart';
import '../core/database/enums.dart';
import '../core/utils/dates.dart';

/// Calendario de una regla recurrente.
///
/// Politica de dias inexistentes (DEC-005):
/// `CLAMP_TO_LAST_VALID_DAY_PRESERVE_NOMINAL`. Si el dia nominal no existe en
/// el mes, se usa el ultimo dia valido, pero el dia nominal se conserva para
/// las ocurrencias siguientes. Cada fecha se calcula desde el ancla original,
/// nunca desde la fecha ajustada anterior, de modo que no hay drift:
/// 31 ene → 28 feb → 31 mar, y no 31 ene → 28 feb → 28 mar.
///
/// Este calendario solo calcula fechas. No materializa movimientos, no
/// escribe en la base y no puede duplicar gastos por consultarlo.
class RecurrenceSchedule {
  RecurrenceSchedule({
    required this.anchor,
    required this.frequency,
    required this.intervalCount,
    this.endDate,
    this.isActive = true,
  }) : assert(intervalCount > 0, 'El intervalo debe ser positivo');

  /// Ancla nominal: la fecha de inicio de la regla. Cambiar el importe no la
  /// mueve; cambiar expresamente la fecha de inicio establece una nueva.
  final DateTime anchor;
  final RecurrenceFrequency frequency;
  final int intervalCount;
  final DateTime? endDate;
  final bool isActive;

  factory RecurrenceSchedule.fromRule(RecurringRule rule) => RecurrenceSchedule(
    anchor: Dates.day(rule.startDate),
    frequency: rule.frequency,
    intervalCount: rule.intervalCount,
    endDate: rule.endDate == null ? null : Dates.day(rule.endDate!),
    isActive: rule.isActive,
  );

  /// Tope de ocurrencias que devuelve una sola consulta.
  static const int maxOccurrences = 100;

  /// Dia nominal del ancla, el que se conserva aunque un mes no lo tenga.
  int get _nominalDay => anchor.day;

  /// Fecha de la ocurrencia numero [index], contando desde cero.
  DateTime occurrenceAt(int index) {
    final anchorDay = Dates.day(anchor);
    final step = index * intervalCount;

    return switch (frequency) {
      RecurrenceFrequency.daily => anchorDay.add(Duration(days: step)),
      RecurrenceFrequency.weekly => anchorDay.add(Duration(days: step * 7)),
      RecurrenceFrequency.monthly => Dates.clampToMonth(
        anchorDay.year,
        anchorDay.month + step,
        _nominalDay,
      ),
      RecurrenceFrequency.yearly => Dates.clampToMonth(
        anchorDay.year + step,
        anchorDay.month,
        _nominalDay,
      ),
    };
  }

  /// Indice de la primera ocurrencia en [from] o posterior.
  ///
  /// Se estima aritmeticamente y se corrige en unos pocos pasos; no recorre
  /// los dias transcurridos desde un ancla antigua.
  int indexOnOrAfter(DateTime from) {
    final target = Dates.day(from);
    final anchorDay = Dates.day(anchor);
    if (!target.isAfter(anchorDay)) return 0;

    final estimate = switch (frequency) {
      RecurrenceFrequency.daily =>
        target.difference(anchorDay).inDays ~/ intervalCount,
      RecurrenceFrequency.weekly =>
        target.difference(anchorDay).inDays ~/ (intervalCount * 7),
      RecurrenceFrequency.monthly =>
        Dates.monthsBetween(anchorDay, target) ~/ intervalCount,
      RecurrenceFrequency.yearly =>
        (target.year - anchorDay.year) ~/ intervalCount,
    };

    var index = estimate < 0 ? 0 : estimate;
    // Retrocede si la estimacion se paso, y avanza si se quedo corta. El
    // ajuste es de uno o dos pasos, nunca proporcional al tiempo pasado.
    while (index > 0 && !occurrenceAt(index - 1).isBefore(target)) {
      index--;
    }
    while (occurrenceAt(index).isBefore(target)) {
      index++;
    }
    return index;
  }

  /// Proximas [count] ocurrencias desde [from], incluida esa fecha.
  ///
  /// Una regla inactiva no tiene ocurrencias. Se respeta `endDate` y el tope
  /// de [maxOccurrences].
  List<DateTime> upcoming({required DateTime from, int count = 6}) {
    if (!isActive || count <= 0) return const [];

    final limit = count > maxOccurrences ? maxOccurrences : count;
    final dates = <DateTime>[];
    var index = indexOnOrAfter(from);

    while (dates.length < limit) {
      final date = occurrenceAt(index);
      if (endDate != null && date.isAfter(endDate!)) break;
      dates.add(date);
      index++;
    }
    return dates;
  }

  /// Ocurrencias dentro de un intervalo, con [from] incluido y [to] excluido.
  ///
  /// Es la consulta que usan la previsión y el calendario para saber qué cae
  /// en una ventana de tiempo.
  List<DateTime> between({required DateTime from, required DateTime to}) {
    if (!isActive) return const [];

    final start = Dates.day(from);
    final end = Dates.day(to);
    final dates = <DateTime>[];
    var index = indexOnOrAfter(start);

    while (dates.length < maxOccurrences) {
      final date = occurrenceAt(index);
      if (!date.isBefore(end)) break;
      if (endDate != null && date.isAfter(endDate!)) break;
      dates.add(date);
      index++;
    }
    return dates;
  }
}
