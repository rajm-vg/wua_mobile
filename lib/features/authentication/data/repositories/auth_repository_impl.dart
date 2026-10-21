import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/logger/app_logger.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete implementation of [AuthRepository].
///
/// Orchestrates between remote and local data sources,
/// checks network connectivity, and maps exceptions to failures.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, ({UserEntity user, AuthTokens tokens})>> login({
    required String identifier,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.login(
        identifier: identifier,
        password: password,
      );

      // Cache user and tokens locally.
      await localDataSource.cacheUser(result.user);
      await localDataSource.cacheTokens(
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      );

      AppLogger.repository('Login successful for: $identifier');

      return Right((
        user: result.user.toEntity(),
        tokens: result.tokens.toEntity(),
      ));
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          code: e.statusCode,
          originalException: e,
        ),
      );
    } on UnauthorizedException catch (e) {
      return Left(
        UnauthorizedFailure(message: e.message, originalException: e),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, originalException: e));
    } on TimeoutException catch (e) {
      return Left(TimeoutFailure(message: e.message, originalException: e));
    } catch (e, stackTrace) {
      AppLogger.error('Login failed', e, stackTrace);
      return Left(UnknownFailure(message: e.toString(), originalException: e));
    }
  }

  @override
  Future<Either<Failure, ({UserEntity user, AuthTokens tokens})>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final result = await remoteDataSource.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      await localDataSource.cacheUser(result.user);
      await localDataSource.cacheTokens(
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
      );

      AppLogger.repository('Registration successful for: $email');

      return Right((
        user: result.user.toEntity(),
        tokens: result.tokens.toEntity(),
      ));
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          code: e.statusCode,
          originalException: e,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Registration failed', e, stackTrace);
      return Left(UnknownFailure(message: e.toString(), originalException: e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout('');
      }
    } catch (_) {
      // Best-effort server-side logout; always clear local state.
    }

    try {
      await localDataSource.clearCache();
      AppLogger.repository('Logout completed.');
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, originalException: e));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e, stackTrace) {
      AppLogger.error('Forgot password failed', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e, stackTrace) {
      AppLogger.error('Reset password failed', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.verifyOtp(email: email, otp: otp);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e, stackTrace) {
      AppLogger.error('OTP verification failed', e, stackTrace);
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCachedUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, originalException: e));
    }
  }

  @override
  Future<bool> isAuthenticated() => localDataSource.hasToken();
}
