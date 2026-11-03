import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';

/// Data transfer model for WUA Pani Patti Bill entity.
class BillModel extends BillEntity {
  const BillModel({
    required super.id,
    required super.billNumber,
    required super.status,
    super.consumerId,
    super.consumerName,
    super.wuaSocietyName,
    super.canalSection,
    super.season,
    super.cropType,
    super.landAreaAcres,
    super.waterQuantityLiters,
    super.rotationsCount,
    super.billDate,
    super.dueDate,
    super.subtotal,
    super.taxes,
    super.maintenanceCess,
    super.penalties,
    super.interestAmount,
    super.discounts,
    super.adjustmentAmount,
    super.totalAmount,
    super.paidAmount,
    super.outstandingAmount,
    super.paymentReference,
    super.paymentDate,
    super.paymentMethod,
    super.notes,
    super.metadata,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: _parseString(json['id']),
      billNumber: _parseString(
        json['bill_number'] ?? json['billNumber'] ?? json['bill_no'],
      ),
      status: _parseString(json['status'], defaultValue: BillStatus.pending),
      consumerId: _parseStringOrNull(json['consumer_id'] ?? json['consumerId']),
      consumerName: _parseStringOrNull(
        json['consumer_name'] ?? json['consumerName'] ?? json['customer'],
      ),
      wuaSocietyName: _parseStringOrNull(
        json['wua_society_name'] ??
            json['society_name'] ??
            json['societyName'] ??
            json['wuaSocietyName'],
      ),
      canalSection: _parseStringOrNull(
        json['canal_section'] ?? json['canalSection'],
      ),
      season: _parseString(
        json['season'],
        defaultValue: 'Rabi Season (2024-25)',
      ),
      cropType: _parseString(
        json['crop_type'] ?? json['cropType'],
        defaultValue: 'Wheat',
      ),
      landAreaAcres: _parseDouble(
        json['land_area_acres'] ?? json['landAreaAcres'],
      ),
      waterQuantityLiters: _parseDouble(
        json['water_quantity_liters'] ?? json['waterQuantityLiters'],
      ),
      rotationsCount: _parseInt(
        json['rotations_count'] ?? json['rotationsCount'],
        defaultValue: 1,
      ),
      billDate: _parseDateTime(
        json['bill_date'] ?? json['billDate'] ?? json['dBillDate'],
      ),
      dueDate: _parseDateTime(
        json['due_date'] ?? json['dueDate'] ?? json['dDueDate'],
      ),
      subtotal: _parseDouble(json['subtotal'] ?? json['base_water_charges']),
      taxes: _parseDouble(json['taxes'] ?? json['govt_cess']),
      maintenanceCess: _parseDouble(
        json['maintenance_cess'] ??
            json['maintenanceCess'] ??
            json['wua_maintenance'],
      ),
      penalties: _parseDouble(json['penalties']),
      interestAmount: _parseDouble(
        json['interest_amount'] ?? json['interestAmount'],
      ),
      discounts: _parseDouble(json['discounts']),
      adjustmentAmount: _parseDouble(
        json['adjustment_amount'] ?? json['adjustmentAmount'],
      ),
      totalAmount: _parseDouble(
        json['total_amount'] ?? json['totalAmount'] ?? json['amount'],
      ),
      paidAmount: _parseDouble(json['paid_amount'] ?? json['paidAmount']),
      outstandingAmount: _parseDouble(
        json['outstanding_amount'] ?? json['outstandingAmount'],
      ),
      paymentReference: _parseStringOrNull(
        json['payment_reference'] ?? json['paymentReference'] ?? json['txnid'],
      ),
      paymentDate: _parseDateTime(json['payment_date'] ?? json['paymentDate']),
      paymentMethod: _parseStringOrNull(
        json['payment_method'] ?? json['paymentMethod'],
      ),
      notes: _parseStringOrNull(json['notes']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bill_number': billNumber,
      'status': status,
      'consumer_id': consumerId,
      'consumer_name': consumerName,
      'wua_society_name': wuaSocietyName,
      'canal_section': canalSection,
      'season': season,
      'crop_type': cropType,
      'land_area_acres': landAreaAcres,
      'water_quantity_liters': waterQuantityLiters,
      'rotations_count': rotationsCount,
      'bill_date': billDate?.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'subtotal': subtotal,
      'taxes': taxes,
      'maintenance_cess': maintenanceCess,
      'penalties': penalties,
      'interest_amount': interestAmount,
      'discounts': discounts,
      'adjustment_amount': adjustmentAmount,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'outstanding_amount': outstandingAmount,
      'payment_reference': paymentReference,
      'payment_date': paymentDate?.toIso8601String(),
      'payment_method': paymentMethod,
      'notes': notes,
      'metadata': metadata,
    };
  }

  // ─── Safe Deserialization Utilities ─────────────────────────

  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString().trim();
  }

  static String? _parseStringOrNull(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
