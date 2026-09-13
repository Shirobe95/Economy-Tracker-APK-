---
id: DEC-007
project: ECONOMY_TRACKER
type: decision
status: active
mode: diario
owner: compartido
related_cut: ECON-100A
created: 2026-09-13
updated: 2026-09-13
---

# DEC-007 · Origen de los tokens visuales

## Decisión

`VISUAL_TOKENS_SOURCE = MOD_PALIKO`, con los mockups como fuente supletoria.

Manda [[MOD · Sistema visual oscuro grafito-cian (Flutter)]], el módulo
compartido entre PALIKO, GameVault y Economy Tracker. De ahí salen, literales:

| Token | Valor | Origen |
| --- | --- | --- |
| background | `#050A12` | PALIKO |
| surface | `#09111E` | PALIKO |
| border | `#17304A` | PALIKO |
| accent | `#2ED8FF` | PALIKO |
| espaciado | xs 4 · sm 8 · md 12 · lg 16 · xl 24 · xxl 32 | PALIKO |

Lo que esa nota **no** fija con un hexadecimal se muestrea de los ocho PNG
aprobados, que [[Pack visual v0.1]] declara contrato congelado: los colores
semánticos financieros (`positive`, `negative`, `pending`, que mapean a los
roles `success` / `danger` / `warning` de PALIKO) y la jerarquía de texto.

Tres valores son interpolados y quedan señalados como tales en el código,
porque no existen ni en la nota ni en los mockups: `surfaceElevated`,
`surfaceSubtle` y `borderStrong`. Cada token lleva escrito de dónde sale.

## Historia de esta decisión

Se abrió como propuesta el 2026-09-13 porque la nota MOD no estaba en la
documentación entregada, y los colores se muestrearon provisionalmente de los
mockups. Andy aportó la nota el mismo día y los valores se sustituyeron por
los de PALIKO, que es lo que la propuesta ya anticipaba: *«si esa nota define
tokens distintos, manda ella»*. Diferían de forma apreciable: el fondo
muestreado (`#0A1825`) era más claro y más azul que el `#050A12` real, y el
acento (`#29B8F0`) menos eléctrico que `#2ED8FF`.

## Pendiente, no resuelto aquí

- **Los radios.** PALIKO tiene escala nombrada (`sm/md/lg/xl/pill`) pero la
  nota no da sus valores numéricos. Economy Tracker conserva los suyos con
  los nombres de la escala, a confirmar cuando se extraiga el paquete.
- **`AppSpace.page` anclado a `xl` (24).** Es decisión de Economy Tracker y
  no un valor PALIKO, tal como la propia nota MOD documenta.
- **Extracción a paquete Dart compartido.** La nota MOD la deja abierta y
  pendiente de decisión expresa de Andy. Economy Tracker parte hoy de los
  mismos valores, copiados, no importados.

## Divergencia de semántica de color, todavía abierta

[[Pack visual v0.1]] reporta que algunas cifras de gasto y de pendiente
aparecen en cian en las imágenes individuales, mientras [[Sistema visual v0.1]]
define rojo para gasto y amarillo para pendiente.

Criterio aplicado, a confirmar por Andy al revisar en dispositivo: el color
semántico va en el importe cuando la lista mezcla entradas y salidas de
dinero, y en el indicador de estado cuando la lista es de un solo tipo. Es lo
que hacen los propios mockups: en UI-01 los gastos van en rojo, y en UI-03 el
importe va en blanco con un chip ámbar al lado.

Relacionado: [[MOD · Sistema visual oscuro grafito-cian (Flutter)]] ·
[[Sistema visual v0.1]] · [[Pack visual v0.1]] · [[DEC-004 · Diseño y navegación]]
