import 'package:flutter/material.dart';

import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Row of 2 quick status cards: Water Balance and Total Dues.
/// Sourced directly from [BuildContext.colors] without manual isDark checks.
class WaterMetricsRow extends StatelessWidget {
  const WaterMetricsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        // 1. Water Balance Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.cardBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WATER BALANCE',
                      style: context.labelSmall.bold.withColor(
                        colors.waterDropIconColor,
                      ).withSize(11),
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xxs),
                      decoration: BoxDecoration(
                        color: colors.waterDropIconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.water_drop_outlined,
                        size: 14,
                        color: colors.waterDropIconColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '5,000 L',
                  style: context.titleLarge.bold.withColor(
                    colors.textPrimary,
                  ).withSize(21),
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: AppRadius.borderRadiusFull,
                  child: LinearProgressIndicator(
                    value: 0.79,
                    minHeight: 5,
                    backgroundColor: colors.waterProgressTrack,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colors.waterProgressFill,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '79% used of 23,500 L',
                  style: context.caption.withSize(11),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // 2. Total Dues Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.cardBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TOTAL DUES',
                      style: context.labelSmall.bold.withColor(
                        colors.duesWarningIcon,
                      ).withSize(11),
                    ),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xxs),
                      decoration: BoxDecoration(
                        color: colors.duesWarningBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 14,
                        color: colors.duesWarningIcon,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '₹ 1,240',
                  style: context.titleLarge.bold.withColor(
                    colors.textPrimary,
                  ).withSize(21),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No late surcharge yet',
                  style: context.caption.medium
                      .withColor(colors.duesSubtitle)
                      .withSize(11.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
