import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/radius.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';

class _ServiceItem {
  const _ServiceItem({
    required this.title,
    required this.icon,
    required this.iconBgColor,
    required this.route,
  });

  final String title;
  final IconData icon;
  final Color iconBgColor;
  final String route;
}

/// 4-column quick action grid matching the regional WUA Farmer Services row.
/// Sourced directly from [BuildContext.colors] without manual isDark checks.
class FarmerServicesGrid extends StatelessWidget {
  const FarmerServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final services = [
      const _ServiceItem(
        title: 'Pay Bill',
        icon: Icons.credit_card_rounded,
        iconBgColor: AppColors.headerTeal,
        route: RouteNames.bills,
      ),
      const _ServiceItem(
        title: 'Canal Wari',
        icon: Icons.schedule_rounded,
        iconBgColor: AppColors.canalGreen,
        route: RouteNames.waterUsage,
      ),
      const _ServiceItem(
        title: 'All Bills',
        icon: Icons.description_rounded,
        iconBgColor: Color(0xFFE65100),
        route: RouteNames.bills,
      ),
      const _ServiceItem(
        title: 'My Farm',
        icon: Icons.people_alt_rounded,
        iconBgColor: Color(0xFF0288D1),
        route: RouteNames.profile,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FARMER SERVICES',
          style: context.badgeText,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: services.map((service) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Material(
                  color: colors.serviceCardBg,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => context.push(service.route),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                        horizontal: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.serviceCardBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.serviceCardShadow,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: service.iconBgColor,
                              borderRadius: AppRadius.borderRadiusMd,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      service.iconBgColor.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              service.icon,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            service.title,
                            style: context.labelSmall.bold.withColor(
                              colors.serviceTitle,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
