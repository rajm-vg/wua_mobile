import 'package:wua_mobile/core/utils/json_parse_utils.dart';
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
      id: JsonParseUtils.parseString(json['id']),
      title: JsonParseUtils.parseString(json['title']),
      message: JsonParseUtils.parseString(json['message']),
      type: _parseType(JsonParseUtils.parseStringOrNull(json['type'])),
      category: _parseCategory(
        JsonParseUtils.parseStringOrNull(json['category']),
      ),
      timestamp: JsonParseUtils.parseDateTimeOrNow(json['timestamp']),
      isRead: JsonParseUtils.parseBool(json['is_read']),
      actionRoute: JsonParseUtils.parseStringOrNull(json['action_route']),
      referenceId: JsonParseUtils.parseStringOrNull(json['reference_id']),
      amount: JsonParseUtils.parseDoubleOrNull(json['amount']),
      metadata: JsonParseUtils.parseMapOrNull(json['metadata']),
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

