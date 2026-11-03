import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Status constants and helpers for Irrigation Bills.
class BillStatus {
  BillStatus._();

  static const String paid = 'PAID';
  static const String pending = 'PENDING';
  static const String partiallyPaid = 'PARTIALLY_PAID';
  static const String overdue = 'OVERDUE';
  static const String approved = 'APPROVED';

  /// Returns user-friendly status title.
  static String toLabel(String status) {
    switch (status.toUpperCase()) {
      case paid:
        return 'Paid';
      case pending:
        return 'Due / Pending';
      case partiallyPaid:
        return 'Partially Paid';
      case overdue:
        return 'Overdue';
      case approved:
        return 'Approved';
      default:
        return status;
    }
  }
}

/// Core domain entity representing a Water Users Association (WUA) Pani Patti Bill.
class BillEntity extends Equatable {
  const BillEntity({
    required this.id,
    required this.billNumber,
    required this.status,
    this.consumerId,
    this.consumerName,
    this.wuaSocietyName,
    this.canalSection,
    this.season = 'Rabi Season (2024-25)',
    this.cropType = 'Wheat',
    this.landAreaAcres = 0.0,
    this.waterQuantityLiters = 0.0,
    this.rotationsCount = 1,
    this.billDate,
    this.dueDate,
    this.subtotal = 0.0,
    this.taxes = 0.0,
    this.maintenanceCess = 0.0,
    this.penalties = 0.0,
    this.interestAmount = 0.0,
    this.discounts = 0.0,
    this.adjustmentAmount = 0.0,
    this.totalAmount = 0.0,
    this.paidAmount = 0.0,
    this.outstandingAmount = 0.0,
    this.paymentReference,
    this.paymentDate,
    this.paymentMethod,
    this.notes,
    this.metadata,
  });

  final String id;
  final String billNumber;
  final String status;
  final String? consumerId;
  final String? consumerName;
  final String? wuaSocietyName;
  final String? canalSection;
  final String season;
  final String cropType;
  final double landAreaAcres;
  final double waterQuantityLiters;
  final int rotationsCount;
  final DateTime? billDate;
  final DateTime? dueDate;
  final double subtotal;
  final double taxes;
  final double maintenanceCess;
  final double penalties;
  final double interestAmount;
  final double discounts;
  final double adjustmentAmount;
  final double totalAmount;
  final double paidAmount;
  final double outstandingAmount;
  final String? paymentReference;
  final DateTime? paymentDate;
  final String? paymentMethod;
  final String? notes;
  final Map<String, dynamic>? metadata;

  // ─── Semantic Status Helpers ─────────────────────────────────

  bool get isPaid =>
      status.toUpperCase() == BillStatus.paid ||
      (outstandingAmount <= 0.0 && paidAmount > 0.0);

  bool get isPartiallyPaid =>
      status.toUpperCase() == BillStatus.partiallyPaid ||
      (paidAmount > 0.0 && outstandingAmount > 0.0);

  bool get isOverdue {
    if (isPaid) return false;
    if (status.toUpperCase() == BillStatus.overdue) return true;
    if (dueDate != null) {
      return DateTime.now().isAfter(dueDate!);
    }
    return false;
  }

  bool get isPayable => !isPaid && outstandingAmount > 0.0;

  /// Human-readable month/year formatting.
  String get formattedMonth {
    if (billDate != null) {
      return DateFormat('MMMM yyyy').format(billDate!);
    }
    if (dueDate != null) {
      return DateFormat('MMMM yyyy').format(dueDate!);
    }
    return 'Current Season';
  }

  /// Formatted due date string (e.g., "25 Nov 2026").
  String get formattedDueDate {
    if (dueDate == null) return 'No due date';
    return DateFormat('dd MMM yyyy').format(dueDate!);
  }

  /// Formatted bill issue date string (e.g., "01 Nov 2026").
  String get formattedBillDate {
    if (billDate == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(billDate!);
  }

  /// Formatted payment date string.
  String? get formattedPaymentDate {
    if (paymentDate == null) return null;
    return DateFormat('dd MMM yyyy, hh:mm a').format(paymentDate!);
  }

  @override
  List<Object?> get props => [
    id,
    billNumber,
    status,
    consumerId,
    consumerName,
    wuaSocietyName,
    canalSection,
    season,
    cropType,
    landAreaAcres,
    waterQuantityLiters,
    rotationsCount,
    billDate,
    dueDate,
    subtotal,
    taxes,
    maintenanceCess,
    penalties,
    interestAmount,
    discounts,
    adjustmentAmount,
    totalAmount,
    paidAmount,
    outstandingAmount,
    paymentReference,
    paymentDate,
    paymentMethod,
    notes,
    metadata,
  ];
}
