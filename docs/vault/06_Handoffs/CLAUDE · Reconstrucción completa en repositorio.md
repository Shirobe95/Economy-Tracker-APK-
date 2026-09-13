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
| ECON-000J · Informes y análisis | No implementado |
| ECON-000K · Seguridad, backup y release | No implementado |

Pantallas del contrato visual: UI-01 a UI-13 y UI-16. Sin implementar UI-14
(informes) ni UI-15 (administración de categorías; se crean desde el
formulario de movimiento).

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

## DECISIÓN PENDIENTE DE TU VALIDACIÓN

[[DEC-007 · Tokens visuales derivados de los mockups]]. Falta la nota
[[MOD · Sistema visual oscuro grafito-cian (Flutter)]], que no venía en la
documentación entregada y es la que fija los tokens PALIKO reales. Mientras
tanto, los colores se han muestreado directamente de los ocho PNG aprobados,
que el Pack visual declara contrato congelado. Si esa nota define otros
valores, manda ella.

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
- `flutter test` — 125 tests correctos.
- `flutter build apk --release` — correcto en GitHub Actions, con el APK
  publicado como artifact descargable.

## LO QUE NO ESTÁ VERIFICADO

**Prueba visual en un Android físico.** No hay dispositivo en este entorno y
ninguna captura de test la sustituye. Es lo que toca revisar antes de dar el
trabajo por bueno: instalar el APK del último run verde y comprobar que la
paleta, la jerarquía y los recorridos se corresponden con los mockups.

Tampoco se ha probado con datos financieros reales de Andy: los tests usan
datos sintéticos, y no existe ninguna semilla en producción.

## SIGUIENTE PASO RECOMENDADO

1. Instalar el APK y revisar el estilo contra los mockups.
2. Resolver DEC-007 aportando la nota MOD, o confirmando los tokens actuales.
3. Decidir si abrir ECON-000J (informes) o ECON-000K (backup, bloqueo local y
   firma de publicación). K es lo que hace falta para tener una app que
   sobreviva a un cambio de móvil.
