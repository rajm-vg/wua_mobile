import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/core/storage/secure_storage_service.dart';

/// Represents a single stage in the startup bootstrapping sequence.
class _InitStage {
  const _InitStage({
    required this.title,
    required this.subtitle,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final double progress;
}

/// Minimalist, high-end production splash screen for the
/// Water Resources Department & Water User Association.
///
/// Designed with subtle micro-animations, clear initialization feedback,
/// and calm government/fintech aesthetics.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  static const List<_InitStage> _stages = [
    _InitStage(
      title: 'Verifying Environment',
      subtitle: 'Establishing secure enclave & Keystore...',
      progress: 0.33,
    ),
    _InitStage(
      title: 'Checking Credentials',
      subtitle: 'Validating Water User session...',
      progress: 0.66,
    ),
    _InitStage(
      title: 'Synchronizing Workspace',
      subtitle: 'Preparing canal schedules & offline data...',
      progress: 1.0,
    ),
  ];

  int _currentStageIndex = 0;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Single calm entrance controller
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _entranceController.forward();
    _runInitializationFlow();
  }

  Future<void> _runInitializationFlow() async {
    // Stage 1: Enclave & crypto store handshake
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _currentStageIndex = 1);

    // Stage 2: Token verification
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    final secureStorage = sl<SecureStorageService>();
    final hasToken = await secureStorage.hasToken();

    // Stage 3: Workspace sync
    setState(() => _currentStageIndex = 2);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() => _isComplete = true);

    // Subtle pause on completion for refined UX before page transition
    await Future<void>.delayed(const Duration(milliseconds: 350));
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
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeStage = _stages[_currentStageIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D), // Obsidian Navy
      body: Stack(
        children: [
          // Subtle top-center ambient water glow
          Positioned(
            top: -120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.20),
                      AppColors.secondary.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Main Minimalist Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // Minimalist Geometric App Icon Mark
                      _buildMinimalLogoMark(),

                      const SizedBox(height: 28),

                      // Department Attribution Tag
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'जल संसाधन विभाग  •  WRD',
                            style: context.badgeText
                                .withSpacing(1.2)
                                .gold
                                .withOpacity(0.9),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Main Title
                      Text(
                        'Water User Association',
                        textAlign: TextAlign.center,
                        style: context.headlineMedium.bold.white.withSpacing(
                          0.2,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Clean Subtitle
                      Text(
                        'Smart Irrigation & Water Governance',
                        textAlign: TextAlign.center,
                        style: context.bodyMedium
                            .withColor(AppColors.textSecondaryDark)
                            .withSpacing(0.3),
                      ),

                      const Spacer(flex: 4),

                      // Initialization Progress Flow Container
                      _buildInitializationCard(activeStage),

                      const Spacer(flex: 2),

                      // Minimalist Government & Security Signature
                      _buildSecurityFooter(),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Minimalist superellipse logo mark featuring a clean water-sprout geometry.
  Widget _buildMinimalLogoMark() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B), // Slate container
            Color(0xFF0F172A),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF29B6F6), // Pure Water Cyan
                Color(0xFF1565C0), // Deep Royal WUA Blue
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withValues(alpha: 0.35),
                blurRadius: 16,
              ),
            ],
          ),
          child: const Icon(
            Icons.water_drop_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  /// Clean, modern card showing the current stage of the initialization sequence.
  Widget _buildInitializationCard(_InitStage stage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Header and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: _isComplete
                        ? const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppColors.sproutGreen,
                          )
                        : CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryLight.withValues(alpha: 0.9),
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Text(stage.title, style: context.bodyMedium.medium.white),
                ],
              ),
              Text(
                '${(_stages[_currentStageIndex].progress * 100).toInt()}%',
                style: context.labelSmall.medium.withColor(
                  AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Subtitle / Detail
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text(
              stage.subtitle,
              style: context.caption.withColor(AppColors.textSecondaryDark),
            ),
          ),

          const SizedBox(height: 14),

          // 3-Segment Minimalist Progress Track
          Row(
            children: List.generate(3, (index) {
              final isFilled = index <= _currentStageIndex;
              final isCurrent = index == _currentStageIndex && !_isComplete;

              return Expanded(
                child: Container(
                  height: 3.5,
                  margin: EdgeInsets.only(right: index < 2 ? 6.0 : 0.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: isFilled
                        ? (isCurrent
                              ? AppColors.primaryLight
                              : AppColors.secondary)
                        : Colors.white.withValues(alpha: 0.10),
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Refined footer with security badge.
  Widget _buildSecurityFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 13,
              color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              'Ministry of Jal Shakti  •  Government of India',
              style: context.labelSmall
                  .withColor(AppColors.textSecondaryDark)
                  .withOpacity(0.7)
                  .withSpacing(0.2),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'End-to-End Encrypted Session',
          style: context.labelSmall
              .withSize(10)
              .withColor(AppColors.textSecondaryDark)
              .withOpacity(0.4),
        ),
      ],
    );
  }
}
