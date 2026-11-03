import 'package:wua_mobile/features/notifications/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.category,
    required super.timestamp,
    super.isRead,
    super.actionRoute,
    super.referenceId,
    super.amount,
    super.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _parseType(json['type'] as String?),
      category: _parseCategory(json['category'] as String?),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      actionRoute: json['action_route'] as String?,
      referenceId: json['reference_id'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type.name,
        'category': category.name,
        'timestamp': timestamp.toIso8601String(),
        'is_read': isRead,
        'action_route': actionRoute,
        'reference_id': referenceId,
        'amount': amount,
        'metadata': metadata,
      };

  static NotificationType _parseType(String? typeStr) {
    switch (typeStr) {
      case 'billGenerated':
        return NotificationType.billGenerated;
      case 'billDue':
        return NotificationType.billDue;
      case 'billOverdue':
        return NotificationType.billOverdue;
      case 'paymentSuccess':
        return NotificationType.paymentSuccess;
      case 'paymentFailed':
        return NotificationType.paymentFailed;
      case 'paymentReceipt':
        return NotificationType.paymentReceipt;
      default:
        return NotificationType.general;
    }
  }

  static NotificationCategory _parseCategory(String? categoryStr) {
    switch (categoryStr) {
      case 'bill':
        return NotificationCategory.bill;
      case 'payment':
        return NotificationCategory.payment;
      default:
        return NotificationCategory.general;
    }
  }
}

