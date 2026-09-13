# Modelo de datos Drift v0.1 · ECON-000C

Esquema SQLite v2. Fuente funcional: contrato ECON-000C y Vault Economy Tracker.

## Tablas

| Tabla | Propósito |
| --- | --- |
| accounts | Cuenta, tipo, moneda, saldo inicial firmado, archivo lógico |
| categories | Clasificación expense/income/both y padre opcional |
| transactions | Única entidad para gastos, salarios, cobros, otros ingresos y transferencias |
| recurring_rules | Plantillas y calendario de repetición; auto_generate=false |
| clients | Cliente y contacto opcional |
| projects | Proyecto de un cliente, modalidad e importe orientativo opcionales |
| salary_sources | Fuente salarial, importe esperado y frecuencia opcionales |
| savings_goals | Meta y aportación mensual objetivo; ahorro real declarado opcional |

Todas tienen id INTEGER autoincremental local, created_at y updated_at. Los timestamps
se inicializan al insertar; quien edite debe actualizar updated_at explícitamente.
No hay datos demo ni seeds en producción. El provider Riverpod existente abre la
base bajo demanda y registra su cierre. No se añaden repositorios vacíos: Drift
ofrece las operaciones tipadas necesarias para el siguiente corte.

## Importes y moneda

Importes INTEGER de 64 bits en unidades menores de la moneda (EUR: céntimos),
nunca double. Movimientos y reglas: positivos; el tipo determina la dirección.
Saldo inicial firmado permite una cuenta con saldo negativo. Metas positivas;
importes orientativos/snapshot no negativos y nullable si desconocidos.
La moneda es un código de tres letras mayúsculas, explícito incluso en proyectos,
salarios y objetivos. No se implementa catálogo ISO, cambio de divisas ni suma
entre monedas. El formateador existente de dos decimales sigue limitado a la UI
placeholder; no se conecta a este modelo. Antes de una UI multimoneda hay que
resolver exponentes y presentación de monedas distintas de EUR.

Saldo actual: derivable del inicial y movimientos reales no eliminados; no se
almacena un segundo saldo mutable ni se calcula todavía. current_amount en metas
es un snapshot real declarado explícitamente, null=desconocido, nunca capacidad
estimada ni suma automática de ingresos. savings_goal_id es un vínculo contextual:
no convierte cualquier movimiento en ahorro ni actualiza el snapshot. El futuro
corte H deberá establecer aportaciones/retiros y reconciliación, sin doble conteo.

## Relaciones e integridad

- transactions → accounts obligatorio; destino opcional solo para transferencias.
- transactions → categories, clients, projects, salary_sources, recurring_rules,
  savings_goals opcionales con foreign keys.
- projects → clients obligatorio. El par project_id/client_id del movimiento debe
  coincidir con el cliente del proyecto; proyecto exige client_id.
- categories → categories mediante parent_id; se rechaza autoparentesco.
- recurring_rules → cuenta y categoría; destino para reglas de transferencia.
- Pares cuenta/moneda referenciados mediante claves compuestas evitan movimientos
  y transferencias con moneda distinta de la cuenta. Una transferencia representa
  una sola fila: salida en account_id y entrada en destination_account_id.
- Borrados físicos de padres referenciados quedan restringidos. No hay cascadas
  financieras destructivas. Archivo/borrado lógico conserva relaciones e historia.
- Índices para fechas/estado/cuenta, todas las relaciones de transactions,
  categorías padre, proyectos por cliente y reglas activas/próxima fecha.

Los importes orientativos de proyecto/salario son independientes del importe
real del movimiento; comparaciones futuras deberán verificar la moneda. Las
reglas enlazadas son procedencia, no una obligación de igualar snapshots antiguos
al editar una plantilla. Categorías compatibles con el tipo, ciclos de varios
padres y políticas sobre registros archivados se validarán en el servicio de
edición del corte correspondiente; hoy no existe ese servicio ni CRUD público.

## Tipos, estados y fechas

CodeConverter usa códigos de texto estables, no posiciones del enum; un código
desconocido falla explícitamente. CHECK SQL también protege escrituras directas.

- MovementType: expense, salary, project_income, other_income, transfer.
- MovementStatus: previsto, pendiente, pagado, cobrado, cancelado.
- AccountType: bank, cash, savings, other.
- CategoryKind: expense, income, both.
- RecurrenceFrequency: daily, weekly, monthly, yearly (interval_count > 0).
- BillingType: fixed, hourly, monthly, per_unit; opcional.

Estado previsto/pendiente/cancelado no tiene actual_date. Pagado requiere fecha
real y corresponde a gasto o transferencia; cobrado requiere fecha real y es
solo ingreso. expected_date siempre existe y puede diferir de actual_date.
Esto es integridad de cada registro, no un motor de transiciones: revertir o
cancelar una operación real requerirá un flujo explícito posterior.
Fechas almacenadas como timestamps Unix (Drift); usar DateTime UTC y convertir
al presentar. No se infiere que fecha real deba ser posterior a la prevista.
Para fechas financieras sin hora, el futuro formulario debe normalizar el día de
forma consistente antes de persistir. No hay scheduler ni reglas de zona horaria.

Reglas: día mensual 1–31, día semanal ISO 1–7, fin >= inicio, próxima fecha dentro
del intervalo. No se genera ninguna ocurrencia; tratamiento del día 31 en meses
cortos y excepciones de calendario queda para recurrencias funcionales.

## Migración y mantenimiento

v1 era el bootstrap sin tablas financieras. v2 crea ocho tablas, índices y
restricciones. La migración 1→2 usa createAll sin borrar entidades anteriores;
versiones no implementadas fallan. foreign_keys=ON se aplica antes de usar la base.
La prueba compara el esquema migrado con el nuevo y preserva un fixture ajeno,
además de escribir y reabrir datos financieros en un archivo temporal.
No se abre ni migra una base personal real durante este corte.

Al cambiar el esquema: subir versión, añadir paso explícito, conservar snapshots,
probar datos previos y validar integridad; nunca sustituirlo por borrar el archivo.
Regenerar con dart run build_runner build. Snapshot de la v2 en drift_schemas/.

## Alcance

Sin CRUD/UI final, cálculo de saldos, motor de previsión, generación automática,
informes, backup, login ni servicios externos. Los placeholders siguen intactos.
La capacidad estimada se calculará en G; objetivos y ahorro real se desarrollarán
con reglas verificadas en H. No se han adelantado esos cortes.

Referencias: [Tablas Drift](https://drift.simonbinder.eu/dart_api/tables/),
[migraciones Drift](https://drift.simonbinder.eu/migrations/).

## Implementación ECON-000D

El flujo funcional se documenta en [[Flujo de gastos y recurrencias v0.1]]. Se conserva esquema v2; saldos derivados y preview de recurrencias sin materialización. La política de días inexistentes queda resuelta en [[DEC-005 · Recurrencias en días inexistentes]].
