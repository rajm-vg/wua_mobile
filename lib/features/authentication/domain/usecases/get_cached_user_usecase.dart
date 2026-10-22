import 'package:dartz/dartz.dart';

import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:wua_mobile/features/authentication/domain/repositories/auth_repository.dart';

/// Retrieves the cached/current user profile.
class GetCachedUserUseCase extends UseCase<UserEntity, NoParams> {
  GetCachedUserUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return repository.getCachedUser();
  }
}
