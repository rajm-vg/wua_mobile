import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/features/notifications/domain/entities/notification_entity.dart';

void main() {
  group('NotificationEntity Tests', () {
    test('copyWith updates properties properly', () {
      final notif = NotificationEntity(
        id: 'n1',
        title: 'New Bill Generated',
        message: 'Your Pani Patti bill is ready',
        type: NotificationType.billGenerated,
        category: NotificationCategory.bill,
        timestamp: DateTime(2026, 11, 1, 10, 0),
        isRead: false,
        amount: 1450.0,
        referenceId: 'BILL-001',
      );

      final updated = notif.copyWith(isRead: true, amount: 1500.0);

      expect(updated.id, 'n1');
      expect(updated.isRead, isTrue);
      expect(updated.amount, 1500.0);
      expect(updated.title, 'New Bill Generated');
      expect(notif.isRead, isFalse);
    });

    test('timeAgo returns formatted string based on timestamp difference', () {
      final now = DateTime.now();

      final justNow = NotificationEntity(
        id: 'n1',
        title: 'Title',
        message: 'Msg',
        type: NotificationType.general,
        category: NotificationCategory.general,
        timestamp: now.subtract(const Duration(seconds: 15)),
      );
      expect(justNow.timeAgo, 'Just now');

      final minutesAgo = NotificationEntity(
        id: 'n2',
        title: 'Title',
        message: 'Msg',
        type: NotificationType.billDue,
        category: NotificationCategory.bill,
        timestamp: now.subtract(const Duration(minutes: 25)),
      );
      expect(minutesAgo.timeAgo, '25 minutes ago');

      final hoursAgo = NotificationEntity(
        id: 'n3',
        title: 'Title',
        message: 'Msg',
        type: NotificationType.paymentSuccess,
        category: NotificationCategory.payment,
        timestamp: now.subtract(const Duration(hours: 3)),
      );
      expect(hoursAgo.timeAgo, '3 hours ago');

      final yesterday = NotificationEntity(
        id: 'n4',
        title: 'Title',
        message: 'Msg',
        type: NotificationType.paymentReceipt,
        category: NotificationCategory.payment,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
      );
      expect(yesterday.timeAgo, 'Yesterday');
    });

    test('props contains all essential fields for equality check', () {
      final notif1 = NotificationEntity(
        id: 'n1',
        title: 'Test',
        message: 'Msg',
        type: NotificationType.billGenerated,
        category: NotificationCategory.bill,
        timestamp: DateTime(2026, 1, 1),
        isRead: false,
      );

      final notif2 = NotificationEntity(
        id: 'n1',
        title: 'Test',
        message: 'Msg',
        type: NotificationType.billGenerated,
        category: NotificationCategory.bill,
        timestamp: DateTime(2026, 1, 1),
        isRead: false,
      );

      expect(notif1, equals(notif2));
    });
  });
}

