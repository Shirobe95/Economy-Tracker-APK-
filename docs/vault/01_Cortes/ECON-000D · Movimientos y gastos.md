---
id: ECON-000D
project: ECONOMY_TRACKER
type: cut
status: completed
mode: diario
owner: compartido
created: 2026-09-05
updated: 2026-09-09
---

# ECON-000D · Movimientos y gastos

## Objetivo y alcance

Implementar movimientos y gastos sobre el modelo validado.

## Restricciones

Respetar [[Visión y alcance v0.1]], [[Modelo financiero funcional]], [[Arquitectura técnica v0.1]] y [[Índice de decisiones]]. No adelantar otros cortes ni modificar otros proyectos.

## Trabajo / Resultados

Abierto tras aprobar y cerrar C el 2026-09-07. BLOQUEADO_POR_DECISION antes de
implementar: falta política de recurrencias cuando el día nominal no existe
(29/30/31 en meses cortos; 29 de febrero en años no bisiestos). Se ha solicitado
último día válido conservando el nominal frente a omitir el período. Ninguna
opción se ha asumido. No hay funcionalidad D implementada ni validada.

Ver [[CODEX · ECON-000C Revisión de cierre]]. Próxima acción: recibir la decisión
y continuar el flujo de gastos y recurrencias ya autorizado. No abrir otros cortes.

## Reanudación autorizada

Decisión resuelta por Andy: [[DEC-005 · Recurrencias en días inexistentes]]. ECON-000D reanudado; la pausa anterior es histórica.

## Validación técnica — actualizado 2026-09-09

Verificado leyendo `docs/validation/ECON-000D/*.txt` directamente (no por lo que dijera esta nota antes):

- `flutter analyze` — limpio.
- `dart format` — limpio.
- Tests — 44 PASS (`app_test`, `database_test`, `expense_repository_test`, `expense_ui_test`, `render_expenses_test`).
- Build APK debug — PASS.

Corte D técnicamente cerrado en ese sentido. **No cerrado del todo**: falta la revisión visual en dispositivo Android físico (nunca hecha, no depende de código). Además, corrección de estilo aplicada el mismo día: `lib/app/theme/app_tokens.dart` usaba colores/spacing propios en vez de los tokens PALIKO reales; ya corregido (ver [[MOD · Sistema visual oscuro grafito-cian (Flutter)]]). Recompilar/reejecutar tests tras ese cambio queda pendiente de confirmación — el cambio es solo de valores de tokens (colores/spacing), no de lógica, pero no se ha vuelto a correr `flutter analyze`/`flutter test` después de tocar el archivo.

## Revisión visual — cerrada 2026-09-09

Andy probó el APK debug en dispositivo real y confirmó que el flujo de gastos (única pestaña funcional; el resto son placeholders de B, esperado) le pareció correcto. Con esto, D queda cerrado en su alcance funcional.

**Aviso importante, no asumir que esto también valida el fix de tokens PALIKO:** el APK probado (`app-debug.apk`, generado 2026-09-07 21:02 UTC) es **anterior** a la corrección de `lib/app/theme/app_tokens.dart` del 2026-09-09. La revisión visual de Andy corresponde a la paleta antigua (Economy Tracker propia, no PALIKO), no a la corregida. Sigue pendiente: recompilar (`flutter build apk --debug`) y volver a pasar `flutter analyze`/`flutter test` después del cambio de tokens, y una revisión visual nueva —aunque sea rápida— para confirmar que el cambio de color/spacing no rompe nada visualmente. Ese pendiente es de estilo, no de funcionalidad de D, y queda registrado también en [[MOD · Sistema visual oscuro grafito-cian (Flutter)]].

