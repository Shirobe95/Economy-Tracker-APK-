---
id: DEC-009
project: ECONOMY_TRACKER
type: decision
status: active
mode: diario
owner: compartido
related_cut: ECON-100A
created: 2026-09-20
updated: 2026-09-20
---

# DEC-009 · Reserva de ahorro sobre el saldo

## Decisión

La cifra grande de Inicio deja de ser el saldo del banco y pasa a ser **lo
disponible**: el saldo menos lo que los objetivos tienen apartado. Al lado, en
pequeno, cuanto hay apartado; debajo, el saldo total; y tocando la tarjeta, el
desglose por objetivo.

No se mueve dinero entre cuentas y no se crea ninguna tabla nueva de saldos: el
reparto es de lectura, derivado en cada recalculo, como el propio saldo.

```
reserva_pedida = Σ objetivos vivos
  mensual      → importe_mensual × (meses desde start_month, este incluido)
  por importe  → current_amount declarado, o nada si no se ha declarado

apartado   = clamp(reserva_pedida, 0, saldo)
disponible = saldo − apartado
```

## Por que asi

Lo pidio Andy el 2026-09-20 con un ejemplo concreto: *«si este mes tenemos de
saldo 500 y queremos ahorrar 200, nos debe mostrar saldo actual de 300 (200 de
ahorro), si el mes siguiente nos suman otros 500 y queremos ahorrar otro mes 200
quedaria: saldo actual de 600 (400 de ahorro)»*. Y el borde: *«en caso que el
saldo actual llegue a 0 se empezara a descontar los gastos del ahorrado»*.

El `clamp` es exactamente esa ultima frase. Si el saldo no llega a cubrir lo que
los objetivos piden, lo apartado baja con el saldo y lo disponible se queda en
cero, en vez de pintar un disponible negativo que no significaria nada. Lo que
falta se ensena en el desglose como deuda con uno mismo, no como dinero.

Un saldo en numeros rojos es la excepcion: ahi lo disponible sigue siendo el
saldo real, negativo. Esconder un descubierto detras de un cero seria mentir en
la cifra mas visible de la aplicacion.

## Los objetivos por importe tambien apartan

Andy describio solo el caso mensual, y se propuso incluir tambien el ahorro
**declarado** de los objetivos por importe, porque es literalmente lo mismo:
dinero que esta en la cuenta y ya tiene destino. Un fondo de emergencia con
3.250 declarados aparta esos 3.250.

**Confirmado por Andy el 2026-09-20**: *«al ahorro anadimos tambien el
declarado de los objetivos»*. Queda cerrado, no es ya una propuesta.

Ojo a la consecuencia: un objetivo por importe aparta lo que la persona
**declara** tener ahorrado, asi que subir esa cifra baja lo disponible en el
acto. Es lo correcto —ese dinero ya tiene dueno— pero explica una bajada
repentina del disponible que si no se veria como un fallo.

## El mes de inicio es un dato, no un timestamp

La acumulacion necesita saber desde cuando cuenta el objetivo. Se ha anadido
`savings_goals.start_month` (esquema v4) en vez de derivarlo de `created_at`:
esa cifra se resta del saldo visible, asi que tiene que poder corregirse.
Alguien puede empezar a apuntar en marzo un ahorro que lleva haciendo desde
enero. La migracion v3 → v4 rellena los objetivos mensuales que ya existian con
el mes en que se crearon, que es lo que se venia suponiendo.

Sin mes de inicio, la reserva cuenta solo el mes corriente. Es preferible
quedarse corto a inventar meses de ahorro que quiza no ocurrieron.

## Que NO cambia

Esto no contradice [[DEC-003 · Modelo financiero y ahorro]]: **sobrar sigue sin
ser ahorrar**. La reserva es lo que los objetivos *piden* apartar, no una
afirmacion de que se haya apartado. El ahorro real declarado sigue siendo un
dato que la persona escribe, y el historico mensual de la pantalla de Objetivos
sigue rotulando lo que sobro como lo que es.

La prevision tampoco cambia: proyecta patrimonio total, no dinero disponible.
Mezclar las dos cosas haria que un objetivo de ahorro pareciera empobrecerte.

Relacionado: [[DEC-003 · Modelo financiero y ahorro]] · [[Modelo financiero funcional]]
