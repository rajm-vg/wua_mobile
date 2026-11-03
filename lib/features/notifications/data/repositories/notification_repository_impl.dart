import 'package:dartz/dartz.dart';
import 'package:wua_mobile/core/errors/exceptions.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/network/network_info.dart';
import 'package:wua_mobile/features/notifications/data/datasources/notification_remote_datasource.dart';
import 'package:wua_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:wua_mobile/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications({
    bool forceRefresh = false,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        final notifications = await remoteDataSource.getNotifications(
          forceRefresh: false,
        );
        return Right(notifications);
      }

      final notifications = await remoteDataSource.getNotifications(
        forceRefresh: forceRefresh,
      );
      return Right(notifications);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to retrieve notifications: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to mark notification as read: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to mark all as read: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to delete notification: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      await remoteDataSource.clearAll();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to clear notifications: ${e.toString()}',
        ),
      );
    }
  }
}

