import 'package:flutter/material.dart';

import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Clean, executive brand header for the Water Resources Department & WUA.
class WrdBrandHeader extends StatelessWidget {
  const WrdBrandHeader({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emblem badge with subtle gradient and gold border
        Container(
          width: compact ? 64 : 76,
          height: compact ? 64 : 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [AppColors.navyDark, AppColors.surfaceDark]
                  : const [AppColors.primary, AppColors.primaryDark],
            ),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: isDark ? 0.6 : 0.8),
              width: 1.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.2),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Subtle inner ripple
              Container(
                width: compact ? 50 : 60,
                height: compact ? 50 : 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.0,
                  ),
                ),
              ),
              // Water drop with wheat sprout iconography
              Icon(
                Icons.water_drop_rounded,
                size: compact ? 30 : 38,
                color: isDark ? AppColors.waterCyan : Colors.white,
              ),
              Positioned(
                bottom: compact ? 10 : 12,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),

        // Department tag pill
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.waterCyan.withValues(alpha: 0.12)
                : AppColors.primary.withValues(alpha: 0.08),
            borderRadius: AppRadius.borderRadiusFull,
            border: Border.all(
              color: isDark
                  ? AppColors.waterCyan.withValues(alpha: 0.25)
                  : AppColors.primary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_outlined,
                size: 13,
                color: isDark ? AppColors.waterCyan : AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                'GOVERNMENT OF WATER RESOURCES',
                style: context.badgeText.withColor(
                  isDark ? AppColors.waterCyan : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Title: Water User Association
        Text(
          l10n.welcomeBack,
          style: (compact ? context.titleLarge : context.headlineSmall).bold
              .withColor(
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxs),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            l10n.loginSubtitle,
            style: context.caption.withColor(
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
