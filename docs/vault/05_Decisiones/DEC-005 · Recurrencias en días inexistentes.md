---
id: DEC-005
project: ECONOMY_TRACKER
type: decision
status: active
mode: diario
owner: compartido
related_cut: ECON-000D
created: 2026-09-07
updated: 2026-09-07
---
# DEC-005 · Recurrencias en días inexistentes

Decisión expresa de Andy al reanudar ECON-000D.
RECURRENCE_INVALID_DAY_POLICY = CLAMP_TO_LAST_VALID_DAY_PRESERVE_NOMINAL.

Si el día nominal no existe, usar el último día válido del mes. Conservar siempre
el día nominal original al calcular las siguientes ocurrencias. No saltar períodos.

- Mensual 31: 31 enero → 28 febrero → 31 marzo → 30 abril → 31 mayo.
- En año bisiesto: 31 enero → 29 febrero → 31 marzo.
- Anual: 29/02/2028 → 28/02/2029 → 28/02/2030 → 28/02/2031 → 29/02/2032.

Prohibido el drift 31 enero → 28 febrero → 28 marzo. Cada fecha se calcula desde
el ancla nominal, nunca desde la fecha ajustada anterior. SKIP_INVALID_PERIOD no
está permitido. Se aplica a gastos recurrentes y a futuras previsiones/calendario.

Relacionado: [[ECON-000D · Movimientos y gastos]] · [[Modelo financiero funcional]].
