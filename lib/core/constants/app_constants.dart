/// Application-wide constant values.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'WUA Mobile';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts (in milliseconds)
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Cache
  static const Duration cacheValidity = Duration(hours: 1);
  static const int maxCacheSize = 100;

  // Retry
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;
  static const int otpLength = 6;
  static const int phoneNumberLength = 10;

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String firstLaunchKey = 'is_first_launch';
  static const String featureFlagsKey = 'feature_flags';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
}
