---
id: DEC-007
project: ECONOMY_TRACKER
type: decision
status: propuesta
mode: diario
owner: claude
related_cut: ECON-100A
created: 2026-09-13
updated: 2026-09-13
---

# DEC-007 · Tokens visuales derivados de los mockups

**Estado: propuesta, pendiente de validación de Andy.** No es una decisión
cerrada por él, a diferencia de DEC-001 a DEC-006.

## Problema

El Vault documenta dos veces que los tokens de `app_tokens.dart` se
reinterpretaron con valores propios en vez de usar los tokens PALIKO reales
(ver [[ECON-000D · Movimientos y gastos]] y [[Economy Tracker · Inicio]]). La
corrección del 2026-09-09 remite a [[MOD · Sistema visual oscuro grafito-cian
(Flutter)]], que **no está en la documentación entregada**: es una nota de
módulo compartido, fuera de la carpeta del proyecto.

Sin esa nota, repetir el mismo error era el resultado más probable.

## Decisión propuesta

`VISUAL_TOKENS_SOURCE = MOCKUPS_CONGELADOS`.

Los valores de color se obtienen muestreando directamente los PNG aprobados
en `04_Diseno_UI_UX/_attachments/`, que [[Pack visual v0.1]] declara contrato
visual congelado. No se reinterpretan los principios del texto con valores
inventados, y no se usan los del bootstrap anterior.

Muestreo sobre las ocho pantallas aprobadas:

| Token | Valor | Origen |
| --- | --- | --- |
| background | `#0A1825` | márgenes de UI-01 y UI-12 |
| surface | `#122234` | tarjetas de UI-01, UI-03 |
| surfaceElevated | `#17293D` | hoja modal de UI-02 |
| accent | `#29B8F0` | botón central, chips activos |
| accentBright | `#54E2FF` | pestaña activa, enlaces |
| positive | `#5FE0A0` | ingresos en UI-01, cobrado en UI-09 |
| negative | `#F1584F` | gastos en UI-01, UI-11 |
| pending | `#F2A93B` | chip "Pendiente" y reloj de UI-03 |

Los tres tonos más frecuentes de la paleta son el cian `#25B7F1`, el verde
`#56C991` y el rojo `#CA443C`, medidos sobre el conjunto de las ocho imágenes.

## Qué invalida esta propuesta

Que aparezca [[MOD · Sistema visual oscuro grafito-cian (Flutter)]]. Si esa
nota define tokens distintos, manda ella y estos valores se sustituyen: es la
referencia de un módulo transversal a varios proyectos, mientras que este
muestreo solo cubre Economy Tracker.

## Divergencia pendiente que esta decisión no resuelve

[[Pack visual v0.1]] reporta que algunas cifras de gasto y de pendiente
aparecen en cian en las imágenes individuales, mientras el texto de
[[Sistema visual v0.1]] define rojo para gasto y amarillo para pendiente.
Inspeccionadas las imágenes: en UI-01 "Próximos movimientos" los gastos sí
son rojos y los ingresos verdes; en UI-03 los importes de la lista van en
blanco y el estado se comunica con un chip ámbar o un check verde, no
coloreando la cifra; en la tarjeta GASTOS de UI-01 el rótulo "120 €
pendiente" sí aparece en cian, no en ámbar.

Criterio aplicado: el color semántico va en el importe cuando la lista mezcla
entradas y salidas de dinero, y en el indicador de estado cuando la lista es
de un solo tipo. El cian del rótulo de UI-01 se trata como información de
interfaz, no como estado. Queda registrado para que Andy lo confirme o lo
corrija al revisar la pantalla.

Relacionado: [[Sistema visual v0.1]] · [[Pack visual v0.1]] · [[DEC-004 · Diseño y navegación]]
