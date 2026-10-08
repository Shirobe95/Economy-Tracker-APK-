---
id: DEC-016
project: ECONOMY_TRACKER
status: active
mode: diario
owner: compartido
related_cut: ECON-000E
created: 2026-10-08
updated: 2026-10-08
---

# DEC-016 · Cobro de proyecto fijo, y por qué el suelto no entra en la previsión

## Contexto

Andy reportó que, al revisar un cobro recién anotado, notó que no existía
forma de declarar un cobro de cliente que se repite solo (una cuota mensual
de mantenimiento, por ejemplo), a diferencia de un cobro puntual de un
trabajo concreto, que ECON-000E ya cubría bien.

Revisando el código: las reglas recurrentes (`recurring_rules`) solo se
podían crear como gasto. Ni la pantalla de alta (`/reglas/nueva`) ni el
botón "Reglas recurrentes" de Gastos pasaban nunca un tipo distinto de
`expense`, y la tabla no tenía columna de proyecto, así que ni siquiera se
podría haber enlazado una regla de ingreso a un cliente.

## Decisión

1. **Un cobro de proyecto puede ser fijo.** `recurring_rules` gana
   `project_id`/`client_id` (nullable), con el mismo patrón de clave
   compuesta `(project_id, client_id) → projects(id, client_id)` que ya
   usaba `transactions`. Un CHECK exige que todo cobro de proyecto fijo
   tenga proyecto, y que ninguna otra regla lo tenga.
2. **Se crea desde la ficha del proyecto**, no desde un selector genérico:
   un cobro de proyecto siempre pertenece a un proyecto (ECON-000E), y eso
   no cambia por ser fijo. La ficha del proyecto gana una sección "Cobros
   fijos" con su propio alta.
3. **Solo el cobro fijo entra en la Previsión.** Un cobro suelto, de un
   trabajo puntual, no tiene la misma certeza de repetirse que un gasto fijo
   o una nómina: contarlo en la proyección inflaría el saldo futuro con un
   ingreso que puede no volver a pasar. `ForecastEngine` excluye un
   `project_income` sin `recurring_rule_id` de los hitos comprometidos; uno
   que sí viene de una regla (fija o ya liquidada) cuenta igual que
   cualquier otro compromiso. El cobro suelto sigue viéndose, como siempre,
   en Ingresos — solo desaparece de la proyección.

Decisión de Andy, 2026-10-08: *"tenemos que contemplar cobros fijos y
recurrentes además de los sueltos que pueden ocurrir. Estos tienen que
estar contemplados en la previsión, solamente los fijos pueden entrar en la
previsión."*

## Lo que esto corrige de paso

`RecurringRuleFormScreen` tenía un bug latente: al editar cualquier regla,
el tipo se tomaba siempre del constructor de la ruta (que por defecto es
`expense`), nunca de la regla real cargada. No se notaba porque hasta ahora
toda regla era de gasto. Al abrir la puerta a reglas de ingreso, editar una
regla de cobro fijo la habría convertido en gasto sin avisar. Se corrigió
junto con este corte: el tipo y el proyecto se cargan de la regla al editar,
no del punto de entrada.

También se corrigió `settleOccurrence`: al liquidar la ocurrencia de una
regla de cobro de proyecto, el movimiento creado no llevaba `project_id`, así
que el cobro liquidado no habría aparecido en la ficha del proyecto ni en
sus totales pese a venir de su propio cobro fijo.

## Lo que queda fuera, anotado para más adelante

- Ingresos (a diferencia de Gastos) no muestra todavía las ocurrencias
  futuras de una regla como "pendiente" en su listado mensual — solo lo que
  ya está anotado como movimiento. Gastos sí lo hace desde DEC-010. Es la
  misma clase de hueco, pero en la pantalla de Ingresos; no se tocó en este
  corte porque no fue lo que se pidió, queda anotado por si conviene
  igualarlo.

Relacionado: [[ECON-000E · Clientes proyectos y cobros]] ·
[[DEC-006 · Importe neto en cobros de proyecto]] ·
[[DEC-010 · Compromisos previstos, con repeticiones incluidas]]
