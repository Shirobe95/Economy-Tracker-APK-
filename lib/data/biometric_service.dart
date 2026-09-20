import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Por que no se puede usar la huella ahora mismo.
enum BiometricUnavailable {
  /// El movil no tiene sensor, o Android no lo expone.
  noHardware,

  /// Hay sensor pero no hay ninguna huella ni rostro registrado.
  notEnrolled,

  /// El sistema lo tiene bloqueado, normalmente por demasiados intentos.
  lockedOut,

  /// Cualquier otra cosa que diga el sistema.
  unknown;

  String get message => switch (this) {
    BiometricUnavailable.noHardware =>
      'Este movil no tiene lector de huella ni reconocimiento facial.',
    BiometricUnavailable.notEnrolled =>
      'No tienes ninguna huella registrada. Anadela en los ajustes de '
          'Android y vuelve aqui.',
    BiometricUnavailable.lockedOut =>
      'Android ha bloqueado la huella por demasiados intentos. Desbloquea el '
          'movil con tu patron o PIN del sistema.',
    BiometricUnavailable.unknown =>
      'El sistema no permite usar la huella ahora mismo.',
  };
}

/// Resultado de intentar desbloquear con huella.
sealed class BiometricResult {
  const BiometricResult();
}

/// La persona se ha identificado.
class BiometricSuccess extends BiometricResult {
  const BiometricSuccess();
}

/// La persona ha cancelado, o el sistema no ha reconocido la huella.
///
/// No es un error que haya que explicar: se vuelve al PIN sin ruido.
class BiometricCancelled extends BiometricResult {
  const BiometricCancelled();
}

/// No se puede usar la huella, y hay algo que contar.
class BiometricFailure extends BiometricResult {
  const BiometricFailure(this.reason);

  final BiometricUnavailable reason;

  String get message => reason.message;
}

/// Desbloqueo por huella o rostro, como atajo del PIN.
///
/// **La huella no sustituye al PIN, lo acompana.** El PIN sigue siendo el
/// secreto que protege la aplicacion: es lo unico que se deriva y se guarda.
/// La huella solo dice «esta persona es la duena del movil», y quien la active
/// tiene que tener ya un PIN puesto. Asi, si el sensor falla, se pierde el
/// dedo o Android bloquea la biometria, siempre queda una forma de entrar que
/// no depende del hardware.
///
/// Tampoco cifra nada. Como el PIN, evita que alguien que coja el movil
/// desbloqueado abra la aplicacion; no protege el archivo de la base de datos.
class BiometricService {
  BiometricService(this._auth, this._preferences);

  final LocalAuthentication _auth;
  final SharedPreferencesAsync _preferences;

  static const _enabledKey = 'app_lock_biometric';

  /// Si el movil puede pedir huella, y por que no si no puede.
  Future<BiometricUnavailable?> unavailableReason() async {
    try {
      if (!await _auth.isDeviceSupported()) {
        return BiometricUnavailable.noHardware;
      }
      if (!await _auth.canCheckBiometrics) {
        return BiometricUnavailable.noHardware;
      }
      final enrolled = await _auth.getAvailableBiometrics();
      if (enrolled.isEmpty) return BiometricUnavailable.notEnrolled;
      return null;
    } on PlatformException catch (error) {
      return _reasonFor(error);
    }
  }

  Future<bool> isAvailable() async => await unavailableReason() == null;

  /// Si la persona ha activado el desbloqueo por huella.
  ///
  /// Se comprueba tambien que siga siendo posible: alguien puede borrar sus
  /// huellas en Android despues de activarlo aqui, y entonces la pantalla de
  /// bloqueo ofreceria un boton que no lleva a ninguna parte.
  Future<bool> isEnabled() async {
    if (!(await _preferences.getBool(_enabledKey) ?? false)) return false;
    return isAvailable();
  }

  /// Activa o desactiva el atajo.
  ///
  /// Activarlo exige identificarse en el momento: si no, cualquiera que coja
  /// el movil abierto podria anadir su propia huella como llave.
  Future<BiometricResult> setEnabled(bool value) async {
    if (!value) {
      await _preferences.setBool(_enabledKey, false);
      return const BiometricSuccess();
    }

    final reason = await unavailableReason();
    if (reason != null) return BiometricFailure(reason);

    final result = await authenticate(
      reason: 'Confirma tu huella para activar el desbloqueo',
    );
    if (result is BiometricSuccess) {
      await _preferences.setBool(_enabledKey, true);
    }
    return result;
  }

  /// Pide la huella.
  Future<BiometricResult> authenticate({required String reason}) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          // Solo biometria: el PIN de la aplicacion es cosa nuestra, y caer
          // al patron del sistema confundiria dos secretos distintos.
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return ok ? const BiometricSuccess() : const BiometricCancelled();
    } on PlatformException catch (error) {
      final reason = _reasonFor(error);
      // Cancelar no es un fallo que haya que explicar.
      return reason == null
          ? const BiometricCancelled()
          : BiometricFailure(reason);
    }
  }

  /// Traduce el codigo de error de la plataforma.
  ///
  /// Devuelve `null` cuando no hay nada que contar: lo ha cancelado la
  /// persona, o es un error que no impide volver a intentarlo.
  static BiometricUnavailable? _reasonFor(PlatformException error) {
    return switch (error.code) {
      'NotAvailable' ||
      'OtherOperatingSystem' => BiometricUnavailable.noHardware,
      'NotEnrolled' => BiometricUnavailable.notEnrolled,
      'LockedOut' || 'PermanentlyLockedOut' => BiometricUnavailable.lockedOut,
      'UserCanceled' || 'auth_in_progress' => null,
      _ => BiometricUnavailable.unknown,
    };
  }
}

final biometricServiceProvider = Provider<BiometricService>(
  (ref) => BiometricService(LocalAuthentication(), SharedPreferencesAsync()),
);

/// Si el movil admite huella, para decidir si se ofrece la opcion.
final biometricAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(biometricServiceProvider).isAvailable(),
);

/// Si el atajo por huella esta activado.
final biometricEnabledProvider = FutureProvider<bool>(
  (ref) => ref.watch(biometricServiceProvider).isEnabled(),
);
