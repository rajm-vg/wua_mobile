import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/notifications/domain/repositories/notification_repository.dart';

class DeleteNotificationParams extends Equatable {
  const DeleteNotificationParams(this.notificationId);

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class DeleteNotificationUseCase extends UseCase<void, DeleteNotificationParams> {
  DeleteNotificationUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeleteNotificationParams params) {
    return _repository.deleteNotification(params.notificationId);
  }
}

