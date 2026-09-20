import 'package:economy_tracker/data/biometric_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_platform_interface/types/auth_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Huella como atajo del PIN.
///
/// Lo que se prueba aqui es la logica, no el sensor: que activar exija
/// identificarse, que un movil sin huella lo diga en vez de callarse, y que
/// nada de esto pueda dejar a nadie fuera de su propia aplicacion.
class _FakeAuth implements LocalAuthentication {
  /// Un movil con sensor y una huella registrada, que es el caso normal.
  /// Cada test cambia lo que necesita.
  bool supported = true;
  bool canCheck = true;
  List<BiometricType> enrolled = const [BiometricType.fingerprint];
  bool result = true;
  PlatformException? throws;

  int authenticateCalls = 0;
  String? lastReason;

  @override
  Future<bool> get canCheckBiometrics async => canCheck;

  @override
  Future<bool> isDeviceSupported() async => supported;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (throws != null) throw throws!;
    return enrolled;
  }

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<AuthMessages> authMessages = const [],
    AuthenticationOptions options = const AuthenticationOptions(),
  }) async {
    authenticateCalls++;
    lastReason = localizedReason;
    if (throws != null) throw throws!;
    return result;
  }

  @override
  Future<bool> stopAuthentication() async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeAuth auth;
  late BiometricService service;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    auth = _FakeAuth();
    service = BiometricService(auth, SharedPreferencesAsync());
  });

  group('disponibilidad', () {
    test('con sensor y huella registrada, esta disponible', () async {
      expect(await service.unavailableReason(), isNull);
      expect(await service.isAvailable(), isTrue);
    });

    test('sin sensor lo dice, en vez de esconder la opcion', () async {
      auth.supported = false;

      final reason = await service.unavailableReason();
      expect(reason, BiometricUnavailable.noHardware);
      expect(reason!.message, contains('no tiene lector'));
    });

    test(
      'con sensor pero sin huella registrada, manda a los ajustes',
      () async {
        auth.enrolled = const [];

        final reason = await service.unavailableReason();
        expect(reason, BiometricUnavailable.notEnrolled);
        expect(reason!.message, contains('ajustes de'));
      },
    );

    test('un bloqueo del sistema se distingue de no tener sensor', () async {
      auth.throws = PlatformException(code: 'LockedOut');

      expect(await service.unavailableReason(), BiometricUnavailable.lockedOut);
    });
  });

  group('activar', () {
    test('activarlo exige identificarse en el momento', () async {
      final result = await service.setEnabled(true);

      // Si no se pidiera, cualquiera que cogiera el movil abierto podria
      // poner su propia huella como llave.
      expect(auth.authenticateCalls, 1);
      expect(result, isA<BiometricSuccess>());
      expect(await service.isEnabled(), isTrue);
    });

    test('si se cancela la huella, no queda activado', () async {
      auth.result = false;

      final result = await service.setEnabled(true);

      expect(result, isA<BiometricCancelled>());
      expect(await service.isEnabled(), isFalse);
    });

    test('en un movil sin sensor no se activa ni se pide nada', () async {
      auth.supported = false;

      final result = await service.setEnabled(true);

      expect(result, isA<BiometricFailure>());
      expect(auth.authenticateCalls, 0);
      expect(await service.isEnabled(), isFalse);
    });

    test('desactivarlo no pide nada', () async {
      await service.setEnabled(true);
      auth.authenticateCalls = 0;

      await service.setEnabled(false);

      expect(auth.authenticateCalls, 0);
      expect(await service.isEnabled(), isFalse);
    });
  });

  group('desbloquear', () {
    test('la huella correcta desbloquea', () async {
      expect(
        await service.authenticate(reason: 'Entra'),
        isA<BiometricSuccess>(),
      );
      expect(auth.lastReason, 'Entra');
    });

    test('cancelar no es un fallo que haya que explicar', () async {
      auth.throws = PlatformException(code: 'UserCanceled');

      expect(
        await service.authenticate(reason: 'Entra'),
        isA<BiometricCancelled>(),
      );
    });

    test('borrar las huellas en Android desactiva el atajo solo', () async {
      await service.setEnabled(true);
      expect(await service.isEnabled(), isTrue);

      // La persona borra sus huellas en los ajustes del sistema.
      auth.enrolled = const [];

      // Sin esto, la pantalla de bloqueo ofreceria un boton de huella que no
      // lleva a ninguna parte. El PIN sigue entrando igual.
      expect(await service.isEnabled(), isFalse);
    });
  });
}
