import 'package:flutter/material.dart';

import 'package:wua_mobile/core/theme/app_theme_colors.dart';
import 'package:wua_mobile/core/theme/colors.dart';

/// Context extensions providing direct, ergonomic access to the application's
/// typography and theme hierarchy without needing raw fontSize or fontWeights.
extension TypographyContextExtensions on BuildContext {
  // ─── Direct Material 3 Text Styles ──────────────────────────
  TextStyle get displayLarge =>
      Theme.of(this).textTheme.displayLarge ?? const TextStyle();
  TextStyle get displayMedium =>
      Theme.of(this).textTheme.displayMedium ?? const TextStyle();
  TextStyle get displaySmall =>
      Theme.of(this).textTheme.displaySmall ?? const TextStyle();

  TextStyle get headlineLarge =>
      Theme.of(this).textTheme.headlineLarge ?? const TextStyle();
  TextStyle get headlineMedium =>
      Theme.of(this).textTheme.headlineMedium ?? const TextStyle();
  TextStyle get headlineSmall =>
      Theme.of(this).textTheme.headlineSmall ?? const TextStyle();

  TextStyle get titleLarge =>
      Theme.of(this).textTheme.titleLarge ?? const TextStyle();
  TextStyle get titleMedium =>
      Theme.of(this).textTheme.titleMedium ?? const TextStyle();
  TextStyle get titleSmall =>
      Theme.of(this).textTheme.titleSmall ?? const TextStyle();

  TextStyle get bodyLarge =>
      Theme.of(this).textTheme.bodyLarge ?? const TextStyle();
  TextStyle get bodyMedium =>
      Theme.of(this).textTheme.bodyMedium ?? const TextStyle();
  TextStyle get bodySmall =>
      Theme.of(this).textTheme.bodySmall ?? const TextStyle();

  TextStyle get labelLarge =>
      Theme.of(this).textTheme.labelLarge ?? const TextStyle();
  TextStyle get labelMedium =>
      Theme.of(this).textTheme.labelMedium ?? const TextStyle();
  TextStyle get labelSmall =>
      Theme.of(this).textTheme.labelSmall ?? const TextStyle();

  // ─── Semantic Typography Shortcuts ──────────────────────────
  /// Standard screen / page title.
  TextStyle get pageTitle => headlineSmall.semiBold.withColor(colors.textPrimary);

  /// Section heading inside a screen.
  TextStyle get sectionTitle => titleMedium.semiBold.withColor(colors.textPrimary);

  /// Card / dialog title.
  TextStyle get cardTitle => titleSmall.medium.withColor(colors.textPrimary);

  /// Secondary caption / timestamp / hint text.
  TextStyle get caption => bodySmall.withColor(colors.textSecondary);

  /// Small badge / tag label text with letter spacing.
  TextStyle get badgeText => labelSmall.semiBold.withSpacing(0.6).withColor(colors.textSecondary);

  /// Action button text.
  TextStyle get buttonText => labelLarge.semiBold;
}

/// Fluent chaining modifiers on [TextStyle] to customize weight, color,
/// spacing, and opacity without repetitive `.copyWith(...)` calls.
extension TextStyleModifiers on TextStyle {
  // ─── Font Weights ───────────────────────────────────────────
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get extraBold => copyWith(fontWeight: FontWeight.w800);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  // ─── Font Style & Decoration ────────────────────────────────
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);
  TextStyle get underline => copyWith(decoration: TextDecoration.underline);
  TextStyle get lineThrough => copyWith(decoration: TextDecoration.lineThrough);

  // ─── Color & Opacity ────────────────────────────────────────
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withOpacity(double opacity) =>
      copyWith(color: (color ?? Colors.black).withValues(alpha: opacity));

  /// Convenience color presets
  TextStyle get white => copyWith(color: Colors.white);
  TextStyle get primary => copyWith(color: AppColors.primary);
  TextStyle get secondary => copyWith(color: AppColors.secondary);
  TextStyle get gold => copyWith(color: AppColors.gold);
  TextStyle get error => copyWith(color: AppColors.error);

  // ─── Geometry & Spacing ─────────────────────────────────────
  TextStyle withSize(double size) => copyWith(fontSize: size);
  TextStyle withSpacing(double spacing) => copyWith(letterSpacing: spacing);
  TextStyle withHeight(double height) => copyWith(height: height);
  TextStyle withShadows(List<Shadow> shadows) => copyWith(shadows: shadows);
}

/// Context extensions providing direct access to the application's
/// theme-aware semantic colors without repetitive `Theme.of(context)` or `isDark` checks.
extension ThemeColorContextExtensions on BuildContext {
  /// Theme-aware semantic colors for the active theme (light or dark).
  /// Query colors directly from context: `context.colors.cardBackground`,
  /// `context.colors.textPrimary`, `context.colors.turnCardBorder`, etc.
  AppThemeColors get colors =>
      Theme.of(this).extension<AppThemeColors>() ??
      (isDarkMode ? AppThemeColors.dark : AppThemeColors.light);

  /// Ergonomic shorthand alias for [colors].
  AppThemeColors get appColors => colors;

  /// Underlying Material 3 [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Whether dark mode is currently active.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Primary brand color.
  Color get primaryColor => colors.primary;
  Color get onPrimaryColor => colorScheme.onPrimary;

  /// Secondary brand color (Teal / Irrigation).
  Color get secondaryColor => colors.secondary;
  Color get onSecondaryColor => colorScheme.onSecondary;

  /// Surface color for cards, dialogs, sheets.
  Color get surfaceColor => colors.surface;
  Color get onSurfaceColor => colorScheme.onSurface;

  /// Main background color.
  Color get backgroundColor => colors.background;

  /// Semantic error color.
  Color get errorColor => colors.error;
  Color get onErrorColor => colorScheme.onError;
}
