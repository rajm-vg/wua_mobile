import 'package:dio/dio.dart';

import 'package:wua_mobile/core/logger/app_logger.dart';

/// Interceptor that logs all HTTP requests and responses.
/// Automatically disabled in release builds via [AppLogger].
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.network(
      '→ ${options.method} ${options.uri}\n'
      '  Headers: ${options.headers}\n'
      '  Data: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    AppLogger.network(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}\n'
      '  Data: ${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      '✖ ${err.requestOptions.method} ${err.requestOptions.uri}\n'
      '  Error: ${err.message}\n'
      '  Response: ${err.response?.data}',
    );
    handler.next(err);
  }
}
