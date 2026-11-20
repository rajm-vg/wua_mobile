/// Centralized API endpoint definitions.
/// All endpoints are defined here to avoid scattered string literals.
class ApiEndpoints {
  ApiEndpoints._();

  // Authentication (wrd_backend Spring Boot / JHipster)
  static const String authenticate = '/api/authenticate';
  static const String account = '/api/account';
  static const String loggedInUser = '/api/loggedInUser';
  static const String login = '/api/authenticate';
  static const String register = '/api/register';
  static const String refreshToken = '/api/refresh-token';
  static const String logout = '/api/logout';
  static const String forgotPassword = '/api/account/reset-password/init';
  static const String resetPassword = '/api/account/reset-password/finish';
  static const String changePassword = '/api/account/change-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';

  // Profile
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';

  // Bills
  static const String bills = '/bills';
  static String billDetail(String id) => '/bills/$id';

  // Payments
  static const String payments = '/payments';
  static const String initiatePayment = '/payments/initiate';
  static const String verifyPayment = '/payments/verify';
  static String paymentDetail(String id) => '/payments/$id';

  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';
  static String notificationDetail(String id) => '/notifications/$id';

  // Water Usage
  static const String waterUsage = '/water-usage';
  static const String waterUsageSummary = '/water-usage/summary';

  // Irrigation Schedule
  static const String irrigationSchedule = '/irrigation/schedule';
}
