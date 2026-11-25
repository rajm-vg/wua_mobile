import 'package:wua_mobile/core/utils/json_parse_utils.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';

/// Data transfer model for Payment transactions aligned with `receipt_details`.
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
    super.farmerMemberId,
    super.societyId,
    super.fiscalYear,
    super.valueDate,
    super.instrumentType,
    super.receiptNo,
    super.bankLedgerId,
    super.glTranId,
    super.rawStatus,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    final statusStr = JsonParseUtils.parseStringOrNull(json['status']);
    final sStatus = JsonParseUtils.parseStringOrNull(json['sStatus']);
    String resolvedStatus;
    if (sStatus == 'A' || JsonParseUtils.parseBool(json['isPaymentDone'])) {
      resolvedStatus = PaymentStatus.success;
    } else if (sStatus == 'P') {
      resolvedStatus = PaymentStatus.pending;
    } else if (sStatus == 'F') {
      resolvedStatus = PaymentStatus.failed;
    } else if (statusStr != null) {
      resolvedStatus = statusStr;
    } else {
      resolvedStatus = PaymentStatus.success;
    }

    final rawReceiptNo = JsonParseUtils.parseIntOrNull(
      json['nReceiptNo'] ?? json['receiptNo'] ?? json['receipt_no'],
    );

    return PaymentModel(
      id: JsonParseUtils.parseString(json['id']),
      paymentNumber: JsonParseUtils.parseString(
        json['payment_number'] ??
            json['receipt_number'] ??
            json['receiptNumber'] ??
            (rawReceiptNo != null ? 'REC-$rawReceiptNo' : null) ??
            json['txnid'] ??
            (json['id'] != null ? 'REC-${json['id']}' : 'REC-000'),
      ),
      status: resolvedStatus,
      amount: JsonParseUtils.parseDouble(
        json['amount'] ?? json['paid_amount'] ?? json['nAmount'],
      ),
      paymentDate: JsonParseUtils.parseDateTimeOrNow(
        json['payment_date'] ??
            json['paymentDate'] ??
            json['dReceiptDate'] ??
            json['dRequestDate'] ??
            json['dUserDateTime'] ??
            json['dValueDate'] ??
            json['dPayDate'] ??
            json['created_at'],
      ),
      billId: JsonParseUtils.parseStringOrNull(
        json['bill_id'] ?? json['billId'] ?? json['billNo'],
      ),
      billNumber: JsonParseUtils.parseStringOrNull(
        json['bill_number'] ??
            json['billNumber'] ??
            (json['billNo'] != null ? 'BILL-${json['billNo']}' : null),
      ),
      consumerId: JsonParseUtils.parseStringOrNull(
        json['consumer_id'] ?? json['consumerId'] ?? json['iFarmerMemberId'],
      ),
      consumerName: JsonParseUtils.parseStringOrNull(
        json['consumer_name'] ??
            json['consumerName'] ??
            json['customer'] ??
            json['sFarmerName'],
      ),
      wuaSocietyName: JsonParseUtils.parseStringOrNull(
        json['wua_society_name'] ??
            json['society_name'] ??
            json['societyName'] ??
            json['sWuaName'],
      ),
      season: JsonParseUtils.parseString(
        json['season'] ?? json['sSeason'],
        defaultValue: 'N/A',
      ),
      cropType: JsonParseUtils.parseString(
        json['crop_type'] ?? json['cropType'] ?? json['sCrop'],
        defaultValue: 'N/A',
      ),
      paymentMode: JsonParseUtils.parseString(
        json['payment_mode'] ??
            json['paymentMode'] ??
            json['sInstrumentType'] ??
            json['sTransactionType'] ??
            json['mode'],
        defaultValue: 'N/A',
      ),
      gatewayTransactionId: JsonParseUtils.parseStringOrNull(
        json['gateway_transaction_id'] ??
            json['gatewayTransactionId'] ??
            json['reference_id'] ??
            json['sTransactionId'],
      ),
      bankReference: JsonParseUtils.parseStringOrNull(
        json['bank_reference'] ??
            json['bankReference'] ??
            json['bank_ref_no'] ??
            json['sBranch'],
      ),
      gatewayName: JsonParseUtils.parseString(
        json['gateway_name'] ?? json['gatewayName'] ?? json['sBankName'],
        defaultValue: 'N/A',
      ),
      remarks: JsonParseUtils.parseStringOrNull(
        json['remarks'] ?? json['notes'] ?? json['sRemarks'],
      ),
      metadata: JsonParseUtils.parseMapOrNull(json['metadata']),
      farmerMemberId: JsonParseUtils.parseIntOrNull(
        json['iFarmerMemberId'] ?? json['farmerMemberId'] ?? json['farmer_member_id'],
      ),
      societyId: JsonParseUtils.parseIntOrNull(
        json['iSocietyId'] ?? json['societyId'] ?? json['society_id'],
      ),
      fiscalYear: JsonParseUtils.parseStringOrNull(
        json['sFiscalYear'] ?? json['fiscalYear'] ?? json['fiscal_year'],
      ),
      valueDate: JsonParseUtils.parseDateTime(
        json['dValueDate'] ?? json['valueDate'] ?? json['value_date'],
      ),
      instrumentType: JsonParseUtils.parseStringOrNull(
        json['sInstrumentType'] ?? json['instrumentType'] ?? json['payment_mode'],
      ),
      receiptNo: rawReceiptNo,
      bankLedgerId: JsonParseUtils.parseIntOrNull(
        json['iBankLedgerId'] ?? json['bankLedgerId'] ?? json['bank_ledger_id'],
      ),
      glTranId: JsonParseUtils.parseIntOrNull(
        json['iGlTranId'] ?? json['glTranId'] ?? json['gl_tran_id'],
      ),
      rawStatus: JsonParseUtils.parseStringOrNull(
        json['sStatus'] ?? json['rawStatus'] ?? json['raw_status'],
      ),
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
      'iFarmerMemberId': farmerMemberId,
      'iSocietyId': societyId,
      'sFiscalYear': fiscalYear,
      'dValueDate': valueDate?.toIso8601String(),
      'sInstrumentType': instrumentType ?? paymentMode,
      'nReceiptNo': receiptNo,
      'iBankLedgerId': bankLedgerId,
      'iGlTranId': glTranId,
      'sStatus': rawStatus ?? (isSuccess ? 'A' : 'P'),
    };
  }

  /// Request payload format for `/api/post-receipt-entry/request` (wrd_backend PostReceiptEntryDTO).
  Map<String, dynamic> toPostReceiptEntryRequestJson() {
    return {
      'iFarmerMemberId': farmerMemberId ?? int.tryParse(consumerId ?? ''),
      'iSocietyId': societyId,
      'billNo': int.tryParse(billId ?? ''),
      'dReceiptDate': paymentDate.toIso8601String(),
      'dValueDate': (valueDate ?? paymentDate).toIso8601String(),
      'sFiscalYear': fiscalYear,
      'nAmount': amount,
      'sInstrumentType': (instrumentType ?? paymentMode).toUpperCase().contains('UPI') ? 'UPI' : 'ONLINE',
      'sTransactionId': gatewayTransactionId ?? paymentNumber,
      'sBankName': gatewayName,
      'sBranch': bankReference,
      'sRemarks': remarks,
      'sStatus': rawStatus ?? 'A',
    };
  }

}
