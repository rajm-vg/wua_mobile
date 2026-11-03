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

/// Core domain entity representing a WUA Irrigation Bill payment transaction.
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
    this.season = 'Current Season',
    this.cropType = 'Wheat',
    this.paymentMode = 'UPI',
    this.gatewayTransactionId,
    this.bankReference,
    this.gatewayName = 'MahaGov WRD Gateway',
    this.remarks,
    this.metadata,
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

  // ─── Semantic Status Helpers ─────────────────────────────────

  bool get isSuccess => status.toUpperCase() == PaymentStatus.success;
  bool get isPending => status.toUpperCase() == PaymentStatus.pending;
  bool get isFailed => status.toUpperCase() == PaymentStatus.failed;
  bool get isRefunded => status.toUpperCase() == PaymentStatus.refunded;

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
  ];
}

