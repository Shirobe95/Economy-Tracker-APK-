import 'package:flutter/material.dart';

/// Tokens del sistema visual PALIKO para Economy Tracker.
///
/// Los valores derivan del contrato visual congelado (Pack visual v0.1):
/// se muestrearon directamente los PNG aprobados en
/// `docs/vault/04_Diseno_UI_UX/_attachments/`, en vez de reinterpretar los
/// principios del texto con valores propios. Ver `docs/DEC-007-tokens.md`.
abstract final class AppTokens {
  const AppTokens._();

  // --- Fondos y superficies -------------------------------------------------

  /// Fondo raiz. Grafito azulado muy oscuro (muestreado en margenes de UI-01).
  static const Color background = Color(0xFF0A1825);

  /// Fondo de tarjetas y paneles sobre [background].
  static const Color surface = Color(0xFF122234);

  /// Paneles elevados: hojas modales, menus, campos de formulario.
  static const Color surfaceElevated = Color(0xFF17293D);

  /// Superficie sutil: filas de lista, chips inactivos.
  static const Color surfaceSubtle = Color(0xFF0F1E2E);

  // --- Bordes ---------------------------------------------------------------

  static const Color border = Color(0xFF223447);
  static const Color borderStrong = Color(0xFF2E4459);

  // --- Acento ---------------------------------------------------------------

  /// Acento principal azul-cian: accion central, chips activos, enlaces.
  static const Color accent = Color(0xFF29B8F0);

  /// Variante clara del acento: iconos y rotulos de pestana activa.
  static const Color accentBright = Color(0xFF54E2FF);

  /// Acento apagado para trazados y fondos de grafico.
  static const Color accentDim = Color(0xFF1C6E9B);

  /// Velo translucido del acento sobre superficies.
  static const Color accentSurface = Color(0x1F29B8F0);

  /// Texto e iconos sobre acento solido.
  static const Color onAccent = Color(0xFF04161F);

  // --- Texto ----------------------------------------------------------------

  static const Color textPrimary = Color(0xFFEAF2FB);
  static const Color textSecondary = Color(0xFF9FB0C4);
  static const Color textMuted = Color(0xFF6C7F93);

  // --- Semanticos (Sistema visual v0.1) -------------------------------------

  /// Ingreso cobrado, saldo positivo, progreso cumplido.
  static const Color positive = Color(0xFF5FE0A0);
  static const Color positiveSurface = Color(0x1F5FE0A0);

  /// Gasto, importe negativo.
  static const Color negative = Color(0xFFF1584F);
  static const Color negativeSurface = Color(0x1FF1584F);

  /// Pendiente de pago o de cobro.
  static const Color pending = Color(0xFFF2A93B);
  static const Color pendingSurface = Color(0x1FF2A93B);

  /// Previsto / informacion de interfaz. Comparte tono con el acento.
  static const Color forecast = accent;
  static const Color forecastSurface = accentSurface;

  // --- Espaciado ------------------------------------------------------------

  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;

  // --- Radios ---------------------------------------------------------------

  static const double radiusCard = 16;
  static const double radiusControl = 12;
  static const double radiusPill = 999;

  /// Objetivo tactil minimo recomendado en Android.
  static const double minTouchTarget = 48;
}
