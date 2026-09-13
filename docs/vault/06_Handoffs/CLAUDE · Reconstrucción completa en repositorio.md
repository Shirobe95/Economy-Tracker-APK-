---
id: ECON-100-HANDOFF
project: ECONOMY_TRACKER
type: handoff
status: pendiente_revision_usuario
mode: diario
owner: claude
created: 2026-09-13
updated: 2026-09-13
---

# Reconstrucción completa · RESULTADO

## ESTADO

`[PENDIENTE REVISIÓN USUARIO]`

Aplicación reconstruida desde cero en el repositorio
`Shirobe95/Economy-Tracker-APK-`, rama `claude/economy-tracker-apk-9a1e7k`.
El repositorio estaba vacío: sin commits ni ramas. El código anterior de
Codex vive en el PC de Andy y no se ha usado como base.

## ALCANCE ACORDADO

Andy eligió: Flutter, notas del Vault aportadas por él, y alcance «base más
previsión y objetivos». Cubierto en su totalidad.

## LO QUE EXISTE AHORA

| Corte del Vault | Estado |
| --- | --- |
| ECON-000B · Bootstrap y sistema visual | Reconstruido |
| ECON-000C · Modelo de datos y SQLite | Reconstruido, esquema v1 con las ocho tablas |
| ECON-000D · Movimientos y gastos | Implementado y probado |
| ECON-000E · Clientes, proyectos y cobros | Implementado y **probado**, que era lo que faltaba |
| ECON-000F · Salarios e ingresos | Implementado |
| ECON-000G · Motor de previsión | Implementado y probado |
| ECON-000H · Objetivos de ahorro | Implementado |
| ECON-000I · Calendario financiero | Implementado |
| ECON-000J · Informes y análisis | Implementado y probado |
| ECON-000K · Seguridad, backup y release | Implementado, con exclusiones |

Pantallas del contrato visual: UI-01 a UI-14 y UI-16, más copia de seguridad
y bloqueo. Sin implementar UI-15 (administración de categorías; se crean desde
el formulario de movimiento).

## DESVIACIONES RESPECTO A LA DOCUMENTACIÓN, Y POR QUÉ

Tres, todas deliberadas y ninguna silenciosa:

1. **Esquema v1 en vez de v2 con migración 1→2.** Aquí se empieza de cero y no
   hay ninguna base instalada con datos que preservar: el paquete Android es
   distinto del que usaba Codex. Mantener una migración desde un v1 que nunca
   existió en este repositorio sería ceremonia sin función.

2. **Fechas financieras como texto ISO, no como timestamp Unix.** El Vault
   pedía timestamps y dejaba abierto «normalizar el día de forma consistente».
   Al probarlo apareció el problema real: Drift devuelve los timestamps en hora
   local, así que medianoche UTC se lee como el día anterior en cualquier zona
   con offset negativo. Un día del calendario no es un instante. `createdAt` y
   `updatedAt` sí lo son y siguen siendo timestamps.

3. **Un repositorio de movimientos en vez de `ExpenseRepository` y
   `ProjectRepository` separados.** La validación de un movimiento es la misma
   para los cinco tipos; separarla por corte la habría triplicado. Los
   repositorios de proyectos, salarios, objetivos y reglas sí son propios.

## DECISIÓN RESUELTA

[[DEC-007 · Origen de los tokens visuales]], cerrada el 2026-09-13. Andy
aportó [[MOD · Sistema visual oscuro grafito-cian (Flutter)]] y los tokens
pasaron a ser los de PALIKO, que diferían de forma apreciable de lo
muestreado: el fondo real `#050A12` es más oscuro y menos azul que el
`#0A1825` que salía de los PNG, y el acento `#2ED8FF` más eléctrico. Un PNG
con degradado no es una fuente de tokens.

Queda abierto en esa decisión: los valores numéricos de la escala de radios de
PALIKO, y si el sistema visual se extrae algún día a un paquete Dart
compartido — que la propia nota MOD deja pendiente de decisión tuya.

## BUGS ENCONTRADOS Y CORREGIDOS DURANTE EL DESARROLLO

Tres de verdad, los tres cubiertos por tests:

1. **Sin integridad referencial en la mitad de las relaciones.** Drift descarta
   las claves foráneas de `references()` en cuanto la tabla declara
   `customConstraints`. Se podía borrar un cliente con proyectos. Ahora todas
   se declaran a mano y hay un test por relación.

2. **Reconstrucción infinita de la pantalla de gastos.** Un provider family
   recibía un `Set` como clave, y los conjuntos comparan por identidad.

3. **Horizonte del motor de previsión desalineado.** Contaba hitos de un mes
   que ningún punto de la serie recogía.

## VALIDACIÓN EJECUTADA

Ejecutado de verdad en esta sesión, no afirmado:

- `flutter analyze` — sin incidencias.
- `dart format` — limpio.
- `flutter test` — 168 tests correctos.
- `flutter build apk --release` — correcto en GitHub Actions, con el APK
  publicado como artifact descargable.

## LO QUE NO ESTÁ VERIFICADO

**Prueba visual en un Android físico.** No hay dispositivo en este entorno y
ninguna captura de test la sustituye. Es lo que toca revisar antes de dar el
trabajo por bueno: instalar el APK del último run verde y comprobar que la
paleta, la jerarquía y los recorridos se corresponden con los mockups.

**Todo lo que depende de un plugin nativo**, que es justo lo que los tests no
alcanzan: compartir el archivo de copia, elegirlo con el selector del sistema
para restaurar, y el bloqueo por PIN de principio a fin. La lógica de los tres
sí está probada (43 tests entre copia, bloqueo e informes); lo que no se ha
ejecutado nunca es el salto al sistema operativo.

Recomendado al probar la copia: exportar, mirar el JSON, y restaurarlo en una
instalación limpia antes de confiarle datos reales.

Tampoco se ha probado con datos financieros reales de Andy: los tests usan
datos sintéticos, y no existe ninguna semilla en producción.

## SIGUIENTE PASO RECOMENDADO

1. Instalar el APK y revisar el estilo contra los mockups.
2. Probar el ciclo completo de copia: exportar, abrir el JSON, restaurar.
3. Activar el PIN y confirmar que el desbloqueo no se hace esperar en tu
   móvil. Si se nota lento, se bajan las iteraciones; el valor está en una
   sola constante.
4. Empezar a usarla con datos reales. El roadmap documentado está completo:
   lo siguiente debería salir del uso, no de la lista.
