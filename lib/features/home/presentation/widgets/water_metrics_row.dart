import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';

/// Row of 2 quick status cards: Water Balance and Total Dues.
/// Sourced directly from [BuildContext.colors] without manual isDark checks.
class WaterMetricsRow extends StatelessWidget {
  const WaterMetricsRow({
    super.key,
    this.quota,
    this.totalDues,
    this.isEmpty = false,
  });

  final WaterQuotaEntity? quota;
  final double? totalDues;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    final activeQuota = quota;
    final hasCropsWithoutQuota = activeQuota != null &&
        activeQuota.totalQuotaHaCm == 0 &&
        activeQuota.usedQuotaHaCm == 0 &&
        activeQuota.remainingQuotaHaCm == 0 &&
        activeQuota.cropBreakdown.isNotEmpty;

    final String balanceText;
    final double progressValue;
    final String waterSummaryText;

    if (activeQuota == null) {
      balanceText = '0 L';
      progressValue = 0.0;
      waterSummaryText = '0 L quota allocated';
    } else if (activeQuota.remainingQuotaHaCm > 0) {
      balanceText =
          '${NumberFormat('#,##0').format((activeQuota.remainingQuotaHaCm * 100000).round())} L';
      progressValue = (activeQuota.percentageUsed / 100.0).clamp(0.0, 1.0);
      waterSummaryText =
          '${activeQuota.percentageUsed.toStringAsFixed(0)}% used of ${NumberFormat('#,##0').format((activeQuota.totalQuotaHaCm * 100000).round())} L';
    } else if (activeQuota.usedQuotaHaCm > 0 &&
        activeQuota.totalQuotaHaCm == 0) {
      balanceText =
          '${NumberFormat('#,##0').format((activeQuota.usedQuotaHaCm * 100000).round())} L used';
      progressValue = 1.0;
      waterSummaryText = activeQuota.season;
    } else if (hasCropsWithoutQuota) {
      final totalArea = activeQuota.totalIrrigatedArea;
      final areaLabel = totalArea % 1 == 0
          ? totalArea.toStringAsFixed(0)
          : totalArea.toStringAsFixed(1);
      balanceText = totalArea > 0
          ? '$areaLabel Acres'
          : '${activeQuota.cropBreakdown.length} Crops';
      progressValue = 1.0;
      final entryCount = activeQuota.cropBreakdown.length;
      waterSummaryText =
          '$entryCount ${entryCount == 1 ? 'crop' : 'crops'} • ${activeQuota.season}';
    } else {
      balanceText = '0 L';
      progressValue = (activeQuota.percentageUsed / 100.0).clamp(0.0, 1.0);
      waterSummaryText =
          '${activeQuota.percentageUsed.toStringAsFixed(0)}% used of ${NumberFormat('#,##0').format((activeQuota.totalQuotaHaCm * 100000).round())} L';
    }

    final duesAmount = totalDues ?? 0.0;
    final duesAmountText = '₹ ${NumberFormat('#,##0').format(duesAmount)}';

    final duesSubtitleText =
        duesAmount <= 0 ? 'All dues cleared' : l10n.noLateSurcharge;

    return Row(
      children: [
        // 1. Water Balance Card
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final router = GoRouter.maybeOf(context);
              router?.pushNamed(RouteNames.waterUsage);
            },
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
                        l10n.waterBalance,
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
                    balanceText,
                    style: context.titleLarge.bold.withColor(
                      colors.textPrimary,
                    ).withSize(21),
                  ),
                  if (!hasCropsWithoutQuota) ...[
                    const SizedBox(height: AppSpacing.xs),
                    ClipRRect(
                      borderRadius: AppRadius.borderRadiusFull,
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 5,
                        backgroundColor: colors.waterProgressTrack,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.waterProgressFill,
                        ),
                      ),
                    ),
                  ] else
                    const SizedBox(height: AppSpacing.sm),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    waterSummaryText,
                    style: context.caption.withSize(11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // 2. Total Dues Card
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final router = GoRouter.maybeOf(context);
              router?.pushNamed(RouteNames.bills);
            },
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
                        l10n.totalDues,
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
                    duesAmountText,
                    style: context.titleLarge.bold.withColor(
                      colors.textPrimary,
                    ).withSize(21),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    duesSubtitleText,
                    style: context.caption.medium
                        .withColor(colors.duesSubtitle)
                        .withSize(11.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
