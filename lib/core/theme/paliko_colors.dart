import 'package:flutter/material.dart';

/// Paleta canónica del sistema visual PALIKO.
///
/// Base grafito azulada, acentos azul-cian, paneles discretos y separadores
/// de bajo contraste. Los colores semánticos (ingreso / gasto) son los únicos
/// que introducen tono cálido o verde en la interfaz, y solo sobre datos.
abstract final class PalikoColors {
  // --- Fondos ---------------------------------------------------------------

  /// Fondo raíz de la aplicación.
  static const Color background = Color(0xFF0B0F14);

  /// Fondo de paneles y tarjetas sobre [background].
  static const Color surface = Color(0xFF121820);

  /// Paneles elevados: hojas modales, menús, campos activos.
  static const Color surfaceElevated = Color(0xFF18202B);

  /// Fondo de elementos sutiles: chips inactivos, filas alternas.
  static const Color surfaceSubtle = Color(0xFF0F151D);

  // --- Bordes y separadores -------------------------------------------------

  static const Color border = Color(0xFF223040);
  static const Color borderStrong = Color(0xFF2E4155);
  static const Color divider = Color(0xFF1A2431);

  // --- Acentos --------------------------------------------------------------

  /// Acento principal azul-cian: acciones, foco, selección.
  static const Color accent = Color(0xFF22D3EE);

  /// Variante apagada del acento, para fondos y estados de reposo.
  static const Color accentDim = Color(0xFF0E7490);

  /// Fondo translúcido del acento para superficies destacadas.
  static const Color accentSurface = Color(0x1A22D3EE);

  /// Acento secundario azul, para series de datos y elementos informativos.
  static const Color accentSecondary = Color(0xFF4C8FFF);

  // --- Texto ----------------------------------------------------------------

  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF9AAAB8);
  static const Color textMuted = Color(0xFF6B7C8C);

  /// Texto sobre superficies de acento sólido.
  static const Color textOnAccent = Color(0xFF04141A);

  // --- Semánticos -----------------------------------------------------------

  /// Ingresos, saldo positivo, objetivos cumplidos.
  static const Color positive = Color(0xFF3DDC97);
  static const Color positiveSurface = Color(0x1A3DDC97);

  /// Gastos, saldo negativo, alertas de presupuesto.
  static const Color negative = Color(0xFFFF6B6B);
  static const Color negativeSurface = Color(0x1AFF6B6B);

  /// Avisos: previsiones ajustadas, pagos próximos.
  static const Color warning = Color(0xFFF5B84C);
  static const Color warningSurface = Color(0x1AF5B84C);

  /// Datos proyectados o simulados, frente a datos reales.
  static const Color forecast = Color(0xFF8B7FE8);
  static const Color forecastSurface = Color(0x1A8B7FE8);
}
