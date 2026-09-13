import 'package:economy_tracker/data/app_lock_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late AppLockService lock;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    lock = AppLockService(SharedPreferencesAsync());
  });

  group('formato del PIN', () {
    test('acepta de cuatro a ocho digitos', () {
      expect(AppLockService.validateFormat('1234'), isNull);
      expect(AppLockService.validateFormat('12345678'), isNull);
    });

    test('rechaza demasiado corto o demasiado largo', () {
      expect(AppLockService.validateFormat('123'), isNotNull);
      expect(AppLockService.validateFormat('123456789'), isNotNull);
    });

    test('rechaza lo que no sean numeros', () {
      expect(AppLockService.validateFormat('12a4'), isNotNull);
      expect(AppLockService.validateFormat('  12'), isNotNull);
    });

    test('rechaza un PIN de digitos repetidos', () {
      expect(AppLockService.validateFormat('1111'), isNotNull);
      expect(AppLockService.validateFormat('000000'), isNotNull);
    });
  });

  group('activacion', () {
    test('empieza desactivado', () async {
      expect(await lock.isEnabled(), isFalse);
    });

    test('queda activado tras establecer el PIN', () async {
      await lock.setPin('2468');
      expect(await lock.isEnabled(), isTrue);
    });

    test('no acepta un PIN con formato invalido', () async {
      await expectLater(lock.setPin('11'), throwsArgumentError);
      expect(await lock.isEnabled(), isFalse);
    });
  });

  group('verificacion', () {
    test('acepta el PIN correcto y rechaza el resto', () async {
      await lock.setPin('2468');

      expect(await lock.verify('2468'), isTrue);
      expect(await lock.verify('2469'), isFalse);
      expect(await lock.verify(''), isFalse);
    });

    test('sin PIN establecido no verifica nada', () async {
      expect(await lock.verify('2468'), isFalse);
    });

    test('cambiar el PIN invalida el anterior', () async {
      await lock.setPin('2468');
      await lock.setPin('1357');

      expect(await lock.verify('2468'), isFalse);
      expect(await lock.verify('1357'), isTrue);
    });
  });

  group('retirada', () {
    test('exige el PIN actual', () async {
      await lock.setPin('2468');

      expect(await lock.removePin('0000'), isFalse);
      expect(await lock.isEnabled(), isTrue);

      expect(await lock.removePin('2468'), isTrue);
      expect(await lock.isEnabled(), isFalse);
    });
  });

  group('almacenamiento', () {
    test('no guarda el PIN en claro', () async {
      final preferences = SharedPreferencesAsync();
      await lock.setPin('2468');

      final stored = await preferences.getAll();
      for (final value in stored.values) {
        expect('$value', isNot(contains('2468')));
      }
    });

    test('dos PIN iguales producen huellas distintas', () async {
      await lock.setPin('2468');
      final first = await SharedPreferencesAsync().getString('app_lock_hash');

      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      await AppLockService(SharedPreferencesAsync()).setPin('2468');
      final second = await SharedPreferencesAsync().getString('app_lock_hash');

      // La sal aleatoria impide reconocer que dos personas usan el mismo PIN.
      expect(first, isNotNull);
      expect(first, isNot(second));
    });
  });
}
