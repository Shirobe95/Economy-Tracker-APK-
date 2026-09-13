# ECON-000D · Gastos y recurrencias

Baseline: a56e3d7 (revisión C aceptada, sin correcciones pendientes).
DEC-005 registra la decisión expresa CLAMP_TO_LAST_VALID_DAY_PRESERVE_NOMINAL.

## Flujo implementado

Inicio/Gastos → + → Nuevo movimiento → Gasto, o Crear gasto desde el listado.
El borrador rápido conserva concepto, importe, categoría y fecha al continuar.
El formulario completo permite cuenta, categoría, concepto, importe, fecha
prevista, estado, fecha real obligatoria si pagado y notas opcionales.

Crear cuenta inicial ofrece nombre y saldo inicial firmado en EUR. Crear categoría
ofrece nombre y kind expense. Estas creaciones se confirman inmediatamente con
su botón Crear, aunque después se cancele el formulario del gasto. No se construye
administración avanzada de cuentas ni categorías.

Listado por cuenta y mes previsto; filtros Todos, Pendientes y filtro de estado
previsto/pendiente/pagado/cancelado. Recurrentes abre las reglas de esa cuenta.
Detalle muestra importe, estado, ambas fechas, cuenta, saldo real, categoría y notas.
Se puede editar, marcar como pagado seleccionando la fecha real y eliminar con
confirmación. Editar el estado a pendiente/previsto/cancelado borra actual_date;
un pagado debe tener una fecha real elegida, no inferida de expected_date.

El botón Guardar bloquea interacciones repetidas mientras escribe. Los errores de
validación se muestran en el formulario; los fallos de persistencia conservan
los valores y permiten reintentar. La consulta tiene estado de carga, error y
Reintentar. Los avisos de éxito son transitorios.

## Dinero e integridad

Sin cambios de tablas: esquema v2 y migración 1→2 de C conservados. Sin codegen o
migración adicional necesaria. Las tablas siguen siendo la fuente de verdad.
ExpenseRepository añade validación funcional y escritura transaccional sobre
Transactions: solo gastos disponibles, cuentas activas EUR, categorías activas
expense/both y coherencia de estado/fecha real. Actualiza updated_at explícitamente.

Primer flujo monetario de UI limitado a EUR (dos decimales); no se reinterpretan
cuentas de otras monedas como EUR. El modelo multimoneda se conserva; selección y
edición multimoneda siguen fuera de esta UI. No hay conversiones de divisas.

El parser acepta coma o punto decimal, sin separadores de miles ni exponentes,
convierte directamente a céntimos enteros y rechaza más de dos decimales y overflow
SQLite. Los saldos y agregados usan BigInt en memoria para no desbordarse al sumar
varios INTEGER de 64 bits. No se persiste ningún importe como double.

Saldo real de cuenta = saldo inicial + ingresos cobrados − gastos pagados
− transferencias pagadas de origen + transferencias pagadas de destino.
Previsto, pendiente, cancelado y borrado lógico no tienen impacto real. Una
transferencia es una fila y no entra en ingresos/gastos económicos; su efecto
global entre ambas cuentas es cero. No se guarda un saldo derivado mutable.

Editar un gasto pagado recalcula desde las filas actuales, incluso si cambia
importe o cuenta. Pagar otra vez una fila pagada no duplica ni cambia la primera
fecha real. Eliminar usa is_deleted=true; no borra físicamente historia ni padres,
y excluye la fila del listado y del saldo, también si estaba pagada.

Tarjeta PAGADOS usa fecha real del mes; PENDIENTES usa fecha prevista. El listado
y el resumen por categoría usan el mes previsto y el filtro visible; el resumen
excluye cancelados. No confundir esos agregados con una previsión. Sin cuenta no
se muestran métricas monetarias; con cuenta creada, cero representa una consulta
real vacía, no datos demo. No hay seeds ni fixtures cargados en producción.

## Recurrencias

Crear/editar regla de gasto: concepto, cuenta, categoría, importe, frecuencia
(días/semanas/meses/años), intervalo entero 1–120, fecha de inicio y activa/inactiva.
La fecha inicial establece el ancla. Cambiar importe no cambia el día nominal;
cambiar expresamente la fecha de inicio establece una nueva ancla.

Cada fecha se calcula desde el ancla original. En mensual/anual, si el día no
existe, se limita al último válido de ese mes sin alterar el nominal:
31/01 → 28/02 → 31/03; en bisiesto 31/01 → 29/02 → 31/03;
29/02/2028 → 28/02/2029 → 28/02/2030 → 28/02/2031 → 29/02/2032.

La UI muestra hasta seis próximas ocurrencias, desde hoy inclusive. El helper
admite como máximo 100 por consulta y respeta end_date si existe en una regla.
Calcula el índice próximo mediante aritmética; no recorre todos los días desde
un ancla antigua. Reglas inactivas devuelven cero ocurrencias.

No se materializan ocurrencias en Transactions ni se paga nada automáticamente.
Consultar repetidamente no escribe y no puede duplicar gastos. auto_generate
permanece false. No hay background service, scheduler, notificaciones ni motor
completo de previsión. Si un corte futuro materializa ocurrencias, deberá añadir
una clave de unicidad y generación transaccional idempotente antes de hacerlo.

## UI y contrato visual

Mockups individuales UI-02 y UI-03 inspeccionados directamente; usados como
referencia de composición, jerarquía, tarjetas y navegación, conservando los PNG.
UI-04 usa el sistema existente y la estructura del detalle en la composición;
no se declara mockup independiente congelado. No se rediseñaron otros módulos.

UI-02: hoja modal con cinco opciones, gasto funcional y resto pendientes, borrador
rápido y continuación. UI-03: mes, cuenta/saldo, métricas, filtros, categorías y
lista; pestaña Recurrentes para reglas y próximas fechas. UI-04: detalle y acciones.

Adaptaciones documentadas: selección de cuenta/saldo y filtro completo necesarios
para el flujo real; categoría opcional; recorridos de formularios desplazables;
fechas reales/previstas etiquetadas. El tab Recurrentes administra reglas, no finge
que existan gastos materializados. Sin logotipos comerciales ni datos del mockup.
Iconos Material y superficies del tema PALIKO existente; sin reproducción de
ilustraciones o efectos raster decorativos de los originales. No se afirma
igualdad píxel a píxel. Pendiente revisión humana del resultado en Android.

Localización española de controles de fecha mediante flutter_localizations del
SDK, única dependencia que pasa de transitiva a directa. Navegación y tema oscuros
conservados; acción central circular y menú de Gastos accesible.

## Archivos

- lib/data/expense_repository.dart: validación, escritura, streams y saldo exacto.
- lib/data/recurrence_schedule.dart: calendario anclado y acotado.
- lib/features/expenses/expenses_screen.dart: listado, detalle, formulario, reglas,
  alta mínima de cuenta/categoría y hoja de creación rápida.
- lib/app/router/app_router.dart: rutas de gasto/regla y hoja modal.
- lib/app/economy_tracker_app.dart: localización española.
- lib/core/widgets/app_shell.dart: título/menú de Gastos y acción central.
- test/expense_repository_test.dart, test/expense_ui_test.dart; app_test actualizado.
- tool/render_expenses_test.dart: capturas con SQLite en memoria y fixtures sintéticos.

Rutas: /gastos, /gastos/nuevo, /gastos/:id, /gastos/:id/editar,
/reglas/nueva, /reglas/:id/editar, /nuevo-movimiento.

## Validación y alcance

Logs y capturas en docs/validation/ECON-000D. Las imágenes qa-*.png son renders del
código real con datos sintéticos exclusivamente de prueba; no datos personales,
no capturas de dispositivo y no sustituyen revisión visual humana.

No se implementaron Clientes, Proyectos, Salarios, Previsión, Objetivos, Informes,
login, cloud, backup ni release signing. Siguiente corte recomendado: ECON-000E ·
Clientes proyectos y cobros, sin abrir ni ejecutar.
