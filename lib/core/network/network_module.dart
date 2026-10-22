import 'package:dio/dio.dart';
import 'package:wua_mobile/core/constants/env_config.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/core/network/api_constants.dart';
import 'package:wua_mobile/core/network/interceptors/auth_interceptor.dart';
import 'package:wua_mobile/core/network/interceptors/logging_interceptor.dart';
import 'package:wua_mobile/core/network/interceptors/refresh_token_interceptor.dart';
import 'package:wua_mobile/core/network/interceptors/retry_interceptor.dart';
import 'package:wua_mobile/core/storage/secure_storage_service.dart';

/// Configures and provides the fully-assembled [ApiClient] with all
/// interceptors wired up. This is the single composition point for
/// the networking stack and is called during DI registration.
class NetworkModule {
  NetworkModule._();

  /// Creates a production-ready [ApiClient] with all interceptors.
  static ApiClient provideApiClient({
    required SecureStorageService secureStorage,
    void Function()? onTokenExpired,
  }) {
    final dio = _createDio();

    // Order matters: Auth → Refresh → Retry → Logging
    dio.interceptors.addAll([
      AuthInterceptor(secureStorage: secureStorage),
      RefreshTokenInterceptor(
        dio: dio,
        secureStorage: secureStorage,
        onTokenExpired: onTokenExpired,
      ),
      RetryInterceptor(dio: dio),
      if (EnvConfig.enableLogging) LoggingInterceptor(),
    ]);

    return ApiClient(dio: dio);
  }

  /// Creates the base [Dio] instance with environment-driven configuration.
  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: Duration(milliseconds: EnvConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: EnvConfig.receiveTimeout),
        sendTimeout: const Duration(milliseconds: 30000),
        headers: {
          ApiConstants.contentType: ApiConstants.applicationJson,
          ApiConstants.accept: ApiConstants.applicationJson,
          ApiConstants.apiKeyHeader: EnvConfig.apiKey,
        },
      ),
    );
  }
}
