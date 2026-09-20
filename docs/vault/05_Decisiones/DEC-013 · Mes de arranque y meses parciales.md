---
id: DEC-013
project: ECONOMY_TRACKER
type: decision
status: active
mode: diario
owner: compartido
related_cut: ECON-100A
created: 2026-09-20
updated: 2026-09-20
---

# DEC-013 · Mes de arranque y meses parciales

## Decisión

El histórico mensual sigue siendo de **mes natural** (del 1 al último día),
pero un mes solo recibe veredicto —cumplido o no cumplido— si la aplicación lo
vivió **entero y ya está cerrado**.

```
untracked   anterior al primer uso     → no se enseña
partial     se empezó a mitad de mes   → cifra sí, veredicto no
inProgress  el mes corriente           → cifra sí, veredicto no
complete    cerrado y cubierto entero  → el único que se juzga
```

## Qué lo provocó

Andy declaró 200 € apartados en septiembre y justo debajo le salía
**«sep 26 · −227 €»** con el icono de objetivo incumplido. Reproducido con sus
datos reales: en septiembre había cobrado 0 € —su nómina está prevista para el
5 de octubre— y pagado 227,84 €. La cifra era correcta; el veredicto, no.

Encima, los meses de abril a agosto aparecían a 0,00 € con el mismo icono de
incumplido: meses en los que la aplicación ni existía.

Andy lo planteó además como problema de producto, no solo suyo: *«si el día de
mañana se lo doy a alguien o la subo a la App Store quedaría mal si no se
empieza a usar la apk el mismo día 1 del mes»*. Tiene razón — el caso normal
de cualquier instalación es empezar a mitad de mes.

## De dónde sale la fecha de arranque

Del **más antiguo** de dos datos:

1. el día del primer arranque, guardado en preferencias la primera vez que
   alguien pregunta;
2. el primer movimiento que hay en la base.

Hacen falta los dos. Solo el primero perdería la historia al restaurar una
copia en un móvil nuevo, donde la aplicación es nueva pero los datos no. Solo
el segundo daría por no cubierto un mes que se vivió entero sin gastar nada.

Si las preferencias fallan, se sigue con los datos: quedarse sin la fecha de
arranque es un inconveniente, perder el histórico entero por eso sería peor.

## Lo que NO cambia

Sigue valiendo [[DEC-003 · Modelo financiero y ahorro]]: **sobrar no es
ahorrar**. Esto no convierte el neto del mes en ahorro; solo deja de fingir que
un mes a medias es un mes fallado.

Se descartaron dos alternativas que Andy consideró:

- **Ciclo de nómina** (del día 5 al 4 siguiente). Respondería mejor a «¿me
  sobró algo este mes?» con su patrón de cobro a mes vencido, pero deja de
  coincidir con el calendario y complica cada informe. Andy eligió mes natural.
- **Quitar el histórico** del objetivo mensual. Descartado: la información es
  útil, lo que estaba mal era el veredicto.

Relacionado: [[DEC-003 · Modelo financiero y ahorro]] ·
[[DEC-009 · Reserva de ahorro sobre el saldo]]
