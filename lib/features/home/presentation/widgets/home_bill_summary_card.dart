import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Summary card displaying current water cess bill with immediate "Pay Now" CTA.
class HomeBillSummaryCard extends StatelessWidget {
  const HomeBillSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.borderRadiusLg,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Section label & Status chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Water Cess (Rabi 2025-26)',
                    style: context.labelMedium.semiBold.withColor(
                      isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: AppRadius.borderRadiusSm,
                ),
                child: Text(
                  l10n.unpaid.toUpperCase(),
                  style: context.badgeText.withColor(AppColors.error),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Bill Amount & Due Date row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.billAmount,
                      style: context.caption,
                    ),
                    const SizedBox(height: AppSpacing.xxxs),
                    Text(
                      '₹ 450.00',
                      style: context.headlineMedium.bold.withColor(
                        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '${l10n.dueDate}: 10 Nov 2026',
                      style: context.caption.medium.withColor(
                        isDark ? AppColors.harvestAmber : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),

              // Pay Now CTA Button
              ElevatedButton.icon(
                onPressed: () => context.push(RouteNames.bills),
                icon: const Icon(Icons.payment_rounded, size: 16),
                label: Text(l10n.payNow),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
