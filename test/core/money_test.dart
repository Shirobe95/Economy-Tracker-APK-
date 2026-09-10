import 'package:economy_tracker/core/format/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money.format', () {
    test('formatea céntimos con dos decimales', () {
      expect(Money.format(123456), contains('1.234,56'));
      expect(Money.format(0), contains('0,00'));
    });

    test('formatea negativos', () {
      expect(Money.format(-500), contains('5,00'));
      expect(Money.format(-500), startsWith('-'));
    });

    test('formatRounded omite decimales', () {
      expect(Money.formatRounded(123456), contains('1.235'));
      expect(Money.formatRounded(123456), isNot(contains(',')));
    });
  });

  group('Money.formatSigned', () {
    test('añade signo explícito', () {
      expect(Money.formatSigned(1000), startsWith('+'));
      expect(Money.formatSigned(-1000), startsWith('−'));
    });

    test('el cero no lleva signo', () {
      expect(Money.formatSigned(0), isNot(startsWith('+')));
      expect(Money.formatSigned(0), isNot(startsWith('−')));
    });
  });

  group('Money.parse', () {
    test('acepta coma decimal', () {
      expect(Money.parse('12,34'), 1234);
      expect(Money.parse('0,05'), 5);
    });

    test('acepta punto decimal', () {
      expect(Money.parse('12.34'), 1234);
    });

    test('acepta un solo decimal y lo completa', () {
      expect(Money.parse('12,5'), 1250);
    });

    test('trata el punto como separador de millar', () {
      expect(Money.parse('1.234'), 123400);
      expect(Money.parse('1.234,56'), 123456);
    });

    test('acepta enteros sin decimales', () {
      expect(Money.parse('40'), 4000);
    });

    test('acepta el símbolo de euro y espacios', () {
      expect(Money.parse(' 40,00 € '), 4000);
    });

    test('conserva el signo negativo', () {
      expect(Money.parse('-12,34'), -1234);
      expect(Money.parse('−12,34'), -1234);
    });

    test('rechaza texto no numérico', () {
      expect(Money.parse('abc'), isNull);
      expect(Money.parse(''), isNull);
      expect(Money.parse('12,3a'), isNull);
    });

    test('ida y vuelta con format', () {
      for (final int cents in <int>[0, 5, 999, 123456, -4235]) {
        expect(Money.parse(Money.format(cents)), cents);
      }
    });
  });
}
