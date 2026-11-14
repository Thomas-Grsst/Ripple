import 'package:flutter/material.dart';

import 'ripple_colors.dart';

abstract final class RippleSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double gutter = 28;
}

ThemeData buildRippleTheme() {
  const ColorScheme colorScheme = ColorScheme.dark(
    primary: RippleColors.accent,
    onPrimary: RippleColors.onAccent,
    secondary: RippleColors.accent,
    onSecondary: RippleColors.onAccent,
    surface: RippleColors.surface,
    onSurface: RippleColors.textPrimary,
    onSurfaceVariant: RippleColors.textSecondary,
    outline: RippleColors.border,
    outlineVariant: RippleColors.surfaceRaised,
    error: RippleColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Colors.transparent,
    splashFactory: InkSparkle.splashFactory,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 64, fontWeight: FontWeight.w300, letterSpacing: -2, color: RippleColors.textPrimary, height: 1),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: RippleColors.textPrimary),
      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: RippleColors.textPrimary),
      bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w400, color: RippleColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: RippleColors.textSecondary),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: RippleColors.textMuted, letterSpacing: 0.4),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: RippleColors.textMuted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: RippleColors.background,
      foregroundColor: RippleColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: RippleColors.surface,
      modalBackgroundColor: RippleColors.surface,
      showDragHandle: true,
      dragHandleColor: RippleColors.border,
    ),
    dialogTheme: const DialogThemeData(backgroundColor: RippleColors.surface),
    dividerTheme: const DividerThemeData(color: RippleColors.surfaceRaised, thickness: 0.5),
    listTileTheme: const ListTileThemeData(iconColor: RippleColors.textSecondary, textColor: RippleColors.textPrimary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RippleColors.surfaceRaised,
      hintStyle: const TextStyle(color: RippleColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: RippleSpacing.md, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => states.contains(WidgetState.selected) ? RippleColors.onAccent : RippleColors.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) => states.contains(WidgetState.selected) ? RippleColors.accent : RippleColors.surfaceRaised,
      ),
    ),
  );
}
