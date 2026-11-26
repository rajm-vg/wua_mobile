import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/features/bills/presentation/widgets/bill_receipt_sheet.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';

class PaymentSuccessView extends StatefulWidget {
  const PaymentSuccessView({
    super.key,
    required this.state,
  });

  final PaymentCheckoutState state;

  @override
  State<PaymentSuccessView> createState() => _PaymentSuccessViewState();
}

class _PaymentSuccessViewState extends State<PaymentSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _circleScale;
  late final Animation<double> _rippleScale;
  late final Animation<double> _rippleOpacity;
  late final Animation<double> _sparkleProgress;
  late final Animation<double> _checkProgress;
  late final Animation<double> _amountProgress;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _circleScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.42, curve: Curves.elasticOut),
    );
    _rippleScale = Tween<double>(begin: 0.7, end: 1.55).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.08, 0.72, curve: Curves.easeOut),
      ),
    );
    _rippleOpacity = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 0.72, curve: Curves.easeOut),
      ),
    );
    _sparkleProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
    );
    _checkProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.24, 0.62, curve: Curves.easeOutCubic),
    );
    _amountProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.78, curve: Curves.easeOutCubic),
    );
    _contentOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.40, 0.92, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.92, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return format.format(amount);
  }

  void _copyValue(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    HapticFeedback.selectionClick();
    context.showSuccessSnackBar('$label copied');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final state = widget.state;

    final payment = state.completedPayment ??
        PaymentEntity(
          id: '',
          paymentNumber: 'N/A',
          status: PaymentStatus.success,
          amount: state.effectivePaymentAmount,
          paymentDate: DateTime.now(),
          billId: state.bill.id,
          billNumber: state.bill.billNumber,
          consumerName: state.bill.consumerName,
          wuaSocietyName: state.bill.wuaSocietyName,
          season: state.bill.season,
          cropType: state.bill.cropType,
          paymentMode: state.paymentModeDisplay,
        );

    final newPaidAmount = state.bill.paidAmount + payment.amount;
    final newOutstanding =
        (state.bill.totalAmount - newPaidAmount).clamp(0.0, double.infinity);
    final isPartial = newOutstanding > 0;

    final updatedPaidBill = state.bill.copyWith(
      status: isPartial ? 'PARTIAL' : 'PAID',
      paidAmount: newPaidAmount,
      outstandingAmount: newOutstanding,
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
              // Animated TPAP Hero Celebration Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withValues(alpha: 0.12),
                      AppColors.canalGreen.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        return SizedBox(
                          width: 128,
                          height: 128,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(128, 128),
                                painter: _SparkleBurstPainter(
                                  progress: _sparkleProgress.value,
                                ),
                              ),
                              Transform.scale(
                                scale: _rippleScale.value,
                                child: Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.success.withValues(
                                        alpha: _rippleOpacity.value,
                                      ),
                                      width: 4,
                                    ),
                                  ),
                                ),
                              ),
                              Transform.scale(
                                scale: _circleScale.value.clamp(0.0, 1.15),
                                child: Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF16A34A),
                                        Color(0xFF15803D),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.success
                                            .withValues(alpha: 0.35),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: CustomPaint(
                                    painter: _AnimatedCheckmarkPainter(
                                      progress: _checkProgress.value,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    FadeTransition(
                      opacity: _contentOpacity,
                      child: Column(
                        children: [
                          Text(
                            l10n.paymentSuccessfulTitle,
                            style: context.headlineSmall.bold
                                .withColor(colors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'पाणीपट्टी भरणा यशस्वीरीत्या पूर्ण झाला',
                            style: context.bodySmall
                                .withColor(colors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AnimatedBuilder(
                            animation: _amountProgress,
                            builder: (context, _) {
                              final animatedAmount =
                                  payment.amount * _amountProgress.value;
                              return Text(
                                _formatCurrency(animatedAmount),
                                style: context.displaySmall.bold
                                    .withColor(colors.success),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colors.cardBackground,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: colors.success.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user_rounded,
                                  size: 14,
                                  color: colors.success,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isPartial
                                      ? 'Partial Payment Settled • Remaining ${_formatCurrency(newOutstanding)}'
                                      : 'Paid to WRD Water User Account',
                                  style: context.caption.bold
                                      .withColor(colors.success),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              FadeTransition(
                opacity: _contentOpacity,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Receipt Card with Dashed Divider & Copyable IDs
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
                              onCopy: () => _copyValue(
                                context,
                                'Receipt No.',
                                payment.paymentNumber,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildReceiptRow(
                              context,
                              'WRD Transaction ID',
                              payment.gatewayTransactionId ?? 'N/A',
                              onCopy: payment.gatewayTransactionId != null
                                  ? () => _copyValue(
                                        context,
                                        'Transaction ID',
                                        payment.gatewayTransactionId!,
                                      )
                                  : null,
                            ),
                            const SizedBox(height: 10),
                            _buildReceiptRow(
                              context,
                              'Payment Method',
                              payment.paymentMode,
                            ),
                            const SizedBox(height: 10),
                            _buildReceiptRow(
                              context,
                              'Date & Time',
                              payment.formattedDateTime,
                            ),
                            const SizedBox(height: 14),
                            _DashedDivider(color: colors.divider),
                            const SizedBox(height: 14),
                            if (payment.wuaSocietyName != null &&
                                payment.wuaSocietyName!.isNotEmpty) ...[
                              _buildReceiptRow(
                                context,
                                'WUA Society',
                                payment.wuaSocietyName!,
                              ),
                              const SizedBox(height: 10),
                            ],
                            _buildReceiptRow(
                              context,
                              'Bill Reference',
                              payment.billNumber ?? state.bill.billNumber,
                            ),
                            const SizedBox(height: 10),
                            _buildReceiptRow(
                              context,
                              'Season & Crops',
                              '${payment.season} • ${payment.cropType}',
                            ),
                            const SizedBox(height: 14),
                            Divider(color: colors.divider, height: 1),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: colors.canalGreen,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Recorded in Government Water Resources Dept ledger.',
                                    style: context.caption
                                        .withSize(11)
                                        .withColor(colors.canalGreen),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Primary CTA: View Official E-Receipt
                      ElevatedButton.icon(
                        onPressed: () {
                          BillReceiptSheet.show(context, bill: updatedPaidBill);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.billCtaBg,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.receipt_long_rounded, size: 20),
                        label: Text(
                          l10n.viewOfficialEReceipt,
                          style: context.buttonText.bold.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Secondary Row: Share & History
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final summary = [
                                  'WRD Pani Patti Payment Receipt',
                                  'Amount: ${_formatCurrency(payment.amount)}',
                                  'Receipt No: ${payment.paymentNumber}',
                                  if (payment.gatewayTransactionId != null)
                                    'Transaction ID: ${payment.gatewayTransactionId}',
                                  'Bill: ${payment.billNumber ?? state.bill.billNumber}',
                                  'Date: ${payment.formattedDateTime}',
                                ].join('\n');
                                _copyValue(context, 'Receipt summary', summary);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(color: colors.cardBorder),
                              ),
                              icon: const Icon(Icons.share_rounded, size: 17),
                              label: Text(l10n.shareReceipt),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: OutlinedButton.icon(
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
                              icon: const Icon(Icons.history_rounded, size: 17),
                              label: const Text('History'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),

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
    VoidCallback? onCopy,
  }) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: context.bodySmall.withColor(colors.textSecondary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: isBold
                        ? context.bodySmall.bold.withColor(colors.textPrimary)
                        : context.bodySmall.withColor(colors.textPrimary),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onCopy != null) ...[
                  const SizedBox(width: 5),
                  Icon(
                    Icons.copy_rounded,
                    size: 13,
                    color: colors.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedCheckmarkPainter extends CustomPainter {
  const _AnimatedCheckmarkPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = ui.Path()
      ..moveTo(size.width * 0.28, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.67)
      ..lineTo(size.width * 0.74, size.height * 0.35);

    for (final metric in path.computeMetrics()) {
      final extract = metric.extractPath(0, metric.length * progress);
      canvas.drawPath(extract, paint);
    }
  }

  @override
  bool shouldRepaint(_AnimatedCheckmarkPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _SparkleBurstPainter extends CustomPainter {
  const _SparkleBurstPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    final opacity = (1.0 - progress).clamp(0.0, 1.0);
    const sparkleColors = [
      Color(0xFF16A34A),
      Color(0xFFF59E0B),
      Color(0xFF0EA5E9),
      Color(0xFF22C55E),
    ];

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) - math.pi / 8;
      final radius = 38.0 + (26.0 * progress);
      final pos = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final dotPaint = Paint()
        ..color = sparkleColors[i % sparkleColors.length].withValues(
          alpha: opacity,
        )
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 3.5 * (1.0 - progress * 0.5), dotPaint);
    }
  }

  @override
  bool shouldRepaint(_SparkleBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(decoration: BoxDecoration(color: color)),
            );
          }),
        );
      },
    );
  }
}
