---
id: ECON-000K
project: ECONOMY_TRACKER
type: cut
status: completed
mode: diario
owner: compartido
created: 2026-09-05
updated: 2026-09-05
---

# ECON-000K · Seguridad backup y release Android

## Objetivo y alcance

Preparar protección local, backups y release Android con validación y autorización correspondientes.

## Restricciones

Respetar [[Visión y alcance v0.1]], [[Modelo financiero funcional]], [[Arquitectura técnica v0.1]] y [[Índice de decisiones]]. No adelantar otros cortes ni modificar otros proyectos.

## Trabajo / Resultados

Implementado el 2026-09-13 sobre la reconstrucción en repositorio.

**Copia de seguridad.** Exportación a JSON de las ocho tablas, restauración
con vista previa de lo que trae el archivo y de lo que se pierde, y escritura
transaccional: una copia corrupta deja la base intacta. El formato es texto
legible a propósito, para que los datos se puedan recuperar a mano si la
aplicación no arranca. Los nombres de columna del archivo se validan contra el
esquema antes de entrar en la consulta.

**Bloqueo local.** PIN de 4 a 8 dígitos, derivado con PBKDF2-HMAC-SHA256 y sal
aleatoria, cien mil iteraciones en un isolate aparte. El PIN nunca se guarda.
La pantalla de ajustes explica sin adornos qué protege y qué no.

**Release Android.** `key.properties` opcional: con clave propia firma de
verdad, sin ella cae a la de depuración. Ninguna clave entra en el
repositorio. Procedimiento en `docs/RELEASE.md`.

30 tests nuevos entre copia y bloqueo.

## Fuera de alcance, decidido

- **Desbloqueo por huella.** Requiere `local_auth` y cambiar la Activity de
  Flutter; sin dispositivo donde probarlo, no se entrega.
- **Cifrado de la base en reposo.** El PIN no cifra nada: sigue sin estar
  implementado, y así se dice en la propia pantalla.
- **Firma en CI y publicación en Google Play.** Mientras el APK sea solo para
  el móvil de Andy, la firma de depuración basta y evita poner una clave en
  circulación.
- **Minificación R8.** Desactivada a propósito: puede recortar algo necesario
  en ejecución, y eso no se ve al compilar. Las reglas quedan escritas.
