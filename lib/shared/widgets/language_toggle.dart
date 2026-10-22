import 'package:flutter/material.dart';

import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Segmented custom toggle widget for switching application language (e.g. English & Hindi/Marathi).
/// Supports both header (dark/teal background) and standard (light surface) style presets.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({
    super.key,
    this.firstLabel = 'En',
    this.secondLabel = 'MR',
    this.backgroundColor,
    this.activeBackgroundColor,
    this.activeTextColor,
    this.inactiveTextColor,
    this.padding,
    this.itemPadding,
    this.onChanged,
    this.isSecondActive,
  });

  /// Factory preset for deep teal or dark headers.
  const LanguageToggle.header({
    super.key,
    this.firstLabel = 'En',
    this.secondLabel = 'MR',
    this.backgroundColor,
    this.activeBackgroundColor = Colors.white,
    this.activeTextColor,
    this.inactiveTextColor,
    this.padding,
    this.itemPadding,
    this.onChanged,
    this.isSecondActive,
  });

  /// Factory preset for standard app bars or forms.
  const LanguageToggle.standard({
    super.key,
    this.firstLabel = 'En',
    this.secondLabel = 'हिन्दी',
    this.backgroundColor,
    this.activeBackgroundColor,
    this.activeTextColor,
    this.inactiveTextColor,
    this.padding,
    this.itemPadding,
    this.onChanged,
    this.isSecondActive,
  });

  /// Label for the first language (default: 'En').
  final String firstLabel;

  /// Label for the second language (default: 'MR' / 'हिन्दी').
  final String secondLabel;

  /// Capsule background color. Defaults to [AppThemeColors.headerToggleBg].
  final Color? backgroundColor;

  /// Active tab background color. Defaults to [Colors.white].
  final Color? activeBackgroundColor;

  /// Active text color. Defaults to [AppThemeColors.headerBackground].
  final Color? activeTextColor;

  /// Inactive text color. Defaults to translucent white.
  final Color? inactiveTextColor;

  /// Outer padding for the pill container. Defaults to 3dp all sides.
  final EdgeInsetsGeometry? padding;

  /// Inner padding for individual language tabs. Defaults to 8dp horizontal, 4dp vertical.
  final EdgeInsetsGeometry? itemPadding;

  /// Optional callback invoked when selection changes. When null, toggles [appLocaleNotifier].
  final ValueChanged<bool>? onChanged;

  /// Optional controlled active state for the second language. When null, uses [context.isHindi].
  final bool? isSecondActive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isSecond = isSecondActive ?? context.isHindi;

    final resolvedBg = backgroundColor ?? colors.headerToggleBg;
    final resolvedActiveBg = activeBackgroundColor ?? Colors.white;
    final resolvedActiveText = activeTextColor ?? colors.headerBackground;
    final resolvedInactiveText =
        inactiveTextColor ?? Colors.white.withValues(alpha: 0.85);

    return Container(
      padding: padding ?? const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: AppRadius.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TogglePill(
            label: firstLabel,
            isActive: !isSecond,
            activeBgColor: resolvedActiveBg,
            activeTextColor: resolvedActiveText,
            inactiveTextColor: resolvedInactiveText,
            padding: itemPadding,
            onTap: () {
              if (isSecond) {
                if (onChanged != null) {
                  onChanged!(false);
                } else {
                  context.toggleLocale();
                }
              }
            },
          ),
          _TogglePill(
            label: secondLabel,
            isActive: isSecond,
            activeBgColor: resolvedActiveBg,
            activeTextColor: resolvedActiveText,
            inactiveTextColor: resolvedInactiveText,
            padding: itemPadding,
            onTap: () {
              if (!isSecond) {
                if (onChanged != null) {
                  onChanged!(true);
                } else {
                  context.toggleLocale();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.isActive,
    required this.activeBgColor,
    required this.activeTextColor,
    required this.inactiveTextColor,
    this.padding,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color activeBgColor;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: padding ??
            const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
        decoration: BoxDecoration(
          color: isActive ? activeBgColor : Colors.transparent,
          borderRadius: AppRadius.borderRadiusFull,
        ),
        child: Text(
          label,
          style: context.labelSmall.bold.withColor(
            isActive ? activeTextColor : inactiveTextColor,
          ),
        ),
      ),
    );
  }
}
