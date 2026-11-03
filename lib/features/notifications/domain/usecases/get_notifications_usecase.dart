import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/notifications/domain/entities/notification_entity.dart';
import 'package:wua_mobile/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsParams extends Equatable {
  const GetNotificationsParams({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

class GetNotificationsUseCase
    extends UseCase<List<NotificationEntity>, GetNotificationsParams> {
  GetNotificationsUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(
    GetNotificationsParams params,
  ) {
    return _repository.getNotifications(forceRefresh: params.forceRefresh);
  }
}

