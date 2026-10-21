import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized environment configuration.
/// Reads values from the loaded .env file via flutter_dotenv.
class EnvConfig {
  EnvConfig._();

  /// The .env file name for the current build flavor.
  /// Set before calling [dotenv.load] in main.
  static String _envFileName = '.env';

  static String get envFileName => _envFileName;

  static void setEnvironment(AppEnvironment env) {
    switch (env) {
      case AppEnvironment.development:
        _envFileName = '.env.dev';
      case AppEnvironment.qa:
        _envFileName = '.env.qa';
      case AppEnvironment.uat:
        _envFileName = '.env.uat';
      case AppEnvironment.production:
        _envFileName = '.env.prod';
    }
  }

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080/api/v1';

  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  static String get buildFlavor =>
      dotenv.env['BUILD_FLAVOR'] ?? 'development';

  static int get connectTimeout =>
      int.tryParse(dotenv.env['CONNECT_TIMEOUT'] ?? '30000') ?? 30000;

  static int get receiveTimeout =>
      int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '30000') ?? 30000;

  static bool get enableLogging =>
      dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';

  static bool get isProduction => buildFlavor == 'production';
  static bool get isDevelopment => buildFlavor == 'development';
}

enum AppEnvironment {
  development,
  qa,
  uat,
  production,
}
