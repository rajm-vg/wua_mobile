import 'package:flutter/material.dart';
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

    final progress = (quota.percentageUsed / 100.0).clamp(0.0, 1.0);
    final progressColor = quota.isLimitExceeded
        ? colors.error
        : quota.isNearLimit
            ? AppColors.harvestAmber
            : colors.canalGreen;

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
          // ─── Header: Live Canal Indicator + Society Tag ──────────
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
                    'CANAL ROTATION ACTIVE',
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
                  quota.canalStatus,
                  style: context.labelSmall.bold.withColor(
                    colors.turnCardBadgeText,
                  ).withSize(11),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: AppSpacing.md),

          // ─── Canal Section & Season ─────────────────────────────
          Row(
            children: [
              Icon(
                Icons.water_rounded,
                size: 20,
                color: colors.turnCardTitle,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  quota.canalName,
                  style: context.titleMedium.bold.withColor(colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16343C) : const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  quota.season,
                  style: context.caption.semiBold.withColor(colors.canalGreen),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ─── Main Water Quota Numbers ───────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEASONAL ALLOCATION',
                    style: context.caption.bold.withColor(colors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        quota.usedQuotaHaCm.toStringAsFixed(1),
                        style: context.headlineMedium.extraBold.withColor(
                          colors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ ${quota.totalQuotaHaCm.toStringAsFixed(1)} ha-cm',
                        style: context.titleSmall.medium.withColor(
                          colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${quota.percentageUsed.toStringAsFixed(0)}% Used',
                  style: context.labelMedium.extraBold.withColor(progressColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ─── Progress Bar ───────────────────────────────────────
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

          const SizedBox(height: AppSpacing.md),

          // ─── Metric Badges Row ──────────────────────────────────
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
                _StatItem(
                  icon: Icons.opacity_rounded,
                  label: 'Remaining',
                  value: '${quota.remainingQuotaHaCm.toStringAsFixed(1)} ha-cm',
                  valueColor: colors.textPrimary,
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: colors.divider,
                ),
                _StatItem(
                  icon: Icons.sync_rounded,
                  label: 'Turns (वारी)',
                  value: '${quota.completedTurnsCount}/${quota.totalTurnsCount} Done',
                  valueColor: colors.textPrimary,
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: colors.divider,
                ),
                _StatItem(
                  icon: Icons.grass_rounded,
                  label: 'Soil Moisture',
                  value: quota.soilMoistureStatus,
                  valueColor: colors.canalGreen,
                ),
              ],
            ),
          ),
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

