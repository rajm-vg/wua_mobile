import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';

class PaymentFailureView extends StatefulWidget {
  const PaymentFailureView({
    super.key,
    required this.state,
  });

  final PaymentCheckoutState state;

  @override
  State<PaymentFailureView> createState() => _PaymentFailureViewState();
}

class _PaymentFailureViewState extends State<PaymentFailureView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _circleScale;
  late final Animation<double> _rippleScale;
  late final Animation<double> _rippleOpacity;
  late final Animation<double> _crossProgress;
  late final Animation<double> _shakeProgress;
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
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );
    _rippleScale = Tween<double>(begin: 0.75, end: 1.45).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
      ),
    );
    _rippleOpacity = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.7, curve: Curves.easeOut),
      ),
    );
    _crossProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.22, 0.58, curve: Curves.easeOutCubic),
    );
    _shakeProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
    );
    _contentOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.9, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
    HapticFeedback.heavyImpact();
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

  String _errorCategoryLabel(String error) {
    final lower = error.toLowerCase();
    if (lower.contains('timeout') || lower.contains('network')) {
      return 'Network / Gateway Timeout';
    }
    if (lower.contains('hash') || lower.contains('verif')) {
      return 'Verification Mismatch';
    }
    if (lower.contains('receipt') || lower.contains('500')) {
      return 'Settlement Pending';
    }
    return 'Transaction Declined';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = widget.state;
    final error = state.errorMessage ??
        'The bank or payment gateway did not respond in time. No money was deducted.';
    final attemptedAmount = state.effectivePaymentAmount;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Failure Banner
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    AppColors.error.withValues(alpha: 0.11),
                    AppColors.error.withValues(alpha: 0.03),
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
                      final shakeOffset =
                          math.sin(_shakeProgress.value * math.pi * 4) *
                          (1 - _shakeProgress.value) *
                          8;
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
                                    color: AppColors.error.withValues(
                                      alpha: _rippleOpacity.value,
                                    ),
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset(shakeOffset, 0),
                              child: Transform.scale(
                                scale: _circleScale.value.clamp(0.0, 1.15),
                                child: Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFDC2626),
                                        Color(0xFFB91C1C),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.error
                                            .withValues(alpha: 0.32),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: CustomPaint(
                                    painter: _AnimatedCrossPainter(
                                      progress: _crossProgress.value,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FadeTransition(
                    opacity: _contentOpacity,
                    child: Column(
                      children: [
                        Text(
                          context.l10n.paymentFailedTitle,
                          style: context.headlineSmall.bold
                              .withColor(colors.textPrimary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'भरणा अयशस्वी झाला',
                          style: context.bodySmall
                              .withColor(colors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        if (attemptedAmount > 0) ...[
                          const SizedBox(height: 10),
                          Text(
                            _formatCurrency(attemptedAmount),
                            style: context.headlineMedium.bold
                                .withColor(colors.error),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.bill.billNumber,
                            style: context.caption.medium
                                .withColor(colors.textSecondary),
                          ),
                        ],
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
                    // Error Detail & Reassurance Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colors.error.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _errorCategoryLabel(error),
                              style: context.caption.bold
                                  .withColor(colors.error),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            error,
                            style: context.bodySmall
                                .withColor(colors.textPrimary),
                          ),
                          const SizedBox(height: 12),
                          Divider(color: colors.divider, height: 1),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 16,
                                color: colors.canalGreen,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'If any amount was debited from your bank account, it is automatically refunded within 2–3 business days.',
                                  style: context.caption.withSize(11.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<PaymentCheckoutBloc>().add(
                              const ResetPaymentCheckoutEvent(),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(
                        context.l10n.tryAgain,
                        style: context.buttonText.bold.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).maybePop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: colors.cardBorder),
                      ),
                      child: const Text('Cancel & Return'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCrossPainter extends CustomPainter {
  const _AnimatedCrossPainter({
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
      ..strokeCap = StrokeCap.round;

    final firstLine = ui.Path()
      ..moveTo(size.width * 0.34, size.height * 0.34)
      ..lineTo(size.width * 0.66, size.height * 0.66);

    final secondLine = ui.Path()
      ..moveTo(size.width * 0.66, size.height * 0.34)
      ..lineTo(size.width * 0.34, size.height * 0.66);

    final p1 = (progress * 2).clamp(0.0, 1.0);
    final p2 = ((progress - 0.5) * 2).clamp(0.0, 1.0);

    for (final metric in firstLine.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * p1), paint);
    }
    if (p2 > 0) {
      for (final metric in secondLine.computeMetrics()) {
        canvas.drawPath(metric.extractPath(0, metric.length * p2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_AnimatedCrossPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
