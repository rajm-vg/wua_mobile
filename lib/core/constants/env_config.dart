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
      case AppEnvironment.preprod:
        _envFileName = '.env.preprod';
      case AppEnvironment.production:
        _envFileName = '.env.prod';
    }
  }

  /// Resolves [AppEnvironment] from `--dart-define=ENV=<name>`,
  /// `--dart-define=APP_ENV=<name>`, or `--dart-define=BUILD_FLAVOR=<name>`,
  /// falling back to [AppEnvironment.development].
  static AppEnvironment resolveEnvironment([String? envName]) {
    const defineEnv = String.fromEnvironment('ENV');
    const defineAppEnv = String.fromEnvironment('APP_ENV');
    const defineBuildFlavor = String.fromEnvironment('BUILD_FLAVOR');

    final candidate = envName ??
        (defineEnv.isNotEmpty
            ? defineEnv
            : (defineAppEnv.isNotEmpty ? defineAppEnv : defineBuildFlavor));

    switch (candidate.trim().toLowerCase()) {
      case 'qa':
        return AppEnvironment.qa;
      case 'uat':
        return AppEnvironment.uat;
      case 'preprod':
      case 'pre-prod':
        return AppEnvironment.preprod;
      case 'prod':
      case 'production':
        return AppEnvironment.production;
      case 'dev':
      case 'development':
      default:
        return AppEnvironment.development;
    }
  }

  static String get baseUrl => dotenv.isInitialized
      ? (dotenv.env['BASE_URL'] ?? 'http://localhost:7010')
      : 'http://localhost:7010';

  static String get apiKey =>
      dotenv.isInitialized ? (dotenv.env['API_KEY'] ?? '') : '';

  static String get buildFlavor => dotenv.isInitialized
      ? (dotenv.env['BUILD_FLAVOR'] ?? 'development')
      : 'development';

  static int get connectTimeout => dotenv.isInitialized
      ? (int.tryParse(dotenv.env['CONNECT_TIMEOUT'] ?? '30000') ?? 30000)
      : 30000;

  static int get receiveTimeout => dotenv.isInitialized
      ? (int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '30000') ?? 30000)
      : 30000;

  static bool get enableLogging =>
      dotenv.isInitialized &&
      dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';

  /// Whether to allow offline mock fallback when backend is unreachable during dev/demo.
  static bool get enableDemoFallback =>
      dotenv.isInitialized &&
      dotenv.env['ENABLE_DEMO_FALLBACK']?.toLowerCase() == 'true';

  /// Payment gateway mode for Easebuzz (`test` or `production`).
  static String get easebuzzPayMode {
    if (dotenv.isInitialized) {
      final mode = dotenv.env['EASEBUZZ_PAY_MODE']?.trim().toLowerCase();
      if (mode == 'production' || mode == 'test') {
        return mode!;
      }
    }
    return isProduction ? 'production' : 'test';
  }

  static bool get isProduction => buildFlavor == 'production';
  static bool get isDevelopment => buildFlavor == 'development';
  static bool get isQa => buildFlavor == 'qa';
  static bool get isUat => buildFlavor == 'uat';
  static bool get isPreprod => buildFlavor == 'preprod';
}

enum AppEnvironment { development, qa, uat, preprod, production }
