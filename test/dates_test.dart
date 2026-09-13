import 'package:economy_tracker/core/utils/dates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normaliza una fecha al dia en UTC', () {
    final value = Dates.day(DateTime(2026, 9, 13, 23, 45));
    expect(value, DateTime.utc(2026, 9, 13));
    expect(value.isUtc, isTrue);
  });

  test('conoce los dias de cada mes, incluido febrero bisiesto', () {
    expect(Dates.daysInMonth(2026, 2), 28);
    expect(Dates.daysInMonth(2028, 2), 29);
    expect(Dates.daysInMonth(2026, 4), 30);
    expect(Dates.daysInMonth(2026, 12), 31);
  });

  test('limita el dia nominal al ultimo dia valido del mes', () {
    expect(Dates.clampToMonth(2026, 2, 31), DateTime.utc(2026, 2, 28));
    expect(Dates.clampToMonth(2028, 2, 31), DateTime.utc(2028, 2, 29));
    expect(Dates.clampToMonth(2026, 3, 31), DateTime.utc(2026, 3, 31));
  });

  test('normaliza meses fuera de rango al ano siguiente', () {
    expect(Dates.clampToMonth(2026, 13, 15), DateTime.utc(2027, 1, 15));
    expect(Dates.clampToMonth(2026, 26, 1), DateTime.utc(2028, 2, 1));
  });

  test('calcula el inicio del mes y del siguiente', () {
    final date = DateTime.utc(2026, 9, 13);
    expect(Dates.monthStart(date), DateTime.utc(2026, 9, 1));
    expect(Dates.nextMonthStart(date), DateTime.utc(2026, 10, 1));
    expect(
      Dates.nextMonthStart(DateTime.utc(2026, 12, 5)),
      DateTime.utc(2027, 1, 1),
    );
  });

  test('cuenta meses entre dos fechas', () {
    expect(
      Dates.monthsBetween(DateTime.utc(2026, 1, 31), DateTime.utc(2026, 4, 1)),
      3,
    );
    expect(
      Dates.monthsBetween(DateTime.utc(2026, 11, 1), DateTime.utc(2027, 2, 1)),
      3,
    );
  });
}
