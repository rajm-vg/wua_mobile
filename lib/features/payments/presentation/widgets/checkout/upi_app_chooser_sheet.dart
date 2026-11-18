import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';

/// Modal bottom sheet simulating the native Android/iOS UPI Intent Chooser.
/// Presents installed UPI apps (Google Pay, PhonePe, Paytm, BHIM, etc.)
/// and launches the simulated external UPI application.
class UpiAppChooserSheet extends StatelessWidget {
  const UpiAppChooserSheet({
    super.key,
    required this.bill,
  });

  final BillEntity bill;

  static Future<void> show(
    BuildContext context, {
    required BillEntity bill,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UpiAppChooserSheet(bill: bill),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final payableAmount = bill.outstandingAmount > 0
        ? bill.outstandingAmount
        : (bill.totalAmount > 0 ? bill.totalAmount : 1240.0);

    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: payableAmount.truncateToDouble() == payableAmount ? 0 : 2,
    );

    final upiApps = [
      {
        'id': 'gpay',
        'name': 'Google Pay',
        'badge': 'Fastest',
        'badgeColor': const Color(0xFF1A73E8),
        'icon': Icons.account_balance_wallet_rounded,
        'iconColor': const Color(0xFF1A73E8),
        'bgColor': const Color(0xFFE8F0FE),
      },
      {
        'id': 'phonepe',
        'name': 'PhonePe',
        'badge': 'Popular in Village',
        'badgeColor': const Color(0xFF5F259F),
        'icon': Icons.phone_android_rounded,
        'iconColor': const Color(0xFF5F259F),
        'bgColor': const Color(0xFFF3E5F5),
      },
      {
        'id': 'paytm',
        'name': 'Paytm UPI',
        'badge': 'Zero Fee',
        'badgeColor': const Color(0xFF002E6E),
        'icon': Icons.payments_rounded,
        'iconColor': const Color(0xFF002E6E),
        'bgColor': const Color(0xFFE1F5FE),
      },
      {
        'id': 'bhim',
        'name': 'BHIM Govt UPI',
        'badge': 'NPCI Official',
        'badgeColor': const Color(0xFF00796B),
        'icon': Icons.security_rounded,
        'iconColor': const Color(0xFF00796B),
        'bgColor': const Color(0xFFE0F2F1),
      },
      {
        'id': 'cred',
        'name': 'CRED UPI',
        'badge': 'Cashback',
        'badgeColor': const Color(0xFF212121),
        'icon': Icons.credit_score_rounded,
        'iconColor': const Color(0xFF212121),
        'bgColor': const Color(0xFFEEEEEE),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Center drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Header Row
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: colors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pay via UPI App',
                        style: context.titleMedium.bold.withColor(colors.textPrimary),
                      ),
                      Text(
                        'Simulated UPI flow (No real app required)',
                        style: context.caption.withColor(colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: colors.textSecondary,
                  tooltip: 'Close',
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Mock notice banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFE082)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFF57F17)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mock UPI Mode: Real apps are not required on your device. Tap any app below to launch its interactive mock.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF5D4037),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Bill info snippet
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.season,
                          style: context.caption.bold.withColor(colors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'To: MahaGov WRD Water Cess',
                          style: context.caption.withSize(11).withColor(colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currencyFormat.format(payableAmount),
                    style: context.titleMedium.bold.withColor(colors.primary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            Text(
              'SELECT UPI APP',
              style: context.caption.bold.withColor(colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),

            // List of UPI apps
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: upiApps.map((app) {
                    final appName = app['name'] as String;
                    final badge = app['badge'] as String;
                    final icon = app['icon'] as IconData;
                    final iconColor = app['iconColor'] as Color;
                    final bgColor = app['bgColor'] as Color;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push(
                            '/payments/upi-app?app=${Uri.encodeComponent(appName)}&billNumber=${Uri.encodeComponent(bill.billNumber)}&amount=$payableAmount&season=${Uri.encodeComponent(bill.season)}',
                            extra: bill,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colors.cardBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: iconColor, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appName,
                                      style: context.bodyMedium.bold
                                          .withColor(colors.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      badge,
                                      style: context.caption
                                          .withSize(11)
                                          .withColor(iconColor),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: colors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Alternative: Open Government Payment Gateway
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/payments/gateway?mode=netbanking', extra: bill);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(color: colors.cardBorder),
              ),
              icon: const Icon(Icons.account_balance_rounded, size: 16),
              label: Text(
                'Pay via Net Banking / Debit Card Gateway',
                style: context.caption.bold.withColor(colors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
