import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/bills/presentation/widgets/bill_receipt_sheet.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({
    super.key,
    required this.payment,
    this.onTap,
  });

  final PaymentEntity payment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Color badgeBg;
    Color badgeFg;
    String badgeLabel;
    IconData badgeIcon;

    if (payment.isSuccess) {
      badgeBg = AppColors.success.withValues(alpha: 0.12);
      badgeFg = AppColors.success;
      badgeLabel = 'Successful';
      badgeIcon = Icons.check_circle_rounded;
    } else if (payment.isFailed) {
      badgeBg = AppColors.error.withValues(alpha: 0.12);
      badgeFg = AppColors.error;
      badgeLabel = 'Failed';
      badgeIcon = Icons.cancel_rounded;
    } else {
      badgeBg = AppColors.warning.withValues(alpha: 0.12);
      badgeFg = AppColors.warning;
      badgeLabel = 'Pending';
      badgeIcon = Icons.timelapse_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: payment.isFailed
              ? AppColors.error.withValues(alpha: 0.3)
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
          onTap: onTap ??
              () {
                context.push('/payments/${payment.id}', extra: payment);
              },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Receipt No & Status Badge
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
                                payment.paymentNumber,
                                style: context.badgeText.bold.withColor(colors.primary),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  payment.paymentMode,
                                  style: context.caption.withSize(10.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            payment.season,
                            style: context.titleSmall.bold.withColor(colors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: AppRadius.borderRadiusFull,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 13, color: badgeFg),
                          const SizedBox(width: 4),
                          Text(
                            badgeLabel,
                            style: context.labelSmall.bold.withColor(badgeFg),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Amount & Actions Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.formattedAmount,
                            style: context.headlineLarge.bold.withColor(
                              payment.isSuccess
                                  ? AppColors.success
                                  : (payment.isFailed ? AppColors.error : colors.textPrimary),
                            ).withSize(26),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            payment.formattedDateTime,
                            style: context.caption.withSize(11.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    if (payment.isSuccess)
                      OutlinedButton.icon(
                        onPressed: () {
                          // Display official digital receipt
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
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: BorderSide(color: AppColors.success.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.receipt_long_rounded, size: 15),
                        label: const Text('Receipt'),
                      )
                    else if (payment.isFailed)
                      ElevatedButton.icon(
                        onPressed: () => context.go('/bills'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 15),
                        label: const Text('Retry'),
                      )
                    else
                      OutlinedButton(
                        onPressed: () {
                          context.push('/payments/${payment.id}', extra: payment);
                        },
                        child: const Text('Details'),
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
}

