import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Notification categories for WUA irrigation services.
enum NotificationCategory {
  bill,
  payment,
  general,
}

/// Notification type identifier.
enum NotificationType {
  billGenerated,
  billDue,
  billOverdue,
  paymentSuccess,
  paymentFailed,
  paymentReceipt,
  general,
}

/// Core domain entity representing a User Notification.
class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    required this.timestamp,
    this.isRead = false,
    this.actionRoute,
    this.referenceId,
    this.amount,
    this.metadata,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationCategory category;
  final DateTime timestamp;
  final bool isRead;
  final String? actionRoute;
  final String? referenceId;
  final double? amount;
  final Map<String, dynamic>? metadata;

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationCategory? category,
    DateTime? timestamp,
    bool? isRead,
    String? actionRoute,
    String? referenceId,
    double? amount,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionRoute: actionRoute ?? this.actionRoute,
      referenceId: referenceId ?? this.referenceId,
      amount: amount ?? this.amount,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Relative human-readable time format (e.g. "2 hours ago", "Yesterday").
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return '$mins ${mins == 1 ? "minute" : "minutes"} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? "hour" : "hours"} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('dd MMM yyyy').format(timestamp);
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        category,
        timestamp,
        isRead,
        actionRoute,
        referenceId,
        amount,
        metadata,
      ];
}

