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
next_action: Decidir si se extrae a un paquete Dart compartido (design_tokens) o se deja como plantilla a copiar/adaptar por app.
created: 2026-09-09
updated: 2026-09-09
---

# MOD · Sistema visual oscuro grafito-cian (Flutter)

## Qué es

La identidad visual "PALIKO" (fondo grafito/azul oscuro, acento cian eléctrico, tarjetas/paneles, jerarquía tipográfica clara) — el lenguaje que **ya usan tres apps Flutter**, pero **cada una lo reimplementó por su cuenta**: no hay una sola fuente de verdad, y los valores ya han divergido.

## Dónde vive (código real, verificado)

- PALIKO — `apps/paliko_flutter/lib/core/ui/tokens/` (`paliko_colors.dart`, `paliko_spacing.dart`, `paliko_radius.dart`, `paliko_typography.dart`, `paliko_shadows.dart`) + `paliko_theme.dart`. Es la implementación más completa: incluye también widgets (`empty_state.dart`, `error_state.dart`, `status_badge.dart`, `panel_card.dart`, `sidebar_nav.dart`, `top_bar.dart`, etc. en `core/ui/widgets/`).
- GameVault — `lib/app/theme/app_colors.dart` + `app_theme.dart`. Paleta y radios definidos ad hoc, sin escala de spacing/radius reutilizable.
- Economy Tracker — `lib/app/theme/app_tokens.dart` + `app_theme.dart`. Tiene su propia escala de spacing (`AppSpace`) y colores (`AppColors`), con nombres de rol en vez de nombres visuales.

## Divergencia real encontrada (histórico) y corrección aplicada

- Fondo: PALIKO `#050A12` / GameVault `#0B1220` / Economy Tracker (antes) `#0C1420` — misma intención, tres grises-azulados distintos.
- Acento cian: PALIKO `#2ED8FF` / GameVault `#2FD7FF` (casi igual) / Economy Tracker (antes) `#53D5F2` (notablemente más claro).
- Escala de espaciado `md`: PALIKO 12 / Economy Tracker (antes) 16 — no coincidían.
- Radios: PALIKO tiene escala nombrada (`sm/md/lg/xl/pill`); GameVault y Economy Tracker usan números sueltos en cada widget.
- Patrón "estado vacío" (icono + título + mensaje + acción opcional) y "badge de estado" (texto + color por tono + fondo translúcido + borde) están **reimplementados los tres**, con la misma forma pero código distinto (`EmptyState` en PALIKO/GameVault, `FeaturePlaceholder` en Economy Tracker; `StatusBadge`/`GameStatusBadge`/`SessionStatusBadge`/`StatusIndicator`).

**Corregido el 2026-09-09 en Economy Tracker:** `lib/app/theme/app_tokens.dart` reescrito para usar los hexadecimales y la escala de spacing/radius exactos de PALIKO (`background #050A12`, `surface #09111E`, `border #17304A`, `primary #2ED8FF`, escala `xs4/sm8/md12/lg16/xl24/xxl32`). Los roles semánticos financieros (`positive/negative/pending`) sin equivalente literal en PALIKO se mapearon a sus tokens `success/danger/warning`. `AppSpace.page` se ancló deliberadamente a `xl` (24, no a PALIKO directamente) para no reducir el margen de pantalla ya validado visualmente en los placeholders — queda documentado en el propio archivo como decisión de Economy Tracker, no como valor PALIKO. Blast radius verificado por grep antes de aplicar: `expenses_screen.dart` usa números de spacing sueltos que ya coincidían numéricamente con la escala PALIKO (no se tocó); los widgets compartidos (`app_shell.dart`, `feature_placeholder.dart`, `metric_card.dart`, `status_indicator.dart`) heredan el cambio vía los tokens, sin lógica propia que rompiese.

**GameVault sigue divergiendo** (paleta y radios ad hoc en `app_colors.dart`/`app_theme.dart`, sin escala reutilizable) — fuera de alcance aquí: GameVault es dominio de Claude Code, no de esta sesión (ver [[REF · Ejecutor activo por proyecto]]). No se ha tocado.

## Estado

Economy Tracker ya no diverge de PALIKO en color/spacing (corregido). GameVault sigue como candidato pendiente de extracción/unificación. Ningún paquete compartido existe todavía: cualquier ajuste de marca futuro sigue requiriendo tocar PALIKO + GameVault a mano (Economy Tracker ahora al menos parte de los mismos valores, aunque copiados, no importados).

## Contrato de reutilización (si se extrae)

Un paquete Dart local (`design_tokens` o similar, vía path dependency) con: colores base + colores de rol, escala de spacing, escala de radius, escala tipográfica, `ThemeData` builder, y los 2-3 widgets de estado (empty/error/badge). Cada app mapea sus propios nombres de rol (ej. `AppColors.primary` de Economy Tracker) a los tokens del paquete.

## Siguiente paso

No implementar la extracción a paquete todavía sin decisión explícita de Andy. Si en algún momento se decide unificar de verdad (no solo copiar valores), GameVault es quien queda pendiente de migrar — y esa migración le corresponde al ejecutor de GameVault (Claude Code), no a esta sesión.
