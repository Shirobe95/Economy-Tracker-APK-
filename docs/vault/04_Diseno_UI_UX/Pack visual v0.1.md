# Pack visual v0.1

VISUAL_CONTRACT_FROZEN = YES
MOCKUPS_AVAILABLE = YES

Incorporado en ECON-000C el 2026-09-07 desde ECONOMY_TRACKER_UI_MOCKUPS_v0.1.zip
proporcionado por Andy. Texto/documentación = contrato funcional; mockups
aprobados = contrato visual congelado. No son inspiración libre. Originales
sin rediseño ni modificación de píxeles; cifras y nombres son demostrativos,
no datos financieros reales ni seeds.

## Pantallas aprobadas

- UI-01 · Inicio: [[_attachments/UI-01_Inicio.png]]
- UI-02 · Nuevo movimiento: [[_attachments/UI-02_Nuevo_movimiento.png]]
- UI-03 · Gastos: [[_attachments/UI-03_Gastos.png]]
- UI-07 · Cliente / Proyecto: [[_attachments/UI-07_Cliente_Proyecto.png]]
- UI-09 · Salarios: [[_attachments/UI-09_Salarios.png]]
- UI-10 · Calendario: [[_attachments/UI-10_Calendario.png]]
- UI-11 · Previsión: [[_attachments/UI-11_Previsión.png]]
- UI-12 · Objetivos: [[_attachments/UI-12_Objetivos.png]]

Composición de referencia: [[_attachments/PACK_VISUAL_v0.1.png]]. La presencia de
UI-04/05/06/08 en la composición no amplía la lista de pantallas congeladas que
establece el contrato de Andy. UI-04/05/06/08/13/14/15/16 siguen pendientes de
diseño final aprobado.

## Inspección y diferencias observadas

Se inspeccionaron visualmente las ocho imágenes individuales y la composición.
Tema azul/grafito, tarjetas, gran jerarquía de importes, acento cian y barra
inferior con acción central presentes. UI-02 individual es un bottom sheet con
formulario rápido; la composición presenta otra distribución. UI-03 individual
incluye resumen de categorías y filtros distintos de la composición. Las otras
pantallas también tienen diferencias de densidad/distribución.

Hay diferencias frente a la semántica textual: algunas cifras/iconos de gasto y
pendiente aparecen en cian en imágenes individuales; el texto define rojo para
gasto y amarillo para pendiente. El mockup de Inicio contiene una errata en el
rótulo de ahorro; las cifras y calendarios ilustrativos no son validación contable.
Estos conflictos quedan reportados y los originales conservados; no se han
reinterpretado proporciones, navegación, jerarquía ni colores en código. Antes
de implementar la pantalla afectada debe resolverse la referencia/semántica
concreta, sin declarar la UI placeholder actual conforme al mockup.

La documentación del ZIP se leyó como referencia del paquete; la autorización y
el alcance proceden del prompt ECON-000C. El contrato queda disponible para los
siguientes cortes. No equivale a implementación pixel-perfect ni smoke Android.

Relacionado: [[Sistema visual v0.1]] · [[Inventario de pantallas]] ·
[[CODEX · ECON-000C Modelo de datos y SQLite]].

## Implementación ECON-000D

UI-02 y UI-03 conectadas al flujo de gastos; UI-04 implementada usando el sistema visual existente. Originales congelados conservados. Adaptaciones funcionales, límites de fidelidad y capturas de QA: [[Flujo de gastos y recurrencias v0.1]] y [[CODEX · ECON-000D Movimientos y gastos]]. Las capturas qa-*.png del repositorio son pruebas con datos sintéticos, no sustituyen el contrato ni una revisión humana en Android.
