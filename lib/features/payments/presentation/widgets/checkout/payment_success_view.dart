import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/features/bills/presentation/widgets/bill_receipt_sheet.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';

class PaymentSuccessView extends StatelessWidget {
  const PaymentSuccessView({
    super.key,
    required this.state,
  });

  final PaymentCheckoutState state;

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
    final l10n = context.l10n;
    final payment = state.completedPayment ??
        PaymentEntity(
          id: 'pay_dummy',
          paymentNumber: 'REC/WUA/2026-27/0942',
          status: PaymentStatus.success,
          amount: state.bill.totalAmount > 0 ? state.bill.totalAmount : 1240.0,
          paymentDate: DateTime.now(),
          billId: state.bill.id,
          billNumber: state.bill.billNumber,
          consumerName: state.bill.consumerName ?? 'Ramesh Patil',
          wuaSocietyName: state.bill.wuaSocietyName ?? 'Ganga-Godavari WUA Society #12',
          season: state.bill.season,
          cropType: state.bill.cropType,
          paymentMode: state.paymentModeDisplay,
          gatewayTransactionId: 'TXN/WRD/20261116/84291',
        );

    final updatedPaidBill = state.bill.copyWith(
      status: 'PAID',
      paidAmount: payment.amount,
      outstandingAmount: 0.0,
      paymentReference: payment.gatewayTransactionId ?? payment.paymentNumber,
      paymentDate: payment.paymentDate,
      paymentMethod: payment.paymentMode,
    );

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Badge & Icon
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 56,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Title
              Text(
                'Payment Successful!',
                style: context.headlineSmall.bold.withColor(colors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                'पाणीपट्टी भरणा यशस्वीरीत्या पूर्ण झाला',
                style: context.bodySmall.withColor(colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Large Amount
              Center(
                child: Text(
                  _formatCurrency(payment.amount),
                  style: context.headlineLarge.bold.withColor(colors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Receipt Summary Card
              Container(
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
                  children: [
                    _buildReceiptRow(
                      context,
                      'Receipt / Challan No.',
                      payment.paymentNumber,
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _buildReceiptRow(
                      context,
                      'WRD Transaction ID',
                      payment.gatewayTransactionId ?? 'TXN/WRD/2026/89412',
                    ),
                    const SizedBox(height: 8),
                    _buildReceiptRow(
                      context,
                      'Payment Method',
                      payment.paymentMode,
                    ),
                    const SizedBox(height: 8),
                    _buildReceiptRow(
                      context,
                      'Date & Time',
                      payment.formattedDateTime,
                    ),
                    const SizedBox(height: 8),
                    _buildReceiptRow(
                      context,
                      'WUA Society',
                      payment.wuaSocietyName ?? 'Ganga-Godavari WUA Society #12',
                    ),
                    const SizedBox(height: 8),
                    _buildReceiptRow(
                      context,
                      'Bill Reference',
                      payment.billNumber ?? state.bill.billNumber,
                    ),
                    const SizedBox(height: 8),
                    _buildReceiptRow(
                      context,
                      'Season & Crops',
                      '${payment.season} • ${payment.cropType}',
                    ),
                    const SizedBox(height: 12),
                    Divider(color: colors.divider, height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.canalGreen,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Recorded in Government Water Resources Dept ledger.',
                            style: context.caption.withSize(11).withColor(
                                  AppColors.canalGreen,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // View Official E-Receipt Button
              ElevatedButton.icon(
                onPressed: () {
                  BillReceiptSheet.show(context, bill: updatedPaidBill);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.headerTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.receipt_long_rounded, size: 20),
                label: Text(
                  l10n.viewOfficialEReceipt,
                  style: context.buttonText.bold.white,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // View in Payments History
              OutlinedButton.icon(
                onPressed: () {
                  context.go('/payments');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(color: colors.cardBorder),
                ),
                icon: const Icon(Icons.history_rounded, size: 18),
                label: const Text('View in Payments History'),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Back to Dashboard
              TextButton(
                onPressed: () {
                  context.go(RouteNames.home);
                },
                child: Text(
                  'Back to Dashboard',
                  style: context.labelMedium.withColor(colors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.bodySmall.withColor(colors.textSecondary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: isBold
                ? context.bodySmall.bold.withColor(colors.textPrimary)
                : context.bodySmall.withColor(colors.textPrimary),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
