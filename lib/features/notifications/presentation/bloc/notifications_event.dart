import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationsEvent {
  const LoadNotificationsEvent({this.refresh = false});

  final bool refresh;

  @override
  List<Object?> get props => [refresh];
}

class FilterNotificationsEvent extends NotificationsEvent {
  const FilterNotificationsEvent(this.filter);

  final String filter;

  @override
  List<Object?> get props => [filter];
}

class MarkNotificationAsReadEvent extends NotificationsEvent {
  const MarkNotificationAsReadEvent(this.notificationId);

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsReadEvent extends NotificationsEvent {
  const MarkAllNotificationsAsReadEvent();
}

class DeleteNotificationEvent extends NotificationsEvent {
  const DeleteNotificationEvent(this.notificationId);

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class ClearAllNotificationsEvent extends NotificationsEvent {
  const ClearAllNotificationsEvent();
}

