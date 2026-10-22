import 'dart:io';

import 'package:dio/dio.dart';

import 'package:wua_mobile/core/errors/exceptions.dart';
import 'package:wua_mobile/core/network/api_constants.dart';

/// Maps [DioException] and HTTP status codes into domain-specific exceptions.
/// Called by [ApiClient] so repositories never see raw Dio errors.
class DioErrorMapper {
  DioErrorMapper._();

  static Exception mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutException(message: 'Connection timed out.');

      case DioExceptionType.connectionError:
        if (error.error is SocketException) {
          return const NetworkException(message: 'No internet connection.');
        }
        return const NetworkException(message: 'Connection error.');

      case DioExceptionType.badResponse:
        return _mapStatusCode(error.response);

      case DioExceptionType.cancel:
        return const ServerException(message: 'Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const ServerException(
          message: 'SSL certificate verification failed.',
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NetworkException();
        }
        return ServerException(
          message: error.message ?? 'An unknown error occurred.',
        );
    }
  }

  static Exception _mapStatusCode(Response<dynamic>? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    final message = _extractMessage(data);

    switch (statusCode) {
      case ApiConstants.statusUnauthorized:
        return UnauthorizedException(message: message);

      case ApiConstants.statusForbidden:
        return ServerException(
          message: message,
          statusCode: statusCode,
          data: data,
        );

      case ApiConstants.statusNotFound:
        return ServerException(
          message: message.isNotEmpty ? message : 'Resource not found.',
          statusCode: statusCode,
          data: data,
        );

      case ApiConstants.statusUnprocessableEntity:
        return ServerException(
          message: message,
          statusCode: statusCode,
          data: data,
        );

      case ApiConstants.statusTooManyRequests:
        return ServerException(
          message: 'Too many requests. Please try again later.',
          statusCode: statusCode,
          data: data,
        );

      default:
        return ServerException(
          message: message.isNotEmpty
              ? message
              : 'Server error (${statusCode ?? "unknown"}).',
          statusCode: statusCode,
          data: data,
        );
    }
  }

  /// Attempts to extract a human-readable error message from the response body.
  static String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return (data['message'] as String?) ?? (data['error'] as String?) ?? '';
    }
    if (data is String) return data;
    return '';
  }
}
