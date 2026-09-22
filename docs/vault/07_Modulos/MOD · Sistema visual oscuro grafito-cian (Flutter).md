---
id: MOD-FLUTTER-SISTEMA-VISUAL
project: PERSONAL
type: reference
status: review
owner: compartido
category: module
area: flutter_ui
used_in:
  - PALIKO
  - GAMEVAULT
  - ECONOMY_TRACKER
  - PAPERWORK_TRACKER
next_action: Decidir si se extrae a un paquete Dart compartido (design_tokens) o se deja como plantilla a copiar/adaptar por app.
created: 2026-09-09
updated: 2026-09-22
---

# MOD · Sistema visual oscuro grafito-cian (Flutter)

## Qué es

La identidad visual "PALIKO" (fondo grafito/azul oscuro, acento cian eléctrico, tarjetas/paneles, jerarquía tipográfica clara) — el lenguaje que **ya usan cuatro apps Flutter**, pero **cada una lo lleva por su cuenta**: no hay una sola fuente de verdad, y los valores han divergido históricamente.

## Dónde vive (código real, verificado)

- PALIKO — `apps/paliko_flutter/lib/core/ui/tokens/` (`paliko_colors.dart`, `paliko_spacing.dart`, `paliko_radius.dart`, `paliko_typography.dart`, `paliko_shadows.dart`) + `paliko_theme.dart`. Es la implementación más completa: incluye también widgets (`empty_state.dart`, `error_state.dart`, `status_badge.dart`, `panel_card.dart`, `sidebar_nav.dart`, `top_bar.dart`, etc. en `core/ui/widgets/`).
- GameVault — `lib/app/theme/app_colors.dart` + `app_theme.dart`. Paleta y radios definidos ad hoc, sin escala de spacing/radius reutilizable.
- Economy Tracker — `lib/app/theme/app_tokens.dart` + `app_theme.dart`. Tiene su propia escala de spacing (`AppSpace`) y colores (`AppColors`), con nombres de rol en vez de nombres visuales.
- Paperwork Tracker — `lib/app/theme/app_tokens.dart` + `app_theme.dart`, copia literal de los de Economy Tracker (repositorio `Shirobe95/Paperwork-Tracker`, desde 2026-09-22).

## Divergencia real encontrada (histórico) y corrección aplicada

- Fondo: PALIKO `#050A12` / GameVault `#0B1220` / Economy Tracker (antes) `#0C1420` — misma intención, tres grises-azulados distintos.
- Acento cian: PALIKO `#2ED8FF` / GameVault `#2FD7FF` (casi igual) / Economy Tracker (antes) `#53D5F2` (notablemente más claro).
- Escala de espaciado `md`: PALIKO 12 / Economy Tracker (antes) 16 — no coincidían.
- Radios: PALIKO tiene escala nombrada (`sm/md/lg/xl/pill`); GameVault y Economy Tracker usan números sueltos en cada widget.
- Patrón "estado vacío" (icono + título + mensaje + acción opcional) y "badge de estado" (texto + color por tono + fondo translúcido + borde) están **reimplementados los tres**, con la misma forma pero código distinto (`EmptyState` en PALIKO/GameVault, `FeaturePlaceholder` en Economy Tracker; `StatusBadge`/`GameStatusBadge`/`SessionStatusBadge`/`StatusIndicator`).

**Corregido el 2026-09-09 en Economy Tracker:** `lib/app/theme/app_tokens.dart` reescrito para usar los hexadecimales y la escala de spacing/radius exactos de PALIKO (`background #050A12`, `surface #09111E`, `border #17304A`, `primary #2ED8FF`, escala `xs4/sm8/md12/lg16/xl24/xxl32`). Los roles semánticos financieros (`positive/negative/pending`) sin equivalente literal en PALIKO se mapearon a sus tokens `success/danger/warning`. `AppSpace.page` se ancló deliberadamente a `xl` (24, no a PALIKO directamente) para no reducir el margen de pantalla ya validado visualmente en los placeholders — queda documentado en el propio archivo como decisión de Economy Tracker, no como valor PALIKO. Blast radius verificado por grep antes de aplicar: `expenses_screen.dart` usa números de spacing sueltos que ya coincidían numéricamente con la escala PALIKO (no se tocó); los widgets compartidos (`app_shell.dart`, `feature_placeholder.dart`, `metric_card.dart`, `status_indicator.dart`) heredan el cambio vía los tokens, sin lógica propia que rompiese.

**GameVault sigue divergiendo** (paleta y radios ad hoc en `app_colors.dart`/`app_theme.dart`, sin escala reutilizable) — fuera de alcance aquí: GameVault es dominio de Claude Code, no de esta sesión (ver [[REF · Ejecutor activo por proyecto]]). No se ha tocado.

## Cuarta app: Paperwork Tracker (2026-09-22)

Paperwork Tracker arrancó **copiando literalmente** `app_tokens.dart` y
`app_theme.dart` de Economy Tracker, así que nace ya alineado con los
hexadecimales y la escala de PALIKO. No hay divergencia nueva que corregir.

Lo que esto aporta a la futura extracción es un **inventario real de qué se
copia cuando se copia el sistema visual**, medido en un arranque desde cero:

| Archivo | Se copió | Cambios que hicieron falta |
| --- | --- | --- |
| `app/theme/app_tokens.dart` | Tal cual | Solo el comentario de cabecera |
| `app/theme/app_theme.dart` | Tal cual | Ninguno |
| `core/widgets/finance_card.dart` | Sí | Renombrado a `panel_card.dart` / `PanelCard` |
| `core/widgets/section_header.dart` | Tal cual | Ninguno (`SectionHeader` + `RoundIcon`) |
| `core/widgets/fade_in.dart` | Tal cual | Ninguno (`FadeIn` + `staggerDelay`) |
| `core/widgets/form_fields.dart` | Tal cual | Ninguno |
| `core/widgets/app_shell.dart` | Estructura | Destinos y etiquetas propias |
| `core/widgets/status_indicator.dart` | **No** | Reescrito: los estados son de otro dominio |
| `core/widgets/money_text.dart` | Tal cual | Ninguno |

Conclusión práctica: **el reparto entre "token", "widget neutro" y "widget de
dominio" es limpio.** Todo lo de la mitad de arriba es candidato directo al
paquete compartido; `status_indicator.dart` no lo es y no debe estarlo,
porque lo que cambia entre apps no es el chip sino el catálogo de estados. El
nombre `FinanceCard` sí era un error de origen: la tarjeta no tiene nada de
financiera y en el paquete debe llamarse `PanelCard`, como en PALIKO.

Dos detalles que se arrastraron y conviene fijar en el contrato:

- `AppTokens.fontFamily = 'Roboto'` hace falta declarado aparte porque los
  `TextStyle` sueltos de `styleFrom` **no heredan** la familia del tema. Sin
  él, botones y chips caen a la fuente por defecto del entorno.
- La `spacePage` de 24 sigue siendo decisión de aplicación, no valor PALIKO.

## Estado

Economy Tracker ya no diverge de PALIKO en color/spacing (corregido), y Paperwork Tracker nace alineado. GameVault sigue como candidato pendiente de extracción/unificación. Ningún paquete compartido existe todavía: cualquier ajuste de marca futuro sigue requiriendo tocar PALIKO + GameVault a mano (Economy Tracker ahora al menos parte de los mismos valores, aunque copiados, no importados).

## Contrato de reutilización (si se extrae)

Un paquete Dart local (`design_tokens` o similar, vía path dependency) con: colores base + colores de rol, escala de spacing, escala de radius, escala tipográfica, familia tipográfica declarada como token, `ThemeData` builder, y los widgets neutros que la tabla de arriba identifica (`PanelCard`, `SectionHeader`, `RoundIcon`, `FadeIn`, campos de formulario, `MoneyText`). Cada app mapea sus propios nombres de rol (ej. `AppColors.primary` de Economy Tracker) a los tokens del paquete, y **se queda con su propio catálogo de estados**: el chip se comparte, la lista de estados no.

## Siguiente paso

No implementar la extracción a paquete todavía sin decisión explícita de Andy. Si en algún momento se decide unificar de verdad (no solo copiar valores), GameVault es quien queda pendiente de migrar — y esa migración le corresponde al ejecutor de GameVault (Claude Code), no a esta sesión.
