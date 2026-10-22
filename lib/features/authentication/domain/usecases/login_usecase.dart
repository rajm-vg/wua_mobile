import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/authentication/domain/entities/auth_tokens.dart';
import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:wua_mobile/features/authentication/domain/repositories/auth_repository.dart';

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
