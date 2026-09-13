# Arquitectura técnica v0.1

Android primero, Flutter, Riverpod, GoRouter y Drift + SQLite. Arquitectura local-first, modular y pragmática. Sin backend, API, Supabase, autenticación remota, login, cuentas online o sincronización cloud.

El código fuente reside exclusivamente en C:\Users\Andy\Documents\Work\Personal Proyects\Economy Tracker.

- lib/app: configuración, router y tema.
- lib/core: base de datos, utilidades y componentes compartidos.
- lib/data: futuros repositorios; sin capas vacías ceremoniales.
- lib/features: dashboard, expenses, income, projects, salaries, forecast, goals, calendar, accounts, reports, categories y settings.

El ProviderScope raíz administra estado y recursos. La base local se abre bajo demanda y se cierra al disponer su provider. La versión inicial de esquema es técnica; ECON-000C definirá tablas financieras y pruebas de migración con datos.

Las pantallas no dependen de servicios externos. La futura biometría/PIN será protección local, no autenticación de cuenta.
## Evolución ECON-000C

El esquema técnico v1 da paso al esquema financiero v2, documentado en [[Modelo de datos Drift v0.1]]. Se conserva la conexión local y lifecycle Riverpod. Sin cambios de stack ni servicios externos.
