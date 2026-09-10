import 'package:flutter/material.dart';

import 'paliko_colors.dart';

/// Tipografía del sistema PALIKO.
///
/// Se usa la fuente del sistema para no depender de descargas en tiempo de
/// ejecución. La identidad se apoya en la jerarquía de tamaño y peso, no en
/// una familia tipográfica exótica.
abstract final class PalikoTypography {
  /// Fuente tabular para importes, de modo que las columnas de cifras queden
  /// alineadas entre filas.
  static const List<FontFeature> numericFeatures = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  static const TextTheme textTheme = TextTheme(
    displaySmall: TextStyle(
      fontSize: 34,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: PalikoColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      height: 1.25,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: PalikoColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      height: 1.3,
      fontWeight: FontWeight.w600,
      color: PalikoColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      height: 1.35,
      fontWeight: FontWeight.w600,
      color: PalikoColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: PalikoColors.textPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: PalikoColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
      color: PalikoColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w400,
      color: PalikoColors.textSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      height: 1.45,
      fontWeight: FontWeight.w400,
      color: PalikoColors.textMuted,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: PalikoColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      height: 1.2,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
      color: PalikoColors.textSecondary,
    ),
    // Etiquetas de sección en versales: el único recurso ornamental permitido.
    labelSmall: TextStyle(
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
      color: PalikoColors.textMuted,
    ),
  );

  /// Estilo para importes destacados (saldo del mes, totales de tarjeta).
  static const TextStyle amountLarge = TextStyle(
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    fontFeatures: numericFeatures,
    color: PalikoColors.textPrimary,
  );

  /// Importes en filas de listado.
  static const TextStyle amountMedium = TextStyle(
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w600,
    fontFeatures: numericFeatures,
    color: PalikoColors.textPrimary,
  );

  /// Importes secundarios: desgloses, comparativas.
  static const TextStyle amountSmall = TextStyle(
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w600,
    fontFeatures: numericFeatures,
    color: PalikoColors.textSecondary,
  );
}
