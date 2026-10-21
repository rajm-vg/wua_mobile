/// Centralized route name constants.
/// All named routes are defined here to prevent typos.
class RouteNames {
  RouteNames._();

  // ─── Root ───────────────────────────────────────────────────
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';

  // ─── Auth ───────────────────────────────────────────────────
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';
  static const String otpVerification = 'otp-verification';

  // ─── Main ───────────────────────────────────────────────────
  static const String home = 'home';
  static const String dashboard = 'dashboard';

  // ─── Profile ────────────────────────────────────────────────
  static const String profile = 'profile';
  static const String editProfile = 'edit-profile';

  // ─── Bills ──────────────────────────────────────────────────
  static const String bills = 'bills';
  static const String billDetail = 'bill-detail';

  // ─── Payments ───────────────────────────────────────────────
  static const String payments = 'payments';
  static const String paymentDetail = 'payment-detail';
  static const String paymentConfirmation = 'payment-confirmation';

  // ─── Transactions ──────────────────────────────────────────
  static const String transactions = 'transactions';
  static const String transactionDetail = 'transaction-detail';

  // ─── Notifications ──────────────────────────────────────────
  static const String notifications = 'notifications';
  static const String notificationDetail = 'notification-detail';

  // ─── Water Usage ────────────────────────────────────────────
  static const String waterUsage = 'water-usage';
  static const String waterUsageDetail = 'water-usage-detail';

  // ─── Settings ───────────────────────────────────────────────
  static const String settings = 'settings';
}
