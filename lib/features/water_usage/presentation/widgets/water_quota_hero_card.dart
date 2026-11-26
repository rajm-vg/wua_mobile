import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';

/// Hero overview card displaying seasonal water quota, live canal flow, and usage gauge.
class WaterQuotaHeroCard extends StatelessWidget {
  const WaterQuotaHeroCard({
    super.key,
    required this.quota,
  });

  final WaterQuotaEntity quota;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    final hasHaCmQuota =
        quota.totalQuotaHaCm > 0 || quota.usedQuotaHaCm > 0;
    final hasCropEntries = quota.cropBreakdown.isNotEmpty;
    final hasTurns = quota.totalTurnsCount > 0;
    final hasCanalName =
        quota.canalName.isNotEmpty && quota.canalName != 'N/A';
    final hasStatusTag =
        quota.canalStatus.isNotEmpty && quota.canalStatus != 'N/A';
    final headerTitle = (hasTurns || hasHaCmQuota)
        ? 'CANAL ROTATION ACTIVE'
        : 'WATER USAGE SUMMARY';
    final seasonLabel = quota.fiscalYear?.isNotEmpty == true
        ? '${quota.season} (${quota.fiscalYear})'
        : quota.season;
    final hasSeasonLabel =
        seasonLabel.isNotEmpty && seasonLabel != 'N/A';
    final areaTotal = quota.totalIrrigatedArea;
    final areaLabel = areaTotal % 1 == 0
        ? areaTotal.toStringAsFixed(0)
        : areaTotal.toStringAsFixed(1);
    final progress = (quota.percentageUsed / 100.0).clamp(0.0, 1.0);
    final progressColor = quota.isLimitExceeded
        ? colors.error
        : quota.isNearLimit
            ? AppColors.harvestAmber
            : colors.canalGreen;

    final dynamicStats = <_StatItem>[
      if (hasHaCmQuota)
        _StatItem(
          icon: Icons.opacity_rounded,
          label: 'Remaining',
          value: '${quota.remainingQuotaHaCm.toStringAsFixed(1)} ha-cm',
          valueColor: colors.textPrimary,
        ),
      if (hasTurns)
        _StatItem(
          icon: Icons.sync_rounded,
          label: 'Turns (वारी)',
          value: '${quota.completedTurnsCount}/${quota.totalTurnsCount} Done',
          valueColor: colors.textPrimary,
        ),
      if (hasCropEntries)
        _StatItem(
          icon: Icons.eco_outlined,
          label: 'Crops',
          value:
              '${quota.cropBreakdown.length} ${quota.cropBreakdown.length == 1 ? 'Entry' : 'Entries'}',
          valueColor: colors.textPrimary,
        ),
      if (quota.outletNumber.isNotEmpty && quota.outletNumber != 'N/A')
        _StatItem(
          icon: Icons.location_on_outlined,
          label: 'Outlet / Survey',
          value: quota.outletNumber,
          valueColor: colors.canalGreen,
        ),
      if (quota.soilMoistureStatus.isNotEmpty &&
          quota.soilMoistureStatus != 'N/A')
        _StatItem(
          icon: Icons.grass_rounded,
          label: 'Soil Moisture',
          value: quota.soilMoistureStatus,
          valueColor: colors.canalGreen,
        ),
    ];

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
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header: Summary / Live Canal Indicator + Status ────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (hasTurns) ...[
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C853),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    headerTitle,
                    style: context.labelMedium.extraBold.withColor(
                      colors.turnCardTitle,
                    ),
                  ),
                ],
              ),
              if (hasStatusTag)
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
                    quota.canalStatus,
                    style: context.labelSmall.bold.withColor(
                      colors.turnCardBadgeText,
                    ).withSize(11),
                  ),
                ),
            ],
          ),

          if (hasCanalName || hasSeasonLabel) ...[
            const SizedBox(height: AppSpacing.sm),
            Divider(color: colors.divider, height: 1),
            const SizedBox(height: AppSpacing.md),

            // ─── Canal / Source & Season ──────────────────────────
            Row(
              children: [
                if (hasCanalName) ...[
                  Icon(
                    Icons.water_rounded,
                    size: 20,
                    color: colors.turnCardTitle,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      quota.canalName,
                      style: context.titleMedium.bold.withColor(
                        colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else
                  const Spacer(),
                if (hasSeasonLabel)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF16343C)
                          : const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      seasonLabel,
                      style: context.caption.semiBold.withColor(
                        colors.canalGreen,
                      ),
                    ),
                  ),
              ],
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // ─── Main Water Metrics ─────────────────────────────────
          if (hasHaCmQuota || hasCropEntries)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (!hasHaCmQuota && hasCropEntries)
                          ? 'RECORDED CROP IRRIGATION'
                          : 'SEASONAL ALLOCATION',
                      style: context.caption.bold.withColor(
                        colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          (!hasHaCmQuota && hasCropEntries)
                              ? areaLabel
                              : quota.usedQuotaHaCm.toStringAsFixed(1),
                          style: context.headlineMedium.extraBold.withColor(
                            colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (!hasHaCmQuota && hasCropEntries)
                              ? 'Are (${quota.cropBreakdown.length} ${quota.cropBreakdown.length == 1 ? 'crop' : 'crops'})'
                              : '/ ${quota.totalQuotaHaCm.toStringAsFixed(1)} ha-cm',
                          style: context.titleSmall.medium.withColor(
                            colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (hasHaCmQuota || quota.totalCropAmount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: progressColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (!hasHaCmQuota &&
                              hasCropEntries &&
                              quota.totalCropAmount > 0)
                          ? '₹ ${NumberFormat('#,##0.##').format(quota.totalCropAmount)}'
                          : '${quota.percentageUsed.toStringAsFixed(0)}% Used',
                      style: context.labelMedium.extraBold.withColor(
                        progressColor,
                      ),
                    ),
                  ),
              ],
            ),

          if (hasHaCmQuota) ...[
            const SizedBox(height: AppSpacing.sm),

            // ─── Progress Bar ─────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],

          if (dynamicStats.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),

            // ─── Dynamic Metric Badges Row (only real data) ───────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF11252B)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.cardBorder,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < dynamicStats.length; i++) ...[
                    if (i > 0)
                      Container(
                        width: 1,
                        height: 28,
                        color: colors.divider,
                      ),
                    dynamicStats[i],
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colors.canalGreen),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.caption.withColor(colors.textSecondary).withSize(10.5),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.labelSmall.bold.withColor(valueColor),
        ),
      ],
    );
  }
}

