---
id: ECONOMY_TRACKER
project: ECONOMY_TRACKER
type: project
status: active
mode: diario
owner: compartido
current_cut: ECON-000E
next_action: ECON-000E implementado sobre DEC-006; pendiente que se corra analyze/tests/build (sin SDK Flutter en esta sesión) y prueba real en dispositivo. Ver [[ECON-000E · Clientes proyectos y cobros]].
created: 2026-09-05
updated: 2026-09-09
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

C:\Users\Andy\Documents\Work\Personal Proyects\Economy Tracker

## Roadmap

- [[ECON-000A · Producto UX Arquitectura]] — completed
- [[ECON-000B · Bootstrap Flutter y sistema visual]] — completed
- [[ECON-000C · Modelo de datos y SQLite]] — completed
- [[ECON-000D · Movimientos y gastos]] — completed (validación técnica en verde; revisión visual de Andy en Android OK; pendiente recompilar/reverificar tras el fix de tokens PALIKO)
- [[ECON-000E · Clientes proyectos y cobros]] — review (implementado sobre DEC-006; pendiente analyze/tests/build y prueba real)
- [[ECON-000F · Salarios e ingresos recurrentes]] — planned
- [[ECON-000G · Motor de previsión]] — planned
- [[ECON-000H · Objetivos de ahorro]] — planned
- [[ECON-000I · Calendario financiero]] — planned
- [[ECON-000J · Informes y análisis]] — planned
- [[ECON-000K · Seguridad backup y release Android]] — planned

## Enlaces clave

[[Modelo financiero funcional]] · [[Arquitectura técnica v0.1]] · [[Modelo de datos inicial]] · [[Sistema visual v0.1]] · [[Pack visual v0.1]] · [[Inventario de pantallas]] · [[Índice de decisiones]]





## Baseline ECON-000C

Commit local 44254edd4cfc8b1751253ba5af21fb181befab0d; working tree limpio.
Mensaje: feat: add Economy Tracker data model foundation. Sin remoto ni push.


