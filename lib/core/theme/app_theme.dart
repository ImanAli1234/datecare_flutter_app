/// ═══════════════════════════════════════════════════════════════════════════════
/// app_theme.dart — Flutter ThemeData Configuration
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// Maps our custom "Digital Herbarium" design system to Flutter's ThemeData.
///
/// TYPOGRAPHY SYSTEM:
///   - Display & Headline → Noto Serif (luxury serif, used for large headings)
///   - Body & Label → Manrope (clean sans-serif, used for forms and data)
///   Both fonts are loaded via the `google_fonts` package.
///
/// USAGE: Access via `Theme.of(context).textTheme.displayLarge` etc.
/// The theme is applied globally in main.dart via `MaterialApp(theme: ...)`.
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  /// The single light theme used throughout the app.
  /// (Dark theme is not yet implemented — see TODO in handoff plan.)
  static ThemeData get lightTheme {
    return ThemeData(
      // Map all our custom colors to Material 3's ColorScheme
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        error: Colors.red,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      // Typography — two font families working together
      textTheme: TextTheme(
        // ── Noto Serif — for cinematic headlines ────────────────────────
        displayLarge: GoogleFonts.notoSerif(color: AppColors.primary, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.notoSerif(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.notoSerif(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.notoSerif(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.notoSerif(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.notoSerif(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold),
        
        // ── Manrope — for body text, forms, labels ─────────────────────
        bodyLarge: GoogleFonts.manrope(color: AppColors.onSurface, fontSize: 16),
        bodyMedium: GoogleFonts.manrope(color: AppColors.onSurface, fontSize: 14),
        bodySmall: GoogleFonts.manrope(color: AppColors.onSurface, fontSize: 12),
        labelLarge: GoogleFonts.manrope(color: AppColors.onSurfaceVariant, fontSize: 14, fontWeight: FontWeight.w600),
        labelSmall: GoogleFonts.manrope(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
