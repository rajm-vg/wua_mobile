import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/bills/presentation/widgets/bill_receipt_sheet.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_state.dart';
import 'package:wua_mobile/shared/widgets/wua_scaffold.dart';

/// Detailed view for an individual payment transaction.
/// Supports both mobile screens and responsive web layouts.
class PaymentDetailPage extends StatelessWidget {
  const PaymentDetailPage({
    super.key,
    required this.paymentId,
    this.initialPayment,
  });

  final String paymentId;
  final PaymentEntity? initialPayment;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentsBloc>(
      create: (context) {
        final bloc = sl<PaymentsBloc>();
        if (initialPayment == null) {
          bloc.add(LoadPaymentDetailEvent(paymentId));
        }
        return bloc;
      },
      child: _PaymentDetailPageView(
        paymentId: paymentId,
        initialPayment: initialPayment,
      ),
    );
  }
}

class _PaymentDetailPageView extends StatelessWidget {
  const _PaymentDetailPageView({required this.paymentId, this.initialPayment});

  final String paymentId;
  final PaymentEntity? initialPayment;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentsBloc, PaymentsState>(
      builder: (context, state) {
        PaymentEntity? activePayment = initialPayment;
        bool isLoading = false;
        String? errorMessage;

        if (state is PaymentDetailLoading && activePayment == null) {
          isLoading = true;
        } else if (state is PaymentDetailLoaded) {
          activePayment = state.payment;
        } else if (state is PaymentDetailError && activePayment == null) {
          errorMessage = state.message;
        }

        final payment = activePayment;

        return WuaScaffold(
          title: 'Payment Receipt',
          subtitle: payment != null
              ? payment.paymentNumber
              : 'Receipt #$paymentId',
          showBackButton: true,
          scrollable: true,
          padding: EdgeInsets.zero,
          enableMaxConstraint: true,
          maxWidth: 960.0,
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRetry: () {
            context.read<PaymentsBloc>().add(LoadPaymentDetailEvent(paymentId));
          },
          actions: payment != null
              ? [
                  IconButton(
                    tooltip: 'Share Receipt',
                    icon: const Icon(Icons.share_rounded),
                    onPressed: () {
                      context.showInfoSnackBar(
                        'Sharing payment confirmation ${payment.paymentNumber}...',
                      );
                    },
                  ),
                  if (payment.isSuccess)
                    IconButton(
                      tooltip: 'View Official E-Receipt',
                      icon: const Icon(Icons.receipt_long_rounded),
                      onPressed: () => _openOfficialReceipt(context, payment),
                    ),
                ]
              : null,
          body: payment == null
              ? const SizedBox.shrink()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideWeb = constraints.maxWidth >= 720;

                    if (isWideWeb) {
                      // Two-column layout on desktop/web
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Hero & Transaction Details
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildHeroBanner(context, payment),
                                  const SizedBox(height: AppSpacing.md),
                                  _buildTransactionDetailsCard(
                                    context,
                                    payment,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),

                            // Right Column: Associated Bill & Action Panel
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildBillParticularsCard(context, payment),
                                  const SizedBox(height: AppSpacing.md),
                                  _buildActionCard(context, payment),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Mobile single-column layout
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeroBanner(context, payment),
                          const SizedBox(height: AppSpacing.md),
                          _buildTransactionDetailsCard(context, payment),
                          const SizedBox(height: AppSpacing.md),
                          _buildBillParticularsCard(context, payment),
                          const SizedBox(height: AppSpacing.md),
                          _buildActionCard(context, payment),
                          const SizedBox(height: 40),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  // ─── 1. Hero Status Card ─────────────────────────────────────

  Widget _buildHeroBanner(BuildContext context, PaymentEntity payment) {
    final colors = context.colors;

    Color badgeBg;
    Color badgeFg;
    String statusTitle;
    IconData statusIcon;

    if (payment.isSuccess) {
      badgeBg = AppColors.success.withValues(alpha: 0.12);
      badgeFg = AppColors.success;
      statusTitle = 'PAYMENT SUCCESSFUL';
      statusIcon = Icons.check_circle_rounded;
    } else if (payment.isFailed) {
      badgeBg = AppColors.error.withValues(alpha: 0.12);
      badgeFg = AppColors.error;
      statusTitle = 'PAYMENT FAILED';
      statusIcon = Icons.cancel_rounded;
    } else {
      badgeBg = AppColors.warning.withValues(alpha: 0.12);
      badgeFg = AppColors.warning;
      statusTitle = 'PROCESSING';
      statusIcon = Icons.timelapse_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: payment.isFailed
              ? AppColors.error.withValues(alpha: 0.3)
              : colors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  payment.season,
                  style: context.titleMedium.bold.withColor(colors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: badgeFg),
                    const SizedBox(width: 5),
                    Text(
                      statusTitle,
                      style: context.labelSmall.bold.withColor(badgeFg),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            payment.formattedAmount,
            style: context.displaySmall.bold
                .withColor(
                  payment.isSuccess
                      ? AppColors.success
                      : (payment.isFailed
                            ? AppColors.error
                            : colors.textPrimary),
                )
                .withSize(36),
          ),
          const SizedBox(height: 4),
          Text(payment.formattedDateTime, style: context.caption.medium),
          if (payment.remarks != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: payment.isFailed
                    ? AppColors.error.withValues(alpha: 0.08)
                    : colors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    payment.isFailed
                        ? Icons.error_outline_rounded
                        : Icons.info_outline_rounded,
                    size: 16,
                    color: payment.isFailed
                        ? AppColors.error
                        : colors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      payment.remarks!,
                      style: context.caption
                          .withSize(11.5)
                          .withColor(
                            payment.isFailed
                                ? AppColors.error
                                : colors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── 2. Transaction Details Card ─────────────────────────────

  Widget _buildTransactionDetailsCard(
    BuildContext context,
    PaymentEntity payment,
  ) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.receipt_rounded,
                size: 20,
                color: AppColors.headerTeal,
              ),
              const SizedBox(width: 8),
              Text('Transaction Particulars', style: context.sectionTitle.bold),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.billDivider, height: 1),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow('Official Receipt No', payment.paymentNumber, context),
          _buildInfoRow('Payment Mode', payment.paymentMode, context),
          _buildInfoRow('Payment Gateway', payment.gatewayName, context),
          _buildInfoRow(
            'Gateway Ref ID / Txn',
            payment.gatewayTransactionId ?? 'N/A',
            context,
          ),
          _buildInfoRow(
            'Bank Reference No',
            payment.bankReference ?? 'N/A',
            context,
          ),
          _buildInfoRow(
            'Payment Date & Time',
            payment.formattedDateTime,
            context,
          ),
        ],
      ),
    );
  }

  // ─── 3. Bill & Consumer Particulars Card ──────────────────────

  Widget _buildBillParticularsCard(
    BuildContext context,
    PaymentEntity payment,
  ) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.water_drop_rounded,
                size: 20,
                color: AppColors.waterCyan,
              ),
              const SizedBox(width: 8),
              Text(
                'Associated Bill & Farmer',
                style: context.sectionTitle.bold,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.billDivider, height: 1),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            'Farmer Name',
            payment.consumerName ?? 'Ramesh Patil',
            context,
          ),
          _buildInfoRow(
            'Kisan / Consumer ID',
            payment.consumerId ?? 'KISAN-MH-41201',
            context,
          ),
          _buildInfoRow(
            'WUA Society',
            payment.wuaSocietyName ?? 'Ganga-Godavari WUA #12',
            context,
          ),
          _buildInfoRow(
            'Bill Number',
            payment.billNumber ?? 'WUA-PANI-BILL',
            context,
          ),
          _buildInfoRow('Season', payment.season, context),
          _buildInfoRow('Crop Cultivated', payment.cropType, context),
        ],
      ),
    );
  }

  // ─── 4. Action Card ──────────────────────────────────────────

  Widget _buildActionCard(BuildContext context, PaymentEntity payment) {
    final colors = context.colors;

    if (payment.isSuccess) {
      return Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.cardBorder),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () => _openOfficialReceipt(context, payment),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.headerTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text('View Official E-Receipt'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () {
                context.showSuccessSnackBar(
                  'Downloading digital certificate...',
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(color: colors.cardBorder),
              ),
              icon: const Icon(Icons.download_rounded, size: 16),
              label: const Text('Download PDF Certificate'),
            ),
          ],
        ),
      );
    }

    if (payment.isFailed) {
      return Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.cardBorder),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry from Bills Screen'),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _openOfficialReceipt(BuildContext context, PaymentEntity payment) {
    final bill = BillEntity(
      id: payment.billId ?? payment.id,
      billNumber: payment.billNumber ?? payment.paymentNumber,
      status: BillStatus.paid,
      consumerName: payment.consumerName,
      wuaSocietyName: payment.wuaSocietyName,
      season: payment.season,
      cropType: payment.cropType,
      totalAmount: payment.amount,
      paidAmount: payment.amount,
      paymentReference: payment.gatewayTransactionId,
      paymentDate: payment.paymentDate,
      paymentMethod: payment.paymentMode,
    );
    BillReceiptSheet.show(context, bill: bill);
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
      ),
    );
  }
}
