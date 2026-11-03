import 'package:dartz/dartz.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/features/notifications/domain/entities/notification_entity.dart';

/// Contract for notifications operations.
abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    bool forceRefresh = false,
  });

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, void>> markAllAsRead();

  Future<Either<Failure, void>> deleteNotification(String notificationId);

  Future<Either<Failure, void>> clearAll();
}

