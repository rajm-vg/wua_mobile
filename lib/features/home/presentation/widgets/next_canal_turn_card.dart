import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Next Canal Turn • Wari scheduling card with mint border, timeline CTA, and outlet flow metrics.
/// All colors sourced declaratively from [BuildContext.colors] without manual isDark checks.
class NextCanalTurnCard extends StatelessWidget {
  const NextCanalTurnCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.turnCardBorder,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Status Dot + Title + "In 2 Days" Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C853),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'NEXT CANAL TURN • WARI',
                    style: context.labelMedium.extraBold.withColor(
                      colors.turnCardTitle,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.turnCardBadgeBg,
                  borderRadius: AppRadius.borderRadiusFull,
                ),
                child: Text(
                  'In 2 Days',
                  style: context.labelSmall.bold.withColor(
                    colors.turnCardBadgeText,
                  ).withSize(11),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),
          Divider(
            color: colors.divider,
            height: 1,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Date & Timeline CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 22,
                    color: colors.turnCardTitle,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Thursday, 31 Oct',
                    style: context.titleMedium.bold.withColor(
                      colors.textPrimary,
                    ).withSize(17),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () => context.push(RouteNames.waterUsage),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: colors.turnCardTimelineBorder,
                    width: 1.2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusFull,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Timeline',
                      style: context.labelSmall.bold.withColor(
                        colors.turnCardTimelineText,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: colors.turnCardTimelineText,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xs),

          // Duration Row
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 18,
                color: colors.turnCardTitle,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '08:00 AM – 08:00 PM (12 Hours)',
                style: context.bodyMedium.medium.withColor(
                  colors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Gate & Outlet Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: AppRadius.borderRadiusXs,
                  border: Border.all(
                    color: colors.cardBorder,
                  ),
                ),
                child: Text(
                  'Gate  #4',
                  style: context.labelSmall.bold.withColor(
                    colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Outlet No. 12 • 50 Cusecs Flow',
                  style: context.caption.medium.withColor(
                    colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
