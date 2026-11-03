import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Current Pani Patti Bill card showing cess breakdown, acre metric, and Pay via UPI CTA.
/// Sourced directly from [BuildContext.colors] without manual isDark checks.
class PaniPattiBillCard extends StatelessWidget {
  const PaniPattiBillCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
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
          // Header: Title + Due Date Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.currentPaniPattiBill, style: context.badgeText),
                  const SizedBox(height: 2),
                  Text(
                    l10n.rabiSeason,
                    style: context.titleSmall.bold.withColor(
                      colors.textPrimary,
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
                  color: colors.billBadgeBg,
                  borderRadius: AppRadius.borderRadiusFull,
                ),
                child: Text(
                  l10n.due25Nov,
                  style: context.labelSmall.bold.withColor(
                    colors.billBadgeText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Amount & Pay via UPI CTA Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Amount and land info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹ 1,240',
                    style: context.headlineLarge.bold
                        .withColor(colors.textPrimary)
                        .withSize(32),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.waterPerAcreLand,
                    style: context.caption.withSize(11.5),
                  ),
                ],
              ),

              // Pay via UPI Button
              ElevatedButton.icon(
                onPressed: () => context.push(RouteNames.bills),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.billCtaBg,
                  foregroundColor: colors.billCtaText,
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.payment_rounded, size: 16),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.payViaUpi, style: context.labelMedium.bold.white),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.billDivider, height: 1),
          const SizedBox(height: AppSpacing.sm),

          // 3-Column Cost Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBreakdownColumn(
                context,
                title: l10n.baseWater,
                amount: '₹ 1,110',
              ),
              Container(height: 24, width: 1, color: colors.billDivider),
              _buildBreakdownColumn(
                context,
                title: l10n.govtCessTax,
                amount: '₹ 90',
              ),
              Container(height: 24, width: 1, color: colors.billDivider),
              _buildBreakdownColumn(
                context,
                title: l10n.wuaMaintenance,
                amount: '₹ 40',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownColumn(
    BuildContext context, {
    required String title,
    required String amount,
  }) {
    return Column(
      children: [
        Text(title, style: context.caption.withSize(11)),
        const SizedBox(height: 2),
        Text(
          amount,
          style: context.labelMedium.bold.withColor(context.colors.textPrimary),
        ),
      ],
    );
  }
}
