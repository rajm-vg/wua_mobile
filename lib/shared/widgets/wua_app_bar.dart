import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/shared/widgets/language_toggle.dart';

/// Global, executive custom [AppBar] for Water User Association application.
/// Sourced directly from [BuildContext.colors] without manual isDark checks.
class WuaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WuaAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.titleWidget,
    this.subtitleWidget,
    this.leading,
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
    this.backgroundColor,
    this.elevation = 0,
    this.useGradient = false,
    this.showBottomDivider = true,
    this.bottom,
    this.toolbarHeight = kToolbarHeight,
  });

  /// Factory constructor for the main Dashboard/Home screen header.
  factory WuaAppBar.home({
    Key? key,
    String? title,
    String? subtitle,
    String? userName,
    int notificationCount = 0,
    VoidCallback? onNotificationPressed,
    VoidCallback? onProfilePressed,
    PreferredSizeWidget? bottom,
  }) {
    return WuaAppBar(
      key: key,
      title: title ?? 'WUA Portal',
      subtitle: subtitle,
      showBrandBadge: true,
      showBackButton: false,
      showLanguageToggle: true,
      showNotificationAction: true,
      notificationCount: notificationCount,
      onNotificationPressed: onNotificationPressed,
      showProfileAvatar: true,
      avatarName: userName,
      onProfilePressed: onProfilePressed,
      centerTitle: false,
      bottom: bottom,
    );
  }

  /// Convenient pre-configured constructor for nested detail screens with back button.
  factory WuaAppBar.nested({
    Key? key,
    required String title,
    String? subtitle,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    PreferredSizeWidget? bottom,
  }) {
    return WuaAppBar(
      key: key,
      title: title,
      subtitle: subtitle,
      showBackButton: true,
      onBackPressed: onBackPressed,
      actions: actions,
      centerTitle: true,
      bottom: bottom,
    );
  }

  final String? title;
  final String? subtitle;
  final Widget? titleWidget;
  final Widget? subtitleWidget;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool showLanguageToggle;
  final bool showNotificationAction;
  final int notificationCount;
  final VoidCallback? onNotificationPressed;
  final bool showProfileAvatar;
  final String? avatarName;
  final VoidCallback? onProfilePressed;
  final bool showBrandBadge;
  final bool? centerTitle;
  final Color? backgroundColor;
  final double elevation;
  final bool useGradient;
  final bool showBottomDivider;
  final PreferredSizeWidget? bottom;
  final double toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(
        toolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'U';
    final clean = name.trim();
    final parts = clean.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return clean[0].toUpperCase();
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (!showBackButton) return null;

    final canPop = Navigator.of(context).canPop();
    if (!canPop && onBackPressed == null) return null;

    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.sm),
        child: InkWell(
          onTap: onBackPressed ?? () => Navigator.of(context).maybePop(),
          borderRadius: AppRadius.borderRadiusFull,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.cardBorder,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.cardBorder,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildTitle(BuildContext context) {
    if (titleWidget != null) return titleWidget;

    if (title == null && !showBrandBadge) return null;

    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: (centerTitle ?? false)
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (showBrandBadge) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.water_drop_rounded,
                size: 13,
                color: AppColors.waterCyan,
              ),
              const SizedBox(width: AppSpacing.xxxs),
              Text(
                'WRD • WUA',
                style: context.badgeText.withSize(10).withColor(
                      colors.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 2),
        ],
        if (title != null)
          Text(
            title!,
            style: context.titleMedium.semiBold.withColor(
              colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (subtitleWidget != null) ...[
          const SizedBox(height: 1),
          subtitleWidget!,
        ] else if (subtitle != null) ...[
          const SizedBox(height: 1),
          Text(
            subtitle!,
            style: context.caption.withSize(11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final colors = context.colors;
    final actionList = <Widget>[];

    // Language switcher toggle button
    if (showLanguageToggle) {
      actionList.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: LanguageToggle.standard(
              firstLabel: 'En',
              secondLabel: 'हिन्दी',
            ),
          ),
        ),
      );
    }

    // Notification action with badge
    if (showNotificationAction) {
      actionList.add(
        IconButton(
          onPressed: onNotificationPressed ??
              () => context.push(RouteNames.notifications),
          tooltip: context.l10n.notifications,
          icon: Badge(
            isLabelVisible: notificationCount > 0,
            label: Text(
              '$notificationCount',
              style: context.labelSmall.withSize(9).bold.white,
            ),
            backgroundColor: AppColors.error,
            smallSize: 8,
            child: Icon(
              Icons.notifications_none_rounded,
              size: 22,
              color: colors.textPrimary,
            ),
          ),
        ),
      );
    }

    // User Avatar
    if (showProfileAvatar) {
      actionList.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: GestureDetector(
            onTap: onProfilePressed ?? () => context.push(RouteNames.profile),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colors.primary,
                    colors.waterCyan,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _getInitials(avatarName),
                  style: context.labelSmall.bold.white,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Custom passed actions
    if (actions != null) {
      actionList.addAll(actions!);
    }

    if (actionList.isNotEmpty) {
      actionList.add(const SizedBox(width: AppSpacing.xs));
    }

    return actionList;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedBg = backgroundColor ?? colors.surface;

    return Container(
      decoration: BoxDecoration(
        color: useGradient ? null : resolvedBg,
        gradient: useGradient
            ? LinearGradient(
                colors: [colors.primary, colors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: showBottomDivider
            ? Border(
                bottom: BorderSide(
                  color: colors.divider,
                ),
              )
            : null,
      ),
      child: AppBar(
        title: _buildTitle(context),
        leading: _buildLeading(context),
        actions: _buildActions(context),
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        elevation: elevation,
        scrolledUnderElevation: 0,
        bottom: bottom,
        toolbarHeight: toolbarHeight,
      ),
    );
  }
}
