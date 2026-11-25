import 'package:flutter/material.dart';

import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

class HomeAdvisoryItem {
  const HomeAdvisoryItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.description,
    required this.tag,
  });

  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String description;
  final String tag;
}

/// Department advisories, canal alerts, and localized agricultural weather forecast.
class HomeAdvisoriesCard extends StatelessWidget {
  const HomeAdvisoriesCard({super.key, this.advisories = const []});

  final List<HomeAdvisoryItem> advisories;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    if (advisories.isEmpty) {
      return const SizedBox.shrink();
    }

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
