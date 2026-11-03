import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:wua_mobile/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:wua_mobile/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:wua_mobile/features/notifications/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:wua_mobile/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:wua_mobile/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:wua_mobile/features/notifications/presentation/bloc/notifications_state.dart';

class NotificationsBloc
    extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
    required this.markAllNotificationsReadUseCase,
    required this.deleteNotificationUseCase,
  }) : super(const NotificationsInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<FilterNotificationsEvent>(_onFilterNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllNotificationsAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<ClearAllNotificationsEvent>(_onClearAllNotifications);
  }

  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase markAllNotificationsReadUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;

  List<NotificationEntity> _cachedNotifications = [];
  String _activeFilter = 'ALL';

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    if (!event.refresh && state is! NotificationsLoaded) {
      emit(const NotificationsLoading());
    }

    AppLogger.bloc('⚡ [NOTIFICATIONS BLOC] Loading notifications (refresh: ${event.refresh})');

    final result = await getNotificationsUseCase(
      GetNotificationsParams(forceRefresh: event.refresh),
    );

    result.fold(
      (failure) {
        AppLogger.error('❌ [NOTIFICATIONS BLOC] Error: ${failure.message}');
        emit(NotificationsError(failure.message));
      },
      (notifications) {
        _cachedNotifications = notifications;
        final filtered = _applyFilter(_cachedNotifications, _activeFilter);
        emit(
          NotificationsLoaded(
            allNotifications: _cachedNotifications,
            filteredNotifications: filtered,
            selectedFilter: _activeFilter,
          ),
        );
      },
    );
  }

  void _onFilterNotifications(
    FilterNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) {
    _activeFilter = event.filter;
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final filtered = _applyFilter(currentState.allNotifications, event.filter);
      emit(
        currentState.copyWith(
          selectedFilter: event.filter,
          filteredNotifications: filtered,
        ),
      );
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updated = currentState.allNotifications.map((n) {
        if (n.id == event.notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      _cachedNotifications = updated;
      final filtered = _applyFilter(updated, _activeFilter);
      emit(
        currentState.copyWith(
          allNotifications: updated,
          filteredNotifications: filtered,
        ),
      );

      await markNotificationReadUseCase(
        MarkNotificationReadParams(event.notificationId),
      );
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updated = currentState.allNotifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();

      _cachedNotifications = updated;
      final filtered = _applyFilter(updated, _activeFilter);
      emit(
        currentState.copyWith(
          allNotifications: updated,
          filteredNotifications: filtered,
        ),
      );

      await markAllNotificationsReadUseCase(const NoParams());
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      final updated = currentState.allNotifications
          .where((n) => n.id != event.notificationId)
          .toList();

      _cachedNotifications = updated;
      final filtered = _applyFilter(updated, _activeFilter);
      emit(
        currentState.copyWith(
          allNotifications: updated,
          filteredNotifications: filtered,
        ),
      );

      await deleteNotificationUseCase(
        DeleteNotificationParams(event.notificationId),
      );
    }
  }

  Future<void> _onClearAllNotifications(
    ClearAllNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationsLoaded) {
      _cachedNotifications = [];
      emit(
        currentState.copyWith(
          allNotifications: [],
          filteredNotifications: [],
        ),
      );
    }
  }

  List<NotificationEntity> _applyFilter(
    List<NotificationEntity> list,
    String filter,
  ) {
    switch (filter) {
      case 'UNREAD':
        return list.where((n) => !n.isRead).toList();
      case 'BILLS':
        return list.where((n) => n.category == NotificationCategory.bill).toList();
      case 'PAYMENTS':
        return list
            .where((n) => n.category == NotificationCategory.payment)
            .toList();
      case 'ALL':
      default:
        return list;
    }
  }
}

