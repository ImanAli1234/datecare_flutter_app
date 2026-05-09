/// ═══════════════════════════════════════════════════════════════════════════════
/// app_colors.dart — The "Digital Herbarium" Color Palette
/// ═══════════════════════════════════════════════════════════════════════════════
///
/// All colors used throughout the app are centralized here. This follows the
/// Material 3 token naming convention but maps to our custom luxury palette.
///
/// COLOR PHILOSOPHY (from design system):
///   - Primary (Deep Espresso) + Secondary (Saddle Terracotta) for high-importance
///   - Surface (Vanilla Custard) backgrounds with subtle paper-grain texture feel
///   - No pure black (#000000) — all darks derived from the espresso palette
///   - Ghost Borders at 15% opacity instead of harsh divider lines
///
/// USAGE: Reference these as `AppColors.primary`, `AppColors.background`, etc.
/// The theme in app_theme.dart maps these to Flutter's ColorScheme automatically.
/// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class AppColors {
  // ── Primary (Deep Espresso) ────────────────────────────────────────────
  static const Color primary = Color(0xFF7F3C13);             // Main brand color
  static const Color onPrimary = Color(0xFFFFFFFF);            // Text on primary
  static const Color primaryContainer = Color(0xFF9D5329);     // Saddle Terracotta
  static const Color onPrimaryContainer = Color(0xFFFFE0D2);   // Text on container

  // ── Secondary (Saddle Terracotta) ──────────────────────────────────────
  static const Color secondary = Color(0xFF81533A);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFFC1A2);
  static const Color onSecondaryContainer = Color(0xFF7A4D34);

  // ── Background & Surface (Vanilla Custard) ─────────────────────────────
  static const Color background = Color(0xFFFFF9EF);           // Page background
  static const Color onBackground = Color(0xFF221B00);
  static const Color surface = Color(0xFFFFF9EF);              // Card surfaces
  static const Color onSurface = Color(0xFF221B00);            // Main text color
  static const Color surfaceVariant = Color(0xFFF2E2B1);       // Chip/tag fills
  static const Color onSurfaceVariant = Color(0xFF54433B);     // Secondary text
  
  // ── Surface Containers (Tonal Layering System) ─────────────────────────
  // These create depth through background color shifts instead of shadows.
  // Higher = more contrast from the base surface.
  static const Color surfaceContainerHighest = Color(0xFFF2E2B1);
  static const Color surfaceContainerHigh = Color(0xFFF7E8B6);
  static const Color surfaceContainer = Color(0xFFFDEDBB);
  static const Color surfaceContainerLow = Color(0xFFFFF3D2);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  // ── Outline & Borders ──────────────────────────────────────────────────
  static const Color outline = Color(0xFF87736A);
  static const Color outlineVariant = Color(0xFFDAC2B7);       // Ghost Borders base

  // ── Market Pulse Module Tokens ─────────────────────────────────────────
  // These are specific to the Market Prices feature (live simulation)
  static const Color vanillaCustard = Color(0xFFFFF3D2);       // Pulse card background
  static const Color ghostBorder = Color(0x26DAC2B7);          // 15% opacity border
  static const Color saddleTerracotta = Color(0xFF9D5329);     // Sparkline curve color
  static const Color deepEspresso = Color(0xFF3E2723);         // LIVE dot & accents
  static const Color bullishGreen = Color(0xFF2E7D32);         // Price went UP
  static const Color bearishRed = Color(0xFFC62828);           // Price went DOWN
  static const Color softTerracottaError = Color(0xFFC4634A);  // Form validation errors
}
