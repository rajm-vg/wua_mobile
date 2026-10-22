import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:wua_mobile/core/theme/colors.dart';

/// Animated background that simulates soft, minute concentric water ripples
/// with full dark and light mode support.
class WaterRippleBackground extends StatelessWidget {
  const WaterRippleBackground({
    super.key,
    required this.animation,
    this.isDark = true,
  });

  final Animation<double> animation;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _WaterRipplePainter(
            progress: animation.value,
            isDark: isDark,
          ),
        );
      },
    );
  }
}

class _WaterRipplePainter extends CustomPainter {
  _WaterRipplePainter({
    required this.progress,
    required this.isDark,
  });

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final maxRadius = math.min(size.width, size.height) * 0.65;

    final baseRippleColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final maxOpacity = isDark ? 0.14 : 0.08;

    // Draw 3 expanding concentric ripple waves with minute, subtle opacity
    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress + (i * 0.33)) % 1.0;
      final radius = 60.0 + (waveProgress * (maxRadius - 60.0));
      final opacity = math.sin(waveProgress * math.pi) * maxOpacity;

      final paint = Paint()
        ..color = baseRippleColor.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 + (1.0 - waveProgress) * 1.5;

      canvas.drawCircle(center, radius, paint);
    }

    // Soft, minute central radial gradient
    final radialPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (isDark ? AppColors.primary : AppColors.primaryLight)
              .withValues(alpha: isDark ? 0.08 : 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: 180));

    canvas.drawCircle(center, 180, radialPaint);

    // Subtle gentle bottom water curve
    _drawBottomWave(canvas, size);
  }

  void _drawBottomWave(Canvas canvas, Size size) {
    final waveColor = isDark
        ? AppColors.primaryDark.withValues(alpha: 0.15)
        : AppColors.primary.withValues(alpha: 0.03);

    final wavePaint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height -
          36 -
          math.sin((x / size.width * 2 * math.pi) + (progress * 2 * math.pi)) *
              8;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _WaterRipplePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
