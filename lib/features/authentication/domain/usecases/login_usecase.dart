import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_tokens.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Authenticates a user with identifier (email/phone) and password.
class LoginUseCase
    extends UseCase<({UserEntity user, AuthTokens tokens}), LoginParams> {
  LoginUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, ({UserEntity user, AuthTokens tokens})>> call(
    LoginParams params,
  ) {
    return repository.login(
      identifier: params.identifier,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.identifier, required this.password});
  final String identifier;
  final String password;

  @override
  List<Object?> get props => [identifier, password];
}
