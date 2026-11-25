import 'package:equatable/equatable.dart';
import 'package:wua_mobile/core/utils/json_parse_utils.dart';

/// Request payload sent to `POST /api/payments/create-order`
class EasebuzzOrderRequest extends Equatable {
  const EasebuzzOrderRequest({
    required this.amount,
    this.currency = 'INR',
    this.description = 'Water Bill Payment',
    this.provider = 'EASEBUZZ',
    this.receipt,
    this.billId,
    this.memberId,
    this.societyId,
  });

  final double amount;
  final String currency;
  final String description;
  final String provider;
  final String? receipt;
  final int? billId;
  final int? memberId;
  final int? societyId;

  Map<String, dynamic> toJson() {
    return {
      'amount': double.parse(amount.toStringAsFixed(2)),
      'currency': currency,
      'description': description,
      'provider': provider,
      'receipt': receipt ?? 'receipt_${DateTime.now().millisecondsSinceEpoch}',
      if (billId != null) 'billId': billId,
      if (memberId != null) 'memberId': memberId,
      if (societyId != null) 'societyId': societyId,
    };
  }

  @override
  List<Object?> get props => [
        amount,
        currency,
        description,
        provider,
        receipt,
        billId,
        memberId,
        societyId,
      ];
}

/// Response received from `POST /api/payments/create-order`
class EasebuzzOrderResponse extends Equatable {
  const EasebuzzOrderResponse({
    required this.transactionId,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.accessKey,
    this.keyId,
    this.provider = 'EASEBUZZ',
    this.status = 'PENDING',
  });

  factory EasebuzzOrderResponse.fromJson(Map<String, dynamic> json) {
    final txnId = JsonParseUtils.parseString(
      json['transactionId'] ?? json['orderId'],
    );
    final ordId = JsonParseUtils.parseString(
      json['orderId'] ?? json['transactionId'],
    );
    return EasebuzzOrderResponse(
      transactionId: txnId,
      orderId: ordId,
      amount: JsonParseUtils.parseDouble(json['amount']),
      currency: JsonParseUtils.parseString(
        json['currency'],
        defaultValue: 'INR',
      ),
      accessKey: JsonParseUtils.parseString(
        json['accessKey'] ?? json['access_key'],
      ),
      keyId: JsonParseUtils.parseStringOrNull(json['keyId'] ?? json['key']),
      provider: JsonParseUtils.parseString(
        json['provider'],
        defaultValue: 'EASEBUZZ',
      ),
      status: JsonParseUtils.parseString(
        json['status'],
        defaultValue: 'PENDING',
      ),
    );
  }

  final String transactionId;
  final String orderId;
  final double amount;
  final String currency;
  final String accessKey;
  final String? keyId;
  final String provider;
  final String status;

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'accessKey': accessKey,
      'keyId': keyId,
      'provider': provider,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        transactionId,
        orderId,
        amount,
        currency,
        accessKey,
        keyId,
        provider,
        status,
      ];
}
