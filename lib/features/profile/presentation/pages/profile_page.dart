import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_event.dart';
import 'package:wua_mobile/features/authentication/presentation/bloc/auth_state.dart';
import 'package:wua_mobile/features/profile/presentation/widgets/app_settings_bottom_sheet.dart';
import 'package:wua_mobile/features/profile/presentation/widgets/change_password_bottom_sheet.dart';
import 'package:wua_mobile/features/profile/presentation/widgets/help_support_bottom_sheet.dart';
import 'package:wua_mobile/features/profile/presentation/widgets/my_profile_bottom_sheet.dart';
import 'package:wua_mobile/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:wua_mobile/shared/widgets/wua_scaffold.dart';

/// Regional WUA Profile & Account management screen.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>()..add(const AuthCheckRequested()),
      child: const _ProfilePageView(),
    );
  }
}

class _ProfilePageView extends StatelessWidget {
  const _ProfilePageView();

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'RP';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed
        .substring(0, trimmed.length > 2 ? 2 : trimmed.length)
        .toUpperCase();
  }

  void _showLogoutDialog(BuildContext context) {
    final colors = context.colors;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: context.titleLarge.bold.withColor(colors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to log out of your WUA account?',
          style: context.bodyMedium.regular.withColor(colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go(RouteNames.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final displayName = user?.name.isNotEmpty == true ? user!.name : 'User';
        final initials = _getInitials(displayName);

        return WuaScaffold(
          title: 'Profile',
          useSafeArea: true,
          padding: EdgeInsets.zero,
          scrollable: true,
          systemUiOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: colors.headerBackground,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 28),

              // 1. Avatar Circle & Farmer Details
              _ProfileHeroAvatar(initials: initials, displayName: displayName),

              const SizedBox(height: 24),

              // 2. Menu Options Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      children: [
                        // My Profile
                        ProfileMenuItem(
                          icon: Icons.person_outline_rounded,
                          title: 'My Profile',
                          onTap: () =>
                              MyProfileBottomSheet.show(context, user: user),
                        ),

                        // Change Password
                        ProfileMenuItem(
                          icon: Icons.lock_outline_rounded,
                          title: 'Change Password',
                          onTap: () => ChangePasswordBottomSheet.show(context),
                        ),

                        // Language / भाषा
                        ValueListenableBuilder<Locale?>(
                          valueListenable: appLocaleNotifier,
                          builder: (context, currentLocale, _) {
                            final isMarathi =
                                currentLocale?.languageCode == 'mr' ||
                                currentLocale?.languageCode == 'hi';
                            return ProfileMenuItem(
                              icon: Icons.language_rounded,
                              title: 'Language / भाषा',
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isMarathi ? 'मराठी' : 'English',
                                    style: context.bodySmall.medium.withColor(
                                      colors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 20,
                                    color: colors.textSecondary.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => context.toggleLocale(),
                            );
                          },
                        ),

                        // Notifications
                        ProfileMenuItem(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          onTap: () {
                            try {
                              context.pushNamed(RouteNames.notifications);
                            } catch (_) {
                              context.push('/notifications');
                            }
                          },
                        ),

                        // App Settings
                        ProfileMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'App Settings',
                          onTap: () => AppSettingsBottomSheet.show(context),
                        ),

                        // Help & Support
                        ProfileMenuItem(
                          icon: Icons.help_outline_rounded,
                          title: 'Help & Support',
                          onTap: () => HelpSupportBottomSheet.show(context),
                        ),

                        // Logout
                        ProfileMenuItem(
                          icon: Icons.logout_rounded,
                          iconColor: const Color(0xFFEF4444),
                          title: 'Logout',
                          titleColor: const Color(0xFFEF4444),
                          trailing: const SizedBox.shrink(),
                          showDivider: false,
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom spacing for floating navigation bar
              const SizedBox(height: 104),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeroAvatar extends StatelessWidget {
  const _ProfileHeroAvatar({required this.initials, required this.displayName});

  final String initials;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        // Circular Avatar
        Container(
          width: 92,
          height: 92,
          decoration: const BoxDecoration(
            color: Color(0xFFE2EEF1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2C4A56),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Farmer Name
        Text(
          displayName,
          style: context.titleMedium.bold
              .withColor(colors.textPrimary)
              .copyWith(fontSize: 18),
        ),
        const SizedBox(height: 4),

        // WUA Role
        const Text(
          'WUA_FARMER_MEMBER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B8B9B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),

        // Association & Sub-basin location
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Mulshi Water User Association (Bhima Sub-Basin), Pune',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
