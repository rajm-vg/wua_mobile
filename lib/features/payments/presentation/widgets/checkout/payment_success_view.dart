import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
  late final Animation<double> _checkProgress;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _circleScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.elasticOut),
    );
    _rippleScale = Tween<double>(begin: 0.7, end: 1.45).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.75, curve: Curves.easeOut),
      ),
    );
    _rippleOpacity = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.75, curve: Curves.easeOut),
      ),
    );
    _checkProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 0.65, curve: Curves.easeOutCubic),
    );
    _contentOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.95, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
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

    final updatedPaidBill = state.bill.copyWith(
      status: newOutstanding <= 0 ? 'PAID' : 'PARTIAL',
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
              // Animated TPAP Success Badge & Stroke Checkmark
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return SizedBox(
                      width: 112,
                      height: 112,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
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
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.success
                                        .withValues(alpha: 0.3),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
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
              ),
              const SizedBox(height: AppSpacing.sm),

              FadeTransition(
                opacity: _contentOpacity,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        'Payment Successful!',
                        style: context.headlineSmall.bold
                            .withColor(colors.textPrimary),
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
                          style: context.headlineLarge.bold
                              .withColor(AppColors.success),
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
                              payment.gatewayTransactionId ?? 'N/A',
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
                            if (payment.wuaSocietyName != null &&
                                payment.wuaSocietyName!.isNotEmpty) ...[
                              _buildReceiptRow(
                                context,
                                'WUA Society',
                                payment.wuaSocietyName!,
                              ),
                              const SizedBox(height: 8),
                            ],
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
                                    style: context.caption
                                        .withSize(11)
                                        .withColor(AppColors.canalGreen),
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
