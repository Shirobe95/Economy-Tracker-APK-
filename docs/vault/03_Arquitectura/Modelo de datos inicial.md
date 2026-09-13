# Modelo de datos inicial

Contrato funcional inicial: [[Modelo financiero funcional]]. Persistencia decidida: Drift + SQLite.

ECON-000B prepara conexión, ubicación de archivo, lifecycle, provider y versión de esquema. No fija tablas financieras ni relaciones definitivas.

ECON-000C debe especificar cuentas, movimientos, categorías y relaciones pertinentes; representación monetaria precisa, moneda, fechas previstas/reales, estados, transferencias, restricciones y migraciones. Estas cuestiones están pendientes de especificación, no se consideran decisiones cerradas.

No existen datos financieros reales ni importaciones en el bootstrap.
## Concreción ECON-000C · 2026-09-07

Las cuestiones pendientes de este documento histórico se concretan en [[Modelo de datos Drift v0.1]]. Esquema v2 con ocho tablas y migración desde v1. Validaciones y resultado en [[CODEX · ECON-000C Modelo de datos y SQLite]].
