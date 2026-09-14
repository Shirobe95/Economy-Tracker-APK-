# Inventario de pantallas

Navegación inferior: Inicio, Gastos, acción central +, Ingresos, Previsión. + representa creación rápida de movimientos; en ECON-000B solo abre un placeholder, sin guardar datos.

| ID | Pantalla | Alcance de ECON-000B |
| --- | --- | --- |
| UI-01 | Inicio | Placeholder navegable |
| UI-02 | Nuevo movimiento | Placeholder desde + |
| UI-03 | Gastos | Placeholder navegable |
| UI-04 | Detalle de gasto | Corte posterior |
| UI-05 | Ingresos | Placeholder navegable |
| UI-06 | Clientes | Acceso secundario Clientes / Proyectos |
| UI-07 | Cliente / Proyecto | Corte posterior |
| UI-08 | Nuevo cobro | Corte posterior |
| UI-09 | Salarios | Placeholder secundario |
| UI-10 | Calendario | Placeholder secundario |
| UI-11 | Previsión | Placeholder navegable |
| UI-12 | Objetivos | Placeholder secundario |
| UI-13 | Cuentas | Placeholder secundario |
| UI-14 | Informes | Placeholder secundario |
| UI-15 | Categorías | Placeholder secundario |
| UI-16 | Ajustes | Placeholder secundario |

No hay pantalla de login. Los placeholders indican funcionalidad pendiente, no contienen cifras inventadas.
## Evolución ECON-000D

UI-02: gasto funcional y borrador rápido; otras opciones pendientes. UI-03: gastos y reglas recurrentes. UI-04: detalle, edición, pago y borrado lógico con confirmación. El resto conserva el alcance anterior. Detalle: [[Flujo de gastos y recurrencias v0.1]].

## Evolución ECON-100 · pantalla nueva, no prevista en el inventario

**UI-17 · Movimientos** (`/movimientos`, `lib/features/movements/movements_screen.dart`).
No estaba en este inventario ni tiene mockup aprobado; sale de una petición
directa de Andy el 2026-09-14 tras probar el APK: *«tenemos que tener visión de
todos los movimientos desde la pantalla de inicio»*.

Lista completa de movimientos con buscador por concepto, filtros (Todos /
Pendientes / Gastos / Ingresos) y agrupación por mes con el neto de cada mes en
la cabecera. Se llega desde tres sitios: el icono de la barra superior de Inicio,
el enlace «Ver todos» de *Próximos movimientos* y Ajustes.

Al no tener mockup, se ha construido reutilizando componentes ya aprobados
(`FinanceCard`, `SectionHeader`, `MoneyText`, la fila de movimiento de UI-03) en
vez de inventar un lenguaje visual nuevo. Captura en `docs/screenshots/09-movimientos.png`.
Queda **pendiente de revisión visual de Andy**.

UI-01 (Inicio) y UI-03 (Gastos) incorporan además acción rápida de marcar
pagado/cobrado sobre la propia fila, con «Deshacer» en el aviso posterior.
