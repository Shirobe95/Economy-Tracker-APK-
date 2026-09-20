---
id: DEC-011
project: ECONOMY_TRACKER
type: decision
status: active
mode: diario
owner: compartido
related_cut: ECON-100A
created: 2026-09-20
updated: 2026-09-20
---

# DEC-011 · Huella como atajo del PIN

## Decisión

La huella **acompaña al PIN, no lo sustituye**. Para activarla hace falta tener
ya un PIN puesto, y el PIN sigue entrando siempre.

Andy lo pidió así el 2026-09-20: *«si lo podemos hacer con huella como método
en seguridad mejor»*. Se ha implementado como atajo, no como método alternativo
de verdad, y esa diferencia es deliberada.

## Por qué no sustituye al PIN

El PIN es el único secreto que la aplicación guarda: derivado con PBKDF2 y sal,
nunca en claro. La huella no aporta ningún secreto — le pregunta a Android «¿es
esta persona la dueña del móvil?» y se cree la respuesta.

Si la huella fuera el único método, cualquiera de estas cosas dejaría a Andy
fuera de sus propias finanzas, sin servidor ni cuenta desde donde recuperarlas:

- el sensor se estropea;
- se borra una huella en los ajustes de Android;
- Android bloquea la biometría por intentos fallidos;
- un dedo con una tirita.

Por eso también: activar el atajo **exige identificarse en el momento**. Sin
eso, cualquiera que cogiera el móvil abierto podría registrar su propia huella
como llave desde los propios ajustes de la aplicación.

Y si alguien borra sus huellas en Android después de activarlo, `isEnabled()`
devuelve `false` por su cuenta: la pantalla de bloqueo no ofrece un botón que
no lleva a ninguna parte.

## Lo que sigue sin proteger

Nada cambia respecto a [[ECON-000K · Seguridad backup y release Android]]: esto
impide que alguien que coja el móvil desbloqueado abra la aplicación. **No
cifra la base de datos.** Quien tenga acceso al almacenamiento privado de la
app puede leer los datos sin pasar por aquí. El cifrado en reposo sigue sin
implementarse, y la pantalla de ajustes lo dice.

## Detalles de implementación

`local_auth` necesita que `MainActivity` extienda `FlutterFragmentActivity`:
el diálogo del sistema (BiometricPrompt) es un fragmento y con
`FlutterActivity` falla al invocarlo. También hace falta el permiso
`USE_BIOMETRIC` en el manifiesto.

`biometricOnly: true`: no se cae al patrón del sistema. Mezclar el PIN de la
aplicación con el del teléfono confundiría dos secretos distintos.

Probado en `test/biometric_service_test.dart` con un doble de
`LocalAuthentication`: lo que se verifica es la lógica, no el sensor.

Relacionado: [[ECON-000K · Seguridad backup y release Android]]
