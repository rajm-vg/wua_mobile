import 'package:flutter/material.dart';

/// Design token: application color palette.
/// Follows Material 3 seed-color approach.
class AppColors {
  AppColors._();

  // ─── Brand / Primary ────────────────────────────────────────
  static const Color primarySeed = Color(0xFF1565C0); // WUA Blue
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF5E92F3);
  static const Color primaryDark = Color(0xFF003C8F);
  static const Color onPrimary = Colors.white;

  // ─── Secondary ──────────────────────────────────────────────
  static const Color secondary = Color(0xFF26A69A); // Teal for irrigation
  static const Color secondaryLight = Color(0xFF64D8CB);
  static const Color secondaryDark = Color(0xFF00766C);
  static const Color onSecondary = Colors.white;

  // ─── Tertiary ───────────────────────────────────────────────
  static const Color tertiary = Color(0xFF7B1FA2);
  static const Color onTertiary = Colors.white;

  // ─── Error ──────────────────────────────────────────────────
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);
  static const Color onError = Colors.white;

  // ─── Success ────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF4CAF50);
  static const Color onSuccess = Colors.white;

  // ─── Warning ────────────────────────────────────────────────
  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFBC02D);
  static const Color onWarning = Colors.black;

  // ─── Info ───────────────────────────────────────────────────
  static const Color info = Color(0xFF0288D1);
  static const Color infoLight = Color(0xFF29B6F6);
  static const Color onInfo = Colors.white;

  // ─── Surface / Background (Light) ──────────────────────────
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceVariantLight = Color(0xFFF1F3F4);
  static const Color onBackgroundLight = Color(0xFF1A1A2E);
  static const Color onSurfaceLight = Color(0xFF1A1A2E);

  // ─── Surface / Background (Dark) ───────────────────────────
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E2D);
  static const Color surfaceVariantDark = Color(0xFF2A2A3D);
  static const Color onBackgroundDark = Color(0xFFE0E0E0);
  static const Color onSurfaceDark = Color(0xFFE0E0E0);

  // ─── Neutral ────────────────────────────────────────────────
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ─── Text ───────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // ─── Domain: Water, Irrigation & Government Branding ───────
  static const Color gold = Color(0xFFFFD54F); // Government / Emblem Gold
  static const Color harvestAmber = Color(0xFFFFB300); // Harvest / Wheat
  static const Color waterCyan = Color(0xFF80DEEA); // Flowing water
  static const Color waterCyanLight = Color(0xFFB2EBF2);
  static const Color sproutGreen = Color(0xFF81C784); // Agricultural sprout
  static const Color navyDark = Color(0xFF0A2240); // Deep official navy
  static const Color abyss = Color(0xFF071426); // Midnight backdrop
  static const Color reservoirTeal = Color(0xFF032B2F); // Canal reservoir
  static const Color darkCanal = Color(0xFF02171A);
}
