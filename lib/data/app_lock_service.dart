import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bloqueo local de la aplicacion con PIN.
///
/// Qué protege y qué no, dicho claro: esto impide que alguien que coja el
/// móvil desbloqueado abra la aplicación y vea las cuentas. No cifra la base
/// de datos. Quien tenga acceso físico al almacenamiento privado de la app
/// (un dispositivo rooteado, una copia del sistema de archivos) puede leer
/// los datos sin pasar por aquí. El cifrado en reposo no está implementado.
///
/// El PIN nunca se guarda: se guarda su derivación con sal, y comprobarlo
/// exige rehacer el mismo trabajo, que es lo que encarece probar a ciegas.
class AppLockService {
  AppLockService(this._preferences);

  final SharedPreferencesAsync _preferences;

  static const _saltKey = 'app_lock_salt';
  static const _hashKey = 'app_lock_hash';

  /// Iteraciones de derivación.
  ///
  /// Un PIN de cuatro dígitos son diez mil combinaciones: sin estirar el
  /// cálculo, probarlas todas es instantáneo. El trabajo corre en un isolate
  /// aparte, así que encarecerlo no congela la interfaz mientras se
  /// desbloquea.
  static const int iterations = 100000;

  /// Longitudes aceptadas.
  static const int minLength = 4;
  static const int maxLength = 8;

  /// Comprueba si el formato del PIN es válido, sin mirar el guardado.
  static String? validateFormat(String pin) {
    if (pin.length < minLength || pin.length > maxLength) {
      return 'El PIN debe tener entre $minLength y $maxLength digitos.';
    }
    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return 'El PIN solo puede tener numeros.';
    }
    if (RegExp(r'^(\d)\1*$').hasMatch(pin)) {
      return 'Un PIN de digitos repetidos no protege nada.';
    }
    return null;
  }

  Future<bool> isEnabled() async =>
      (await _preferences.getString(_hashKey)) != null;

  /// Establece o cambia el PIN.
  Future<void> setPin(String pin) async {
    final error = validateFormat(pin);
    if (error != null) throw ArgumentError(error);

    final salt = _randomSalt();
    final hash = await compute(_deriveInIsolate, (pin: pin, salt: salt));
    await _preferences.setString(_saltKey, base64Encode(salt));
    await _preferences.setString(_hashKey, base64Encode(hash));
  }

  /// Quita el bloqueo. Exige el PIN actual.
  Future<bool> removePin(String currentPin) async {
    if (!await verify(currentPin)) return false;
    await _preferences.remove(_saltKey);
    await _preferences.remove(_hashKey);
    return true;
  }

  /// Comprueba un PIN contra el guardado.
  Future<bool> verify(String pin) async {
    final storedHash = await _preferences.getString(_hashKey);
    final storedSalt = await _preferences.getString(_saltKey);
    if (storedHash == null || storedSalt == null) return false;

    final computed = await compute(_deriveInIsolate, (
      pin: pin,
      salt: base64Decode(storedSalt),
    ));
    return _constantTimeEquals(computed, base64Decode(storedHash));
  }

  /// PBKDF2-HMAC-SHA256, escrito a mano porque es lo unico que hace falta de
  /// una biblioteca de contrasenas completa.
  @visibleForTesting
  static Uint8List derive(String pin, Uint8List salt) {
    final hmac = Hmac(sha256, utf8.encode(pin));

    // Bloque 1 de PBKDF2: HMAC(sal || 0x00000001).
    var block = Uint8List.fromList(hmac.convert([...salt, 0, 0, 0, 1]).bytes);
    final result = Uint8List.fromList(block);

    for (var i = 1; i < iterations; i++) {
      block = Uint8List.fromList(hmac.convert(block).bytes);
      for (var j = 0; j < result.length; j++) {
        result[j] ^= block[j];
      }
    }
    return result;
  }

  static Uint8List _randomSalt() {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));
  }

  /// Compara sin cortocircuito: el tiempo de respuesta no debe delatar
  /// cuantos bytes coincidian.
  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}

/// Punto de entrada del isolate: `compute` necesita una funcion de nivel
/// superior con un unico argumento.
Uint8List _deriveInIsolate(({String pin, Uint8List salt}) input) =>
    AppLockService.derive(input.pin, input.salt);

final appLockServiceProvider = Provider<AppLockService>(
  (ref) => AppLockService(SharedPreferencesAsync()),
);

/// Si el bloqueo esta activado.
final appLockEnabledProvider = FutureProvider<bool>(
  (ref) => ref.watch(appLockServiceProvider).isEnabled(),
);
