import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';

/// Interactive summary card displaying the bill to be paid with expandable tariff details.
class BillSummaryCard extends StatefulWidget {
  const BillSummaryCard({super.key, required this.bill});

  final BillEntity bill;

  @override
  State<BillSummaryCard> createState() => _BillSummaryCardState();
}

class _BillSummaryCardState extends State<BillSummaryCard> {
  bool _isExpanded = false;

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
    final bill = widget.bill;
    final l10n = context.l10n;

    final payableAmount = bill.outstandingAmount > 0
        ? bill.outstandingAmount
        : bill.totalAmount;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bill.billNumber,
                          style: context.caption.bold.withColor(colors.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 14,
                          color: colors.canalGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Govt WRD Portal',
                          style: context.caption
                              .withSize(11)
                              .withColor(colors.canalGreen),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  bill.season,
                  style: context.titleMedium.bold.withColor(colors.textPrimary),
                ),
                if (bill.wuaSocietyName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    bill.wuaSocietyName!,
                    style: context.bodySmall.withColor(colors.textSecondary),
                  ),
                ],
                const SizedBox(height: 12),
                Divider(color: colors.divider, height: 1),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.totalPayable,
                          style: context.caption.withColor(
                            colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatCurrency(payableAmount),
                          style: context.headlineMedium.bold.withColor(
                            colors.primary,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: colors.primary,
                      ),
                      label: Text(
                        _isExpanded ? 'Hide Breakdown' : 'View Breakdown',
                        style: context.labelMedium.bold.withColor(
                          colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  _buildCostRow(
                    context,
                    l10n.baseWaterTariff,
                    _formatCurrency(bill.subtotal),
                  ),
                  const SizedBox(height: 6),
                  _buildCostRow(
                    context,
                    l10n.govtWaterCessTaxes,
                    _formatCurrency(bill.taxes),
                  ),
                  const SizedBox(height: 6),
                  _buildCostRow(
                    context,
                    l10n.wuaInfrastructureMaint,
                    _formatCurrency(bill.maintenanceCess),
                  ),
                  if (bill.penalties > 0) ...[
                    const SizedBox(height: 6),
                    _buildCostRow(
                      context,
                      l10n.lateOverduePenalty,
                      _formatCurrency(bill.penalties),
                      isHighlight: true,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Divider(color: colors.divider, height: 1),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.grossBillAmount,
                        style: context.bodySmall.bold.withColor(
                          colors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatCurrency(bill.totalAmount),
                        style: context.bodySmall.bold.withColor(
                          colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (bill.paidAmount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.amountPaid,
                          style: context.bodySmall.withColor(colors.success),
                        ),
                        Text(
                          '- ${_formatCurrency(bill.paidAmount)}',
                          style: context.bodySmall.bold.withColor(
                            colors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Divider(color: colors.divider, height: 1),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.netOutstandingBalance,
                          style: context.bodySmall.bold.withColor(
                            colors.primary,
                          ),
                        ),
                        Text(
                          _formatCurrency(payableAmount),
                          style: context.bodySmall.bold.withColor(
                            colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostRow(
    BuildContext context,
    String label,
    String amount, {
    bool isHighlight = false,
  }) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.bodySmall.withColor(
            isHighlight ? colors.error : colors.textSecondary,
          ),
        ),
        Text(
          amount,
          style: context.bodySmall.bold.withColor(
            isHighlight ? colors.error : colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
