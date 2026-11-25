import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
            final hasHaCm = crop.allocatedHaCm > 0 || crop.usedHaCm > 0;
            final ratio = hasHaCm
                ? (crop.usedHaCm /
                        (crop.allocatedHaCm > 0 ? crop.allocatedHaCm : 1.0))
                    .clamp(0.0, 1.0)
                : 0.0;
            final unitValue = crop.formattedUnitValue;
            final areaLabel = crop.areaAcres % 1 == 0
                ? crop.areaAcres.toStringAsFixed(0)
                : crop.areaAcres.toStringAsFixed(1);
            final rightSummary = hasHaCm
                ? '${crop.usedHaCm.toStringAsFixed(1)} / ${crop.allocatedHaCm.toStringAsFixed(1)} ha-cm (${crop.percentage.toStringAsFixed(0)}%)'
                : (unitValue ?? (crop.amount != null
                    ? '₹ ${NumberFormat('#,##0.##').format(crop.amount)}'
                    : 'Recorded'));

            final metaParts = <String>[
              if (crop.fiscalYear?.isNotEmpty == true) crop.fiscalYear!,
              if (crop.season?.isNotEmpty == true) crop.season!,
              if (crop.rotation?.isNotEmpty == true) 'Rot ${crop.rotation}',
              if (crop.village?.isNotEmpty == true) crop.village!,
              if (crop.surveyNo?.isNotEmpty == true) 'Survey ${crop.surveyNo}',
              if (crop.source?.isNotEmpty == true) crop.source!,
            ];

            final rateParts = <String>[
              if (crop.rateValue != null)
                'Rate ₹ ${NumberFormat('#,##0.##').format(crop.rateValue)}${crop.perType?.isNotEmpty == true ? '/${crop.perType}' : ''}',
              if (crop.seasonalWaterUsage?.isNotEmpty == true)
                crop.seasonalWaterUsage!,
            ];

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
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
                            Flexible(
                              child: Text(
                                crop.displayCropName,
                                style: context.bodySmall.bold
                                    .withColor(colors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (crop.areaAcres > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '($areaLabel Are)',
                                style: context.caption
                                    .withColor(colors.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        rightSummary,
                        style: context.caption.bold.withColor(colors.textPrimary),
                      ),
                    ],
                  ),
                  if (metaParts.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      metaParts.join(' • '),
                      style: context.caption
                          .withColor(colors.textSecondary)
                          .withSize(11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (rateParts.isNotEmpty ||
                      crop.amount != null ||
                      crop.billGenerated != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (rateParts.isNotEmpty)
                          Expanded(
                            child: Text(
                              rateParts.join(' • '),
                              style: context.caption
                                  .withColor(colors.textSecondary)
                                  .withSize(11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        else
                          const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (crop.billGenerated != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: (crop.billGenerated!
                                          ? colors.success
                                          : AppColors.harvestAmber)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  crop.billGenerated!
                                      ? 'Bill Generated'
                                      : 'Bill Pending',
                                  style: context.caption.bold
                                      .withColor(
                                        crop.billGenerated!
                                            ? colors.success
                                            : AppColors.harvestAmber,
                                      )
                                      .withSize(10),
                                ),
                              ),
                            if (crop.amount != null) ...[
                              const SizedBox(width: 6),
                              Text(
                                '₹ ${NumberFormat('#,##0.##').format(crop.amount)}',
                                style: context.caption.semiBold
                                    .withColor(colors.canalGreen)
                                    .withSize(11.5),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                  if (hasHaCm) ...[
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
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

