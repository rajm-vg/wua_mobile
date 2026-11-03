import 'package:dartz/dartz.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/notifications/domain/repositories/notification_repository.dart';

class MarkAllNotificationsReadUseCase extends UseCase<void, NoParams> {
  MarkAllNotificationsReadUseCase(this._repository);

  final NotificationRepository _repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.markAllAsRead();
  }
}

