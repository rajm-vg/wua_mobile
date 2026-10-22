import 'package:dio/dio.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/network/api_constants.dart';
import 'package:wua_mobile/core/network/api_endpoints.dart';
import 'package:wua_mobile/core/storage/secure_storage_service.dart';

/// Interceptor that handles 401 responses by refreshing the token
/// and retrying the original request exactly once.
///
/// If the refresh itself fails, the user is logged out.
class RefreshTokenInterceptor extends QueuedInterceptor {
  RefreshTokenInterceptor({
    required this.dio,
    required this.secureStorage,
    this.onTokenExpired,
  }) : _tokenDio = Dio(dio.options);
  final Dio dio;
  final SecureStorageService secureStorage;
  final Dio _tokenDio; // Separate Dio instance to avoid interceptor loop.
  final void Function()? onTokenExpired;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != ApiConstants.statusUnauthorized) {
      handler.next(err);
      return;
    }

    // Don't retry the refresh endpoint itself.
    if (err.requestOptions.path == ApiEndpoints.refreshToken) {
      _handleTokenExpired();
      handler.next(err);
      return;
    }

    AppLogger.info('Access token expired. Attempting refresh…');

    try {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        _handleTokenExpired();
        handler.next(err);
        return;
      }

      final response = await _tokenDio.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data?['access_token'] as String?;
      final newRefreshToken = response.data?['refresh_token'] as String?;

      if (newAccessToken == null) {
        _handleTokenExpired();
        handler.next(err);
        return;
      }

      await secureStorage.saveAccessToken(newAccessToken);
      if (newRefreshToken != null) {
        await secureStorage.saveRefreshToken(newRefreshToken);
      }

      AppLogger.info(
        'Token refreshed successfully. Retrying original request.',
      );

      // Retry original request with the new token.
      err.requestOptions.headers[ApiConstants.authorization] =
          '${ApiConstants.bearerPrefix}$newAccessToken';

      final retryResponse = await dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(retryResponse);
    } on DioException catch (e) {
      AppLogger.error('Token refresh failed: ${e.message}');
      _handleTokenExpired();
      handler.next(e);
    }
  }

  void _handleTokenExpired() {
    AppLogger.warning('Session expired. Logging user out.');
    secureStorage.clearTokens();
    onTokenExpired?.call();
  }
}
