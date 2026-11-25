import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Status constants for Payments.
class PaymentStatus {
  PaymentStatus._();

  static const String success = 'SUCCESS';
  static const String pending = 'PENDING';
  static const String failed = 'FAILED';
  static const String refunded = 'REFUNDED';

  static String toLabel(String status) {
    switch (status.toUpperCase()) {
      case success:
        return 'Successful';
      case pending:
        return 'Processing / Pending';
      case failed:
        return 'Failed';
      case refunded:
        return 'Refunded';
      default:
        return status;
    }
  }
}

/// Core domain entity representing a WUA Irrigation Bill payment transaction aligned with `receipt_details`.
class PaymentEntity extends Equatable {
  const PaymentEntity({
    required this.id,
    required this.paymentNumber,
    required this.status,
    required this.amount,
    required this.paymentDate,
    this.billId,
    this.billNumber,
    this.consumerId,
    this.consumerName,
    this.wuaSocietyName,
    this.season = 'N/A',
    this.cropType = 'N/A',
    this.paymentMode = 'N/A',
    this.gatewayTransactionId,
    this.bankReference,
    this.gatewayName = 'N/A',
    this.remarks,
    this.metadata,
    this.farmerMemberId,
    this.societyId,
    this.fiscalYear,
    this.valueDate,
    this.instrumentType,
    this.receiptNo,
    this.bankLedgerId,
    this.glTranId,
    this.rawStatus,
  });

  final String id;
  final String paymentNumber;
  final String status;
  final double amount;
  final DateTime paymentDate;
  final String? billId;
  final String? billNumber;
  final String? consumerId;
  final String? consumerName;
  final String? wuaSocietyName;
  final String season;
  final String cropType;
  final String paymentMode;
  final String? gatewayTransactionId;
  final String? bankReference;
  final String gatewayName;
  final String? remarks;
  final Map<String, dynamic>? metadata;

  // ─── Database Fields from `receipt_details` (vgwaterresource) ───
  final int? farmerMemberId;
  final int? societyId;
  final String? fiscalYear;
  final DateTime? valueDate;
  final String? instrumentType;
  final int? receiptNo;
  final int? bankLedgerId;
  final int? glTranId;
  final String? rawStatus;

  // ─── Semantic Status Helpers ─────────────────────────────────

  bool get isSuccess => status.toUpperCase() == PaymentStatus.success;
  bool get isPending => status.toUpperCase() == PaymentStatus.pending;
  bool get isFailed => status.toUpperCase() == PaymentStatus.failed;
  bool get isRefunded => status.toUpperCase() == PaymentStatus.refunded;

  /// Effective Indian Fiscal Year (e.g. "2026-2027").
  /// Uses backend `fiscalYear` when available, otherwise derives it from `paymentDate`
  /// (April-March cycle).
  String get effectiveFiscalYear {
    final fy = fiscalYear?.trim();
    if (fy != null && fy.isNotEmpty) return fy;
    final startYear = paymentDate.month >= 4 ? paymentDate.year : paymentDate.year - 1;
    return '$startYear-${startYear + 1}';
  }

  /// Formatted date string (e.g. "14 Aug 2026, 03:30 PM").
  String get formattedDateTime {
    return DateFormat('dd MMM yyyy, hh:mm a').format(paymentDate);
  }

  /// Formatted date only string (e.g. "14 Aug 2026").
  String get formattedDate {
    return DateFormat('dd MMM yyyy').format(paymentDate);
  }

  /// Formatted currency (e.g. "₹ 2,360").
  String get formattedAmount {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return format.format(amount);
  }

  PaymentEntity copyWith({
    String? id,
    String? paymentNumber,
    String? status,
    double? amount,
    DateTime? paymentDate,
    String? billId,
    String? billNumber,
    String? consumerId,
    String? consumerName,
    String? wuaSocietyName,
    String? season,
    String? cropType,
    String? paymentMode,
    String? gatewayTransactionId,
    String? bankReference,
    String? gatewayName,
    String? remarks,
    Map<String, dynamic>? metadata,
    int? farmerMemberId,
    int? societyId,
    String? fiscalYear,
    DateTime? valueDate,
    String? instrumentType,
    int? receiptNo,
    int? bankLedgerId,
    int? glTranId,
    String? rawStatus,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      paymentNumber: paymentNumber ?? this.paymentNumber,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      billId: billId ?? this.billId,
      billNumber: billNumber ?? this.billNumber,
      consumerId: consumerId ?? this.consumerId,
      consumerName: consumerName ?? this.consumerName,
      wuaSocietyName: wuaSocietyName ?? this.wuaSocietyName,
      season: season ?? this.season,
      cropType: cropType ?? this.cropType,
      paymentMode: paymentMode ?? this.paymentMode,
      gatewayTransactionId: gatewayTransactionId ?? this.gatewayTransactionId,
      bankReference: bankReference ?? this.bankReference,
      gatewayName: gatewayName ?? this.gatewayName,
      remarks: remarks ?? this.remarks,
      metadata: metadata ?? this.metadata,
      farmerMemberId: farmerMemberId ?? this.farmerMemberId,
      societyId: societyId ?? this.societyId,
      fiscalYear: fiscalYear ?? this.fiscalYear,
      valueDate: valueDate ?? this.valueDate,
      instrumentType: instrumentType ?? this.instrumentType,
      receiptNo: receiptNo ?? this.receiptNo,
      bankLedgerId: bankLedgerId ?? this.bankLedgerId,
      glTranId: glTranId ?? this.glTranId,
      rawStatus: rawStatus ?? this.rawStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    paymentNumber,
    status,
    amount,
    paymentDate,
    billId,
    billNumber,
    consumerId,
    consumerName,
    wuaSocietyName,
    season,
    cropType,
    paymentMode,
    gatewayTransactionId,
    bankReference,
    gatewayName,
    remarks,
    metadata,
    farmerMemberId,
    societyId,
    fiscalYear,
    valueDate,
    instrumentType,
    receiptNo,
    bankLedgerId,
    glTranId,
    rawStatus,
  ];
}
