import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';

/// Recent Activity / Transaction card displaying the latest payment record.
/// Sourced directly from [BuildContext.colors] without manual isDark checks.
class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key, this.payment, this.isEmpty = false});

  final PaymentEntity? payment;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    final activePayment = payment;
    final titleText = activePayment != null
        ? (activePayment.remarks?.isNotEmpty == true
              ? activePayment.remarks!
              : (activePayment.season.isNotEmpty
                    ? '${activePayment.season} Payment'
                    : 'N/A'))
        : '';

    final subtitleText = activePayment != null
        ? '${activePayment.formattedDate} • ${activePayment.paymentMode.toUpperCase().contains("UPI") ? l10n.paidViaUpi : (activePayment.paymentMode.isNotEmpty ? activePayment.paymentMode : "N/A")}'
        : '';

    final amountText = activePayment?.formattedAmount ?? '';

    final badgeText = activePayment != null
        ? (activePayment.isSuccess
              ? l10n.paid
              : PaymentStatus.toLabel(activePayment.status))
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.recentActivity, style: context.badgeText),
            GestureDetector(
              onTap: () => context.pushNamed(RouteNames.payments),
              child: Text(
                l10n.viewAll,
                style: context.labelSmall.bold.withColor(
                  colors.turnCardTimelineText,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (isEmpty || payment == null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.history_rounded,
                      color: colors.textSecondary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.noPaymentsFound,
                        style: context.titleSmall.bold.withColor(
                          colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.noPaymentsRecordedHint,
                        style: context.caption.withSize(12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Material(
            color: colors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => context.pushNamed(RouteNames.payments),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: colors.cardShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Green check badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.activityCheckBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: colors.activityCheckIcon,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),

                    // Title and Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleText,
                            style: context.titleSmall.bold.withColor(
                              colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitleText,
                            style: context.caption.withSize(12),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppSpacing.sm),

                    // Amount & Status Badge
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          amountText,
                          style: context.titleMedium.bold.withColor(
                            colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.activityPaidBadgeBg,
                            borderRadius: AppRadius.borderRadiusFull,
                          ),
                          child: Text(
                            badgeText,
                            style: context.labelSmall.bold
                                .withColor(colors.activityPaidBadgeText)
                                .withSize(10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
