import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/shared/widgets/wua_bottom_sheet.dart';

/// Modal bottom sheet displaying official Water Resources Department payment receipt.
class BillReceiptSheet extends StatelessWidget {
  const BillReceiptSheet({super.key, required this.bill});

  final BillEntity bill;

  static Future<void> show(BuildContext context, {required BillEntity bill}) {
    return showWuaBottomSheet<void>(
      context: context,
      builder: (context) => BillReceiptSheet(bill: bill),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    final receiptNo =
        bill.metadata?['receipt_no'] ??
        'REC-WUA-${bill.billNumber.replaceAll(RegExp(r'[^0-9]'), '')}';

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: AppSpacing.md,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom:
            MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Header: Govt & WUA Title
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.headerTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.water_drop_rounded,
                    color: AppColors.headerTeal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.waterResourcesDepartmentUpper,
                        style: context.badgeText.bold.withColor(
                          AppColors.headerTeal,
                        ),
                      ),
                      Text(
                        l10n.paniPattiEReceiptTitle,
                        style: context.titleSmall.bold.withColor(
                          colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            Divider(color: colors.divider),
            const SizedBox(height: AppSpacing.sm),

            // Receipt Box
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildRow(l10n.receiptNoLabel, receiptNo.toString(), context),
                  const SizedBox(height: 8),
                  _buildRow(l10n.billNoLabel, bill.billNumber, context),
                  const SizedBox(height: 8),
                  _buildRow(l10n.seasonLabel, bill.season, context),
                  const SizedBox(height: 8),
                  _buildRow(
                    l10n.kisanConsumerLabel,
                    bill.consumerName ?? 'Ramesh Patil',
                    context,
                  ),
                  const SizedBox(height: 8),
                  _buildRow(
                    l10n.societyLabel,
                    bill.wuaSocietyName ?? 'Ganga-Godavari WUA #12',
                    context,
                  ),
                  const SizedBox(height: 8),
                  _buildRow(
                    l10n.paymentDateLabel,
                    bill.formattedPaymentDate ?? '14 Aug 2026',
                    context,
                  ),
                  const SizedBox(height: 8),
                  _buildRow(
                    l10n.paymentModeLabel,
                    bill.paymentMethod ?? 'BHIM UPI',
                    context,
                  ),
                  const SizedBox(height: 8),
                  _buildRow(
                    l10n.refIdTxnLabel,
                    bill.paymentReference ?? 'UPI/WRD/894123',
                    context,
                  ),
                  const SizedBox(height: 12),
                  Divider(color: colors.divider),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.totalAmountPaidLabel,
                        style: context.titleSmall.bold.withColor(
                          colors.textPrimary,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(
                          bill.paidAmount > 0
                              ? bill.paidAmount
                              : bill.totalAmount,
                        ),
                        style: context.titleLarge.bold.withColor(
                          AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Paid Stamp & Verification indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.success,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.paymentVerifiedByWrd,
                          style: context.labelMedium.bold.withColor(
                            AppColors.success,
                          ),
                        ),
                        Text(
                          l10n.digitalReceiptProofNote,
                          style: context.caption.withSize(11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Action Buttons: Download PDF & Share
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.showSuccessSnackBar(
                        l10n.downloadingReceiptPdf,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(color: colors.cardBorder),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(l10n.downloadPdf),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.showSuccessSnackBar(
                        l10n.receiptSharedSuccess,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.headerTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: Text(l10n.shareReceipt),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.bodySmall.withColor(colors.textSecondary)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: context.bodySmall.medium.withColor(colors.textPrimary),
          ),
        ),
      ],
    );
  }
}
