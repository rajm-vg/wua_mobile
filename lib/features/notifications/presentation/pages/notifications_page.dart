import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/colors.dart';
import 'package:wua_mobile/core/theme/spacing.dart';
import 'package:wua_mobile/core/theme/theme_extensions.dart';
import 'package:wua_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:wua_mobile/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:wua_mobile/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:wua_mobile/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:wua_mobile/features/notifications/presentation/widgets/notification_card.dart';
import 'package:wua_mobile/features/notifications/presentation/widgets/notification_card_skeleton.dart';
import 'package:wua_mobile/features/notifications/presentation/widgets/notifications_filter_chips.dart';
import 'package:wua_mobile/shared/widgets/wua_scaffold.dart';

/// Notifications screen for payment confirmations, bill due dates, and alerts.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationsBloc>(
      create: (context) =>
          sl<NotificationsBloc>()..add(const LoadNotificationsEvent()),
      child: const _NotificationsPageView(),
    );
  }
}

class _NotificationsPageView extends StatelessWidget {
  const _NotificationsPageView();

  Future<void> _onRefresh(BuildContext context) async {
    context.read<NotificationsBloc>().add(
      const LoadNotificationsEvent(refresh: true),
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  void _onNotificationTapped(
    BuildContext context,
    NotificationEntity notification,
  ) {
    if (!notification.isRead) {
      context.read<NotificationsBloc>().add(
        MarkNotificationAsReadEvent(notification.id),
      );
    }

    if (notification.actionRoute != null) {
      context.push(notification.actionRoute!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return WuaScaffold(
      title: l10n.notifications,
      subtitle: 'Bill Alerts & Payment Receipts • सूचना',
      showBackButton: true,
      scrollable: false,
      padding: EdgeInsets.zero,
      enableMaxConstraint: true,
      maxWidth: 800.0,
      actions: [
        BlocBuilder<NotificationsBloc, NotificationsState>(
          builder: (context, state) {
            final hasUnread =
                state is NotificationsLoaded && state.unreadCount > 0;
            if (!hasUnread) return const SizedBox.shrink();

            return TextButton.icon(
              onPressed: () {
                context.read<NotificationsBloc>().add(
                  const MarkAllNotificationsAsReadEvent(),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.markAllAsRead),
                    duration: const Duration(seconds: 2),
                    backgroundColor: AppColors.canalGreen,
                  ),
                );
              },
              icon: const Icon(
                Icons.done_all_rounded,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                l10n.markAllAsRead,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        IconButton(
          tooltip: l10n.refresh,
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () => _onRefresh(context),
        ),
      ],
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsInitial || state is NotificationsLoading) {
            return const NotificationCardSkeleton();
          }

          if (state is NotificationsError) {
            return _buildErrorState(context, state.message);
          }

          if (state is NotificationsLoaded) {
            return _buildLoadedContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: colors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Failed to load notifications',
              style: context.titleMedium.bold.withColor(colors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.caption.withColor(colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: () => _onRefresh(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.canalGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, NotificationsLoaded state) {
    final colors = context.colors;

    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      color: colors.canalGreen,
      child: Column(
        children: [
          // ─── Filter Chips & Status Bar ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: NotificationsFilterChips(
                    selectedFilter: state.selectedFilter,
                    unreadCount: state.unreadCount,
                    onFilterChanged: (filter) {
                      context.read<NotificationsBloc>().add(
                        FilterNotificationsEvent(filter),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ─── List of Notifications ─────────────────────────────────
          Expanded(
            child: state.filteredNotifications.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: state.filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final item = state.filteredNotifications[index];
                      return NotificationCard(
                        notification: item,
                        onTap: () => _onNotificationTapped(context, item),
                        onDismissed: () {
                          context.read<NotificationsBloc>().add(
                            DeleteNotificationEvent(item.id),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 38,
                color: colors.textSecondary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Notifications',
              style: context.titleMedium.bold.withColor(colors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'All caught up! Payment confirmations and seasonal bill alerts will appear here.',
              textAlign: TextAlign.center,
              style: context.caption.withColor(colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
