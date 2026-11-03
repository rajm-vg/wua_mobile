import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/bills/presentation/widgets/bill_receipt_sheet.dart';

/// Interactive, theme-aware card representing an individual WUA Pani Patti Bill.
class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.bill,
    this.onTap,
    this.onPayPressed,
  });

  final BillEntity bill;
  final VoidCallback? onTap;
  final VoidCallback? onPayPressed;

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Status chip styling
    Color badgeBg;
    Color badgeText;
    String badgeLabel;
    IconData badgeIcon;

    if (bill.isPaid) {
      badgeBg = AppColors.success.withValues(alpha: 0.12);
      badgeText = AppColors.success;
      badgeLabel = 'Paid';
      badgeIcon = Icons.check_circle_rounded;
    } else if (bill.isOverdue) {
      badgeBg = AppColors.error.withValues(alpha: 0.12);
      badgeText = AppColors.error;
      badgeLabel = 'Overdue';
      badgeIcon = Icons.warning_amber_rounded;
    } else {
      badgeBg = colors.billBadgeBg;
      badgeText = colors.billBadgeText;
      badgeLabel = 'Due ${bill.formattedDueDate}';
      badgeIcon = Icons.schedule_rounded;
    }

    final double displayAmount = bill.isPaid
        ? bill.paidAmount
        : (bill.outstandingAmount > 0
              ? bill.outstandingAmount
              : bill.totalAmount);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: bill.isOverdue
              ? AppColors.error.withValues(alpha: 0.35)
              : colors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap:
              onTap ??
              () {
                context.push('/bills/${bill.id}', extra: bill);
              },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Season / Title + Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                bill.billNumber,
                                style: context.badgeText.bold.withColor(
                                  colors.primary,
                                ),
                              ),
                              if (bill.cropType.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    bill.cropType,
                                    style: context.caption.withSize(10.5),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            bill.season,
                            style: context.titleSmall.bold.withColor(
                              colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 13, color: badgeText),
                          const SizedBox(width: 4),
                          Text(
                            badgeLabel,
                            style: context.labelSmall.bold.withColor(badgeText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Amount & CTA Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatCurrency(displayAmount),
                            style: context.headlineLarge.bold
                                .withColor(colors.textPrimary)
                                .withSize(28),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bill.waterQuantityLiters > 0
                                ? '${NumberFormat('#,###').format(bill.waterQuantityLiters)} L water for ${bill.landAreaAcres} Acres'
                                : 'Command area cess for ${bill.landAreaAcres} Acres',
                            style: context.caption.withSize(11.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Action Button
                    if (bill.isPayable)
                      ElevatedButton.icon(
                        onPressed:
                            onPayPressed ??
                            () {
                              context.push('/bills/${bill.id}', extra: bill);
                            },
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
                            Text(
                              'Pay via UPI',
                              style: context.labelMedium.bold.white,
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, size: 14),
                          ],
                        ),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () {
                          BillReceiptSheet.show(context, bill: bill);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: BorderSide(
                            color: AppColors.success.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.receipt_long_rounded, size: 15),
                        label: const Text('Receipt'),
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
                      title: 'Base Water',
                      amount: _formatCurrency(bill.subtotal),
                    ),
                    Container(height: 22, width: 1, color: colors.billDivider),
                    _buildBreakdownColumn(
                      context,
                      title: 'Govt Cess',
                      amount: _formatCurrency(bill.taxes),
                    ),
                    Container(height: 22, width: 1, color: colors.billDivider),
                    _buildBreakdownColumn(
                      context,
                      title: 'WUA Maint.',
                      amount: _formatCurrency(bill.maintenanceCess),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
