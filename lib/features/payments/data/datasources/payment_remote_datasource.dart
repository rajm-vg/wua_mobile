import 'package:dio/dio.dart';
import 'package:wua_mobile/core/errors/exceptions.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/core/network/api_endpoints.dart';
import 'package:wua_mobile/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:wua_mobile/features/bills/data/models/bill_model.dart';
import 'package:wua_mobile/features/payments/data/models/easebuzz_order_model.dart';
import 'package:wua_mobile/features/payments/data/models/easebuzz_verify_model.dart';
import 'package:wua_mobile/features/payments/data/models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentModel>> getPayments({
    String? consumerId,
    String? status,
    String? query,
  });

  Future<PaymentModel> getPaymentById(String id);

  Future<PaymentModel> processPayment(PaymentModel payment);

  Future<EasebuzzOrderResponse> createPaymentOrder(
    EasebuzzOrderRequest request,
  );

  Future<EasebuzzVerifyResponse> verifyPaymentOrder(
    EasebuzzVerifyRequest request,
  );

  Future<void> postReceiptEntry({
    required double amount,
    required String transactionRefNo,
    int? farmerMemberId,
    int? societyId,
    String? fiscalYear,
    String? season,
    String? remarks,
  });

  Future<String> getActivePaymentProvider();
}

/// Remote Payments data source connecting directly to `wrd_backend` (`/api/receipt-details`).
/// Pure live data; returns an empty list if no transactions exist.
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl({
    required this.apiClient,
    this.authLocalDataSource,
  });

  final ApiClient apiClient;
  final AuthLocalDataSource? authLocalDataSource;

  @override
  Future<List<PaymentModel>> getPayments({
    String? consumerId,
    String? status,
    String? query,
  }) async {
    AppLogger.repository(
      '📦 [PAYMENTS REMOTE] Fetching payments (consumerId: $consumerId, status: $status, query: $query)',
    );

    int? farmerId = int.tryParse(consumerId ?? '');
    int? societyId;
    String? cachedUserName;
    var isFarmer = true;

    if (authLocalDataSource != null) {
      try {
        final cachedUser = await authLocalDataSource!.getCachedUser();
        societyId = cachedUser.societyId;
        isFarmer = cachedUser.isFarmerMember;
        farmerId ??= cachedUser.effectiveFarmerMemberId;
        if (cachedUser.name.trim().isNotEmpty) {
          cachedUserName = cachedUser.name.trim();
        }
      } catch (_) {}
    }

    final endpoint = farmerId != null
        ? ApiEndpoints.receiptsHistory(farmerMemberId: farmerId)
        : (!isFarmer && societyId != null
              ? ApiEndpoints.societyReceiptsHistory(societyId: societyId)
              : ApiEndpoints.payments);

    final billsFuture = _fetchRelatedBills(
      farmerId: farmerId,
      societyId: societyId,
      isFarmer: isFarmer,
    );
    final response = await apiClient.get<dynamic>(endpoint);
    if (response.statusCode == 200 && response.data != null) {
      final items = ApiClient.extractListData(response.data);

      if (items.isNotEmpty) {
        final bills = await billsFuture;
        final remotePayments = items
            .map(PaymentModel.fromJson)
            .map(
              (p) => _enrichPayment(
                p,
                bills: bills,
                cachedUserName: cachedUserName,
              ),
            )
            .toList();

        var results = remotePayments;
        if (consumerId != null && consumerId.isNotEmpty) {
          results = results
              .where(
                (p) => p.consumerId?.toLowerCase() == consumerId.toLowerCase(),
              )
              .toList();
        }

        if (status != null &&
            status.isNotEmpty &&
            status.toUpperCase() != 'ALL') {
          final s = status.toUpperCase();
          results = results.where((p) => p.status.toUpperCase() == s).toList();
        }

        if (query != null && query.trim().isNotEmpty) {
          final q = query.trim().toLowerCase();
          results = results.where((p) {
            return p.paymentNumber.toLowerCase().contains(q) ||
                p.season.toLowerCase().contains(q) ||
                (p.gatewayTransactionId?.toLowerCase().contains(q) ?? false) ||
                (p.billNumber?.toLowerCase().contains(q) ?? false) ||
                p.paymentMode.toLowerCase().contains(q);
          }).toList();
        }

        results.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
        return results;
      }
    }
    return const <PaymentModel>[];
  }

  @override
  Future<PaymentModel> getPaymentById(String id) async {
    AppLogger.repository(
      '📦 [PAYMENTS REMOTE] Fetching payment detail for id: $id',
    );

    try {
      final endpoint = ApiEndpoints.paymentDetail(id);
      final response = await apiClient.get<Map<String, dynamic>>(endpoint);
      if (response.statusCode == 200 && response.data != null) {
        final payment = PaymentModel.fromJson(response.data!);
        String? cachedUserName;
        int? farmerId = payment.farmerMemberId;
        int? societyId = payment.societyId;
        var isFarmer = true;
        if (authLocalDataSource != null) {
          try {
            final cachedUser = await authLocalDataSource!.getCachedUser();
            cachedUserName = cachedUser.name.trim().isNotEmpty
                ? cachedUser.name.trim()
                : null;
            farmerId ??= cachedUser.effectiveFarmerMemberId;
            societyId ??= cachedUser.societyId;
            isFarmer = cachedUser.isFarmerMember;
          } catch (_) {}
        }
        final bills = await _fetchRelatedBills(
          farmerId: farmerId,
          societyId: societyId,
          isFarmer: isFarmer,
        );
        return _enrichPayment(
          payment,
          bills: bills,
          cachedUserName: cachedUserName,
        );
      }
    } catch (e) {
      AppLogger.warning('Payment detail API error: $e');
    }

    throw ServerException(message: 'Payment with ID "$id" not found');
  }

  @override
  Future<PaymentModel> processPayment(PaymentModel payment) async {
    AppLogger.repository(
      '📦 [PAYMENTS REMOTE] Processing payment: ${payment.paymentNumber}',
    );

    int? farmerId =
        int.tryParse(payment.consumerId ?? '') ?? payment.farmerMemberId;
    int? societyId = payment.societyId;
    String? farmerName = payment.consumerName;
    final String? wuaName = payment.wuaSocietyName;
    if (authLocalDataSource != null &&
        (farmerId == null || societyId == null)) {
      try {
        final cachedUser = await authLocalDataSource!.getCachedUser();
        farmerId ??= cachedUser.refTableId ?? int.tryParse(cachedUser.id);
        societyId ??= cachedUser.societyId;
        farmerName ??= cachedUser.name;
      } catch (_) {}
    }

    final receiptPayload = {
      'nAmount': payment.amount,
      'dReceiptDate': payment.paymentDate.toIso8601String(),
      'sInstrumentType': payment.paymentMode.toUpperCase().contains('UPI')
          ? 'UPI'
          : 'ONLINE',
      'sTransactionId': payment.gatewayTransactionId ?? payment.paymentNumber,
      'billNo': int.tryParse(payment.billId ?? '') ?? payment.billId,
      'iFarmerMemberId': farmerId,
      'iSocietyId': societyId,
      'sFarmerName': farmerName,
      'sWuaName': wuaName,
      'sStatus': 'A',
    };

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.postReceiptDetails,
        data: receiptPayload,
      );
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        return PaymentModel.fromJson(response.data!);
      }
    } catch (e) {
      AppLogger.warning('Process payment API error: $e');
    }

    return payment;
  }

  @override
  Future<EasebuzzOrderResponse> createPaymentOrder(
    EasebuzzOrderRequest request,
  ) async {
    AppLogger.repository(
      '📦 [PAYMENTS REMOTE] Creating payment order for: ${request.amount} (provider: ${request.provider}, billId: ${request.billId})',
    );

    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.createPaymentOrder,
      data: request.toJson(),
    );
    if (response.statusCode == 200 && response.data != null) {
      final order = EasebuzzOrderResponse.fromJson(response.data!);
      AppLogger.repository(
        '📦 [PAYMENTS REMOTE] Order created: txn=${order.transactionId}, provider=${order.provider}, accessKeyLen=${order.accessKey.length}',
      );
      return order;
    }

    throw const ServerException(
      message: 'Unable to initiate payment with gateway server.',
    );
  }

  @override
  Future<EasebuzzVerifyResponse> verifyPaymentOrder(
    EasebuzzVerifyRequest request,
  ) async {
    AppLogger.repository(
      '📦 [PAYMENTS REMOTE] Verifying payment for transaction: ${request.transactionId}',
    );

    final response = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.verifyPaymentOrder,
      data: request.toJson(),
    );
    if (response.statusCode == 200 && response.data != null) {
      return EasebuzzVerifyResponse.fromJson(response.data!);
    }

    return const EasebuzzVerifyResponse(
      verified: false,
      message: 'Verification response empty.',
    );
  }

  @override
  Future<void> postReceiptEntry({
    required double amount,
    required String transactionRefNo,
    int? farmerMemberId,
    int? societyId,
    String? fiscalYear,
    String? season,
    String? remarks,
  }) async {
    int? resolvedMemberId = farmerMemberId;
    int? resolvedSocietyId = societyId;

    if (authLocalDataSource != null &&
        (resolvedMemberId == null || resolvedSocietyId == null)) {
      try {
        final cachedUser = await authLocalDataSource!.getCachedUser();
        resolvedMemberId ??= cachedUser.effectiveFarmerMemberId;
        resolvedSocietyId ??= cachedUser.societyId;
      } catch (_) {}
    }

    int? bankLedgerId;
    if (resolvedSocietyId != null) {
      try {
        final ledgerRes = await apiClient.get<dynamic>(
          ApiEndpoints.bankLedgers(societyId: resolvedSocietyId),
        );
        if (ledgerRes.statusCode == 200 && ledgerRes.data != null) {
          final ledgers = ApiClient.extractListData(ledgerRes.data);
          if (ledgers.isNotEmpty) {
            final rawId = ledgers.first['id'];
            bankLedgerId = rawId is int
                ? rawId
                : int.tryParse(rawId?.toString() ?? '');
          }
        }
      } catch (e) {
        AppLogger.warning(
          'Unable to fetch bank ledger for society $resolvedSocietyId: $e',
        );
      }
    }

    final payload = <String, dynamic>{
      'societyId': ?resolvedSocietyId,
      'farmerMemberId': ?resolvedMemberId,
      'tranDate': DateTime.now().toUtc().toIso8601String(),
      if (fiscalYear != null && fiscalYear.isNotEmpty) 'fiscalYear': fiscalYear,
      'receiptAmount': double.parse(amount.toStringAsFixed(2)),
      'instrumentType': 'Online',
      'transactionType': 'Online',
      if (season != null && season.isNotEmpty && season != 'N/A')
        'season': season,
      'bankLedgerId': ?bankLedgerId,
      'transactionRefNo': transactionRefNo,
      if (remarks != null && remarks.isNotEmpty) 'remark': remarks,
    };

    AppLogger.repository(
      '📦 [PAYMENTS REMOTE] Posting receipt entry: amount=$amount, fiscalYear=$fiscalYear, bankLedgerId=$bankLedgerId, ref=$transactionRefNo',
    );

    final response = await apiClient.post<dynamic>(
      ApiEndpoints.postReceiptEntryRequest,
      data: payload,
      options: Options(responseType: ResponseType.plain),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw const ServerException(
        message: 'Payment succeeded, but receipt settlement failed on server.',
      );
    }
  }

  @override
  Future<String> getActivePaymentProvider() async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.activePaymentProvider,
      );
      if (response.statusCode == 200 && response.data != null) {
        return (response.data!['activeProvider'] as String?) ?? 'EASEBUZZ';
      }
    } catch (e) {
      AppLogger.warning(
        'Get active provider error ($e). Defaulting to EASEBUZZ.',
      );
    }
    return 'EASEBUZZ';
  }

  Future<List<BillModel>> _fetchRelatedBills({
    required int? farmerId,
    required int? societyId,
    required bool isFarmer,
  }) async {
    try {
      final billEndpoint = farmerId != null
          ? ApiEndpoints.memberBillDetails(farmerMemberId: farmerId)
          : (!isFarmer && societyId != null
                ? ApiEndpoints.societyBillDetails(societyId: societyId)
                : null);
      if (billEndpoint == null) return const [];
      final billRes = await apiClient.get<dynamic>(billEndpoint);
      if (billRes.statusCode == 200 && billRes.data != null) {
        return ApiClient.extractListData(billRes.data)
            .map(BillModel.fromJson)
            .toList();
      }
    } catch (e) {
      AppLogger.warning(
        'Unable to fetch related bills for payment enrichment: $e',
      );
    }
    return const [];
  }

  PaymentModel _enrichPayment(
    PaymentModel payment, {
    required List<BillModel> bills,
    String? cachedUserName,
  }) {
    BillModel? matchedBill;
    if (payment.billId != null && bills.isNotEmpty) {
      for (final b in bills) {
        if (b.id == payment.billId) {
          matchedBill = b;
          break;
        }
      }
    }

    String? fallbackSocietyName;
    String? fallbackConsumerName;
    for (final b in bills) {
      fallbackSocietyName ??= b.wuaSocietyName;
      fallbackConsumerName ??= b.consumerName;
      if (fallbackSocietyName != null && fallbackConsumerName != null) break;
    }

    final resolvedConsumerName =
        payment.consumerName ??
        matchedBill?.consumerName ??
        fallbackConsumerName ??
        cachedUserName;
    final resolvedSocietyName =
        payment.wuaSocietyName ??
        matchedBill?.wuaSocietyName ??
        fallbackSocietyName;
    final resolvedBillNumber = payment.billNumber ?? matchedBill?.billNumber;

    final resolvedSeason =
        (payment.season != 'N/A' && payment.season.isNotEmpty)
        ? payment.season
        : (matchedBill != null && matchedBill.season != 'N/A'
              ? matchedBill.season
              : (payment.fiscalYear != null
                    ? 'FY ${payment.fiscalYear}'
                    : 'N/A'));

    final resolvedCrop =
        (payment.cropType != 'N/A' && payment.cropType.isNotEmpty)
        ? payment.cropType
        : (matchedBill?.cropType ?? 'N/A');

    String resolvedGateway = payment.gatewayName;
    if (resolvedGateway == 'N/A' || resolvedGateway.isEmpty) {
      final txn = payment.gatewayTransactionId ?? '';
      final modeUpper = payment.paymentMode.toUpperCase();
      if (txn.startsWith('TXN_EASE_')) {
        resolvedGateway = 'Easebuzz Payment Gateway';
      } else if (txn.startsWith('pay_') || txn.startsWith('order_')) {
        resolvedGateway = 'Razorpay';
      } else if (modeUpper == 'CASH' || modeUpper == 'BANK') {
        resolvedGateway = 'WUA Society Counter';
      } else if (modeUpper == 'ONLINE' || modeUpper == 'UPI') {
        resolvedGateway = 'Online Payment Gateway';
      }
    }

    return PaymentModel(
      id: payment.id,
      paymentNumber: payment.paymentNumber,
      status: payment.status,
      amount: payment.amount,
      paymentDate: payment.paymentDate,
      billId: payment.billId,
      billNumber: resolvedBillNumber,
      consumerId: payment.consumerId ?? payment.farmerMemberId?.toString(),
      consumerName: resolvedConsumerName,
      wuaSocietyName: resolvedSocietyName,
      season: resolvedSeason,
      cropType: resolvedCrop,
      paymentMode: payment.paymentMode,
      gatewayTransactionId: payment.gatewayTransactionId,
      bankReference: payment.bankReference,
      gatewayName: resolvedGateway,
      remarks: payment.remarks,
      metadata: payment.metadata,
      farmerMemberId: payment.farmerMemberId,
      societyId: payment.societyId,
      fiscalYear: payment.fiscalYear,
      valueDate: payment.valueDate,
      instrumentType: payment.instrumentType,
      receiptNo: payment.receiptNo,
      bankLedgerId: payment.bankLedgerId,
      glTranId: payment.glTranId,
      rawStatus: payment.rawStatus,
    );
  }
}
