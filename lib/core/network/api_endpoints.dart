/// Centralized API endpoint definitions.
/// All endpoints are defined here to avoid scattered string literals.
class ApiEndpoints {
  ApiEndpoints._();

  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
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

  // Transactions
  static const String transactions = '/transactions';
  static String transactionDetail(String id) => '/transactions/$id';

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
