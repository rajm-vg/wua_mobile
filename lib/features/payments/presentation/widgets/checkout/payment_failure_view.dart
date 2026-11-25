import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late final Animation<double> _crossProgress;
  late final Animation<double> _shakeProgress;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _circleScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final error = widget.state.errorMessage ??
        'The bank or payment gateway did not respond in time. No money was deducted.';

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final shakeOffset =
                      math.sin(_shakeProgress.value * math.pi * 4) *
                      (1 - _shakeProgress.value) *
                      8;
                  return Transform.translate(
                    offset: Offset(shakeOffset, 0),
                    child: Transform.scale(
                      scale: _circleScale.value.clamp(0.0, 1.15),
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withValues(alpha: 0.28),
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
                  );
                },
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
                    Text(
                      'Payment Failed',
                      style: context.headlineSmall.bold
                          .withColor(colors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'भरणा अयशस्वी झाला',
                      style: context.bodySmall.withColor(colors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            error,
                            style: context.bodySmall
                                .withColor(colors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'If amount is deducted from your bank account, it will be automatically refunded within 2 business days.',
                            style: context.caption.withSize(11),
                            textAlign: TextAlign.center,
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Try Again'),
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
