import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Top summary hero card for the Bills list page showing outstanding balance and counts.
class BillsSummaryCard extends StatelessWidget {
  const BillsSummaryCard({
    super.key,
    required this.totalOutstanding,
    required this.pendingCount,
    required this.overdueCount,
    required this.paidCount,
    this.onPayDuesPressed,
  });

  final double totalOutstanding;
  final int pendingCount;
  final int overdueCount;
  final int paidCount;
  final VoidCallback? onPayDuesPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: totalOutstanding.truncateToDouble() == totalOutstanding ? 0 : 2,
    );

    final hasDues = totalOutstanding > 0;

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
          // Row 1: Header + Total Outstanding
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.totalWaterDuesUpper,
                      style: context.badgeText.bold.withColor(
                        hasDues ? colors.warning : colors.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(totalOutstanding),
                      style: context.headlineLarge.bold
                          .withColor(colors.textPrimary)
                          .withSize(30),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (hasDues)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: overdueCount > 0
                        ? colors.error.withValues(alpha: 0.14)
                        : colors.billBadgeBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        overdueCount > 0 ? Icons.error_outline_rounded : Icons.schedule_rounded,
                        size: 14,
                        color: overdueCount > 0 ? colors.error : colors.billBadgeText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        overdueCount > 0
                            ? l10n.overdueCountLabel(overdueCount)
                            : l10n.dueCountLabel(pendingCount),
                        style: context.labelSmall.bold.withColor(
                          overdueCount > 0 ? colors.error : colors.billBadgeText,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 14, color: colors.success),
                      const SizedBox(width: 4),
                      Text(
                        l10n.allDuesCleared,
                        style: context.labelSmall.bold.withColor(colors.success),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.billDivider, height: 1),
          const SizedBox(height: AppSpacing.sm),

          // Row 2: 3 Metrics Columns (Pending, Overdue, Paid)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(
                context,
                title: l10n.pendingBills,
                value: '$pendingCount',
                color: colors.textPrimary,
              ),
              Container(width: 1, height: 26, color: colors.billDivider),
              _buildMetric(
                context,
                title: l10n.filterOverdue,
                value: '$overdueCount',
                color: overdueCount > 0 ? colors.error : colors.textSecondary,
              ),
              Container(width: 1, height: 26, color: colors.billDivider),
              _buildMetric(
                context,
                title: l10n.paidBills,
                value: '$paidCount',
                color: colors.success,
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

