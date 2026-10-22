import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/core/storage/secure_storage_service.dart';
import 'package:wua_mobile/features/splash/presentation/widgets/water_ripple_background.dart';
import 'package:wua_mobile/features/splash/presentation/widgets/wrd_emblem.dart';

/// Rich animated splash screen for the Water Resources Department (WRD)
/// and Water User Association (WUA) platform.
///
/// Features refined, minute cohesive colors with full dark and light theme support.
class AnimatedSplashPage extends StatefulWidget {
  const AnimatedSplashPage({super.key});

  @override
  State<AnimatedSplashPage> createState() => _AnimatedSplashPageState();
}

class _AnimatedSplashPageState extends State<AnimatedSplashPage>
    with TickerProviderStateMixin {
  // Continuous loop controller for water ripples and ambient motion
  late final AnimationController _ambientController;
  late final Animation<double> _rippleAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _pulseAnimation;

  // Staggered entrance controller
  late final AnimationController _entranceController;
  late final Animation<double> _emblemScaleAnimation;
  late final Animation<double> _emblemFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;
  late final Animation<double> _textFadeAnimation;
  late final Animation<double> _footerFadeAnimation;

  // Dynamic initialization state
  String _statusMessage = 'Connecting to Water Resources Department...';
  double _loadProgress = 0.15;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // ── Ambient Loop Controller ───────────────────────────────────────────────
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _rippleAnimation = CurvedAnimation(
      parent: _ambientController,
      curve: Curves.easeInOut,
    );

    _rotationAnimation = CurvedAnimation(
      parent: _ambientController,
      curve: Curves.linear,
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ambientController, curve: Curves.easeInOutSine),
    );

    // ── Staggered Entrance Controller ─────────────────────────────────────────
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _emblemScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _emblemFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeIn),
      ),
    );

    _footerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
      ),
    );

    _entranceController.forward();

    // ── Start Dynamic Bootstrapping Sequence ──────────────────────────────────
    _bootstrapApplication();
  }

  Future<void> _bootstrapApplication() async {
    // Step 1: Initial secure handshake
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _statusMessage = 'Initializing secure cryptographic store...';
      _loadProgress = 0.45;
    });

    // Step 2: Check authentication credentials
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _statusMessage = 'Verifying Water User credentials...';
      _loadProgress = 0.75;
    });

    final secureStorage = sl<SecureStorageService>();
    final hasToken = await secureStorage.hasToken();

    // Step 3: Finalize and ready
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _statusMessage = 'System Ready';
      _loadProgress = 1.0;
    });

    // Step 4: Smooth transition
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    if (GoRouter.maybeOf(context) != null) {
      if (hasToken) {
        context.go('/');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _ambientController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );

    final bgColors = isDark
        ? const [Color(0xFF0F172A), Color(0xFF0B111E), Color(0xFF060A14)]
        : const [Color(0xFFFFFFFF), Color(0xFFF8FAFC), Color(0xFFF1F5F9)];

    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final badgeBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : AppColors.primary.withValues(alpha: 0.05);
    final badgeBorder = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : AppColors.primary.withValues(alpha: 0.14);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgColors,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Ambient water wave ripples (muted & theme-aware)
            WaterRippleBackground(animation: _rippleAnimation, isDark: isDark),

            // Foreground Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Top Government of India / Jal Shakti Header Badge
                    FadeTransition(
                      opacity: _footerFadeAnimation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: badgeBorder, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_balance_rounded,
                              size: 13,
                              color: isDark
                                  ? AppColors.gold
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'जल शक्ति अभियान  •  DEPARTMENT OF WATER RESOURCES',
                              style: context.badgeText
                                  .withColor(
                                    isDark ? Colors.white : AppColors.primary,
                                  )
                                  .withOpacity(isDark ? 0.85 : 0.90),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Central Animated Emblem (refined, cohesive)
                    FadeTransition(
                      opacity: _emblemFadeAnimation,
                      child: ScaleTransition(
                        scale: _emblemScaleAnimation,
                        child: WrdEmblem(
                          rotationAnimation: _rotationAnimation,
                          pulseAnimation: _pulseAnimation,
                          size: 140,
                          isDark: isDark,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Typography and Department Names
                    SlideTransition(
                      position: _textSlideAnimation,
                      child: FadeTransition(
                        opacity: _textFadeAnimation,
                        child: Column(
                          children: [
                            // Hindi Title
                            Text(
                              'जल संसाधन विभाग',
                              style: context.headlineSmall.bold
                                  .withColor(textColor)
                                  .withSpacing(0.4),
                            ),
                            const SizedBox(height: 4),

                            // English Main Title
                            Text(
                              'WATER USER ASSOCIATION',
                              style: context.titleMedium.extraBold
                                  .withColor(
                                    isDark ? Colors.white : AppColors.primary,
                                  )
                                  .withSpacing(1.6),
                            ),
                            const SizedBox(height: 10),

                            // Subtitle & Mission Statement
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: badgeBorder),
                              ),
                              child: Text(
                                'Irrigation Management  •  Water Distribution  •  Smart Billing',
                                textAlign: TextAlign.center,
                                style: context.labelSmall.medium
                                    .withColor(secondaryTextColor)
                                    .withSpacing(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 4),

                    // Dynamic Status & Progress Bar (single cohesive accent)
                    FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark
                                        ? AppColors.primaryLight
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _statusMessage,
                                style: context.bodySmall.medium.withColor(
                                  secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Muted Progress Track
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: 180,
                              height: 3.5,
                              child: Stack(
                                children: [
                                  Container(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : AppColors.primary.withValues(
                                            alpha: 0.08,
                                          ),
                                  ),
                                  AnimatedFractionallySizedBox(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOutCubic,
                                    widthFactor: _loadProgress,
                                    child: Container(
                                      color: isDark
                                          ? AppColors.primaryLight
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),

                    // Official Trust Footer
                    FadeTransition(
                      opacity: _footerFadeAnimation,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                size: 13,
                                color: secondaryTextColor.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '256-bit Encrypted Government Service Gateway',
                                style: context.labelSmall
                                    .withColor(secondaryTextColor)
                                    .withOpacity(0.7)
                                    .withSpacing(0.2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'WUA Mobile • v1.0.0',
                            style: context.labelSmall
                                .withSize(9)
                                .withColor(secondaryTextColor)
                                .withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
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
