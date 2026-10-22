import 'package:dartz/dartz.dart';

import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/features/authentication/domain/entities/auth_tokens.dart';
import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';

/// Authentication repository contract.
/// Implemented in the data layer — consumed by use cases only.
abstract class AuthRepository {
  /// Authenticates with email/phone and password.
  Future<Either<Failure, ({UserEntity user, AuthTokens tokens})>> login({
    required String identifier,
    required String password,
  });

  /// Registers a new user.
  Future<Either<Failure, ({UserEntity user, AuthTokens tokens})>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  });

  /// Logs out the current user and clears session.
  Future<Either<Failure, void>> logout();

  /// Requests a password reset OTP.
  Future<Either<Failure, void>> forgotPassword({required String email});

  /// Resets password with OTP verification.
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  /// Verifies the OTP sent during registration.
  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String otp,
  });

  /// Returns the currently cached user, if any.
  Future<Either<Failure, UserEntity>> getCachedUser();

  /// Returns true if the user has a valid session.
  Future<bool> isAuthenticated();
}
