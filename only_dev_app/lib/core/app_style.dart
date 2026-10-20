import 'package:flutter/material.dart';

/// Centralized Design System & Colors for Only Dev
class AppStyle {
  AppStyle._();

  // ---------------------------------------------------------------------------
  // Brand Colors
  // ---------------------------------------------------------------------------
  /// Main Brand Primary Color
  static const Color primaryColor = Colors.green;
  static const Color primary = Colors.green;
  static final Color primaryLight = Colors.green.shade400;
  static final Color primaryDark = Colors.green.shade700;

  /// Secondary Accent
  static const Color secondaryColor = Color(0xFF64748B);
  static const Color secondary = Color(0xFF64748B);

  // ---------------------------------------------------------------------------
  // Status & Semantic Colors
  // ---------------------------------------------------------------------------
  static const Color success = Colors.green;
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ---------------------------------------------------------------------------
  // Surfaces & Backgrounds
  // ---------------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF171717);
  static const Color darkSurface = Color(0xFF212121);
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFECECEC);

  // ---------------------------------------------------------------------------
  // Radii
  // ---------------------------------------------------------------------------
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;
  static const double radiusXl = 20.0;
  static const double radiusRound = 999.0;

  // ---------------------------------------------------------------------------
  // Common Text Styles
  // ---------------------------------------------------------------------------
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.4,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}

/// Semantic alias for color-focused usages
typedef AppColors = AppStyle;
