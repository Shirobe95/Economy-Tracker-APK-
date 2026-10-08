---
id: DEC-017
project: ECONOMY_TRACKER
type: decision
status: active
mode: diario
owner: compartido
created: 2026-10-08
updated: 2026-10-08
---

# DEC-017 · FinanceCard sin contorno, sombra mínima

## Decisión

`FinanceCard` —la tarjeta base de todo el sistema visual, usada en Inicio,
Gastos, Ingresos, Previsión, Informes, Proyectos, Salarios, Objetivos y
Calendario— pierde el `Border.all` y gana una `BoxShadow` suave
(`Color(0x33000000)`, blur 14, o 20 en la variante `accent`) que la
delimita sin el contorno duro de antes.

`PlannedListTile` ("Próximos movimientos") sigue el mismo criterio, con
una excepción: un recibo vencido conserva el borde rojo, porque ahí el
contorno no es decoración, es el único aviso de que hay algo pendiente de
verdad. El resto de filas va sin contorno, con la misma sombra mínima.

## Por qué

Andy eligió, entre varias propuestas visuales, la opción "plano, sin
bordes" para Inicio, y después confirmó explícitamente: *"a partir de
ahora vamos a buscar un diseño limpio"*, extendiendo el criterio a toda la
aplicación, no solo a la pantalla que se le enseñó primero.

## Alcance

Se tocó `FinanceCard` en vez de reescribir cada pantalla, así que el
cambio se ve en toda la aplicación de una vez, con un solo punto de
verdad. No se ha revisado pantalla por pantalla si el contenido de cada
una sigue siendo el óptimo para este estilo —eso queda para cuando Andy
pida rediseñar una en concreto— pero visualmente todas quedan coherentes
entre sí desde ya.

Mismo criterio aplicado en paralelo en Daily Deck, sobre `PanelCard`
(DECK-DEC-018): los dos componentes nacieron del mismo patrón y se
corrigieron juntos.
