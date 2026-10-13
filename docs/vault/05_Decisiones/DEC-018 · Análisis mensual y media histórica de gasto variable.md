---
id: DEC-018
project: ECONOMY_TRACKER
status: active
mode: diario
owner: compartido
related_cut: ECON-000E
created: 2026-10-13
updated: 2026-10-13
---

# DEC-018 · Análisis mensual y media histórica de gasto variable

## Contexto

La pantalla de Previsión enseñaba un total agregado de "Gastos previstos"
para todo el horizonte elegido (3, 6, 12 o 24 meses mezclados), y una lista
plana de "Próximos hitos". Andy lo encontró abstracto: quería poder
deslosar mes a mes, y una previsión que tuviera en cuenta tres cosas
separadas — lo que debería entrar, lo que se paga fijo, y el resto de
gastos.

También pidió afinar el motor: hasta ahora `ForecastEngine` no estimaba
nada de gasto variable para un mes futuro sin movimientos anotados — ese
mes se proyectaba con gasto variable en cero, lo que infla la previsión en
vez de acercarla a lo que de verdad suele pasar.

Se exploraron varios diseños visuales en un canvas aparte (desglose por
tarjeta expandible vs. barra de reparto vs. resumen en bloques) y Andy
eligió fusionar dos: una lista de tarjetas por mes, colapsada en
`Mes — Balance`, que al expandirse muestra una barra de reparto con
Entrada / Gastos recurrentes / Gastado / Balance.

## Decisión

1. **`ForecastPoint` desglosa el gasto en `fixedExpense` y
   `variableExpense`.** Antes solo exponía `expense` (la suma de ambos).
   Se mantiene `expense` por compatibilidad de lectura, pero ahora es
   literal `fixedExpense + variableExpense`: lo recurrente no sorprende,
   lo del día a día sí, y de cara a la interfaz no pesan igual.

2. **Media histórica de gasto variable.** `ForecastEngine` calcula la
   media mensual de gasto variable real (pagado, sin regla detrás) de los
   últimos 6 meses — mismo patrón que `ReportResult.averageMonthlyExpense`:
   se divide por la ventana completa, no solo por los meses con
   movimiento, para no inflar la media de quien algunos meses no gasta
   nada suelto. Sin ningún gasto variable real en toda la historia, la
   media es `null` y no se estima nada: sin referencia alguna, estimar
   sería inventar un número de la nada.

3. **Un mes futuro sin nada anotado recibe un hito estimado** con esa
   media, marcado `ForecastMilestone.isEstimate = true`. Si el mes ya
   tiene algún gasto variable comprometido (aunque sea uno solo), no se
   añade la estimación encima — se completa, no se dobla. Lo estimado
   nunca sustituye a lo real ni se mezcla con `fromRule`: sigue siendo
   gasto "suelto", solo que previsto por media en vez de anotado.

4. **Nueva sección "Análisis mensual"** (`MonthlyBreakdown`), sustituye a
   "Próximos hitos": una tarjeta expandible por mes proyectado.
   - Colapsada: mes + `ForecastPoint.net` ("balance del mes"), coloreado
     verde/rojo. Cada mes se juzga solo por lo que pasó en él — un mes
     puede cerrar en números rojos y eso también es información real, de
     ahí "Balance" y no "Sobrante" (que leería mal en negativo).
   - Expandida: Entrada, barra de reparto (recurrente / gastado / libre,
     con marca de "ahí se acaba tu ingreso" si hay sobregasto), Gastos
     recurrentes, Gastado (con sufijo "(estimado)" cuando ese mes lleva
     algo de la media histórica), Balance, y una línea con el saldo
     acumulado de la cuenta a fin de ese mes (`ForecastPoint.balance`,
     que ya es acumulativo: no hace falta recalcularlo en la interfaz).
   - Encima de la lista, "Saldo de tu cuenta, hoy" ancla el acumulado de
     partida: responde directamente a la pregunta de Andy de dónde queda
     el sobrante (o el descubierto) de un mes al pasar al siguiente, sin
     mezclarlo con el balance propio de cada mes.
   - El diálogo "Cómo se calcula" se actualizó para dejar de decir que no
     se estiman gastos variables — ahora explica cuándo y cómo se hace, y
     que queda marcado como estimado.

## Lo que no incluye, a propósito

- No se tocó el motor de informes (`ReportEngine`): la media histórica
  vive solo en `ForecastEngine`, que es el único que proyecta hacia
  delante.
- No se estiman ingresos ni gastos recurrentes por media: solo el gasto
  variable, que es el único hueco que no tenía ya una fuente exacta
  (movimiento comprometido, regla recurrente o fuente salarial).
- Los tres diseños visuales descartados (fichas de resumen en 3 bloques,
  medidor de presupuesto, añadido incremental a las 4 fichas actuales) no
  se implementaron; quedan solo como referencia de lo explorado.

## Verificado

- `flutter analyze` limpio en todo el proyecto.
- `flutter test` completo: 316/317 verde. El único test que falla
  (`expense_flow_test.dart`, "un gasto pendiente no mueve el saldo hasta
  que se paga") ya fallaba igual antes de este corte — confirmado
  reproduciéndolo sobre el commit previo (`git stash` + re-run) — y no
  tiene relación con este cambio; queda pendiente aparte.
- Los 29 tests previos de `forecast_engine_test.dart` siguen pasando sin
  tocarlos; se añadieron 5 nuevos para la media histórica, el desglose
  fijo/variable y la no-duplicación de la estimación sobre un mes ya
  anotado.
- Smoke test manual (widget test ad-hoc, no comiteado) de
  `MonthlyBreakdown` montando los tres casos límite — sobregasto, mes
  marcado como estimado, y mes con `income`/`expense` en cero (división
  por cero en las fracciones de la barra) — sin excepciones de render.

Relacionado: [[DEC-016 · Cobro de proyecto fijo, y por que el suelto no entra en la previsión]] ·
[[DEC-010 · Compromisos previstos, con repeticiones incluidas]] ·
[[DEC-017 · FinanceCard sin contorno, sombra minima]]
