import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';

/// Current Pani Patti Bill card showing cess breakdown, acre metric, and Pay via UPI CTA.
/// Sourced directly from [BuildContext.colors] without manual isDark checks.
class PaniPattiBillCard extends StatelessWidget {
  const PaniPattiBillCard({super.key, this.bill, this.isEmpty = false});

  final BillEntity? bill;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    if (isEmpty || bill == null) {
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 36,
                color: colors.activityCheckIcon,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.noBillsFound,
              style: context.titleSmall.bold.withColor(colors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.noBillsRecordedHint,
              textAlign: TextAlign.center,
              style: context.caption.withColor(colors.textSecondary),
            ),
          ],
        ),
      );
    }

    final billTitle = bill!.season.isNotEmpty
        ? (bill!.fiscalYear?.isNotEmpty == true
              ? '${bill!.season} (${bill!.fiscalYear!})'
              : bill!.season)
        : (bill!.billNumber.isNotEmpty ? bill!.billNumber : 'N/A');

    final dueDateText = bill!.formattedDueDate.isNotEmpty
        ? bill!.formattedDueDate
        : 'N/A';

    final amountValue = bill!.outstandingAmount > 0
        ? bill!.outstandingAmount
        : bill!.totalAmount;

    final amountText = '₹ ${NumberFormat('#,##0').format(amountValue)}';

    final landInfoText = bill!.waterQuantityLiters > 0
        ? '${NumberFormat('#,##0').format(bill!.waterQuantityLiters)} L water for ${bill!.landAreaAcres > 0 ? bill!.landAreaAcres.toStringAsFixed(1) : "0"} Acres land'
        : (bill!.landAreaAcres > 0
              ? '${bill!.landAreaAcres.toStringAsFixed(1)} Acres land'
              : 'N/A');

    final baseWaterAmount = '₹ ${NumberFormat('#,##0').format(bill!.subtotal)}';

    final cessTaxAmount = '₹ ${NumberFormat('#,##0').format(bill!.taxes)}';

    final maintenanceAmount =
        '₹ ${NumberFormat('#,##0').format(bill!.maintenanceCess)}';

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
                    billTitle,
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
                  dueDateText,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      amountText,
                      style: context.headlineLarge.bold
                          .withColor(colors.textPrimary)
                          .withSize(32),
                    ),
                    const SizedBox(height: 2),
                    Text(landInfoText, style: context.caption.withSize(11.5)),
                    if (bill!.paidAmount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.amountPaid}: ₹ ${NumberFormat('#,##0.##').format(bill!.paidAmount)} • ${l10n.grossBillAmount}: ₹ ${NumberFormat('#,##0.##').format(bill!.totalAmount)}',
                        style: context.caption
                            .withSize(11)
                            .withColor(colors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Pay via Easebuzz Button
              ElevatedButton.icon(
                onPressed: bill == null
                    ? null
                    : () => context.pushNamed(
                        RouteNames.paymentCheckout,
                        extra: bill!,
                      ),
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
                    Text('Pay Now', style: context.labelMedium.bold.white),
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
                amount: baseWaterAmount,
              ),
              Container(height: 24, width: 1, color: colors.billDivider),
              _buildBreakdownColumn(
                context,
                title: l10n.govtCessTax,
                amount: cessTaxAmount,
              ),
              Container(height: 24, width: 1, color: colors.billDivider),
              _buildBreakdownColumn(
                context,
                title: l10n.wuaMaintenance,
                amount: maintenanceAmount,
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
