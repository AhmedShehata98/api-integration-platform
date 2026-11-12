import 'package:flutter/material.dart';
import 'package:test_point/core/ui/theme/app_fonts.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/theme/http_colors.dart';

/// Material 3 themes seeded from the teal brand color. Dark is the primary theme.
abstract final class AppTheme {
  static const Color seed = Color(0xFF0F9D8A);

  static final ThemeData dark = _build(
    ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark).copyWith(
      primary: const Color(0xFF0F9D8A),
      // White on this teal is only 3.4:1; dark text passes WCAG AA.
      onPrimary: const Color(0xFF00201B),
      surface: const Color(0xFF0E1513),
      surfaceContainer: const Color(0xFF161D1B),
      surfaceContainerHigh: const Color(0xFF1E2624),
      outline: const Color(0xFF3F4946),
    ),
    HttpColors.dark,
    inputBorder: const Color(0xFF76827E),
  );

  static final ThemeData light = _build(
    ColorScheme.fromSeed(seedColor: seed).copyWith(
      primary: const Color(0xFF006B5E),
      surface: const Color(0xFFF5FBF8),
      surfaceContainer: const Color(0xFFEAF2EF),
      surfaceContainerHigh: const Color(0xFFE0EAE6),
      outline: const Color(0xFFBFC9C5),
    ),
    HttpColors.light,
    inputBorder: const Color(0xFF6F7A77),
  );

  static ThemeData _build(
    ColorScheme scheme,
    HttpColors httpColors, {
    required Color inputBorder,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppFonts.ui,
    );
    final text = base.textTheme;
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text.copyWith(
        displayLarge: text.displayLarge?.copyWith(
          fontFamily: AppFonts.headline,
        ),
        displayMedium: text.displayMedium?.copyWith(
          fontFamily: AppFonts.headline,
        ),
        displaySmall: text.displaySmall?.copyWith(
          fontFamily: AppFonts.headline,
        ),
        headlineLarge: text.headlineLarge?.copyWith(
          fontFamily: AppFonts.headline,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          fontFamily: AppFonts.headline,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          fontFamily: AppFonts.headline,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline,
        space: 1,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        // WCAG 1.4.11: input boundaries need 3:1 against the surface, which
        // the subtle divider colour `outline` does not give.
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          borderSide: BorderSide(color: inputBorder),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
        ),
      ),
      // Floating, on theme surfaces; the Material default is a full-width bar
      // in the inverse colours that covers the status bar.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        width: 480,
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: text.bodyMedium?.copyWith(color: scheme.onSurface),
        actionTextColor: scheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      extensions: [httpColors],
    );
  }
}
