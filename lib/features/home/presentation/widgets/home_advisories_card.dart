import 'package:flutter/material.dart';

import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Department advisories, canal alerts, and localized agricultural weather forecast.
class HomeAdvisoriesCard extends StatelessWidget {
  const HomeAdvisoriesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    final advisories = [
      (
        icon: Icons.campaign_rounded,
        iconColor: AppColors.harvestAmber,
        bgColor: AppColors.harvestAmber.withValues(alpha: isDark ? 0.2 : 0.12),
        title: 'Canal Rotational Supply Active',
        description:
            'Minor-4 canal running on 7-day rotation. Water users in Ward 4B scheduled for Turn #2 on Oct 24.',
        tag: 'OFFICIAL NOTICE',
      ),
      (
        icon: Icons.wb_sunny_rounded,
        iconColor: AppColors.secondary,
        bgColor: AppColors.secondary.withValues(alpha: isDark ? 0.2 : 0.12),
        title: 'Weather & Soil Moisture Advisory',
        description:
            'Dry weather forecasted for the next 72 hours. Ideal window for pre-sowing irrigation and land levelling.',
        tag: 'AGRI WEATHER',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department Advisories',
          style: context.sectionTitle.withColor(
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: advisories.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final item = advisories[index];

            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: AppRadius.borderRadiusMd,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: item.bgColor,
                      borderRadius: AppRadius.borderRadiusSm,
                    ),
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: item.iconColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: context.cardTitle.semiBold.withColor(
                                  isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxs,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: item.iconColor.withValues(alpha: 0.15),
                                borderRadius: AppRadius.borderRadiusXs,
                              ),
                              child: Text(
                                item.tag,
                                style: context.labelSmall.bold
                                    .withSize(8)
                                    .withColor(item.iconColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          item.description,
                          style: context.caption.withSize(12).withHeight(1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
