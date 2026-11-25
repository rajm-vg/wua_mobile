import 'package:equatable/equatable.dart';
import 'package:wua_mobile/core/utils/json_parse_utils.dart';

/// Request payload sent to `POST /api/payments/verify`
class EasebuzzVerifyRequest extends Equatable {
  const EasebuzzVerifyRequest({
    required this.transactionId,
    required this.orderId,
    required this.paymentId,
    required this.signature,
    required this.amount,
    required this.payload,
  });

  final String transactionId;
  final String orderId;
  final String paymentId;
  final String signature;
  final double amount;
  final String payload;

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'orderId': orderId,
      'paymentId': paymentId,
      'signature': signature,
      'amount': double.parse(amount.toStringAsFixed(2)),
      'payload': payload,
    };
  }

  @override
  List<Object?> get props => [
        transactionId,
        orderId,
        paymentId,
        signature,
        amount,
        payload,
      ];
}

/// Response received from `POST /api/payments/verify`
class EasebuzzVerifyResponse extends Equatable {
  const EasebuzzVerifyResponse({
    required this.verified,
    this.transactionId,
    this.paymentId,
    this.status,
    this.message,
  });

  factory EasebuzzVerifyResponse.fromJson(Map<String, dynamic> json) {
    final statusStr = JsonParseUtils.parseStringOrNull(json['status']);
    return EasebuzzVerifyResponse(
      verified: JsonParseUtils.parseBool(json['verified']) ||
          statusStr?.toUpperCase() == 'SUCCESS',
      transactionId: JsonParseUtils.parseStringOrNull(json['transactionId']),
      paymentId: JsonParseUtils.parseStringOrNull(json['paymentId']),
      status: statusStr,
      message: JsonParseUtils.parseStringOrNull(json['message']),
    );
  }

  final bool verified;
  final String? transactionId;
  final String? paymentId;
  final String? status;
  final String? message;

  Map<String, dynamic> toJson() {
    return {
      'verified': verified,
      'transactionId': transactionId,
      'paymentId': paymentId,
      'status': status,
      'message': message,
    };
  }

  @override
  List<Object?> get props => [
        verified,
        transactionId,
        paymentId,
        status,
        message,
      ];
}
