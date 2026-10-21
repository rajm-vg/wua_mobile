/// Exception types thrown by data sources before being caught
/// and converted to [Failure] objects by repositories.
library;

/// Thrown when the API returns a non-success status code.
class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode, this.data});
  final String message;
  final int? statusCode;
  final dynamic data;

  @override
  String toString() =>
      'ServerException(message: $message, statusCode: $statusCode)';
}

/// Thrown when there is no network connectivity.
class NetworkException implements Exception {
  const NetworkException({this.message = 'No internet connection.'});
  final String message;

  @override
  String toString() => 'NetworkException(message: $message)';
}

/// Thrown when a cache operation fails.
class CacheException implements Exception {
  const CacheException({this.message = 'Cache operation failed.'});
  final String message;

  @override
  String toString() => 'CacheException(message: $message)';
}

/// Thrown when the user's session has expired.
class UnauthorizedException implements Exception {
  const UnauthorizedException({this.message = 'Unauthorized access.'});
  final String message;

  @override
  String toString() => 'UnauthorizedException(message: $message)';
}

/// Thrown when the request times out.
class TimeoutException implements Exception {
  const TimeoutException({this.message = 'Request timed out.'});
  final String message;

  @override
  String toString() => 'TimeoutException(message: $message)';
}
