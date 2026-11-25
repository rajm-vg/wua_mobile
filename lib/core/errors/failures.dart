import 'package:equatable/equatable.dart';
import 'package:wua_mobile/core/errors/exceptions.dart';

/// Base failure class for functional error handling.
/// All failures in the application extend this class.
/// Used with [Either<Failure, T>] from dartz for type-safe error propagation.
abstract class Failure extends Equatable {
  const Failure({required this.message, this.code, this.originalException});
  final String message;
  final int? code;
  final dynamic originalException;

  @override
  List<Object?> get props => [message, code];
}

/// Server returned an error response (4xx/5xx).
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.originalException,
  });
}

/// No internet connectivity or unreachable server.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code,
    super.originalException,
  });
}

/// Local cache read/write failure.
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to access local storage.',
    super.code,
    super.originalException,
  });
}

/// Input validation failure.
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    this.fieldErrors = const {},
    super.code,
    super.originalException,
  });
  final Map<String, List<String>> fieldErrors;

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Authentication token expired or invalid.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Session expired. Please log in again.',
    super.code = 401,
    super.originalException,
  });
}

/// Forbidden – user lacks permission.
class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'You do not have permission to perform this action.',
    super.code = 403,
    super.originalException,
  });
}

/// Requested resource not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.code = 404,
    super.originalException,
  });
}

/// Request timed out.
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out. Please try again.',
    super.code,
    super.originalException,
  });
}

/// Catch-all for unhandled exceptions.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred.',
    super.code,
    super.originalException,
  });
}

/// Maps data-layer exceptions into typed domain [Failure] instances.
Failure mapExceptionToFailure(Object error, {String? fallbackPrefix}) {
  if (error is UnauthorizedException) {
    return UnauthorizedFailure(
      message: error.message.isNotEmpty
          ? error.message
          : 'Session expired. Please log in again.',
      originalException: error,
    );
  }
  if (error is NetworkException) {
    return NetworkFailure(
      message: error.message.isNotEmpty
          ? error.message
          : 'No internet connection. Please check your network.',
      originalException: error,
    );
  }
  if (error is TimeoutException) {
    return TimeoutFailure(
      message: error.message.isNotEmpty
          ? error.message
          : 'Request timed out. Please try again.',
      originalException: error,
    );
  }
  if (error is CacheException) {
    return CacheFailure(message: error.message, originalException: error);
  }
  if (error is ServerException) {
    if (error.statusCode == 401) {
      return UnauthorizedFailure(
        message: error.message.isNotEmpty
            ? error.message
            : 'Session expired. Please log in again.',
        originalException: error,
      );
    }
    if (error.statusCode == 403) {
      return ForbiddenFailure(
        message: error.message.isNotEmpty
            ? error.message
            : 'You do not have permission to perform this action.',
        originalException: error,
      );
    }
    if (error.statusCode == 404) {
      return NotFoundFailure(
        message: error.message.isNotEmpty
            ? error.message
            : 'The requested resource was not found.',
        originalException: error,
      );
    }
    return ServerFailure(
      message: error.message,
      code: error.statusCode,
      originalException: error,
    );
  }
  final detail = fallbackPrefix != null ? '$fallbackPrefix: $error' : '$error';
  return ServerFailure(message: detail, originalException: error);
}
