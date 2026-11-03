import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

/// Single interactive row entry within the profile options card.
class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.titleColor,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final effectiveIconColor = iconColor ?? colors.textSecondary;
    final effectiveTitleColor = titleColor ?? colors.textPrimary;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 21,
                    color: effectiveIconColor,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: context.bodyMedium.medium.withColor(
                        effectiveTitleColor,
                      ),
                    ),
                  ),
                  trailing ??
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: colors.textSecondary.withValues(alpha: 0.6),
                      ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: colors.divider.withValues(alpha: 0.35),
          ),
      ],
    );
  }
}
