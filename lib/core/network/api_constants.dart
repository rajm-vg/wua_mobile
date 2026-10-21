/// API-level constants for headers, content types, and configuration.
class ApiConstants {
  ApiConstants._();

  // Headers
  static const String contentType = 'Content-Type';
  static const String accept = 'Accept';
  static const String authorization = 'Authorization';
  static const String bearerPrefix = 'Bearer ';
  static const String apiKeyHeader = 'X-API-Key';
  static const String platformHeader = 'X-Platform';
  static const String appVersionHeader = 'X-App-Version';
  static const String deviceIdHeader = 'X-Device-Id';

  // Content Types
  static const String applicationJson = 'application/json';
  static const String multipartFormData = 'multipart/form-data';

  // Status Codes
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusConflict = 409;
  static const int statusUnprocessableEntity = 422;
  static const int statusTooManyRequests = 429;
  static const int statusInternalServerError = 500;
  static const int statusBadGateway = 502;
  static const int statusServiceUnavailable = 503;
}
