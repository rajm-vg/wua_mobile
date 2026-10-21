import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_tokens.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

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
