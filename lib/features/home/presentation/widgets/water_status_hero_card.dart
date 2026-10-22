import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Hero overview card highlighting live canal status, seasonal quota, and next irrigation turn.
class WaterStatusHeroCard extends StatelessWidget {
  const WaterStatusHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.borderRadiusLg,
        gradient: LinearGradient(
          colors: isDark
              ? [
                  AppColors.navyDark,
                  AppColors.reservoirTeal,
                ]
              : [
                  AppColors.primary,
                  AppColors.primaryDark,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.35 : 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(RouteNames.waterUsage),
          borderRadius: AppRadius.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Canal Status Badge + Live indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Live pulsating indicator dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.sproutGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          l10n.canalStatus.toUpperCase(),
                          style: context.badgeText.white,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxxs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                      child: Text(
                        '125 Cusecs • Active',
                        style: context.labelSmall.semiBold.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Main Quota Metric
                Text(
                  l10n.waterQuota,
                  style: context.caption.white.withOpacity(0.85),
                ),
                const SizedBox(height: AppSpacing.xxxs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '14.2',
                      style: context.headlineLarge.bold.white,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '/ 20.0 ha-cm (71%)',
                      style: context.titleMedium.medium.white.withOpacity(0.9),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Quota Progress Bar
                ClipRRect(
                  borderRadius: AppRadius.borderRadiusFull,
                  child: LinearProgressIndicator(
                    value: 0.71,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.waterCyan,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
                Divider(
                  color: Colors.white.withValues(alpha: 0.15),
                  height: 1,
                ),
                const SizedBox(height: AppSpacing.md),

                // Bottom Sub-section: Next Scheduled Turn
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: AppRadius.borderRadiusSm,
                      ),
                      child: const Icon(
                        Icons.access_time_filled_rounded,
                        size: 20,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.activeTurns,
                            style: context.labelSmall.white.withOpacity(0.8),
                          ),
                          Text(
                            'Tomorrow, 06:30 AM (Outlet 12B • 3.5 hrs)',
                            style: context.bodySmall.semiBold.white,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
