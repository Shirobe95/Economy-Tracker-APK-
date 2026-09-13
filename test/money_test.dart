import 'package:economy_tracker/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async => initializeDateFormatting('es_ES'));

  group('lectura de importes escritos a mano', () {
    test('acepta coma y punto decimal', () {
      expect(Money.tryParse('12,50'), 1250);
      expect(Money.tryParse('12.50'), 1250);
    });

    test('acepta enteros y espacios sobrantes', () {
      expect(Money.tryParse('  40 '), 4000);
      expect(Money.tryParse('0'), 0);
    });

    test('completa un solo decimal', () {
      expect(Money.tryParse('12,5'), 1250);
    });

    test('rechaza mas de dos decimales', () {
      expect(Money.tryParse('12,555'), isNull);
    });

    test('rechaza separadores de miles', () {
      expect(Money.tryParse('1.234,56'), isNull);
      expect(Money.tryParse('1 234'), isNull);
    });

    test('rechaza exponentes y texto', () {
      expect(Money.tryParse('1e3'), isNull);
      expect(Money.tryParse('doce'), isNull);
      expect(Money.tryParse(''), isNull);
      expect(Money.tryParse('12,'), isNull);
    });

    test('admite negativos, para saldos iniciales', () {
      expect(Money.tryParse('-250,75'), -25075);
    });

    test('rechaza un importe que no cabe en un entero de 64 bits', () {
      expect(Money.tryParse('99999999999999999999'), isNull);
    });

    test('no pierde precision en importes grandes', () {
      expect(Money.tryParse('92233720368547758,07'), 9223372036854775807);
    });
  });

  group('presentacion', () {
    test('usa formato espanol con simbolo de euro', () {
      expect(Money.format(123456), '1.234,56 €');
      expect(Money.format(50), '0,50 €');
    });

    test('muestra el codigo cuando la moneda no es el euro', () {
      expect(Money.format(1000, currency: 'USD'), '10,00 USD');
    });

    test('el formato con signo distingue entrada y salida', () {
      expect(Money.formatSigned(85000), '+850,00 €');
      expect(Money.formatSigned(-85000), '−850,00 €');
      expect(Money.formatSigned(0), '0,00 €');
    });

    test('el formato compacto omite decimales redondos', () {
      expect(Money.formatCompact(432000), '4.320 €');
      expect(Money.formatCompact(1199), '11,99 €');
    });
  });

  group('agregados', () {
    test('suma importes normales', () {
      expect(Money.sum([1000, 2500, -500]), 3000);
    });

    test('la suma vacia es cero', () {
      expect(Money.sum([]), 0);
    });

    test('devuelve null en vez de desbordar en silencio', () {
      final huge = List.filled(3, 9223372036854775807);
      expect(Money.sum(huge), isNull);
    });
  });
}
