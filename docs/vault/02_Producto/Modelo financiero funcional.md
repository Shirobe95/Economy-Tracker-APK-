# Modelo financiero funcional

## Cuatro conceptos

| Concepto | Significado |
| --- | --- |
| REAL | Movimientos ocurridos realmente. |
| COMPROMETIDO | Pagos o cobros pendientes. |
| PREVISTO | Proyección financiera futura. |
| OBJETIVO | Ahorro o situación financiera deseada. |

## Movimientos

Tipos iniciales: EXPENSE, SALARY, PROJECT_INCOME, OTHER_INCOME y TRANSFER.

Estados: PREVISTO, PENDIENTE, PAGADO, COBRADO y CANCELADO. Se diferencian fecha_prevista y fecha_real. La matriz de transiciones, impacto de transferencias y validaciones por tipo se concretarán en ECON-000C; este documento no inventa reglas adicionales.

## Ahorro

Separar capacidad estimada de ahorro, objetivo de ahorro y ahorro real. No asumir que todo dinero sobrante constituye ahorro.

## Previsión

Horizontes: final de mes, 3, 6, 12 y 24 meses. El futuro motor podrá considerar saldo actual, salarios, mensualidades, cobros de proyectos, gastos fijos, recurrentes, variables, extraordinarios y objetivos de ahorro.

El motor no se implementa en ECON-000B. Los placeholders no muestran métricas financieras ficticias ni ceros que aparenten saldos reales.
## Recurrencias

La política oficial es [[DEC-005 · Recurrencias en días inexistentes]]: último día válido conservando el nominal, sin saltar períodos ni drift.
