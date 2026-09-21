import 'package:flutter/material.dart';

/// Tokens del sistema visual PALIKO para Economy Tracker.
///
/// Fuente de verdad: `MOD · Sistema visual oscuro grafito-cian (Flutter)`,
/// el modulo compartido entre PALIKO, GameVault y Economy Tracker. De ahi
/// salen, literales, el fondo, la superficie, el borde, el acento y la
/// escala de espaciado.
///
/// Los roles que esa nota no fija con un hexadecimal —los colores semanticos
/// financieros y la jerarquia de texto— se muestrearon de los mockups
/// aprobados en `docs/vault/04_Diseno_UI_UX/_attachments/`, que el Pack
/// visual declara contrato congelado. Cada token dice de donde sale, para que
/// la proxima persona no tenga que adivinarlo. Ver DEC-007.
abstract final class AppTokens {
  const AppTokens._();

  // --- Fondos y superficies -------------------------------------------------

  /// Fondo raiz. Valor PALIKO.
  static const Color background = Color(0xFF050A12);

  /// Fondo de tarjetas y paneles sobre [background]. Valor PALIKO.
  static const Color surface = Color(0xFF09111E);

  /// Paneles elevados: hojas modales, menus, campos de formulario.
  ///
  /// PALIKO no define un tercer nivel en la nota del modulo: se interpola
  /// entre [surface] y [border] para separar lo elevado sin inventar un tono.
  static const Color surfaceElevated = Color(0xFF0D1829);

  /// Superficie sutil: filas de lista y chips inactivos. Derivada igual que
  /// la anterior, entre el fondo y la superficie.
  static const Color surfaceSubtle = Color(0xFF070E19);

  // --- Bordes ---------------------------------------------------------------

  /// Valor PALIKO.
  static const Color border = Color(0xFF17304A);

  /// Borde de enfasis, aclarado sobre [border] para paneles destacados.
  static const Color borderStrong = Color(0xFF224A6B);

  // --- Acento ---------------------------------------------------------------

  /// Acento principal cian electrico. Valor PALIKO.
  static const Color accent = Color(0xFF2ED8FF);

  /// Variante clara del acento: iconos y rotulos de pestana activa.
  static const Color accentBright = Color(0xFF6BE5FF);

  /// Variante apagada del acento: trazados y fondos de grafico.
  static const Color accentDim = Color(0xFF1B7E9B);

  /// Velo translucido del acento sobre superficies.
  static const Color accentSurface = Color(0x1F2ED8FF);

  /// Texto e iconos sobre acento solido.
  static const Color onAccent = Color(0xFF031017);

  // --- Texto ----------------------------------------------------------------
  //
  // Muestreados de los mockups: la nota del modulo no fija la jerarquia de
  // texto con hexadecimales.

  static const Color textPrimary = Color(0xFFEAF2FB);
  static const Color textSecondary = Color(0xFF9FB0C4);
  static const Color textMuted = Color(0xFF6C7F93);

  // --- Semanticos (Sistema visual v0.1) -------------------------------------
  //
  // Mapean a los roles success / danger / warning de PALIKO. La nota del
  // modulo no da sus hexadecimales, asi que estos vienen de los mockups
  // aprobados de Economy Tracker.

  /// Ingreso cobrado, saldo positivo, progreso cumplido.
  static const Color positive = Color(0xFF5FE0A0);
  static const Color positiveSurface = Color(0x1F5FE0A0);

  /// Gasto, importe negativo.
  static const Color negative = Color(0xFFF1584F);
  static const Color negativeSurface = Color(0x1FF1584F);

  /// Pendiente de pago o de cobro.
  static const Color pending = Color(0xFFF2A93B);
  static const Color pendingSurface = Color(0x1FF2A93B);

  /// Previsto e informacion de interfaz. Comparte tono con el acento.
  static const Color forecast = accent;
  static const Color forecastSurface = accentSurface;

  // --- Espaciado ------------------------------------------------------------
  //
  // Escala PALIKO: xs 4 · sm 8 · md 12 · lg 16 · xl 24 · xxl 32.

  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 12;
  static const double spaceLg = 16;
  static const double spaceXl = 24;
  static const double spaceXxl = 32;

  // Alias numerados: es como los usa toda la interfaz.
  /// Familia tipografica de toda la aplicacion.
  ///
  /// Esta aqui porque `styleFrom` construye TextStyle sueltos que no heredan
  /// la familia del tema: sin declararla, el texto de esos botones cae a la
  /// fuente por defecto del entorno.
  static const String fontFamily = 'Roboto';

  static const double space1 = spaceXs;
  static const double space2 = spaceSm;
  static const double space3 = spaceMd;
  static const double space4 = spaceLg;
  static const double space5 = spaceXl;
  static const double space6 = spaceXxl;

  /// Margen lateral de pantalla.
  ///
  /// Anclado a [spaceXl] por decision de Economy Tracker, no por PALIKO:
  /// bajarlo estrecharia un margen ya validado visualmente.
  static const double spacePage = spaceXl;

  // --- Radios ---------------------------------------------------------------
  //
  // PALIKO tiene escala nombrada (sm/md/lg/xl/pill), pero la nota del modulo
  // no da sus valores numericos: se conservan los de Economy Tracker con los
  // nombres de la escala, pendientes de confirmar cuando se extraiga el
  // paquete compartido.

  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusPill = 999;

  static const double radiusCard = radiusLg;
  static const double radiusControl = radiusMd;

  /// Objetivo tactil minimo recomendado en Android.
  static const double minTouchTarget = 48;
}
