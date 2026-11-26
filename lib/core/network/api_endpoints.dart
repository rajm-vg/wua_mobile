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
  static const String forgotPassword = '/api/generate-OTP';
  static const String resetPassword = '/api/change-password';
  static const String accountChangePassword = '/api/account/change-password';
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

  // Water Tax Bills (BillDetails for Member Payments)
  static const String bills = '/api/bill-details';
  static String billDetail(String id) => '/api/bill-details/$id';
  static String memberBillDetails({
    required int farmerMemberId,
    bool? isPaymentDone,
    String? fiscalYear,
    int page = 0,
    int size = 100,
    String sort = 'id,desc',
  }) {
    final paymentFilter = isPaymentDone != null
        ? '&isPaymentDone.equals=$isPaymentDone'
        : '';
    final fiscalYearFilter = fiscalYear != null
        ? '&sFiscalYear.equals=$fiscalYear'
        : '';
    return '/api/bill-details?iFarmerMemberId.equals=$farmerMemberId$paymentFilter$fiscalYearFilter&page=$page&size=$size&sort=$sort';
  }

  static String societyBillDetails({
    required int societyId,
    bool? isPaymentDone,
    String? fiscalYear,
    int page = 0,
    int size = 100,
    String sort = 'id,desc',
  }) {
    final paymentFilter = isPaymentDone != null
        ? '&isPaymentDone.equals=$isPaymentDone'
        : '';
    final fiscalYearFilter = fiscalYear != null
        ? '&sFiscalYear.equals=$fiscalYear'
        : '';
    return '/api/bill-details?iSocietyId.equals=$societyId$paymentFilter$fiscalYearFilter&page=$page&size=$size&sort=$sort';
  }

  static String billHeaders({
    required int farmerMemberId,
    bool? isPaymentDone,
    int page = 0,
    int size = 100,
    String sort = 'id,desc',
  }) => memberBillDetails(
    farmerMemberId: farmerMemberId,
    isPaymentDone: isPaymentDone,
    page: page,
    size: size,
    sort: sort,
  );

  static String billHeaderDetail(int id) => '/api/bill-details/$id';
  static String billDetails({required int billHeaderId}) =>
      '/api/bill-details?iBillNo.equals=$billHeaderId';

  // Payments & Receipts (ReceiptDetails & PostReceiptEntry)
  static const String payments = '/api/receipt-details';
  static const String postReceiptDetails = '/api/receipt-details';
  static const String postReceiptEntryRequest =
      '/api/post-receipt-entry/request';
  static String bankLedgers({required int societyId}) =>
      '/api/account-registrations?iSocietyId.equals=$societyId&sAccountClass.equals=Bank';
  static const String initiatePayment = '/api/post-receipt-entry/request';
  static const String verifyPayment = '/api/receipt-details';
  static String paymentDetail(String id) => '/api/receipt-details/$id';
  static String receiptsHistory({
    required int farmerMemberId,
    int page = 0,
    int size = 100,
    String sort = 'dReceiptDate,desc',
  }) =>
      '/api/receipt-details?iFarmerMemberId.equals=$farmerMemberId&page=$page&size=$size&sort=$sort';

  static String societyReceiptsHistory({
    required int societyId,
    int page = 0,
    int size = 100,
    String sort = 'dReceiptDate,desc',
  }) =>
      '/api/receipt-details?iSocietyId.equals=$societyId&page=$page&size=$size&sort=$sort';

  // Online Payment Gateways (Easebuzz & Razorpay via PaymentResource)
  static const String activePaymentProvider = '/api/payments/active-provider';
  static const String createPaymentOrder = '/api/payments/create-order';
  static const String verifyPaymentOrder = '/api/payments/verify';
  static String paymentTransaction(String id) =>
      '/api/payments/transaction/$id';

  // Canal Water Rotations & Crop Allocation (WUAWaterUsage & CropDetails)
  static const String waterUsage = '/api/wua-water-usages';
  static const String waterUsageSummary = '/api/wua-water-usages';
  static String canalRotations({
    required int societyId,
    String? fiscalYear,
    String sort = 'startDate,asc',
  }) {
    final yearFilter = fiscalYear != null
        ? '&sFiscalYear.equals=$fiscalYear'
        : '';
    return '/api/wua-water-usages?iSocietyId.equals=$societyId$yearFilter&sort=$sort';
  }

  static String farmerCropUsage({
    required int farmerMemberId,
    String? fiscalYear,
    int page = 0,
    int size = 500,
    String sort = 'id,desc',
  }) {
    final yearFilter = fiscalYear != null
        ? '&fiscalYear.equals=$fiscalYear'
        : '';
    return '/api/crop-details?farmerMemberId.equals=$farmerMemberId$yearFilter&page=$page&size=$size&sort=$sort';
  }

  static String societyCropUsage({
    required int societyId,
    String? fiscalYear,
    int page = 0,
    int size = 500,
    String sort = 'id,desc',
  }) {
    final yearFilter = fiscalYear != null
        ? '&fiscalYear.equals=$fiscalYear'
        : '';
    return '/api/crop-details?societyId.equals=$societyId$yearFilter&page=$page&size=$size&sort=$sort';
  }

  static const String cropDetails = '/api/crop-details';
  static const String waterUsagesOutward = '/api/water-usages';

  static String outwardWaterUsages({
    required int farmerMemberId,
    String? fiscalYear,
    int page = 0,
    int size = 500,
    String sort = 'id,desc',
  }) {
    final yearFilter = fiscalYear != null
        ? '&fiscalYear.equals=$fiscalYear'
        : '';
    return '/api/water-usages?farmerMemberId.equals=$farmerMemberId$yearFilter&page=$page&size=$size&sort=$sort';
  }

  static String societyOutwardWaterUsages({
    required int societyId,
    String? fiscalYear,
    int page = 0,
    int size = 500,
    String sort = 'id,desc',
  }) {
    final yearFilter = fiscalYear != null
        ? '&fiscalYear.equals=$fiscalYear'
        : '';
    return '/api/water-usages?societyId.equals=$societyId$yearFilter&page=$page&size=$size&sort=$sort';
  }

  // Irrigation Schedule (Maps to WUAWaterUsage)
  static const String irrigationSchedule = '/api/wua-water-usages';

  // Notifications
  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications/read';
  static String notificationDetail(String id) => '/notifications/$id';
}
