import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/features/payments/data/models/payment_model.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentModel>> getPayments({
    String? consumerId,
    String? status,
    String? query,
  });

  Future<PaymentModel> getPaymentById(String id);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  final List<PaymentModel> _mockPayments = [
    // 1. Paid Kharif Season Bill
    PaymentModel(
      id: 'pay_001',
      paymentNumber: 'REC/WUA/2024-25/0842',
      status: PaymentStatus.success,
      amount: 2360.0,
      paymentDate: DateTime(2026, 8, 14, 15, 30),
      billId: 'bill_kharif_2024_03',
      billNumber: 'WUA/PANI/2024-25/0319',
      consumerId: 'KISAN-MH-41201',
      consumerName: 'Ramesh Patil',
      wuaSocietyName: 'Ganga-Godavari WUA Society #12',
      season: 'Kharif Season (2024-25)',
      cropType: 'Sugarcane & Soybean',
      paymentMode: 'BHIM UPI (GPay)',
      gatewayTransactionId: 'UPI/WRD/20240814/894123',
      bankReference: 'HDFC000192837',
      gatewayName: 'MahaGov UPI Gateway',
      remarks: 'Online instant settlement via NPCI UPI.',
      metadata: const {
        'auth_code': 'APV-99214',
        'operator': 'Auto Clearing House',
      },
    ),

    // 2. Paid Summer Season Irrigation Bill
    PaymentModel(
      id: 'pay_002',
      paymentNumber: 'REC/WUA/2023-24/1102',
      status: PaymentStatus.success,
      amount: 840.0,
      paymentDate: DateTime(2026, 5, 2, 11, 15),
      billId: 'bill_summer_2024_04',
      billNumber: 'WUA/PANI/2023-24/1102',
      consumerId: 'KISAN-MH-41201',
      consumerName: 'Ramesh Patil',
      wuaSocietyName: 'Ganga-Godavari WUA Society #12',
      season: 'Summer Season (2023-24)',
      cropType: 'Fodder & Summer Vegetables',
      paymentMode: 'Net Banking (SBI)',
      gatewayTransactionId: 'NETBANK/WRD/20240502/102938',
      bankReference: 'SBIN88219401',
      gatewayName: 'State Bank NetBanking Gateway',
      remarks: 'Paid through SBI corporate net banking gateway.',
      metadata: const {
        'auth_code': 'SBIN-OK-4421',
      },
    ),

    // 3. Paid Previous Rabi Bill via Cash
    PaymentModel(
      id: 'pay_003',
      paymentNumber: 'REC/WUA/2023-24/0711',
      status: PaymentStatus.success,
      amount: 1225.0,
      paymentDate: DateTime(2025, 12, 10, 14, 0),
      billId: 'bill_rabi_2023_05',
      billNumber: 'WUA/PANI/2023-24/0711',
      consumerId: 'KISAN-MH-41201',
      consumerName: 'Ramesh Patil',
      wuaSocietyName: 'Ganga-Godavari WUA Society #12',
      season: 'Rabi Season (2023-24)',
      cropType: 'Wheat',
      paymentMode: 'Cash at Society Kendra',
      gatewayTransactionId: 'CASH/WUA/20251210/4482',
      bankReference: 'MANUAL-KENDRA-01',
      gatewayName: 'WUA Society Counter',
      remarks: 'Paid in cash directly at WUA Society Office, Shrirampur.',
      metadata: const {
        'treasurer_name': 'M. V. Shinde',
      },
    ),

    // 4. Advance Canal Turn Deposit
    PaymentModel(
      id: 'pay_004',
      paymentNumber: 'PAY/WUA/2026/ADV-001',
      status: PaymentStatus.success,
      amount: 500.0,
      paymentDate: DateTime(2026, 10, 5, 18, 45),
      consumerId: 'KISAN-MH-41201',
      consumerName: 'Ramesh Patil',
      wuaSocietyName: 'Ganga-Godavari WUA Society #12',
      season: 'Canal Rotation Advance Deposit',
      cropType: 'Wheat (Rabi)',
      paymentMode: 'UPI (PhonePe)',
      gatewayTransactionId: 'UPI/WRD/20261005/771923',
      bankReference: 'AXIS99318210',
      gatewayName: 'MahaGov UPI Gateway',
      remarks: 'Advance deposit credited towards upcoming Rabi 2nd rotation.',
    ),

    // 5. Failed Transaction Attempt
    PaymentModel(
      id: 'pay_005',
      paymentNumber: 'PAY/FAIL/2026/0912',
      status: PaymentStatus.failed,
      amount: 380.0,
      paymentDate: DateTime(2026, 10, 20, 10, 12),
      billId: 'bill_spec_2024_02',
      billNumber: 'WUA/MAINT/2024-25/0194',
      consumerId: 'KISAN-MH-41201',
      consumerName: 'Ramesh Patil',
      wuaSocietyName: 'Ganga-Godavari WUA Society #12',
      season: 'Annual Canal Desilting & Sluice Gate Cess',
      cropType: 'Command Area Maintenance',
      paymentMode: 'BHIM UPI',
      gatewayTransactionId: 'UPI/FAIL/20261020/00491',
      bankReference: 'NPCI_U30_TIMED_OUT',
      gatewayName: 'MahaGov UPI Gateway',
      remarks: 'Transaction timed out at user bank. No amount debited.',
    ),
  ];

  @override
  Future<List<PaymentModel>> getPayments({
    String? consumerId,
    String? status,
    String? query,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    AppLogger.repository(
      '📦 [PAYMENTS REMOTE] Fetching payments (status: $status, query: $query)',
    );

    var results = List<PaymentModel>.from(_mockPayments);

    if (consumerId != null && consumerId.isNotEmpty) {
      results = results
          .where((p) => p.consumerId?.toLowerCase() == consumerId.toLowerCase())
          .toList();
    }

    if (status != null && status.isNotEmpty && status.toUpperCase() != 'ALL') {
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

    // Sort by paymentDate descending
    results.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

    return results;
  }

  @override
  Future<PaymentModel> getPaymentById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    AppLogger.repository('📦 [PAYMENTS REMOTE] Fetching payment detail for id: $id');

    final payment = _mockPayments.firstWhere(
      (p) => p.id == id || p.paymentNumber == id,
      orElse: () => throw Exception('Payment with ID "$id" not found'),
    );

    return payment;
  }
}

