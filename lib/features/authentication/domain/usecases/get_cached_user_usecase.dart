import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Retrieves the cached/current user profile.
class GetCachedUserUseCase extends UseCase<UserEntity, NoParams> {
  GetCachedUserUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return repository.getCachedUser();
  }
}
