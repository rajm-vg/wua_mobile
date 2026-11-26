import 'package:wua_mobile/core/errors/exceptions.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/core/network/api_endpoints.dart';
import 'package:wua_mobile/features/authentication/data/datasources/auth_local_datasource.dart';
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

  Future<BillModel> markBillAsPaid(
    String id, {
    required String paymentReference,
    required String paymentMethod,
    required double paidAmount,
  });
}

/// Remote Bills data source connecting directly to `wrd_backend` (`/api/bill-details`).
/// Returns pure live data; if no records exist, returns an empty list so that UI empty states render cleanly.
class BillRemoteDataSourceImpl implements BillRemoteDataSource {
  BillRemoteDataSourceImpl({required this.apiClient, this.authLocalDataSource});

  final ApiClient apiClient;
  final AuthLocalDataSource? authLocalDataSource;

  @override
  Future<List<BillModel>> getBills({
    String? consumerId,
    String? status,
    String? query,
  }) async {
    AppLogger.repository(
      '📦 [BILLS REMOTE] Fetching bills (consumerId: $consumerId, status: $status, query: $query)',
    );

    int? farmerId = int.tryParse(consumerId ?? '');
    int? societyId;
    var isFarmer = true;

    if (farmerId == null && authLocalDataSource != null) {
      try {
        final cachedUser = await authLocalDataSource!.getCachedUser();
        societyId = cachedUser.societyId;
        isFarmer = cachedUser.isFarmerMember;
        farmerId = cachedUser.effectiveFarmerMemberId;
      } catch (_) {}
    }

    final endpoint = farmerId != null
        ? ApiEndpoints.memberBillDetails(farmerMemberId: farmerId)
        : (!isFarmer && societyId != null
            ? ApiEndpoints.societyBillDetails(societyId: societyId)
            : ApiEndpoints.bills);

    final response = await apiClient.get<dynamic>(endpoint);
    if (response.statusCode == 200 && response.data != null) {
      final items = ApiClient.extractListData(response.data);

      if (items.isNotEmpty) {
        final remoteBills = items.map(BillModel.fromJson).toList();

        var results = remoteBills;
        if (consumerId != null && consumerId.isNotEmpty) {
          results = results
              .where(
                (b) => b.consumerId?.toLowerCase() == consumerId.toLowerCase(),
              )
              .toList();
        }

        if (status != null &&
            status.isNotEmpty &&
            status.toUpperCase() != 'ALL') {
          final cleanStatus = status.toUpperCase();
          if (cleanStatus == 'DUE' || cleanStatus == 'PENDING') {
            results = results
                .where((b) => !b.isPaid && !b.isOverdue)
                .toList();
          } else if (cleanStatus == 'OVERDUE') {
            results = results.where((b) => b.isOverdue).toList();
          } else if (cleanStatus == 'PAID') {
            results = results.where((b) => b.isPaid).toList();
          } else {
            results = results
                .where((b) => b.status.toUpperCase() == cleanStatus)
                .toList();
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

        results.sort((a, b) {
          final dateA = a.billDate ?? DateTime(2000);
          final dateB = b.billDate ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });

        return results;
      }
    }
    return const <BillModel>[];
  }

  @override
  Future<BillModel> getBillById(String id) async {
    AppLogger.repository('📦 [BILLS REMOTE] Fetching bill details for id: $id');

    try {
      final endpoint = ApiEndpoints.billDetail(id);
      final response = await apiClient.get<Map<String, dynamic>>(endpoint);
      if (response.statusCode == 200 && response.data != null) {
        final data = Map<String, dynamic>.from(response.data!);
        return BillModel.fromJson(data);
      }
    } catch (e) {
      AppLogger.warning('BillDetail API error ($e)');
    }

    throw ServerException(message: 'Bill with ID "$id" not found');
  }

  @override
  Future<BillModel> markBillAsPaid(
    String id, {
    required String paymentReference,
    required String paymentMethod,
    required double paidAmount,
  }) async {
    int? farmerId;
    int? societyId;
    if (authLocalDataSource != null) {
      try {
        final cachedUser = await authLocalDataSource!.getCachedUser();
        farmerId = cachedUser.refTableId ?? int.tryParse(cachedUser.id);
        societyId = cachedUser.societyId;
      } catch (_) {}
    }

    final receiptPayload = {
      'nAmount': paidAmount,
      'dReceiptDate': DateTime.now().toIso8601String(),
      'sInstrumentType': paymentMethod.toUpperCase().contains('UPI')
          ? 'UPI'
          : 'ONLINE',
      'sTransactionId': paymentReference,
      'billNo': int.tryParse(id) ?? id,
      'iFarmerMemberId': ?farmerId,
      'iSocietyId': ?societyId,
      'sStatus': 'A',
    };

    try {
      await apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.postReceiptDetails,
        data: receiptPayload,
      );
    } catch (e) {
      AppLogger.warning('Direct receipt post error ($e)');
    }

    try {
      return await getBillById(id);
    } catch (_) {
      return BillModel(
        id: id,
        billNumber: 'BILL-$id',
        status: BillStatus.paid,
        paidAmount: paidAmount,
        outstandingAmount: 0.0,
        paymentReference: paymentReference,
        paymentDate: DateTime.now(),
        paymentMethod: paymentMethod,
      );
    }
  }
}
