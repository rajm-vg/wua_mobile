import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/notifications/domain/repositories/notification_repository.dart';

class MarkNotificationReadParams extends Equatable {
  const MarkNotificationReadParams(this.notificationId);

  final String notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class MarkNotificationReadUseCase
    extends UseCase<void, MarkNotificationReadParams> {
  MarkNotificationReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, void>> call(MarkNotificationReadParams params) {
    return _repository.markAsRead(params.notificationId);
  }
}

