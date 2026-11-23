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
    final statusStr = json['status']?.toString();
    final sStatus = json['sStatus']?.toString();
    String resolvedStatus;
    if (sStatus == 'A' || json['isPaymentDone'] == true) {
      resolvedStatus = PaymentStatus.success;
    } else if (sStatus == 'P') {
      resolvedStatus = PaymentStatus.pending;
    } else if (sStatus == 'F') {
      resolvedStatus = PaymentStatus.failed;
    } else if (statusStr != null && statusStr.isNotEmpty) {
      resolvedStatus = statusStr;
    } else {
      resolvedStatus = PaymentStatus.success;
    }

    return PaymentModel(
      id: _parseString(json['id']),
      paymentNumber: _parseString(
        json['payment_number'] ??
            json['receipt_number'] ??
            json['receiptNumber'] ??
            json['nReceiptNo'] ??
            json['txnid'] ??
            (json['id'] != null ? 'REC-${json['id']}' : 'REC-000'),
      ),
      status: resolvedStatus,
      amount: _parseDouble(json['amount'] ?? json['paid_amount'] ?? json['nAmount']),
      paymentDate: _parseDateTime(
            json['payment_date'] ??
                json['paymentDate'] ??
                json['dReceiptDate'] ??
                json['dPayDate'] ??
                json['created_at'],
          ) ??
          DateTime.now(),
      billId: _parseStringOrNull(json['bill_id'] ?? json['billId'] ?? json['billNo']),
      billNumber: _parseStringOrNull(
        json['bill_number'] ??
            json['billNumber'] ??
            (json['billNo'] != null ? 'BILL-${json['billNo']}' : null),
      ),
      consumerId: _parseStringOrNull(
        json['consumer_id'] ?? json['consumerId'] ?? json['iFarmerMemberId'],
      ),
      consumerName: _parseStringOrNull(
        json['consumer_name'] ??
            json['consumerName'] ??
            json['customer'] ??
            json['sFarmerName'],
      ),
      wuaSocietyName: _parseStringOrNull(
        json['wua_society_name'] ??
            json['society_name'] ??
            json['societyName'] ??
            json['sWuaName'],
      ),
      season: _parseString(json['season'] ?? json['sSeason'], defaultValue: 'Current Season'),
      cropType: _parseString(
        json['crop_type'] ?? json['cropType'] ?? json['sCrop'],
        defaultValue: 'General Crop',
      ),
      paymentMode: _parseString(
        json['payment_mode'] ??
            json['paymentMode'] ??
            json['sInstrumentType'] ??
            json['mode'],
        defaultValue: 'UPI',
      ),
      gatewayTransactionId: _parseStringOrNull(
        json['gateway_transaction_id'] ??
            json['gatewayTransactionId'] ??
            json['reference_id'] ??
            json['sTransactionId'],
      ),
      bankReference: _parseStringOrNull(
        json['bank_reference'] ??
            json['bankReference'] ??
            json['bank_ref_no'] ??
            json['sBranch'],
      ),
      gatewayName: _parseString(
        json['gateway_name'] ?? json['gatewayName'] ?? json['sBankName'],
        defaultValue: 'MahaGov WRD Gateway',
      ),
      remarks: _parseStringOrNull(json['remarks'] ?? json['notes'] ?? json['sRemarks']),
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

