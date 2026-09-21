import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Tema oscuro unico de la aplicacion (Sistema visual v0.1).
///
/// Centraliza tipografia, tarjetas, botones, campos y navegacion. Las
/// pantallas no definen colores propios: los toman de aqui o de [AppTokens].
abstract final class AppTheme {
  const AppTheme._();

  static ThemeData build() {
    const colorScheme = ColorScheme.dark(
      primary: AppTokens.accent,
      onPrimary: AppTokens.onAccent,
      secondary: AppTokens.accentBright,
      onSecondary: AppTokens.onAccent,
      surface: AppTokens.surface,
      onSurface: AppTokens.textPrimary,
      error: AppTokens.negative,
      onError: AppTokens.onAccent,
      outline: AppTokens.border,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      // Declarada explicitamente en vez de depender de la fuente por defecto
      // del entorno: es la del sistema en Android, y hace que los renders de
      // revision salgan con la misma tipografia que el dispositivo.
      fontFamily: AppTokens.fontFamily,
      scaffoldBackgroundColor: AppTokens.background,
      canvasColor: AppTokens.background,
      splashFactory: InkSparkle.splashFactory,
    );

    final textTheme = _textTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppTokens.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        // Derivado del textTheme para que arrastre la familia tipografica;
        // un TextStyle suelto aqui no la hereda.
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 22,
          color: AppTokens.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppTokens.textSecondary),
        actionsIconTheme: const IconThemeData(color: AppTokens.accentBright),
      ),
      cardTheme: CardThemeData(
        color: AppTokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
          side: const BorderSide(color: AppTokens.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppTokens.border,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppTokens.accent,
          foregroundColor: AppTokens.onAccent,
          minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
          textStyle: const TextStyle(
            fontFamily: AppTokens.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusControl),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTokens.textPrimary,
          minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
          side: const BorderSide(color: AppTokens.borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusControl),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppTokens.accentBright),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppTokens.accent,
        foregroundColor: Colors.white,
        // Sin sombra dura: el sistema visual separa por color y borde, no
        // por elevacion.
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        extendedTextStyle: textTheme.titleMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.surfaceElevated,
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppTokens.textSecondary,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppTokens.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space4,
          vertical: AppTokens.space3,
        ),
        border: _inputBorder(AppTokens.border),
        enabledBorder: _inputBorder(AppTokens.border),
        focusedBorder: _inputBorder(AppTokens.accent),
        errorBorder: _inputBorder(AppTokens.negative),
        focusedErrorBorder: _inputBorder(AppTokens.negative),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppTokens.surfaceSubtle,
        selectedColor: AppTokens.accent,
        side: const BorderSide(color: AppTokens.border),
        // Derivados del textTheme: un TextStyle suelto no arrastra la
        // familia tipografica y el chip acaba sin fuente.
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppTokens.textSecondary,
        ),
        secondaryLabelStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: const StadiumBorder(),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppTokens.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppTokens.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.surfaceElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppTokens.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppTokens.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.bodySmall!.copyWith(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? AppTokens.accentBright : AppTokens.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? AppTokens.accentBright : AppTokens.textMuted,
          );
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppTokens.accent,
        linearTrackColor: AppTokens.surfaceElevated,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppTokens.textSecondary,
        textColor: AppTokens.textPrimary,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppTokens.radiusControl),
    borderSide: BorderSide(color: color),
  );

  static TextTheme _textTheme(TextTheme base) => base
      .copyWith(
        displaySmall: base.displaySmall?.copyWith(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: base.bodyMedium?.copyWith(fontSize: 14),
        bodySmall: base.bodySmall?.copyWith(
          fontSize: 13,
          color: AppTokens.textSecondary,
        ),
        labelSmall: base.labelSmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppTokens.textSecondary,
        ),
      )
      .apply(
        bodyColor: AppTokens.textPrimary,
        displayColor: AppTokens.textPrimary,
      );
}
