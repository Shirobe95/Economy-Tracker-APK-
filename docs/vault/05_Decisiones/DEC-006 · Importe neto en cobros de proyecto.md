---
id: DEC-006
project: ECONOMY_TRACKER
type: decision
status: active
mode: diario
owner: compartido
related_cut: ECON-000E
created: 2026-09-09
updated: 2026-09-09
---
# DEC-006 · Importe neto en cobros de proyecto

Decisión expresa de Andy al desbloquear ECON-000E.
INCOME_AMOUNT_POLICY = NETO_SOLAMENTE.

El importe que se registra en un cobro de proyecto (`transactions.amount` de un
`project_income`) es el neto que realmente entra en la cuenta. No se registra
retención de IRPF/IVA ni el importe bruto facturado. El esquema no cambia:
no se añade ningún campo de retención en esta decisión.

Consecuencia directa: el saldo real de cuenta (definido en ECON-000D como
saldo inicial + ingresos cobrados − gastos pagados) queda correcto sin ajustes
adicionales, porque coincide con el dinero que de verdad entra en el banco.

Lo que esta decisión NO resuelve, y queda fuera de ECON-000E: no hay
trazabilidad del importe bruto facturado ni de la retención aplicada. Si en
el futuro Andy necesita esa cifra (por ejemplo para su propia contabilidad o
declaración), requerirá una decisión aparte y probablemente una migración de
esquema (añadir un campo de retención/bruto) — no asumida aquí.

Relacionado: [[ECON-000E · Clientes proyectos y cobros]] · [[Modelo financiero funcional]].
