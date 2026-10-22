import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

class _QuickActionItem {
  const _QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.badgeText,
    this.badgeColor,
    required this.route,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String? badgeText;
  final Color? badgeColor;
  final String route;
}

/// Grid of primary actions allowing one-tap navigation to vital irrigation services.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = context.l10n;

    final actions = [
      _QuickActionItem(
        title: l10n.bills,
        subtitle: '₹450 Due',
        icon: Icons.receipt_long_rounded,
        iconColor: AppColors.primary,
        bgColor: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
        badgeText: 'DUE',
        badgeColor: AppColors.error,
        route: RouteNames.bills,
      ),
      _QuickActionItem(
        title: l10n.waterUsage,
        subtitle: 'Logs & Quota',
        icon: Icons.water_drop_rounded,
        iconColor: isDark ? AppColors.waterCyan : AppColors.secondary,
        bgColor: (isDark ? AppColors.waterCyan : AppColors.secondary)
            .withValues(alpha: isDark ? 0.2 : 0.1),
        route: RouteNames.waterUsage,
      ),
      _QuickActionItem(
        title: l10n.irrigationSchedule,
        subtitle: 'Turn Roaster',
        icon: Icons.calendar_month_rounded,
        iconColor: AppColors.sproutGreen,
        bgColor: AppColors.sproutGreen.withValues(alpha: isDark ? 0.2 : 0.1),
        route: RouteNames.waterUsage,
      ),
      _QuickActionItem(
        title: l10n.transactionHistory,
        subtitle: 'Past Receipts',
        icon: Icons.history_edu_rounded,
        iconColor: AppColors.harvestAmber,
        bgColor: AppColors.harvestAmber.withValues(alpha: isDark ? 0.2 : 0.1),
        route: RouteNames.transactions,
      ),
      _QuickActionItem(
        title: l10n.canalStatus,
        subtitle: 'Active 125 cusecs',
        icon: Icons.alt_route_rounded,
        iconColor: AppColors.info,
        bgColor: AppColors.info.withValues(alpha: isDark ? 0.2 : 0.1),
        route: RouteNames.waterUsage,
      ),
      _QuickActionItem(
        title: l10n.profile,
        subtitle: 'Ward & Land Details',
        icon: Icons.account_circle_outlined,
        iconColor: AppColors.tertiary,
        bgColor: AppColors.tertiary.withValues(alpha: isDark ? 0.2 : 0.1),
        route: RouteNames.profile,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Heading
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quick Services',
              style: context.sectionTitle.withColor(
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            Text(
              'ALL SERVICES',
              style: context.badgeText.withColor(
                isDark ? AppColors.waterCyan : AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Grid Cards
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.1,
          ),
          itemBuilder: (context, index) {
            final item = actions[index];

            return Material(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: AppRadius.borderRadiusMd,
              child: InkWell(
                onTap: () => context.push(item.route),
                borderRadius: AppRadius.borderRadiusMd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.borderRadiusMd,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Circular Icon
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: item.bgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item.icon,
                          size: 22,
                          color: item.iconColor,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),

                      // Title & Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: context.labelMedium.semiBold.withColor(
                                      isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (item.badgeText != null) ...[
                                  const SizedBox(width: AppSpacing.xxs),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.xxs,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.badgeColor ?? AppColors.primary,
                                      borderRadius: AppRadius.borderRadiusXs,
                                    ),
                                    child: Text(
                                      item.badgeText!,
                                      style: context.labelSmall.extraBold.white
                                          .withSize(8),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: context.caption.withSize(11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
