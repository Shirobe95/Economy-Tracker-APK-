---
id: DEC-008
project: ECONOMY_TRACKER
type: decision
status: active
mode: diario
owner: compartido
related_cut: ECON-100A
created: 2026-09-14
updated: 2026-09-14
---

# DEC-008 · Disparador de recarga en streams Drift

## Decisión

Cuando un repositorio necesite recalcular en Dart algo que depende de **varias
tablas** (saldos, resúmenes de proyecto), el disparador es
`db.tableUpdates(TableUpdateQuery.onAllTables([...]))`, envuelto en el helper
`watchTables()` de `lib/core/database/database_provider.dart`.

Queda **prohibido** usar `customSelect('SELECT 1', readsFrom: {...})` como
disparador de cambios.

```dart
Stream<void> watchTables(AppDatabase db, List<TableInfo<Table, dynamic>> tables) async* {
  yield null; // primer valor inmediato: el stream de tableUpdates solo emite en cambios
  yield* db.tableUpdates(TableUpdateQuery.onAllTables(tables));
}
```

## Por qué

Drift cachea los streams de consulta por **texto SQL y variables**, no por las
tablas observadas. En `drift-2.31.0`,
`lib/src/runtime/executor/stream_queries.dart`:

```dart
class StreamKey {
  final String sql;
  final List<dynamic> variables;
  // hashCode y == solo miran sql y variables
}
```

`readsFrom` no entra en la clave. Dos repositorios distintos que ejecutaban
`customSelect('SELECT 1', readsFrom: {...})` producían la **misma** `StreamKey`,
así que el segundo suscriptor recibía el stream ya cacheado del primero, con el
conjunto de tablas del primero. El disparador quedaba escuchando tablas ajenas.

Es un fallo silencioso: no hay excepción, no hay aviso, la pantalla
simplemente no se entera de sus propios cambios.

## Qué rompió de verdad

Andy reportó **dos veces** que un proyecto nuevo no aparecía en el detalle del
cliente. La primera corrección endureció el selector de cliente del formulario,
que no era la causa, y por eso el fallo sobrevivió. La causa real era ésta:
`AccountRepository` y `ProjectRepository` compartían un único stream, y el
detalle de cliente nunca recibía notificación al insertarse un proyecto.

El mismo patrón explica el saldo congelado reportado antes, aunque allí se
sumaba otra causa distinta (`watchBalances()` solo observaba `accounts`).

## Cómo queda protegido

`test/stream_isolation_test.dart` abre los dos repositorios contra la misma
base, inserta por debajo en cada tabla y comprueba que **cada** stream emite por
su cuenta. Antes del arreglo ese test falla; es la reproducción del bug, no una
comprobación decorativa.

## Regla práctica

Si un stream tiene que reaccionar a una escritura, la pregunta a hacerse es
«¿qué tablas hacen que este cálculo cambie?» y listarlas todas en
`watchTables()`. Observar de menos es el fallo que Andy ve en el móvil; observar
de más solo cuesta un recálculo.

Relacionado: [[Modelo de datos Drift v0.1]] ·
[[CLAUDE · Reconstrucción completa en repositorio]]
