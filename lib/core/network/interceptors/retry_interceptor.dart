import 'dart:io';

import 'package:dio/dio.dart';

import 'package:wua_mobile/core/constants/app_constants.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';

/// Interceptor that retries failed requests due to transient errors.
/// Retries on 5xx server errors, timeouts, and connection errors.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = AppConstants.maxRetryAttempts,
    this.retryDelay = AppConstants.retryDelay,
  });
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      AppLogger.warning(
        'Retrying request (${retryCount + 1}/$maxRetries): '
        '${err.requestOptions.method} ${err.requestOptions.uri}',
      );

      await Future<void>.delayed(
        retryDelay * (retryCount + 1),
      ); // Exponential backoff

      err.requestOptions.extra['retryCount'] = retryCount + 1;

      try {
        final response = await dio.fetch<dynamic>(err.requestOptions);
        handler.resolve(response);
        return;
      } on DioException catch (e) {
        handler.next(e);
        return;
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on connection errors
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    // Retry on 5xx server errors
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500) {
      return true;
    }

    // Retry on SocketException
    if (err.error is SocketException) {
      return true;
    }

    return false;
  }
}
