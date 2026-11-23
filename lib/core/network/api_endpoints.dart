/// Centralized API endpoint definitions matching wrd_backend Spring Boot REST services.
/// All endpoints are defined here to avoid scattered string literals.
class ApiEndpoints {
  ApiEndpoints._();

  // Authentication & OTP (wrd_backend Spring Boot / JHipster)
  static const String authenticate = '/api/authenticate';
  static const String account = '/api/account';
  static const String loggedInUser = '/api/loggedInUser';
  static const String login = '/api/authenticate';
  static const String register = '/api/register';
  static const String refreshToken = '/api/refresh-token';
  static const String logout = '/api/logout';
  static const String forgotPassword = '/api/account/reset-password/init';
  static const String resetPassword = '/api/account/reset-password/finish';
  static const String changePassword = '/api/change-password';
  static const String generateOtp = '/api/generate-OTP';
  static const String verifyOtp = '/api/verify-OTP';
  static const String resendOtp = '/api/generate-OTP';

  // Farmer Member & Land Records (SocietyFarmer & FarmDetails)
  static const String societyFarmers = '/api/society-farmers';
  static String societyFarmer(int id) => '/api/society-farmers/$id';
  static String farmDetails({required int memberId}) =>
      '/api/farm-details?memberId.equals=$memberId';
  static const String profile = '/api/account';
  static const String updateProfile = '/api/account';

  // Water Tax Bills (BillHeader & BillDetails)
  static const String bills = '/api/bill-headers';
  static String billDetail(String id) => '/api/bill-headers/$id';
  static String billHeaders({
    required int farmerMemberId,
    bool? isPaymentDone,
    int page = 0,
    int size = 20,
    String sort = 'id,desc',
  }) {
    final paymentFilter = isPaymentDone != null ? '&isPaymentDone.equals=$isPaymentDone' : '';
    return '/api/bill-headers?iFarmerMemberId.equals=$farmerMemberId$paymentFilter&page=$page&size=$size&sort=$sort';
  }
  static String billHeaderDetail(int id) => '/api/bill-headers/$id';
  static String billDetails({required int billHeaderId}) =>
      '/api/bill-details?iBillNo.equals=$billHeaderId';

  // Payments & Receipts (ReceiptDetails & PostReceiptEntry)
  static const String payments = '/api/receipt-details';
  static const String postReceiptDetails = '/api/receipt-details';
  static const String postReceiptEntryRequest = '/api/post-receipt-entry/request';
  static const String initiatePayment = '/api/post-receipt-entry/request';
  static const String verifyPayment = '/api/receipt-details';
  static String paymentDetail(String id) => '/api/receipt-details/$id';
  static String receiptsHistory({
    required int farmerMemberId,
    int page = 0,
    int size = 20,
    String sort = 'dReceiptDate,desc',
  }) =>
      '/api/receipt-details?iFarmerMemberId.equals=$farmerMemberId&page=$page&size=$size&sort=$sort';

  // Canal Water Rotations & Crop Allocation (WUAWaterUsage & CropDetails)
  static const String waterUsage = '/api/wua-water-usages';
  static const String waterUsageSummary = '/api/wua-water-usages';
  static String canalRotations({
    required int societyId,
    String? fiscalYear,
    String sort = 'startDate,asc',
  }) {
    final yearFilter = fiscalYear != null ? '&sFiscalYear.equals=$fiscalYear' : '';
    return '/api/wua-water-usages?iSocietyId.equals=$societyId$yearFilter&sort=$sort';
  }
  static String farmerCropUsage({
    required int farmerMemberId,
    String? fiscalYear,
  }) {
    final yearFilter = fiscalYear != null ? '&fiscalYear.equals=$fiscalYear' : '';
    return '/api/crop-details?farmerMemberId.equals=$farmerMemberId$yearFilter';
  }

  // Irrigation Schedule (Maps to WUAWaterUsage)
  static const String irrigationSchedule = '/api/wua-water-usages';

  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';
  static String notificationDetail(String id) => '/notifications/$id';
}
