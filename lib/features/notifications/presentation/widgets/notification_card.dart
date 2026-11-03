import 'package:flutter/material.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/notifications/domain/entities/notification_entity.dart';

/// Card displaying an individual notification item with category badge and action button.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismissed,
  });

  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  Color _getIconBgColor(BuildContext context) {
    switch (notification.type) {
      case NotificationType.paymentSuccess:
      case NotificationType.paymentReceipt:
        return const Color(0xFFE8F5E9);
      case NotificationType.billOverdue:
      case NotificationType.paymentFailed:
        return const Color(0xFFFFEBEE);
      case NotificationType.billDue:
        return const Color(0xFFFFF8E1);
      case NotificationType.billGenerated:
        return const Color(0xFFE3F2FD);
      default:
        return context.colors.surfaceVariant;
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (notification.type) {
      case NotificationType.paymentSuccess:
      case NotificationType.paymentReceipt:
        return AppColors.canalGreen;
      case NotificationType.billOverdue:
      case NotificationType.paymentFailed:
        return AppColors.error;
      case NotificationType.billDue:
        return AppColors.harvestAmber;
      case NotificationType.billGenerated:
        return AppColors.info;
      default:
        return context.colors.textSecondary;
    }
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.paymentSuccess:
        return Icons.check_circle_rounded;
      case NotificationType.paymentReceipt:
        return Icons.receipt_long_rounded;
      case NotificationType.paymentFailed:
        return Icons.cancel_rounded;
      case NotificationType.billOverdue:
        return Icons.warning_amber_rounded;
      case NotificationType.billDue:
        return Icons.access_time_rounded;
      case NotificationType.billGenerated:
        return Icons.description_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    final iconBgColor = isDark
        ? _getIconColor(context).withValues(alpha: 0.15)
        : _getIconBgColor(context);
    final iconColor = _getIconColor(context);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: notification.isRead
              ? colors.cardBackground
              : (isDark ? const Color(0xFF132D34) : const Color(0xFFF0FDF9)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? colors.cardBorder
                : colors.canalGreen.withValues(alpha: 0.4),
            width: notification.isRead ? 1.0 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Leading Icon ─────────────────────────────────
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getIcon(), size: 22, color: iconColor),
                  ),

                  const SizedBox(width: AppSpacing.sm),

                  // ─── Center Content ───────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + Unread Indicator
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: (notification.isRead
                                        ? context.bodyMedium.semiBold
                                        : context.bodyMedium.bold)
                                    .withColor(colors.textPrimary),
                              ),
                            ),
                            if (!notification.isRead) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: colors.canalGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Message body
                        Text(
                          notification.message,
                          style: context.bodySmall.withColor(
                            colors.textSecondary,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        // Bottom row: Amount & Reference ID & Timestamp
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (notification.amount != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '₹${notification.amount!.toStringAsFixed(notification.amount! % 1 == 0 ? 0 : 2)}',
                                  style: context.caption.bold.withColor(
                                    colors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                            if (notification.referenceId != null) ...[
                              Text(
                                notification.referenceId!,
                                style: context.caption.semiBold.withColor(
                                  colors.textSecondary,
                                ),
                              ),
                              Text(
                                '•',
                                style: context.caption.withColor(
                                  colors.textSecondary,
                                ),
                              ),
                            ],
                            Text(
                              notification.timeAgo,
                              style: context.caption.withColor(
                                colors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ─── Trailing Arrow ───────────────────────────────
                  if (notification.actionRoute != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: colors.textSecondary.withValues(alpha: 0.5),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

