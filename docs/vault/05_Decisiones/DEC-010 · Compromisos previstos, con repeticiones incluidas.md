---
id: DEC-010
project: ECONOMY_TRACKER
type: decision
status: active
mode: diario
owner: compartido
related_cut: ECON-100A
created: 2026-09-20
updated: 2026-09-20
---

# DEC-010 · Compromisos previstos, con repeticiones incluidas

## Decisión

Todo listado de «lo que queda por pagar o por cobrar» se alimenta de
`PlannedRepository`, que junta dos cosas que hasta ahora vivian separadas:

1. movimientos anotados en estado `pendiente` o `previsto`;
2. ocurrencias de reglas recurrentes activas que todavia no tienen fila.

Se sigue sin materializar ninguna ocurrencia: las reglas no escriben en
`transactions`, no hay planificador, y consultar el calendario no puede
duplicar un gasto. Lo que cambia es que ahora **se leen juntas**.

## Por que

Una regla recurrente no crea filas. Consecuencia: un alquiler de 850 al mes no
aparecia en ningun listado de pendientes. La pantalla de Gastos decia
«Pendientes 225 €» cuando la realidad del mes eran 1.075 €, e Inicio solo
ensenaba lo que alguien se habia acordado de anotar a mano — que en la practica
eran los cobros, porque los gastos fijos estaban todos en reglas.

Andy lo reporto asi: *«en Proximos movimientos tenemos que poner ademas de los
ingresos tambien los gastos»* y *«que en los Gastos pendientes se muestren
tambien los gastos recurrentes, asi tenemos un global de que gastos tendremos
fijos en el mes»*. Son el mismo fallo visto desde dos pantallas.

## Reglas de la union

- **Una ocurrencia con fila gana a la proyeccion.** Si existe un movimiento con
  esa `(regla, fecha prevista)`, la proyeccion no se anade: es el mismo recibo.
- **Lo realizado y lo cancelado no son compromisos.** Salen de la lista.
- **Lo vencido no se esconde.** La ventana empieza en el mes pasado y lo que ya
  paso sin marcarse se pinta con borde y rotulo rojos. Un recibo que vencio hace
  una semana es lo mas urgente de la lista, no lo que hay que ocultar.
- **Dos meses de horizonte en Inicio.** Con una ventana mas larga, una sola
  regla mensual llena la lista con el mismo concepto repetido y tapa lo demas.

## La trampa que queda abierta

Si un gasto recurrente se anota como gasto suelto en vez de marcarse desde su
regla, la ocurrencia de la regla **sigue contando como pendiente**: el mismo
recibo aparece pagado y por pagar a la vez.

No se ha puesto ninguna heuristica de emparejamiento por concepto e importe:
adivinar que dos apuntes son el mismo y fusionarlos en silencio es peor que el
problema que resuelve. La via buena es el boton de marcar que llevan las propias
filas previstas, que liquida la ocurrencia enlazandola a su regla en un toque.
Queda anotado por si conviene revisarlo.

## Deshacer un pago rapido borra de verdad

El borrado logico no vale aqui: la fila seguiria ocupando su hueco en el indice
unico de `(regla, fecha prevista)` y esa ocurrencia no se podria volver a
marcar nunca. `MovementRepository.purge` borra la fila; y `settleOccurrence`
revive una fila borrada logicamente en vez de chocar contra el indice.

Relacionado: [[DEC-005 · Recurrencias en días inexistentes]] ·
[[Flujo de gastos y recurrencias v0.1]] · [[Inventario de pantallas]]
