import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/authentication/domain/entities/auth_tokens.dart';
import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:wua_mobile/features/authentication/domain/repositories/auth_repository.dart';

/// Registers a new user account.
class RegisterUseCase
    extends UseCase<({UserEntity user, AuthTokens tokens}), RegisterParams> {
  RegisterUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<Failure, ({UserEntity user, AuthTokens tokens})>> call(
    RegisterParams params,
  ) {
    return repository.register(
      name: params.name,
      email: params.email,
      phone: params.phone,
      password: params.password,
    );
  }
}

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });
  final String name;
  final String email;
  final String phone;
  final String password;

  @override
  List<Object?> get props => [name, email, phone, password];
}
