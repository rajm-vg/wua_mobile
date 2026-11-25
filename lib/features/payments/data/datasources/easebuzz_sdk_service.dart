import 'dart:convert';
import 'package:easebuzz_flutter/easebuzz_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';

enum EasebuzzPaymentStatus {
  success,
  failed,
  cancelled,
}

class EasebuzzSdkResult extends Equatable {
  const EasebuzzSdkResult({
    required this.status,
    this.rawResponse,
    this.transactionId,
    this.paymentId,
    this.signature,
    this.amount,
    this.errorMessage,
    this.paymentResponse,
  });

  factory EasebuzzSdkResult.success({
    required String rawResponse,
    required Map<String, dynamic> paymentResponse,
  }) {
    return EasebuzzSdkResult(
      status: EasebuzzPaymentStatus.success,
      rawResponse: rawResponse,
      transactionId: (paymentResponse['txnid'] ?? paymentResponse['transaction_id']) as String?,
      paymentId: (paymentResponse['easepayid'] ?? paymentResponse['payment_id']) as String?,
      signature: (paymentResponse['hash'] ?? paymentResponse['signature']) as String?,
      amount: double.tryParse((paymentResponse['amount'] ?? '').toString()),
      paymentResponse: paymentResponse,
    );
  }

  factory EasebuzzSdkResult.cancelled({String? rawResponse, String? message}) {
    return EasebuzzSdkResult(
      status: EasebuzzPaymentStatus.cancelled,
      rawResponse: rawResponse,
      errorMessage: message ?? 'Payment cancelled by user.',
    );
  }

  factory EasebuzzSdkResult.failed({String? rawResponse, String? message}) {
    return EasebuzzSdkResult(
      status: EasebuzzPaymentStatus.failed,
      rawResponse: rawResponse,
      errorMessage: message ?? 'Payment failed.',
    );
  }

  final EasebuzzPaymentStatus status;
  final String? rawResponse;
  final String? transactionId;
  final String? paymentId;
  final String? signature;
  final double? amount;
  final String? errorMessage;
  final Map<String, dynamic>? paymentResponse;

  bool get isSuccess => status == EasebuzzPaymentStatus.success;
  bool get isCancelled => status == EasebuzzPaymentStatus.cancelled;
  bool get isFailed => status == EasebuzzPaymentStatus.failed;

  @override
  List<Object?> get props => [
        status,
        rawResponse,
        transactionId,
        paymentId,
        signature,
        amount,
        errorMessage,
        paymentResponse,
      ];
}

abstract class EasebuzzSdkService {
  Future<EasebuzzSdkResult> payWithEasebuzz({
    required String accessKey,
    String payMode = 'test',
  });
}

class EasebuzzSdkServiceImpl implements EasebuzzSdkService {
  EasebuzzSdkServiceImpl({EasebuzzFlutter? easebuzzPlugin})
      : _easebuzzPlugin = easebuzzPlugin ?? EasebuzzFlutter();

  final EasebuzzFlutter _easebuzzPlugin;

  @override
  Future<EasebuzzSdkResult> payWithEasebuzz({
    required String accessKey,
    String payMode = 'test',
  }) async {
    AppLogger.info('💳 [EASEBUZZ SDK] Initiating payment (payMode: $payMode)');

    try {
      final jsonResult = await _easebuzzPlugin.payWithEasebuzz(accessKey, payMode);
      if (jsonResult == null || jsonResult.isEmpty) {
        AppLogger.warning('💳 [EASEBUZZ SDK] Null or empty response returned from SDK');
        return EasebuzzSdkResult.cancelled(
          message: 'No response received from Easebuzz checkout.',
        );
      }

      AppLogger.info('💳 [EASEBUZZ SDK] Raw response received: $jsonResult');
      final dynamic decoded = jsonDecode(jsonResult);
      if (decoded is! Map<String, dynamic>) {
        return EasebuzzSdkResult.failed(
          rawResponse: jsonResult,
          message: 'Invalid response format from Easebuzz SDK.',
        );
      }

      final resultString =
          (decoded['result']?.toString() ?? '').trim().toLowerCase();
      final rawPaymentResponse = decoded['payment_response'];
      final paymentResponse = rawPaymentResponse is Map<String, dynamic>
          ? rawPaymentResponse
          : (rawPaymentResponse is Map
                ? rawPaymentResponse.map((k, v) => MapEntry(k.toString(), v))
                : <String, dynamic>{});

      final paymentStatus =
          (paymentResponse['status']?.toString() ?? '').trim().toLowerCase();
      final errorMsgLower =
          (paymentResponse['error_Message']?.toString() ??
                  paymentResponse['message']?.toString() ??
                  '')
              .trim()
              .toLowerCase();

      final isCancelled =
          resultString == 'user_cancelled' ||
          resultString.contains('cancel') ||
          paymentStatus == 'usercancelled';

      final isSuccess =
          !isCancelled &&
          (resultString == 'payment_successed' ||
              resultString == 'payment_succeeded' ||
              resultString == 'payment_success' ||
              resultString == 'payment_successful' ||
              resultString == 'payment_successfull' ||
              resultString == 'success' ||
              (paymentStatus == 'success' && !resultString.contains('fail')) ||
              (errorMsgLower == 'transaction is successful' &&
                  !resultString.contains('fail')));

      if (isSuccess) {
        return EasebuzzSdkResult.success(
          rawResponse: jsonResult,
          paymentResponse: paymentResponse,
        );
      } else if (isCancelled) {
        return EasebuzzSdkResult.cancelled(
          rawResponse: jsonResult,
          message: 'Payment was cancelled by the user.',
        );
      } else {
        final errorMsg = paymentResponse['error_Message'] as String? ??
            paymentResponse['error'] as String? ??
            paymentResponse['message'] as String? ??
            'Payment transaction was not completed.';
        return EasebuzzSdkResult.failed(
          rawResponse: jsonResult,
          message: errorMsg,
        );
      }
    } catch (e) {
      AppLogger.error('💳 [EASEBUZZ SDK] Exception during payment execution: $e');
      return EasebuzzSdkResult.failed(
        message: 'Easebuzz checkout error: $e',
      );
    }
  }
}
