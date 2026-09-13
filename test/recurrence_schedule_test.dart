import 'package:economy_tracker/core/database/enums.dart';
import 'package:economy_tracker/data/recurrence_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

/// Los casos de esta prueba son los que fija DEC-005 palabra por palabra.
void main() {
  RecurrenceSchedule monthly(DateTime anchor, {int interval = 1}) =>
      RecurrenceSchedule(
        anchor: anchor,
        frequency: RecurrenceFrequency.monthly,
        intervalCount: interval,
      );

  List<String> asDays(List<DateTime> dates) => dates
      .map(
        (d) =>
            '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}/${d.year}',
      )
      .toList();

  group('DEC-005 · dia nominal conservado', () {
    test('mensual dia 31 se limita sin arrastrar el dia nominal', () {
      final schedule = monthly(DateTime.utc(2026, 1, 31));
      expect(
        asDays(schedule.upcoming(from: DateTime.utc(2026, 1, 1), count: 5)),
        ['31/01/2026', '28/02/2026', '31/03/2026', '30/04/2026', '31/05/2026'],
      );
    });

    test('en ano bisiesto el limite de febrero es el 29', () {
      final schedule = monthly(DateTime.utc(2028, 1, 31));
      expect(
        asDays(schedule.upcoming(from: DateTime.utc(2028, 1, 1), count: 3)),
        ['31/01/2028', '29/02/2028', '31/03/2028'],
      );
    });

    test('anual desde un 29 de febrero', () {
      final schedule = RecurrenceSchedule(
        anchor: DateTime.utc(2028, 2, 29),
        frequency: RecurrenceFrequency.yearly,
        intervalCount: 1,
      );
      expect(
        asDays(schedule.upcoming(from: DateTime.utc(2028, 1, 1), count: 5)),
        ['29/02/2028', '28/02/2029', '28/02/2030', '28/02/2031', '29/02/2032'],
      );
    });

    test('no se permite el drift 31 ene → 28 feb → 28 mar', () {
      final schedule = monthly(DateTime.utc(2026, 1, 31));
      final march = schedule.occurrenceAt(2);
      expect(march.day, 31, reason: 'marzo debe volver al dia nominal');
    });

    test('dia 30 tambien se limita en febrero', () {
      final schedule = monthly(DateTime.utc(2026, 1, 30));
      expect(
        asDays(schedule.upcoming(from: DateTime.utc(2026, 1, 1), count: 3)),
        ['30/01/2026', '28/02/2026', '30/03/2026'],
      );
    });
  });

  group('frecuencias', () {
    test('diaria con intervalo', () {
      final schedule = RecurrenceSchedule(
        anchor: DateTime.utc(2026, 9, 1),
        frequency: RecurrenceFrequency.daily,
        intervalCount: 3,
      );
      expect(
        asDays(schedule.upcoming(from: DateTime.utc(2026, 9, 1), count: 3)),
        ['01/09/2026', '04/09/2026', '07/09/2026'],
      );
    });

    test('semanal con intervalo de dos semanas', () {
      final schedule = RecurrenceSchedule(
        anchor: DateTime.utc(2026, 9, 7),
        frequency: RecurrenceFrequency.weekly,
        intervalCount: 2,
      );
      expect(
        asDays(schedule.upcoming(from: DateTime.utc(2026, 9, 1), count: 3)),
        ['07/09/2026', '21/09/2026', '05/10/2026'],
      );
    });

    test('mensual cada tres meses', () {
      final schedule = monthly(DateTime.utc(2026, 1, 15), interval: 3);
      expect(
        asDays(schedule.upcoming(from: DateTime.utc(2026, 1, 1), count: 3)),
        ['15/01/2026', '15/04/2026', '15/07/2026'],
      );
    });
  });

  group('consultas', () {
    test('una regla inactiva no devuelve ocurrencias', () {
      final schedule = RecurrenceSchedule(
        anchor: DateTime.utc(2026, 1, 1),
        frequency: RecurrenceFrequency.monthly,
        intervalCount: 1,
        isActive: false,
      );
      expect(schedule.upcoming(from: DateTime.utc(2026, 1, 1)), isEmpty);
      expect(
        schedule.between(
          from: DateTime.utc(2026, 1, 1),
          to: DateTime.utc(2027, 1, 1),
        ),
        isEmpty,
      );
    });

    test('se respeta la fecha de fin', () {
      final schedule = RecurrenceSchedule(
        anchor: DateTime.utc(2026, 1, 10),
        frequency: RecurrenceFrequency.monthly,
        intervalCount: 1,
        endDate: DateTime.utc(2026, 3, 31),
      );
      expect(
        asDays(schedule.upcoming(from: DateTime.utc(2026, 1, 1), count: 6)),
        ['10/01/2026', '10/02/2026', '10/03/2026'],
      );
    });

    test('la consulta empieza en hoy inclusive', () {
      final schedule = monthly(DateTime.utc(2026, 1, 10));
      final dates = schedule.upcoming(
        from: DateTime.utc(2026, 3, 10),
        count: 2,
      );
      expect(asDays(dates), ['10/03/2026', '10/04/2026']);
    });

    test('un ancla antigua no desplaza el resultado', () {
      final schedule = monthly(DateTime.utc(2015, 1, 31));
      expect(
        asDays(schedule.upcoming(from: DateTime.utc(2026, 2, 1), count: 2)),
        ['28/02/2026', '31/03/2026'],
      );
    });

    test('between excluye el limite superior', () {
      final schedule = monthly(DateTime.utc(2026, 1, 1));
      final dates = schedule.between(
        from: DateTime.utc(2026, 1, 1),
        to: DateTime.utc(2026, 4, 1),
      );
      expect(asDays(dates), ['01/01/2026', '01/02/2026', '01/03/2026']);
    });

    test('nunca devuelve mas del tope por consulta', () {
      final schedule = RecurrenceSchedule(
        anchor: DateTime.utc(2026, 1, 1),
        frequency: RecurrenceFrequency.daily,
        intervalCount: 1,
      );
      final dates = schedule.between(
        from: DateTime.utc(2026, 1, 1),
        to: DateTime.utc(2030, 1, 1),
      );
      expect(dates.length, RecurrenceSchedule.maxOccurrences);
    });

    test('consultar repetidamente no cambia el resultado', () {
      final schedule = monthly(DateTime.utc(2026, 1, 31));
      final first = schedule.upcoming(from: DateTime.utc(2026, 1, 1), count: 4);
      final second = schedule.upcoming(
        from: DateTime.utc(2026, 1, 1),
        count: 4,
      );
      expect(first, second);
    });
  });
}
