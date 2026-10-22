import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:wua_mobile/core/theme/colors.dart';

/// Refined emblem for the Water Resources Department & WUA
/// featuring minute, cohesive colors and full dark/light theme support.
class WrdEmblem extends StatelessWidget {
  const WrdEmblem({
    super.key,
    required this.rotationAnimation,
    required this.pulseAnimation,
    this.size = 140,
    this.isDark = true,
  });

  final Animation<double> rotationAnimation;
  final Animation<double> pulseAnimation;
  final double size;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([rotationAnimation, pulseAnimation]),
      builder: (context, child) {
        final scale = 1.0 + (pulseAnimation.value * 0.03);

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating subtle orbital ring
                Transform.rotate(
                  angle: rotationAnimation.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: _OrbitalRingPainter(
                      color: (isDark ? Colors.white : AppColors.primary)
                          .withValues(alpha: isDark ? 0.12 : 0.15),
                    ),
                  ),
                ),

                // Outer soft, minute glowing aura
                Container(
                  width: size * 0.84,
                  height: size * 0.84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: isDark ? 0.22 : 0.12,
                        ),
                        blurRadius: 28,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

                // Main circular crest container
                Container(
                  width: size * 0.82,
                  height: size * 0.82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const [
                              Color(0xFF1E3A5F),
                              Color(0xFF0F2236),
                            ]
                          : const [
                              AppColors.primary,
                              AppColors.primaryDark,
                            ],
                    ),
                    border: Border.all(
                      color: (isDark ? Colors.white : AppColors.primaryLight)
                          .withValues(alpha: isDark ? 0.16 : 0.28),
                      width: 1.8,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Inner concentric decorative border
                      Container(
                        width: size * 0.70,
                        height: size * 0.70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                            width: 1.0,
                          ),
                        ),
                      ),

                      // Emblem Graphics: Unified, cohesive white and frosted accents
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.water_drop_rounded,
                            size: size * 0.36,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.eco_rounded,
                                size: size * 0.15,
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.waves_rounded,
                                size: size * 0.16,
                                color: Colors.white.withValues(alpha: 0.90),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.eco_rounded,
                                size: size * 0.15,
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OrbitalRingPainter extends CustomPainter {
  _OrbitalRingPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const dashCount = 20;
    const sweep = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * sweep,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitalRingPainter oldDelegate) =>
      oldDelegate.color != color;
}
