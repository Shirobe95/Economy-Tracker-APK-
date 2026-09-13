---
id: ECON-000J
project: ECONOMY_TRACKER
type: cut
status: completed
mode: diario
owner: compartido
created: 2026-09-05
updated: 2026-09-05
---

# ECON-000J · Informes y análisis

## Objetivo y alcance

Implementar informes basados en datos reales.

## Restricciones

Respetar [[Visión y alcance v0.1]], [[Modelo financiero funcional]], [[Arquitectura técnica v0.1]] y [[Índice de decisiones]]. No adelantar otros cortes ni modificar otros proyectos.

## Trabajo / Resultados

Implementado el 2026-09-13.

Balance del periodo, serie mensual de ingresos y gastos, reparto del gasto por
categoría, medias mensuales, tasa de ahorro y comparación con el periodo
anterior. Horizontes de un mes a doce.

**Regla que define el corte:** un informe cuenta lo que ya ha pasado. Solo
entran movimientos realizados, y por su fecha real: un gasto previsto en junio
y pagado en septiembre pertenece a septiembre. Lo comprometido se muestra en
su propio bloque y no suma a los totales, o el informe sería una previsión
disfrazada. Las transferencias quedan fuera porque mueven dinero propio.

Sin ingresos, la tasa de ahorro no existe en vez de valer cero. Gastar más de
lo que entra da cero, no un porcentaje negativo.

17 tests del motor, que es puro y se prueba sin base de datos.

## Fuera de alcance

Exportar un informe a PDF o a hoja de cálculo, y comparativas entre categorías
concretas a lo largo del tiempo. No se han pedido.
