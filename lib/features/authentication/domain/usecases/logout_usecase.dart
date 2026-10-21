import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Logs out the current user and clears local session.
class LogoutUseCase extends UseCase<void, NoParams> {
  LogoutUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}
