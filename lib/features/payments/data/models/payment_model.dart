import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';

/// Data transfer model for Payment transactions.
class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.paymentNumber,
    required super.status,
    required super.amount,
    required super.paymentDate,
    super.billId,
    super.billNumber,
    super.consumerId,
    super.consumerName,
    super.wuaSocietyName,
    super.season,
    super.cropType,
    super.paymentMode,
    super.gatewayTransactionId,
    super.bankReference,
    super.gatewayName,
    super.remarks,
    super.metadata,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: _parseString(json['id']),
      paymentNumber: _parseString(
        json['payment_number'] ?? json['receipt_number'] ?? json['receiptNumber'] ?? json['txnid'],
      ),
      status: _parseString(json['status'], defaultValue: PaymentStatus.success),
      amount: _parseDouble(json['amount'] ?? json['paid_amount']),
      paymentDate: _parseDateTime(
            json['payment_date'] ?? json['paymentDate'] ?? json['created_at'],
          ) ??
          DateTime.now(),
      billId: _parseStringOrNull(json['bill_id'] ?? json['billId']),
      billNumber: _parseStringOrNull(json['bill_number'] ?? json['billNumber']),
      consumerId: _parseStringOrNull(json['consumer_id'] ?? json['consumerId']),
      consumerName: _parseStringOrNull(
        json['consumer_name'] ?? json['consumerName'] ?? json['customer'],
      ),
      wuaSocietyName: _parseStringOrNull(
        json['wua_society_name'] ?? json['society_name'] ?? json['societyName'],
      ),
      season: _parseString(json['season'], defaultValue: 'Current Season'),
      cropType: _parseString(json['crop_type'] ?? json['cropType'], defaultValue: 'Wheat'),
      paymentMode: _parseString(
        json['payment_mode'] ?? json['paymentMode'] ?? json['mode'],
        defaultValue: 'UPI',
      ),
      gatewayTransactionId: _parseStringOrNull(
        json['gateway_transaction_id'] ?? json['gatewayTransactionId'] ?? json['reference_id'],
      ),
      bankReference: _parseStringOrNull(
        json['bank_reference'] ?? json['bankReference'] ?? json['bank_ref_no'],
      ),
      gatewayName: _parseString(
        json['gateway_name'] ?? json['gatewayName'],
        defaultValue: 'MahaGov WRD Gateway',
      ),
      remarks: _parseStringOrNull(json['remarks'] ?? json['notes']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_number': paymentNumber,
      'status': status,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'bill_id': billId,
      'bill_number': billNumber,
      'consumer_id': consumerId,
      'consumer_name': consumerName,
      'wua_society_name': wuaSocietyName,
      'season': season,
      'crop_type': cropType,
      'payment_mode': paymentMode,
      'gateway_transaction_id': gatewayTransactionId,
      'bank_reference': bankReference,
      'gateway_name': gatewayName,
      'remarks': remarks,
      'metadata': metadata,
    };
  }

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

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

