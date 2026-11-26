import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/core/network/api_endpoints.dart';
import 'package:wua_mobile/features/notifications/data/models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({bool forceRefresh = false});
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> clearAll();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<List<NotificationModel>> getNotifications({
    bool forceRefresh = false,
  }) async {
    try {
      final response = await apiClient.get<List<dynamic>>(
        ApiEndpoints.notifications,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data!
            .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      AppLogger.warning(
        'Notifications API unavailable or empty ($e), returning empty list.',
      );
    }

    return const <NotificationModel>[];
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await apiClient.post<dynamic>(
        '${ApiEndpoints.markNotificationRead}/$notificationId',
      );
    } catch (e) {
      AppLogger.warning('Mark notification API error ($e)');
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await apiClient.post<dynamic>(ApiEndpoints.markNotificationRead);
    } catch (e) {
      AppLogger.warning('Mark all notifications API error ($e)');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await apiClient.delete<dynamic>(
        '${ApiEndpoints.notifications}/$notificationId',
      );
    } catch (e) {
      AppLogger.warning('Delete notification API error ($e)');
      rethrow;
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await apiClient.delete<dynamic>(ApiEndpoints.notifications);
    } catch (e) {
      AppLogger.warning('Clear notifications API error ($e)');
      rethrow;
    }
  }
}

