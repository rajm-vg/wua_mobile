import 'package:flutter/material.dart';
import 'package:wua_mobile/core/constants/app_assets.dart';
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
        // Emblem badge with official logo and gold border
        Container(
          width: compact ? 68 : 84,
          height: compact ? 68 : 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.gold.withValues(alpha: isDark ? 0.6 : 0.8),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: isDark ? 0.35 : 0.25,
                ),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              AppAssets.appLogo,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const [AppColors.navyDark, AppColors.surfaceDark]
                          : const [AppColors.primary, AppColors.primaryDark],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.water_drop_rounded,
                        size: compact ? 32 : 40,
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
                );
              },
            ),
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
