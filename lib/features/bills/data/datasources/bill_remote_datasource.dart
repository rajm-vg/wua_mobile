import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/features/bills/data/models/bill_model.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';

/// Contract for remote Bills operations.
abstract class BillRemoteDataSource {
  Future<List<BillModel>> getBills({
    String? consumerId,
    String? status,
    String? query,
  });

  Future<BillModel> getBillById(String id);
}

/// Remote Bills data source with simulated WUA & WRD irrigation backend dataset.
/// Integrates with [ApiClient] and supports offline/development mock datasets.
class BillRemoteDataSourceImpl implements BillRemoteDataSource {
  BillRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  // In-memory simulated database for realistic stateful actions during the session.
  final List<BillModel> _mockBills = [
    // 1. Current Active Rabi Bill (matches Dashboard PaniPattiBillCard)
    BillModel(
      id: 'bill_rabi_2024_01',
      billNumber: 'WUA/PANI/2024-25/0842',
      status: BillStatus.pending,
      consumerId: 'KISAN-MH-41201',
      consumerName: 'Ramesh Patil',
      wuaSocietyName: 'Ganga-Godavari WUA Society #12',
      canalSection: 'Minor-3 (Outlet 4B), Distributary 7',
      season: 'Rabi Season (2024-25)',
      cropType: 'Wheat (गहू) & Gram',
      landAreaAcres: 4.5,
      waterQuantityLiters: 18500,
      rotationsCount: 3,
      billDate: DateTime(2026, 10, 15),
      dueDate: DateTime(2026, 11, 25),
      subtotal: 1110.0,
      taxes: 90.0,
      maintenanceCess: 40.0,
      penalties: 0.0,
      interestAmount: 0.0,
      discounts: 0.0,
      adjustmentAmount: 0.0,
      totalAmount: 1240.0,
      paidAmount: 0.0,
      outstandingAmount: 1240.0,
      notes: 'Please clear dues before 25 Nov to maintain uninterrupted canal rotational turn.',
      metadata: const {
        'meter_reading_start': 10420,
        'meter_reading_end': 12270,
        'water_gauge_officer': 'S. K. Deshmukh',
      },
    ),

    // 2. Overdue Canal Desilting & Maintenance Bill
    BillModel(
      id: 'bill_spec_2024_02',
      billNumber: 'WUA/MAINT/2024-25/0194',
      status: BillStatus.overdue,
      consumerId: 'KISAN-MH-41201',
      consumerName: 'Ramesh Patil',
      wuaSocietyName: 'Ganga-Godavari WUA Society #12',
      canalSection: 'Minor-3, Outlet 4B',
      season: 'Annual Canal Desilting & Sluice Gate Cess',
      cropType: 'Command Area Maintenance',
      landAreaAcres: 4.5,
      waterQuantityLiters: 0,
      rotationsCount: 0,
      billDate: DateTime(2026, 9, 1),
      dueDate: DateTime(2026, 10, 15),
      subtotal: 300.0,
      taxes: 30.0,
      maintenanceCess: 0.0,
      penalties: 50.0,
      interestAmount: 0.0,
      discounts: 0.0,
      adjustmentAmount: 0.0,
      totalAmount: 380.0,
      paidAmount: 0.0,
      outstandingAmount: 380.0,
      notes: 'Overdue grace period expired on 15 Oct. Late penalty of ₹50 applied.',
      metadata: const {
        'resolution_no': 'WUA-RES-2024-88',
      },
    ),

    // 3. Paid Kharif Bill (matches Dashboard Recent Activity)
    BillModel(
      id: 'bill_kharif_2024_03',
      billNumber: 'WUA/PANI/2024-25/0319',
      status: BillStatus.paid,
      consumerId: 'KISAN-MH-41201',
      consumerName: 'Ramesh Patil',
      wuaSocietyName: 'Ganga-Godavari WUA Society #12',
      canalSection: 'Minor-3 (Outlet 4B), Distributary 7',
      season: 'Kharif Season (2024-25)',
      cropType: 'Sugarcane & Soybean',
      landAreaAcres: 5.0,
      waterQuantityLiters: 28400,
      rotationsCount: 4,
      billDate: DateTime(2026, 7, 10),
      dueDate: DateTime(2026, 8, 20),
      subtotal: 2150.0,
      taxes: 180.0,
      maintenanceCess: 80.0,
      penalties: 0.0,
      interestAmount: 0.0,
      discounts: 50.0, // Early payment rebate
      adjustmentAmount: 0.0,
      totalAmount: 2360.0,
      paidAmount: 2360.0,
      outstandingAmount: 0.0,
      paymentReference: 'UPI/WRD/20240814/894123',
      paymentDate: DateTime(2026, 8, 14, 15, 30),
      paymentMethod: 'BHIM UPI (GPay)',
      notes: 'Early payment incentive rebate of ₹50 applied. Payment verified by WUA Treasurer.',
      metadata: const {
        'receipt_no': 'REC-WUA-2024-K089',
        'auth_code': 'APV-99214',
      },
    ),

    // 4. Paid Summer Irrigation Bill
    BillModel(
      id: 'bill_summer_2024_04',
      billNumber: 'WUA/PANI/2023-24/1102',
      status: BillStatus.paid,
      consumerId: 'KISAN-MH-41201',
      consumerName: 'Ramesh Patil',
      wuaSocietyName: 'Ganga-Godavari WUA Society #12',
      canalSection: 'Minor-3 (Outlet 4B), Distributary 7',
      season: 'Summer Season (2023-24)',
      cropType: 'Fodder & Summer Vegetables',
      landAreaAcres: 2.5,
      waterQuantityLiters: 9800,
      rotationsCount: 2,
      billDate: DateTime(2026, 4, 12),
      dueDate: DateTime(2026, 5, 25),
      subtotal: 750.0,
      taxes: 60.0,
      maintenanceCess: 30.0,
      penalties: 0.0,
      interestAmount: 0.0,
      discounts: 0.0,
      adjustmentAmount: 0.0,
      totalAmount: 840.0,
      paidAmount: 840.0,
      outstandingAmount: 0.0,
      paymentReference: 'NETBANK/WRD/20240502/102938',
      paymentDate: DateTime(2026, 5, 2, 11, 15),
      paymentMethod: 'Net Banking (SBI)',
      notes: 'Paid via State Bank of India NetBanking portal.',
      metadata: const {
        'receipt_no': 'REC-WUA-2024-S041',
      },
    ),

    // 5. Previous Year Rabi Bill
    BillModel(
      id: 'bill_rabi_2023_05',
      billNumber: 'WUA/PANI/2023-24/0711',
      status: BillStatus.paid,
      consumerId: 'KISAN-MH-41201',
      consumerName: 'Ramesh Patil',
      wuaSocietyName: 'Ganga-Godavari WUA Society #12',
      canalSection: 'Minor-3 (Outlet 4B)',
      season: 'Rabi Season (2023-24)',
      cropType: 'Wheat',
      landAreaAcres: 4.5,
      waterQuantityLiters: 17800,
      rotationsCount: 3,
      billDate: DateTime(2025, 11, 5),
      dueDate: DateTime(2025, 12, 20),
      subtotal: 1100.0,
      taxes: 85.0,
      maintenanceCess: 40.0,
      penalties: 0.0,
      interestAmount: 0.0,
      discounts: 0.0,
      adjustmentAmount: 0.0,
      totalAmount: 1225.0,
      paidAmount: 1225.0,
      outstandingAmount: 0.0,
      paymentReference: 'CASH/WUA/20251210/4482',
      paymentDate: DateTime(2025, 12, 10, 14, 00),
      paymentMethod: 'Cash at Society Kendra',
      notes: 'Paid in cash directly at WUA Society Office, Shrirampur.',
      metadata: const {
        'receipt_no': 'REC-WUA-2023-R077',
      },
    ),
  ];

  @override
  Future<List<BillModel>> getBills({
    String? consumerId,
    String? status,
    String? query,
  }) async {
    // Simulated realistic network delay
    await Future<void>.delayed(const Duration(milliseconds: 350));

    AppLogger.repository(
      '📦 [BILLS REMOTE] Fetching bills (status: $status, query: $query)',
    );

    var results = List<BillModel>.from(_mockBills);

    if (consumerId != null && consumerId.isNotEmpty) {
      results = results
          .where((b) => b.consumerId?.toLowerCase() == consumerId.toLowerCase())
          .toList();
    }

    if (status != null && status.isNotEmpty && status.toUpperCase() != 'ALL') {
      final cleanStatus = status.toUpperCase();
      if (cleanStatus == 'DUE' || cleanStatus == 'PENDING') {
        results = results.where((b) => !b.isPaid && !b.isOverdue).toList();
      } else if (cleanStatus == 'OVERDUE') {
        results = results.where((b) => b.isOverdue).toList();
      } else if (cleanStatus == 'PAID') {
        results = results.where((b) => b.isPaid).toList();
      } else {
        results = results.where((b) => b.status.toUpperCase() == cleanStatus).toList();
      }
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results.where((b) {
        return b.billNumber.toLowerCase().contains(q) ||
            b.season.toLowerCase().contains(q) ||
            b.cropType.toLowerCase().contains(q) ||
            (b.wuaSocietyName?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    // Sort by billDate descending (most recent first)
    results.sort((a, b) {
      final dateA = a.billDate ?? DateTime(2000);
      final dateB = b.billDate ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

    return results;
  }

  @override
  Future<BillModel> getBillById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    AppLogger.repository('📦 [BILLS REMOTE] Fetching bill details for id: $id');

    final bill = _mockBills.firstWhere(
      (b) => b.id == id || b.billNumber == id,
      orElse: () => throw Exception('Bill with ID "$id" not found'),
    );

    return bill;
  }
}

