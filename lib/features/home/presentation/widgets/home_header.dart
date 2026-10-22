import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:wua_mobile/shared/widgets/widgets.dart';

/// Deep teal executive header matching the regional WUA irrigation dashboard.
/// Sourced directly from [BuildContext.colors] without manual isDark checks.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    this.user,
    this.onNotificationPressed,
    this.showTopUtilities = false,
  });

  final UserEntity? user;
  final VoidCallback? onNotificationPressed;
  final bool showTopUtilities;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, 🙏';
    if (hour < 17) return 'Good Afternoon, 🙏';
    return 'Good Evening, 🙏';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;

    final displayName = user?.name.isNotEmpty == true
        ? user!.name
        : 'Ramesh Patil';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.headerBackground,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: MediaQuery.paddingOf(context).top + AppSpacing.sm,
          bottom: AppSpacing.lg,
        ),
        child: Row(
          children: [
            // Left: Avatar with green active dot + Farmer details
            Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () => context.push(RouteNames.profile),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.harvestAmber.withValues(alpha: 0.7),
                        width: 1.8,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.agriculture_rounded,
                        color: AppColors.harvestAmber,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.headerBackground,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: AppSpacing.sm),

            // User info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getGreeting(),
                    style: context.caption.white.withOpacity(0.85).withSize(12),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    displayName,
                    style: context.titleLarge.bold.white.withSize(18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gat No. 142 • Mulshi WUA',
                    style: context.caption
                        .withColor(colors.headerSubtitle)
                        .withSize(12)
                        .medium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Right: Notification Bell Button
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.headerActionBg,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed:
                    onNotificationPressed ??
                    () => context.push(RouteNames.notifications),
                tooltip: l10n.notifications,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.xs),

            // Right: Segmented Language Toggle [ En | MR ]
            const LanguageToggle(firstLabel: 'En', secondLabel: 'MR'),
          ],
        ),
      ),
    );
  }
}
