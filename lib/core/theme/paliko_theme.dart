import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'paliko_colors.dart';
import 'paliko_spacing.dart';
import 'paliko_typography.dart';

/// Tema Material 3 que materializa el sistema visual PALIKO.
///
/// La app es oscura por diseño: no se ofrece variante clara, porque la
/// identidad depende del contraste entre el grafito azulado y el acento cian.
abstract final class PalikoTheme {
  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: PalikoColors.accent,
    onPrimary: PalikoColors.textOnAccent,
    primaryContainer: PalikoColors.accentDim,
    onPrimaryContainer: PalikoColors.textPrimary,
    secondary: PalikoColors.accentSecondary,
    onSecondary: PalikoColors.textOnAccent,
    secondaryContainer: PalikoColors.surfaceElevated,
    onSecondaryContainer: PalikoColors.textPrimary,
    tertiary: PalikoColors.forecast,
    onTertiary: PalikoColors.textOnAccent,
    error: PalikoColors.negative,
    onError: PalikoColors.textOnAccent,
    errorContainer: PalikoColors.negativeSurface,
    onErrorContainer: PalikoColors.negative,
    surface: PalikoColors.surface,
    onSurface: PalikoColors.textPrimary,
    surfaceContainerLowest: PalikoColors.background,
    surfaceContainerLow: PalikoColors.surfaceSubtle,
    surfaceContainer: PalikoColors.surface,
    surfaceContainerHigh: PalikoColors.surfaceElevated,
    surfaceContainerHighest: PalikoColors.surfaceElevated,
    onSurfaceVariant: PalikoColors.textSecondary,
    outline: PalikoColors.border,
    outlineVariant: PalikoColors.divider,
    shadow: Color(0xFF000000),
    scrim: Color(0xCC05080C),
    inverseSurface: PalikoColors.textPrimary,
    onInverseSurface: PalikoColors.background,
    inversePrimary: PalikoColors.accentDim,
  );

  /// Estilo de la barra de sistema, para que Android no pinte barras claras
  /// sobre el fondo grafito.
  static const SystemUiOverlayStyle systemOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: PalikoColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static ThemeData get dark {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: PalikoColors.background,
      canvasColor: PalikoColors.background,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: PalikoTypography.textTheme,
      primaryTextTheme: PalikoTypography.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: PalikoColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: PalikoColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemOverlayStyle,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: PalikoColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: PalikoColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PalikoRadius.lg),
          side: const BorderSide(color: PalikoColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: PalikoColors.divider,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: PalikoColors.textSecondary,
        size: 22,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: PalikoColors.textSecondary,
        textColor: PalikoColors.textPrimary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: PalikoSpacing.lg,
          vertical: PalikoSpacing.xs,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: PalikoColors.accent,
          foregroundColor: PalikoColors.textOnAccent,
          disabledBackgroundColor: PalikoColors.surfaceElevated,
          disabledForegroundColor: PalikoColors.textMuted,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: PalikoSpacing.xl),
          textStyle: PalikoTypography.textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PalikoRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PalikoColors.textPrimary,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: PalikoSpacing.xl),
          side: const BorderSide(color: PalikoColors.borderStrong),
          textStyle: PalikoTypography.textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PalikoRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: PalikoColors.accent,
          textStyle: PalikoTypography.textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: PalikoColors.accent,
        foregroundColor: PalikoColors.textOnAccent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PalikoRadius.lg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PalikoColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PalikoSpacing.lg,
          vertical: PalikoSpacing.md,
        ),
        hintStyle: PalikoTypography.textTheme.bodyMedium?.copyWith(
          color: PalikoColors.textMuted,
        ),
        labelStyle: PalikoTypography.textTheme.bodyMedium,
        floatingLabelStyle: PalikoTypography.textTheme.labelMedium?.copyWith(
          color: PalikoColors.accent,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PalikoRadius.md),
          borderSide: const BorderSide(color: PalikoColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PalikoRadius.md),
          borderSide: const BorderSide(color: PalikoColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PalikoRadius.md),
          borderSide: const BorderSide(color: PalikoColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PalikoRadius.md),
          borderSide: const BorderSide(color: PalikoColors.negative),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PalikoRadius.md),
          borderSide: const BorderSide(
            color: PalikoColors.negative,
            width: 1.5,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: PalikoColors.surfaceElevated,
        selectedColor: PalikoColors.accentSurface,
        side: const BorderSide(color: PalikoColors.border),
        labelStyle: PalikoTypography.textTheme.labelMedium,
        secondaryLabelStyle: PalikoTypography.textTheme.labelMedium?.copyWith(
          color: PalikoColors.accent,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: PalikoSpacing.md,
          vertical: PalikoSpacing.sm,
        ),
        shape: const StadiumBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: PalikoColors.surfaceSubtle,
        surfaceTintColor: Colors.transparent,
        indicatorColor: PalikoColors.accentSurface,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? PalikoColors.accent : PalikoColors.textMuted,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          final bool selected = states.contains(WidgetState.selected);
          return PalikoTypography.textTheme.labelMedium!.copyWith(
            color: selected ? PalikoColors.accent : PalikoColors.textMuted,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: PalikoColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: PalikoColors.surfaceElevated,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(PalikoRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: PalikoColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PalikoRadius.lg),
          side: const BorderSide(color: PalikoColors.border),
        ),
        titleTextStyle: PalikoTypography.textTheme.titleLarge,
        contentTextStyle: PalikoTypography.textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PalikoColors.surfaceElevated,
        contentTextStyle: PalikoTypography.textTheme.bodyMedium?.copyWith(
          color: PalikoColors.textPrimary,
        ),
        actionTextColor: PalikoColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PalikoRadius.md),
          side: const BorderSide(color: PalikoColors.border),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: PalikoColors.surfaceSubtle,
          foregroundColor: PalikoColors.textSecondary,
          selectedBackgroundColor: PalikoColors.accentSurface,
          selectedForegroundColor: PalikoColors.accent,
          side: const BorderSide(color: PalikoColors.border),
          textStyle: PalikoTypography.textTheme.labelMedium,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: PalikoColors.accent,
        linearTrackColor: PalikoColors.surfaceElevated,
        circularTrackColor: PalikoColors.surfaceElevated,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          return states.contains(WidgetState.selected)
              ? PalikoColors.accent
              : PalikoColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          return states.contains(WidgetState.selected)
              ? PalikoColors.accentSurface
              : PalikoColors.surfaceElevated;
        }),
        trackOutlineColor: const WidgetStatePropertyAll<Color>(
          PalikoColors.border,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: PalikoColors.surfaceElevated,
          borderRadius: BorderRadius.circular(PalikoRadius.sm),
          border: Border.all(color: PalikoColors.border),
        ),
        textStyle: PalikoTypography.textTheme.bodySmall,
      ),
    );
  }
}
