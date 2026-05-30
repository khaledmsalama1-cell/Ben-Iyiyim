import 'package:flutter/material.dart';

/// Ben İyiyim color palette
/// Earthquake/disaster themed: seismic reds, dark surfaces, safety greens
class AppColors {
  AppColors._();

  // === PRIMARY PALETTE ===
  static const Color primary = Color(0xFF0066CC); // Design Primary Blue
  static const Color primaryDark = Color(0xFF0052A3);
  static const Color primaryLight = Color(0xFF3385FF);
  static const Color primaryContainer = Color(0xFFE5F0FF); // Very Light Blue

  // === ACCENT ===
  static const Color accent = Color(0xFF0088FF);
  static const Color accentDark = Color(0xFF0066CC);

  // === SAFE GREEN ===
  static const Color safeGreen = Color(0xFF34A853); // Google Green
  static const Color safeGreenLight = Color(0xFF47D16C);
  static const Color safeGreenDark = Color(0xFF247D3B);
  static const Color safeGreenContainer = Color(0xFFEBF7ED);

  // === DARK THEME SURFACES ===
  static const Color backgroundDark = Color(0xFF0A192F); // Deep Navy
  static const Color surfaceDark = Color(0xFF0F2245);
  static const Color surfaceVariantDark = Color(0xFF172A4E);
  static const Color cardDark = Color(0xFF112240);
  static const Color dividerDark = Color(0xFF1D3557);

  // === LIGHT THEME SURFACES ===
  static const Color backgroundLight = Color(0xFFF4F7FC); // Soft blue-grey
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFEBF0F6);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE2E8F0);

  // === TEXT DARK THEME ===
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8892B0);
  static const Color textHintDark = Color(0xFF495670);

  // === TEXT LIGHT THEME ===
  static const Color textPrimaryLight = Color(0xFF0F1E36); // Deep Navy Text
  static const Color textSecondaryLight = Color(0xFF4A5568);
  static const Color textHintLight = Color(0xFF718096);

  // === STATUS COLORS ===
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC05);
  static const Color error = Color(0xFFEA4335);
  static const Color info = Color(0xFF4285F4);

  // === GRADIENTS ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0066CC), Color(0xFF004C99)],
  );

  static const LinearGradient safeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34A853), Color(0xFF247D3B)],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A192F), Color(0xFF050C1A)],
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEA4335), Color(0xFFB31412)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEBF2FA), Color(0xFFF0F6FC)],
  );

  // === OPACITY COLORS ===
  static Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);
  static Color safeGreenWithOpacity(double opacity) =>
      safeGreen.withValues(alpha: opacity);
}
