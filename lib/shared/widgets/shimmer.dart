import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Direction in which the shimmer highlight travels.
enum ShimmerDirection {
  ltr,
  rtl,
  ttb,
  btt;

  Alignment get begin {
    switch (this) {
      case ShimmerDirection.ltr:
        return const Alignment(-1.0, -0.3);
      case ShimmerDirection.rtl:
        return const Alignment(1.0, 0.3);
      case ShimmerDirection.ttb:
        return const Alignment(-0.3, -1.0);
      case ShimmerDirection.btt:
        return const Alignment(0.3, 1.0);
    }
  }

  Alignment get end {
    switch (this) {
      case ShimmerDirection.ltr:
        return const Alignment(1.0, 0.3);
      case ShimmerDirection.rtl:
        return const Alignment(-1.0, -0.3);
      case ShimmerDirection.ttb:
        return const Alignment(0.3, 1.0);
      case ShimmerDirection.btt:
        return const Alignment(-0.3, -1.0);
    }
  }
}

/// Internal Matrix4 gradient transform for smooth GPU hardware-accelerated shimmer.
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
    required this.direction,
  });

  final double slidePercent;
  final ShimmerDirection direction;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    switch (direction) {
      case ShimmerDirection.ltr:
        return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
      case ShimmerDirection.rtl:
        return Matrix4.translationValues(-bounds.width * slidePercent, 0.0, 0.0);
      case ShimmerDirection.ttb:
        return Matrix4.translationValues(0.0, bounds.height * slidePercent, 0.0);
      case ShimmerDirection.btt:
        return Matrix4.translationValues(0.0, -bounds.height * slidePercent, 0.0);
    }
  }
}

/// Scope inherited widget for synchronized nested shimmer elements.
class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({
    required this.baseColor,
    required this.highlightColor,
    required this.enabled,
    required super.child,
  });

  final Color baseColor;
  final Color highlightColor;
  final bool enabled;

  @override
  bool updateShouldNotify(_ShimmerScope oldWidget) {
    return baseColor != oldWidget.baseColor ||
        highlightColor != oldWidget.highlightColor ||
        enabled != oldWidget.enabled;
  }
}

/// A custom, high-performance shimmer widget that applies a sweeping gradient
/// effect over its child widget tree.
///
/// Features:
/// - Theme-aware default colors (light/dark mode)
/// - GPU-accelerated [ShaderMask] with matrix translation
/// - Synchronized shimmer for all nested shapes ([ShimmerContainer], [ShimmerCircle], etc.)
/// - Configurable sweep direction, duration, and enable/disable toggle.
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.ltr,
    this.enabled = true,
  });

  /// Factory constructor matching familiar flutter_shimmer pattern.
  const Shimmer.fromColors({
    super.key,
    required this.child,
    required Color baseColor,
    required Color highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.direction = ShimmerDirection.ltr,
    this.enabled = true,
  })  : baseColor = baseColor,
        highlightColor = highlightColor;

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final ShimmerDirection direction;
  final bool enabled;

  /// Default theme-aware base color.
  static Color defaultBaseColor(BuildContext context) {
    return context.isDarkMode
        ? const Color(0xFF16343C)
        : AppColors.surfaceVariantLight;
  }

  /// Default theme-aware highlight color.
  static Color defaultHighlightColor(BuildContext context) {
    return context.isDarkMode
        ? const Color(0xFF285461)
        : const Color(0xFFFFFFFF).withValues(alpha: 0.7);
  }

  /// Checks if the widget tree is currently inside an active [Shimmer] scope.
  static bool isInsideShimmer(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ShimmerScope>() != null;
  }

  /// Retrieves the ambient [_ShimmerScope] if available.
  static _ShimmerScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ShimmerScope>();
  }

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final effectiveBase = widget.baseColor ?? Shimmer.defaultBaseColor(context);
    final effectiveHighlight =
        widget.highlightColor ?? Shimmer.defaultHighlightColor(context);

    return _ShimmerScope(
      baseColor: effectiveBase,
      highlightColor: effectiveHighlight,
      enabled: widget.enabled,
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) {
              if (bounds.isEmpty) {
                return const LinearGradient(
                  colors: [Colors.transparent, Colors.transparent],
                ).createShader(bounds);
              }

              return LinearGradient(
                begin: widget.direction.begin,
                end: widget.direction.end,
                colors: [
                  effectiveBase,
                  effectiveHighlight,
                  effectiveBase,
                ],
                stops: const [0.1, 0.5, 0.9],
                transform: _SlidingGradientTransform(
                  slidePercent: _controller.value * 3.0 - 1.5,
                  direction: widget.direction,
                ),
              ).createShader(bounds);
            },
            child: child,
          );
        },
      ),
    );
  }
}

/// A rectangular or rounded container placeholder that automatically synchronizes
/// with any parent [Shimmer] scope, or animates itself if used standalone.
class ShimmerContainer extends StatelessWidget {
  const ShimmerContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.margin,
    this.padding,
    this.baseColor,
    this.highlightColor,
  });

  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape shape;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final scope = Shimmer.maybeOf(context);
    final effectiveBase = baseColor ?? scope?.baseColor ?? Shimmer.defaultBaseColor(context);
    final effectiveHighlight =
        highlightColor ?? scope?.highlightColor ?? Shimmer.defaultHighlightColor(context);

    final box = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBase,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(8)),
      ),
    );

    // If an ancestor Shimmer is managing the sweep, render the solid shape.
    if (scope != null) {
      return box;
    }

    // Standalone fallback: self-contained shimmer.
    return Shimmer(
      baseColor: effectiveBase,
      highlightColor: effectiveHighlight,
      child: box,
    );
  }
}

/// A circular placeholder widget, ideal for avatars, circular icons, and indicators.
class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({
    super.key,
    required this.size,
    this.margin,
    this.baseColor,
    this.highlightColor,
  });

  /// Diameter of the circle.
  final double size;
  final EdgeInsetsGeometry? margin;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      width: size,
      height: size,
      shape: BoxShape.circle,
      margin: margin,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }
}

/// A text-line placeholder widget simulating lines of content.
class ShimmerText extends StatelessWidget {
  const ShimmerText({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
    this.margin,
    this.baseColor,
    this.highlightColor,
  });

  final double? width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return ShimmerContainer(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(4),
      margin: margin,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }
}

/// A card placeholder matching the design system's border, padding, and background tokens.
/// The card wrapper maintains its frame and background, while children shimmer in unison.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.cardBackground,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? colors.cardBorder,
        ),
      ),
      child: Shimmer(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: child,
      ),
    );
  }
}

/// Helper widget to generate a list of shimmer skeleton items.
class ShimmerList extends StatelessWidget {
  const ShimmerList({
    super.key,
    this.itemCount = 4,
    required this.itemBuilder,
    this.separator,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget? separator;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      separatorBuilder: (context, index) =>
          separator ?? const SizedBox(height: AppSpacing.sm),
      itemBuilder: itemBuilder,
    );
  }
}

/// Conditional switcher that displays a [skeleton] when [isLoading] is true,
/// and fades in the actual [child] when [isLoading] is false.
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    super.key,
    required this.isLoading,
    required this.skeleton,
    required this.child,
    this.animateTransition = true,
    this.transitionDuration = const Duration(milliseconds: 250),
  });

  final bool isLoading;
  final Widget skeleton;
  final Widget child;
  final bool animateTransition;
  final Duration transitionDuration;

  @override
  Widget build(BuildContext context) {
    if (!animateTransition) {
      return isLoading ? skeleton : child;
    }

    return AnimatedSwitcher(
      duration: transitionDuration,
      child: isLoading
          ? KeyedSubtree(
              key: const ValueKey('shimmer_skeleton'),
              child: skeleton,
            )
          : KeyedSubtree(
              key: const ValueKey('shimmer_content'),
              child: child,
            ),
    );
  }
}

