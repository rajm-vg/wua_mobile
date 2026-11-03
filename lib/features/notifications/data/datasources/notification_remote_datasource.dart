import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/core/network/api_endpoints.dart';
import 'package:wua_mobile/features/notifications/data/models/notification_model.dart';
import 'package:wua_mobile/features/notifications/domain/entities/notification_entity.dart';

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

  // In-memory simulated notifications focused on payments & bills
  late final List<NotificationModel> _mockNotifications = [
    NotificationModel(
      id: 'notif_01',
      title: 'Payment Received • भरणा यशस्वी',
      message:
          'Payment of ₹2,360 for Kharif Season (2024-25) pani patti has been received successfully. Receipt #REC/2024-25/0192 is ready.',
      type: NotificationType.paymentSuccess,
      category: NotificationCategory.payment,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      actionRoute: '/payments',
      referenceId: 'TXN-2024-88912',
      amount: 2360.0,
    ),
    NotificationModel(
      id: 'notif_02',
      title: 'New Pani Patti Bill • नवीन बिल',
      message:
          'Bill WUA/PANI/2024-25/0842 for ₹1,240 (4.5 Acres Wheat & Gram) is generated. Due date: 25 Nov 2026.',
      type: NotificationType.billGenerated,
      category: NotificationCategory.bill,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
      actionRoute: '/bills',
      referenceId: 'WUA/PANI/2024-25/0842',
      amount: 1240.0,
    ),
    NotificationModel(
      id: 'notif_03',
      title: 'Maintenance Cess Overdue • थकबाकी सूचना',
      message:
          '₹380 for Annual Canal Desilting & Sluice Gate Cess is overdue. Please clear dues to prevent rotational turn interruption.',
      type: NotificationType.billOverdue,
      category: NotificationCategory.bill,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: false,
      actionRoute: '/bills',
      referenceId: 'WUA/CESS/2024/0119',
      amount: 380.0,
    ),
    NotificationModel(
      id: 'notif_04',
      title: 'UPI Payment Failed • व्यवहार अयशस्वी',
      message:
          'Online payment of ₹1,240 via UPI failed due to a bank gateway timeout. If debited, amount will be refunded within 48 hours.',
      type: NotificationType.paymentFailed,
      category: NotificationCategory.payment,
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      isRead: true,
      actionRoute: '/payments',
      referenceId: 'UPI-FAIL-49021',
      amount: 1240.0,
    ),
    NotificationModel(
      id: 'notif_05',
      title: 'Advance Deposit Credited • पावती तयार',
      message:
          'Advance Canal Rotation Deposit of ₹1,500 has been credited to your WUA member passbook account.',
      type: NotificationType.paymentReceipt,
      category: NotificationCategory.payment,
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      isRead: true,
      actionRoute: '/payments',
      referenceId: 'REC/ADV/2024-0041',
      amount: 1500.0,
    ),
    NotificationModel(
      id: 'notif_06',
      title: 'Prompt Payment Rebate Applied • ५% सवलत',
      message:
          'Early bird discount of ₹62.00 was applied to your account for prompt clearance before the deadline.',
      type: NotificationType.paymentSuccess,
      category: NotificationCategory.payment,
      timestamp: DateTime.now().subtract(const Duration(days: 12)),
      isRead: true,
      actionRoute: '/bills',
      referenceId: 'DISC-2024-RABI',
      amount: 62.0,
    ),
  ];

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
        'Notifications API unavailable ($e), serving simulated payments/bills notification dataset.',
      );
    }

    return List.unmodifiable(_mockNotifications);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await apiClient.post<dynamic>(
        '${ApiEndpoints.markNotificationRead}/$notificationId',
      );
    } catch (e) {
      AppLogger.warning('Mark notification API error ($e), updating locally.');
    }

    final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _mockNotifications[index] = _mockNotifications[index].copyWith(isRead: true) as NotificationModel;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await apiClient.post<dynamic>(ApiEndpoints.markNotificationRead);
    } catch (e) {
      AppLogger.warning('Mark all notifications API error ($e), updating locally.');
    }

    for (var i = 0; i < _mockNotifications.length; i++) {
      _mockNotifications[i] = _mockNotifications[i].copyWith(isRead: true) as NotificationModel;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await apiClient.delete<dynamic>(
        '${ApiEndpoints.notifications}/$notificationId',
      );
    } catch (e) {
      AppLogger.warning('Delete notification API error ($e), updating locally.');
    }

    _mockNotifications.removeWhere((n) => n.id == notificationId);
  }

  @override
  Future<void> clearAll() async {
    try {
      await apiClient.delete<dynamic>(ApiEndpoints.notifications);
    } catch (e) {
      AppLogger.warning('Clear notifications API error ($e), updating locally.');
    }

    _mockNotifications.clear();
  }
}

