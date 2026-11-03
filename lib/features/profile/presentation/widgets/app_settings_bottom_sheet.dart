import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Modal bottom sheet for configuring appearance and viewing app build version.
class AppSettingsBottomSheet extends StatelessWidget {
  const AppSettingsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppSettingsBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header row with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'App Settings',
                style: context.titleLarge.bold.withColor(colors.textPrimary),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Appearance Section Header
          Text(
            'Appearance',
            style: context.bodyMedium.semiBold.withColor(colors.textSecondary),
          ),
          const SizedBox(height: 12),

          // Theme Selector (Light, System, Dark)
          ValueListenableBuilder<ThemeMode>(
            valueListenable: appThemeModeNotifier,
            builder: (context, currentMode, _) {
              return Row(
                children: [
                  Expanded(
                    child: _ThemeModeOption(
                      label: 'Light',
                      icon: currentMode == ThemeMode.light
                          ? Icons.check_rounded
                          : null,
                      isSelected: currentMode == ThemeMode.light,
                      onTap: () => appThemeModeNotifier.value = ThemeMode.light,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ThemeModeOption(
                      label: 'System',
                      icon: Icons.computer_outlined,
                      isSelected: currentMode == ThemeMode.system,
                      onTap: () => appThemeModeNotifier.value = ThemeMode.system,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ThemeModeOption(
                      label: 'Dark',
                      icon: Icons.dark_mode_outlined,
                      isSelected: currentMode == ThemeMode.dark,
                      onTap: () => appThemeModeNotifier.value = ThemeMode.dark,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // App Version Card
          Container(
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.cardBorder),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'App Version',
                  style: context.bodyMedium.semiBold.withColor(colors.textPrimary),
                ),
                Text(
                  'v1.0.0 (Build 24)',
                  style: context.bodyMedium.regular.withColor(colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? colors.surface : colors.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? colors.textPrimary : colors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 17,
                  color: isSelected ? colors.textPrimary : colors.textSecondary,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: context.bodyMedium.semiBold.withColor(
                  isSelected ? colors.textPrimary : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
