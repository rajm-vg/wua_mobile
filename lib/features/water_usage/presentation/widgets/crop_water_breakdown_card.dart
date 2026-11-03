import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';

/// Card showing crop-wise water consumption breakdown.
class CropWaterBreakdownCard extends StatelessWidget {
  const CropWaterBreakdownCard({
    super.key,
    required this.crops,
  });

  final List<CropWaterUsage> crops;

  Color _getCropColor(int index) {
    const palette = [
      AppColors.canalGreen,
      AppColors.harvestAmber,
      AppColors.info,
      AppColors.secondary,
    ];
    return palette[index % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CROP-WISE WATER CONSUMPTION',
                style: context.caption.bold.withColor(colors.textSecondary),
              ),
              Icon(Icons.pie_chart_outline_rounded, size: 16, color: colors.canalGreen),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: AppSpacing.md),

          // List of crops
          ...crops.asMap().entries.map((entry) {
            final index = entry.key;
            final crop = entry.value;
            final cropColor = _getCropColor(index);
            final ratio = (crop.usedHaCm / (crop.allocatedHaCm > 0 ? crop.allocatedHaCm : 1.0))
                .clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: cropColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            crop.cropNameMarathi,
                            style: context.bodySmall.bold.withColor(colors.textPrimary),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${crop.areaAcres} Ac)',
                            style: context.caption.withColor(colors.textSecondary),
                          ),
                        ],
                      ),
                      Text(
                        '${crop.usedHaCm.toStringAsFixed(1)} / ${crop.allocatedHaCm.toStringAsFixed(1)} ha-cm (${crop.percentage.toStringAsFixed(0)}%)',
                        style: context.caption.bold.withColor(colors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 6,
                      backgroundColor: colors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(cropColor),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

