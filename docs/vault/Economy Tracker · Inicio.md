---
id: ECONOMY_TRACKER
project: ECONOMY_TRACKER
type: project
status: active
mode: diario
owner: compartido
current_cut: ECON-100 (reconstruccion)
next_action: Tercera ronda cerrada (2026-09-20): reserva de ahorro sobre el saldo, compromisos previstos con repeticiones, historial solo de lo realizado. Pendiente de Andy: confirmar si los objetivos por importe deben apartar su ahorro declarado (DEC-009). Ver [[CLAUDE · Reconstrucción completa en repositorio]].
created: 2026-09-05
updated: 2026-09-21
---

# Economy Tracker · Inicio

## Objetivo

Aplicación Android personal para control y previsión financiera. [[Visión y alcance v0.1]].

## Estado actual

ECON-000C completado con observaciones el 2026-09-07: esquema Drift v2 con ocho
tablas, claves foráneas, índices, enums y migración 1→2; contrato visual aprobado
incorporado (ocho mockups más composición, originales verificados por SHA256).
Pub get, formato, analyze y 20 tests PASS; APK debug PASS. Sin CRUD ni UI final.

Detalle: [[CODEX · ECON-000C Modelo de datos y SQLite]], [[Modelo de datos Drift v0.1]]
y [[Pack visual v0.1]]. El Pack registra diferencias entre composición e imágenes
individuales y colores semánticos; no se han reinterpretado. Sin dispositivo para
smoke visual Android. ECON-000C aprobado para cierre tras revisión y 14 tests DB reejecutados. ECON-000D reanudado tras [[DEC-005 · Recurrencias en días inexistentes]]. Gastos y reglas implementados.

**Actualizado 2026-09-09** (verificado leyendo `docs/validation/ECON-000D/*.txt`, no la nota anterior): validación técnica de ECON-000D **completa y en verde** — `flutter analyze` limpio, `dart format` limpio, 44 tests PASS (app_test, database_test, expense_repository_test, expense_ui_test, render_expenses_test), build APK debug PASS. La nota previa ("validaciones finales en curso") estaba desactualizada.

**ECON-000D cerrado del todo el 2026-09-09**: Andy probó el APK debug en su móvil y confirmó que el flujo de gastos (única pestaña funcional) le pareció correcto; el resto de pestañas son placeholders de B, como corresponde a este punto del roadmap. Ojo: ese APK es de antes del fix de tokens PALIKO (ver siguiente párrafo) — la revisión visual valida el flujo de D, no todavía el estilo corregido. Detalle en [[ECON-000D · Movimientos y gastos]].

Además, el 2026-09-09 se corrigió una divergencia de estilo real en `lib/app/theme/app_tokens.dart`: colores y escala de spacing habían sido reinterpretados con valores propios en el bootstrap (ECON-000B) en vez de usar los tokens PALIKO reales. Ya alineado a PALIKO — detalle en [[MOD · Sistema visual oscuro grafito-cian (Flutter)]].

ECON-000E abierto el 2026-09-09. Andy resolvió el bloqueo con [[DEC-006 · Importe neto en cobros de proyecto]] (solo neto, sin retención, sin cambio de esquema). Con eso implementé repositorio (`lib/data/project_repository.dart`) y UI (`lib/features/projects/projects_screen.dart` + rutas nuevas en `app_router.dart`) para clientes, proyectos y cobros. **No verificado por mí**: sin SDK de Flutter en esta sesión no pude correr `flutter analyze`/`flutter test`/`flutter build apk`, y no escribí tests que no pudiera ejecutar. Detalle completo y lista de verificación pendiente en [[ECON-000E · Clientes proyectos y cobros]].

Ver [[CODEX · ECON-000C Revisión de cierre]].

La fundación B/B.1 permanece cerrada; baseline histórico 95ba2a8.
[[CODEX · ECON-000B.1 Cierre técnico]] y [[CODEX · ECON-000B Bootstrap inicial]]
conservan su evidencia histórica. Commit del corte C registrado en su handoff.

## Código fuente

**Canónico desde 2026-09-13:** repositorio `Shirobe95/Economy-Tracker-APK-`,
rama `claude/economy-tracker-apk-9a1e7k`. El APK se descarga de GitHub
Actions, sin compilar nada en local.

Histórico, ya no es la fuente: `C:\Users\Andy\Documents\Work\Personal Proyects\Economy Tracker`

## Reconstrucción · 2026-09-13

Andy decidió rehacer el proyecto desde cero en el repositorio para poder
terminarlo. El repositorio estaba vacío; el código de Codex no se ha usado
como base, pero **toda la documentación de este Vault sí manda**: decisiones
DEC-001 a DEC-006, modelo financiero, esquema de datos, política de
recurrencias y mockups congelados se han respetado.

Estado: **cortes B a K implementados**, es decir el roadmap completo.
`flutter analyze` limpio, 168 tests correctos y APK release compilando en
GitHub Actions — todo ejecutado, no afirmado. Falta la revisión visual en un
Android físico, que ninguna captura de test sustituye, y probar en dispositivo
lo que depende de plugins nativos: compartir el archivo de copia, elegirlo
para restaurar y el bloqueo por PIN.

Los tokens visuales son ya los de [[MOD · Sistema visual oscuro grafito-cian (Flutter)]],
que Andy aportó el 2026-09-13; ver [[DEC-007 · Origen de los tokens visuales]].

Tres desviaciones deliberadas respecto a esta documentación, explicadas en
[[CLAUDE · Reconstrucción completa en repositorio]]: esquema v1 sin migración
histórica, fechas financieras como texto ISO en vez de timestamp, y un
repositorio de movimientos único en vez de uno por corte.

## Pruebas en dispositivo · 2026-09-13 y 2026-09-14

Andy probó el APK release en su móvil. Lo que encontró, y cómo quedó:

| Lo que reportó | Causa real | Estado |
| --- | --- | --- |
| El saldo no se descontaba al pagar | `watchBalances()` solo observaba `accounts`, no `transactions` | corregido |
| Previsión en negativo con sueldo de 1.700 | el motor ignoraba las fuentes salariales | corregido |
| No se podía crear proyecto dentro de un cliente | streams Drift compartidos, ver [[DEC-008 · Disparador de recarga en streams Drift]] | corregido en la 2.ª pasada |
| Cobrar un pago recurrente no funcionaba | no había acción; había que crear el gasto a mano | botón «Pagar ya / Cobrar ya» |
| Falta objetivo de ahorro mensual | solo existía objetivo por importe | esquema v3, `savings_goals.kind` |
| Falta ver todos los movimientos desde Inicio | no existía esa pantalla | UI-17, ver [[Inventario de pantallas]] |
| Marcar pagado desde Inicio | no existía | acción rápida en la fila, con deshacer |

Dos lecciones que conviene no perder:

1. **El fallo de los proyectos sobrevivió a una corrección.** La primera pasada
   endureció el formulario, que no era la causa. Está documentado en DEC-008
   junto con la regla para no repetirlo.
2. **«Sobrar no es ahorrar».** Al pedir Andy que el dinero sobrante del mes
   cuente como ahorro, se implementó el histórico mensual mostrando lo que quedó
   libre, pero rotulado como tal y no como dinero apartado. Es una diferencia
   real de [[Modelo financiero funcional]] y la pantalla la dice en voz alta.

Esquema de datos: **v3**. v1→v2 añadió `salary_sources.payment_day`; v2→v3 añade
`savings_goals.kind` y el índice único `idx_tx_rule_occurrence`
(`recurring_rule_id`, `expected_date`), que hace idempotente el pago rápido de
recurrencias. La migración a v3 deduplica antes de crear el índice, y abrir una
base más nueva que el binario falla con mensaje explícito en vez de corromper.

## Tercera ronda en dispositivo · 2026-09-20

Andy uso el APK varios dias seguidos. Cuatro peticiones y las correcciones que
salieron por el camino:

| Lo que pidió | Cómo quedó |
| --- | --- |
| Próximos movimientos con gastos, no solo ingresos | la causa no era un filtro: los gastos fijos son reglas y las reglas no crean filas — [[DEC-010 · Compromisos previstos, con repeticiones incluidas]] |
| Movimientos solo con lo ya hecho | es un historial: solo pagado y cobrado, ordenado por fecha real |
| El ahorro descontado del saldo, y acumulándose | [[DEC-009 · Reserva de ahorro sobre el saldo]], esquema v4 con `start_month` |
| Gastos pendientes con los recurrentes incluidos | misma raíz que el primero; «Pendientes» pasó de 225 € a 1.075 € en el fixture |

Correcciones no pedidas, encontradas revisando:

- **`account_repository` seguía usando el disparador prohibido** por
  [[DEC-008 · Disparador de recarga en streams Drift]]. El commit anterior decía
  que estaban los dos arreglados y solo lo estaba `project_repository`. Como ya
  no había dos usuarios del mismo SQL, el fallo no se manifestaba — pero el
  siguiente repositorio que lo hubiera copiado lo habría resucitado.
- **Ingresos y Gastos del mes contaban lo cancelado.** Sumaban todo lo que
  cayera en el mes por fecha prevista, sin mirar el estado. Ahora cuentan solo
  lo realizado, por fecha real, que es lo mismo que mueve el saldo.
- **Deshacer un pago rápido de una recurrencia dejaba la ocurrencia muerta.** El
  borrado lógico conserva la fila, que seguía ocupando su hueco en el índice
  único de (regla, fecha prevista): esa ocurrencia no se podía volver a marcar
  nunca más.
- **El resumen por categoría no cuadraba con ninguna métrica.** Mezclaba pagados
  y pendientes; ahora cuenta lo pagado y su total coincide con «Pagados».

Esquema de datos: **v4**. v3 → v4 añade `savings_goals.start_month` y fecha los
objetivos mensuales que ya existían con el mes en que se crearon.

237 tests, analyze y format limpios, APK release compilando en Actions.

## Cuarta ronda · 2026-09-20 (tarde)

Andy restauró su copia en el APK nuevo y salieron dos cosas, más lo que
quedaba pendiente:

- **Los acentos se rompían al importar.** `String.fromCharCodes` lee cada byte
  como un carácter: Latin-1, no UTF-8. «Suscripción» entraba como
  «SuscripciÃ³n». Corregido en [[DEC-012 · La copia se guarda como archivo, no solo se comparte]].
- **Compartir por mensajería mutilaba el archivo.** WhatsApp le devolvió la
  copia como `DOC-20260920-WA0018._`, sin extensión y sin poder restaurarla.
  Ahora hay «Guardar copia en el móvil» como acción principal. Misma nota.
- **Huella**, que Andy pidió expresamente: [[DEC-011 · Huella como atajo del PIN]].
  Acompaña al PIN, no lo sustituye, y esa diferencia es deliberada.

- **Un mes a medias salia como mes fallado.** Andy declaro 200 € apartados y
  justo debajo leia «sep 26 · −227 €» con icono de incumplido. La cifra era
  correcta —cero ingresos cobrados, 227,84 € pagados— pero el veredicto no:
  septiembre ni ha terminado ni se cubrio entero.
  [[DEC-013 · Mes de arranque y meses parciales]].

## Quinta ronda · 2026-09-21

- **Guardar la copia en el movil fallaba.** `saveFile` ya escribe el archivo a
  traves del sistema y devuelve un identificador de documento, no una ruta:
  abrirlo como `File` reventaba con PathNotFoundException aunque la copia
  estuviera perfectamente guardada. La comprobacion defensiva que anadi era
  justo lo que rompia. Ahora solo se escribe a mano en escritorio.
- **Teclado propio para el PIN**, con puntos y sin campo de texto:
  [[DEC-014 · Teclado propio para el PIN]].
- **Animaciones sutiles**: las filas de lista entran escalonadas una sola vez
  —no en cada recalculo del stream— y el saldo de Inicio se sustituye con un
  fundido en vez de cambiar de golpe.
- **Repetir un movimiento.** Sale de los datos reales de Andy: «Supermercado»
  cuatro veces, «Desayuno» tres. Abre un alta ya rellena con la fecha de hoy.

Tres fallos que encontro la revision del codigo, ninguno visible en
dispositivo todavia: el teclado del PIN desbordaba dentro de un dialogo en un
movil de 360 dp; el hueco de altura fija recortaba los avisos de huella de
varias lineas; y `FadeIn` creaba un `CurvedAnimation` en cada `build`, dejando
un oyente por fila y por reconstruccion en listas que cuelgan de streams.

Tambien se arreglo la fidelidad de las capturas: el texto de los botones salia
en cajas porque `styleFrom` construye TextStyle que no heredan la familia del
tema. Ahora la familia es un token.

284 tests, analyze y format limpios.

## Roadmap

- [[ECON-000A · Producto UX Arquitectura]] — completed
- [[ECON-000B · Bootstrap Flutter y sistema visual]] — completed
- [[ECON-000C · Modelo de datos y SQLite]] — completed
- [[ECON-000D · Movimientos y gastos]] — completed (validación técnica en verde; revisión visual de Andy en Android OK; pendiente recompilar/reverificar tras el fix de tokens PALIKO)
- [[ECON-000E · Clientes proyectos y cobros]] — completed (reimplementado en ECON-100 y probado en móvil)
- [[ECON-000F · Salarios e ingresos recurrentes]] — completed
- [[ECON-000G · Motor de previsión]] — completed
- [[ECON-000H · Objetivos de ahorro]] — completed (por importe y mensual)
- [[ECON-000I · Calendario financiero]] — completed
- [[ECON-000J · Informes y análisis]] — completed
- [[ECON-000K · Seguridad backup y release Android]] — completed (con huella desde el 2026-09-20; sigue sin cifrado en reposo)

## Enlaces clave

[[Modelo financiero funcional]] · [[Arquitectura técnica v0.1]] · [[Modelo de datos inicial]] · [[Sistema visual v0.1]] · [[Pack visual v0.1]] · [[Inventario de pantallas]] · [[Índice de decisiones]]





## Baseline ECON-000C

Commit local 44254edd4cfc8b1751253ba5af21fb181befab0d; working tree limpio.
Mensaje: feat: add Economy Tracker data model foundation. Sin remoto ni push.


