import 'package:dio/dio.dart';
import 'package:wua_mobile/core/network/api_constants.dart';
import 'package:wua_mobile/core/storage/secure_storage_service.dart';

/// Interceptor that attaches the Bearer token to every outgoing request.
/// Reads the access token from secure storage.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this._secureStorage});
  final SecureStorageService _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers[ApiConstants.authorization] =
          '${ApiConstants.bearerPrefix}$token';
    }
    handler.next(options);
  }
}
