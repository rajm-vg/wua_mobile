import 'package:equatable/equatable.dart';
import 'package:wua_mobile/features/notifications/domain/entities/notification_entity.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded({
    required this.allNotifications,
    required this.filteredNotifications,
    this.selectedFilter = 'ALL',
  });

  final List<NotificationEntity> allNotifications;
  final List<NotificationEntity> filteredNotifications;
  final String selectedFilter;

  int get unreadCount => allNotifications.where((n) => !n.isRead).length;

  NotificationsLoaded copyWith({
    List<NotificationEntity>? allNotifications,
    List<NotificationEntity>? filteredNotifications,
    String? selectedFilter,
  }) {
    return NotificationsLoaded(
      allNotifications: allNotifications ?? this.allNotifications,
      filteredNotifications:
          filteredNotifications ?? this.filteredNotifications,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [
        allNotifications,
        filteredNotifications,
        selectedFilter,
      ];
}

class NotificationsError extends NotificationsState {
  const NotificationsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

