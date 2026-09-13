---
id: ECON-000E
project: ECONOMY_TRACKER
type: cut
status: review
mode: diario
owner: compartido
created: 2026-09-05
updated: 2026-09-09
---

# ECON-000E · Clientes proyectos y cobros

## Objetivo y alcance

Implementar clientes, proyectos y cobros: CRUD y flujo funcional sobre el esquema `clients`/`projects`/`transactions` ya creado en ECON-000C, siguiendo el mismo patrón que ECON-000D aplicó a gastos y recurrencias (repositorio con validación, UI, tests, sin tocar el esquema).

## Restricciones

Respetar [[Visión y alcance v0.1]], [[Modelo financiero funcional]], [[Arquitectura técnica v0.1]] y [[Índice de decisiones]]. No adelantar otros cortes ni modificar otros proyectos.

## Lo que ya está decidido (esquema v2, ECON-000C — no se reabre)

- `clients`: nombre + contacto opcional.
- `projects`: cliente obligatorio (`client_id`), `billing_type` opcional (fixed/hourly/monthly/per_unit), importe orientativo opcional — valor de referencia, no vinculante para el cálculo real.
- No existe entidad factura/invoice: un cobro **es** una fila de `transactions` con `type=project_income` y `project_id` (y su `client_id` debe coincidir con el del proyecto). El esquema ya soporta varios cobros por proyecto (relación 1:N), aunque el flujo funcional para eso está por definir (ver más abajo).
- Estados de `transactions` ya definidos y ya usados en D: previsto/pendiente/pagado/cobrado/cancelado; `cobrado` exige fecha real y solo aplica a ingresos. Para `project_income` en concreto, el CHECK de la tabla excluye `pagado` (solo aplica a expense/transfer), así que los estados válidos de un cobro son previsto/pendiente/cobrado/cancelado.
- **Corrección sobre esta misma nota** (la versión anterior decía que `projects` no tenía campo de estado propio — eso era una suposición mía sin haber leído `tables.dart` todavía; era falso): `projects` **sí tiene** `is_active` (booleano, default true), igual que `accounts`/`categories` tienen `is_archived`. Se usa para archivar/reactivar un proyecto sin borrarlo ni afectar sus cobros históricos.
- Solo EUR en la UI, igual que D; sin conversión de divisas.

## Decisión que desbloqueó E

[[DEC-006 · Importe neto en cobros de proyecto]]: el importe de un cobro es siempre el neto que entra en la cuenta. Sin retención, sin bruto, sin cambio de esquema. Decisión de Andy, 2026-09-09.

## Trabajo / Resultados — implementado 2026-09-09, sin verificar

Con DEC-006 resuelto, implementé el repositorio y la UI siguiendo el mismo patrón que D usó para gastos:

- `lib/data/project_repository.dart` (nuevo): `ProjectRepository` con `saveClient`, `setClientArchived`, `saveProject`, `setProjectActive`, `saveIncome`, `markCollected`, `deleteIncome` (borrado lógico), y `ProjectSnapshot`/`watch()` reactivo sobre `accounts`/`clients`/`projects`/`transactions`, replicando el estilo de `ExpenseRepository`. Los cobros se guardan siempre con `project_id` obligatorio (no hay cobro suelto sin proyecto en esta primera vuelta) y `client_id` derivado del proyecto en cada guardado, para respetar el FK compuesto `(project_id, client_id) → projects(id, client_id)`.
- `lib/features/projects/projects_screen.dart` (reescrito, antes placeholder): `ProjectsScreen` (lista de clientes, UI-06), `ClientEditor`, `ClientDetailScreen` (cliente + sus proyectos, UI-07), `ProjectEditor`, `ProjectDetailScreen` (proyecto + sus cobros + totales cobrado/pendiente, UI-07), `IncomeEditor` (alta/edición/eliminación de cobro, UI-08).
- Rutas nuevas en `lib/app/router/app_router.dart`: `/proyectos/clientes/nuevo`, `/proyectos/clientes/:id`, `/proyectos/clientes/:id/editar`, `/proyectos/clientes/:clientId/proyectos/nuevo`, `/proyectos/detalle/:id`, `/proyectos/detalle/:id/editar`, `/proyectos/detalle/:id/cobros/nuevo`, `/proyectos/detalle/:id/cobros/:cobroId/editar`.
- La opción "Cobro de proyecto" de la hoja de nuevo movimiento (antes "Próximamente") ahora lleva a Clientes/Proyectos para elegir el proyecto — no hay una creación rápida de cobro sin elegir proyecto primero, por diseño (un cobro siempre pertenece a un proyecto).
- Si no hay ninguna cuenta EUR creada, el editor de cobro redirige a Gastos para crearla ahí (no se duplicó el diálogo de alta de cuenta).

## Alcance no cubierto en esta primera vuelta (no bloqueante, revisar si hace falta más adelante)

- Sin conciliación de "cobro esperado del proyecto vs. cobros parciales registrados" — solo lista y crea cobros uno a uno.
- Sin trazabilidad de bruto/retención (ver DEC-006).
- El importe orientativo del proyecto sigue siendo solo referencia visual, no se compara automáticamente contra lo cobrado.

## Verificación — pendiente, no hecha por mí

**Importante:** esta sesión no tiene el SDK de Flutter/Dart instalado, igual que ya se documentó para el resto del proyecto. No he ejecutado `flutter analyze`, `flutter test` ni `flutter build apk` sobre este código — no puedo, y no voy a afirmar que pasa sin haberlo corrido. No escribí tests nuevos (`project_repository_test.dart` / UI test) porque no podía verificarlos yo mismo y prefiero no entregar tests sin ejecutar como si fueran una garantía.

Antes de considerar cerrado este corte, pendiente que Andy (o Codex/otro asistente de desarrollo con entorno Flutter):
1. Corra `flutter analyze` y `dart format --output=none --set-exit-if-changed .` sobre el proyecto.
2. Escriba y corra tests de `ProjectRepository` (mínimo: crear cliente, crear proyecto, guardar/editar/eliminar cobro, constraint de estado cobrado↔fecha real, constraint pagado prohibido para project_income) y, si procede, un test de render de las pantallas nuevas.
3. Corra `flutter build apk --debug` para confirmar que compila.
4. Pruebe el flujo real en dispositivo: crear cliente → crear proyecto → crear cobro → marcarlo cobrado → archivar cliente.

Hasta que eso se confirme, este corte queda en `status: review`, no `completed`.
