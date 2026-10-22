import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/shared/widgets/shared_widgets.dart';
import 'package:wua_mobile/shared/widgets/wua_app_bar.dart';

/// Global, executive custom [Scaffold] for WUA Mobile screens.
///
/// Standardizes page layout across the application:
/// - Automatic theme-aware background colors (Light / Dark)
/// - Integrated [WuaAppBar] with convenient one-line configurations
/// - Responsive max-width constraint for tablet/desktop/web centering (default 600dp)
/// - Optional pull-to-refresh ([onRefresh])
/// - Optional automated scrolling ([scrollable])
/// - Built-in feedback states: loading overlay ([isLoading]), error display ([errorMessage]),
///   and empty state ([isEmpty])
/// - Full design-token adherence using [AppSpacing], [AppColors], and typography
class WuaScaffold extends StatelessWidget {
  const WuaScaffold({
    super.key,
    required this.body,
    // AppBar configuration
    this.appBar,
    this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.showLanguageToggle = false,
    this.showNotificationAction = false,
    this.notificationCount = 0,
    this.onNotificationPressed,
    this.showProfileAvatar = false,
    this.avatarName,
    this.onProfilePressed,
    this.showBrandBadge = false,
    this.centerTitle,
    this.appBarBottom,
    this.hideAppBar = false,
    // Layout configuration
    this.useSafeArea = true,
    this.scrollable = false,
    this.scrollPhysics,
    this.padding,
    this.enableMaxConstraint = true,
    this.maxWidth = 600.0,
    this.onRefresh,
    // State feedback configuration
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.isEmpty = false,
    this.emptyMessage,
    this.emptyIcon,
    // Standard Scaffold options
    this.backgroundColor,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomSheet,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.systemUiOverlayStyle,
  });

  /// Main screen body content.
  final Widget body;

  // ─── AppBar Options ───────────────────────────────────────────
  /// Explicit [PreferredSizeWidget] override (e.g. custom [WuaAppBar]).
  final PreferredSizeWidget? appBar;

  /// Screen title text. Automatically creates a [WuaAppBar] if [appBar] is null.
  final String? title;

  /// Optional subtitle or department division text.
  final String? subtitle;

  /// Whether to display leading back button when screen can pop.
  final bool showBackButton;

  /// Custom back button callback.
  final VoidCallback? onBackPressed;

  /// Custom action widgets in app bar.
  final List<Widget>? actions;

  /// Whether to display English / हिन्दी toggle button.
  final bool showLanguageToggle;

  /// Whether to display notification bell action.
  final bool showNotificationAction;

  /// Badge count on notification bell.
  final int notificationCount;

  /// Notification bell tap callback.
  final VoidCallback? onNotificationPressed;

  /// Whether to display circular profile avatar.
  final bool showProfileAvatar;

  /// User name used to generate avatar initials.
  final String? avatarName;

  /// Avatar tap callback.
  final VoidCallback? onProfilePressed;

  /// Whether to display government WRD branding pill in app bar.
  final bool showBrandBadge;

  /// Center title alignment.
  final bool? centerTitle;

  /// Optional bottom widget for app bar (e.g. TabBar or search).
  final PreferredSizeWidget? appBarBottom;

  /// Set to true to suppress all AppBars.
  final bool hideAppBar;

  // ─── Layout Options ───────────────────────────────────────────
  /// Wrap body in [SafeArea]. Default is true.
  final bool useSafeArea;

  /// Automatically wrap content in a scroll view. Default is false.
  final bool scrollable;

  /// Custom scroll physics when [scrollable] is true or [onRefresh] is provided.
  final ScrollPhysics? scrollPhysics;

  /// Padding applied to content. Defaults to [AppSpacing.md] horizontal.
  final EdgeInsetsGeometry? padding;

  /// Constrain body width for clean centered presentation on wide viewports.
  final bool enableMaxConstraint;

  /// Maximum layout width when [enableMaxConstraint] is true. Default is 600.
  final double maxWidth;

  /// Optional pull-to-refresh handler. Automatically activates scroll physics.
  final Future<void> Function()? onRefresh;

  // ─── State Feedback Options ───────────────────────────────────
  /// Displays a non-blocking loading overlay when true.
  final bool isLoading;

  /// When not null/empty, replaces body with standardized [AppErrorWidget].
  final String? errorMessage;

  /// Retry callback triggered from error state.
  final VoidCallback? onRetry;

  /// When true, displays standardized [AppEmptyWidget].
  final bool isEmpty;

  /// Message displayed during empty state.
  final String? emptyMessage;

  /// Icon displayed during empty state.
  final IconData? emptyIcon;

  // ─── Scaffold Native Options ──────────────────────────────────
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomSheet;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final SystemUiOverlayStyle? systemUiOverlayStyle;

  PreferredSizeWidget? _resolveAppBar(BuildContext context) {
    if (hideAppBar) return null;
    if (appBar != null) return appBar;

    final hasConfig =
        title != null ||
        subtitle != null ||
        showBrandBadge ||
        showLanguageToggle ||
        showNotificationAction ||
        showProfileAvatar ||
        actions != null ||
        onBackPressed != null;

    if (hasConfig) {
      return WuaAppBar(
        title: title,
        subtitle: subtitle,
        showBackButton: showBackButton,
        onBackPressed: onBackPressed,
        actions: actions,
        showLanguageToggle: showLanguageToggle,
        showNotificationAction: showNotificationAction,
        notificationCount: notificationCount,
        onNotificationPressed: onNotificationPressed,
        showProfileAvatar: showProfileAvatar,
        avatarName: avatarName,
        onProfilePressed: onProfilePressed,
        showBrandBadge: showBrandBadge,
        centerTitle: centerTitle,
        bottom: appBarBottom,
      );
    }

    return null;
  }

  Widget _buildContent(BuildContext context) {
    // 1. Error state takes priority
    if (errorMessage != null && errorMessage!.trim().isNotEmpty) {
      return AppErrorWidget(message: errorMessage!, onRetry: onRetry);
    }

    // 2. Empty state
    if (isEmpty) {
      return AppEmptyWidget(
        message: emptyMessage ?? 'No records available.',
        icon: emptyIcon ?? Icons.inbox_outlined,
      );
    }

    // 3. Normal body content
    Widget content = body;

    final resolvedPadding =
        padding ??
        (scrollable || onRefresh != null
            ? const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              )
            : null);

    if (resolvedPadding != null) {
      content = Padding(padding: resolvedPadding, child: content);
    }

    // 4. Scroll view wrapping
    if (scrollable || onRefresh != null) {
      content = SingleChildScrollView(
        physics: scrollPhysics ?? const AlwaysScrollableScrollPhysics(),
        child: content,
      );
    }

    // 5. Pull-to-refresh
    if (onRefresh != null) {
      content = RefreshIndicator(
        onRefresh: onRefresh!,
        color: context.colors.primary,
        child: content,
      );
    }

    // 6. Responsive max-width constrain
    if (enableMaxConstraint) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      );
    }

    // 7. SafeArea wrapping
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    // 8. Loading overlay
    if (isLoading) {
      content = AppLoadingOverlay(isLoading: true, child: content);
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedBg = backgroundColor ?? colors.background;

    Widget scaffold = Scaffold(
      backgroundColor: resolvedBg,
      appBar: _resolveAppBar(context),
      body: _buildContent(context),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomSheet: bottomSheet,
      drawer: drawer,
      endDrawer: endDrawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );

    if (systemUiOverlayStyle != null) {
      scaffold = AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemUiOverlayStyle!,
        child: scaffold,
      );
    }

    return scaffold;
  }
}
