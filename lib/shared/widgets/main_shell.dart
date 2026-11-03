import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Persistent shell container providing the floating bottom navigation bar.
/// Sourced directly from [BuildContext.colors] without manual isDark checks.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final config = GoRouter.of(context).routerDelegate.currentConfiguration;
    final location = config.lastOrNull?.matchedLocation ?? config.uri.path;
    final normalized = location.startsWith('/') ? location : '/$location';

    if (normalized.startsWith('/bills')) {
      return 1;
    }
    if (normalized.startsWith('/payments') ||
        normalized.startsWith('/transactions')) {
      return 2;
    }
    if (normalized.startsWith('/profile')) {
      return 3;
    }
    return 0; // Default to Dashboard (Home)
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/bills');
        break;
      case 2:
        context.go('/payments');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GoRouter.of(context).routerDelegate,
      builder: (context, _) {
        final colors = context.colors;
        final l10n = context.l10n;
        final selectedIndex = _calculateSelectedIndex(context);

        return Scaffold(
          backgroundColor: colors.background,
          extendBody: true,
          body: child,
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: colors.navBarBg,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: colors.navBarBorder),
                  boxShadow: [
                    BoxShadow(
                      color: colors.navBarShadow,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.grid_view_rounded,
                      label: l10n.navDashboard,
                      isSelected: selectedIndex == 0,
                      onTap: () => _onItemTapped(0, context),
                    ),
                    _NavItem(
                      icon: Icons.credit_card_outlined,
                      label: l10n.navBills,
                      isSelected: selectedIndex == 1,
                      onTap: () => _onItemTapped(1, context),
                    ),
                    _NavItem(
                      icon: Icons.receipt_long_rounded,
                      label: l10n.navPayments,
                      isSelected: selectedIndex == 2,
                      onTap: () => _onItemTapped(2, context),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      label: l10n.navProfile,
                      isSelected: selectedIndex == 3,
                      onTap: () => _onItemTapped(3, context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeColor = colors.navBarActive;
    final inactiveColor = colors.navBarInactive;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: (isSelected ? context.labelSmall.bold : context.caption)
                  .withColor(isSelected ? activeColor : inactiveColor)
                  .withSize(11),
            ),
          ],
        ),
      ),
    );
  }
}
