import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

class PaymentsSummaryCard extends StatelessWidget {
  const PaymentsSummaryCard({
    super.key,
    required this.totalAmountPaid,
    required this.successCount,
    required this.pendingCount,
    required this.failedCount,
  });

  final double totalAmountPaid;
  final int successCount;
  final int pendingCount;
  final int failedCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: totalAmountPaid.truncateToDouble() == totalAmountPaid ? 0 : 2,
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(22),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL SETTLED PAYMENTS',
                      style: context.badgeText.bold.withColor(AppColors.success),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(totalAmountPaid),
                      style: context.headlineLarge.bold
                          .withColor(colors.textPrimary)
                          .withSize(30),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      '$successCount Completed',
                      style: context.labelSmall.bold.withColor(AppColors.success),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.billDivider, height: 1),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(
                context,
                title: 'Successful',
                value: '$successCount',
                color: AppColors.success,
              ),
              Container(width: 1, height: 26, color: colors.billDivider),
              _buildMetric(
                context,
                title: 'Pending',
                value: '$pendingCount',
                color: pendingCount > 0 ? AppColors.warning : colors.textSecondary,
              ),
              Container(width: 1, height: 26, color: colors.billDivider),
              _buildMetric(
                context,
                title: 'Failed',
                value: '$failedCount',
                color: failedCount > 0 ? AppColors.error : colors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(title, style: context.caption.withSize(11)),
        const SizedBox(height: 2),
        Text(value, style: context.titleMedium.bold.withColor(color)),
      ],
    );
  }
}

