import 'package:wua_mobile/core/utils/json_parse_utils.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';

/// Data transfer model for WUA Pani Patti Bill entity aligned with `bill_header` table.
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
    super.farmerMemberId,
    super.societyId,
    super.fiscalYear,
    super.valueDate,
    super.glTranId,
    super.rawStatus,
    super.details,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    final isPaid = JsonParseUtils.parseBool(
          json['isPaymentDone'] ?? json['is_payment_done'],
        ) ||
        (JsonParseUtils.parseString(json['status']).toUpperCase() ==
            BillStatus.paid.toUpperCase());

    final dueDateParsed = JsonParseUtils.parseDateTime(
      json['due_date'] ?? json['dueDate'] ?? json['dDueDate'],
    );

    String resolvedStatus;
    if (isPaid) {
      resolvedStatus = BillStatus.paid;
    } else if (JsonParseUtils.parseStringOrNull(json['status']) != null) {
      resolvedStatus = JsonParseUtils.parseString(json['status']);
    } else if (dueDateParsed != null && dueDateParsed.isBefore(DateTime.now())) {
      resolvedStatus = BillStatus.overdue;
    } else {
      resolvedStatus = BillStatus.pending;
    }

    final total = JsonParseUtils.parseDouble(
      json['total_amount'] ??
          json['totalAmount'] ??
          json['amount'] ??
          json['nBillAmount'] ??
          ((json['nAmount'] != null)
              ? (JsonParseUtils.parseDouble(json['nAmount']) +
                  JsonParseUtils.parseDouble(json['nLocalTax']) +
                  JsonParseUtils.parseDouble(json['nPenalty']))
              : null),
    );
    final paid = JsonParseUtils.parseDouble(
      json['paid_amount'] ?? json['paidAmount'] ?? json['nPaidAmount'],
    );
    final taxesAmount = JsonParseUtils.parseDouble(
      json['taxes'] ?? json['govt_cess'] ?? json['nLocalTax'],
    );
    final penaltyAmount = JsonParseUtils.parseDouble(
      json['penalties'] ?? json['nPenalty'],
    );
    final subtotalAmount = JsonParseUtils.parseDouble(
      json['subtotal'] ??
          json['base_water_charges'] ??
          json['nAmount'] ??
          (total > 0 ? (total - taxesAmount - penaltyAmount) : 0.0),
    );
    final outstanding = JsonParseUtils.parseDouble(
      json['balanceAmount'] ??
          json['balance_amount'] ??
          json['outstanding_amount'] ??
          json['outstandingAmount'] ??
          json['nPreviousBalance'] ??
          (isPaid ? 0.0 : (total - paid)),
    );

    final rawDetails = json['details'] ?? json['bill_details'] ?? json['billDetails'];
    final detailsList = JsonParseUtils.parseMapList(rawDetails)
        .map(BillDetailModel.fromJson)
        .toList();

    final farmerObj = JsonParseUtils.parseMapOrNull(json['farmerObj']);
    final societyObj = JsonParseUtils.parseMapOrNull(farmerObj?['societyObj']);

    return BillModel(
      id: JsonParseUtils.parseString(json['id']),
      billNumber: JsonParseUtils.parseString(
        json['bill_number'] ??
            json['billNumber'] ??
            (json['iBillNo'] != null ? 'BILL-${json['iBillNo']}' : null) ??
            json['bill_no'] ??
            json['sKhateNumber'] ??
            (json['id'] != null ? 'BILL-${json['id']}' : 'BILL-000'),
      ),
      status: resolvedStatus,
      consumerId: JsonParseUtils.parseStringOrNull(
        json['consumer_id'] ?? json['consumerId'] ?? json['iFarmerMemberId'],
      ),
      consumerName: JsonParseUtils.parseStringOrNull(
        json['consumer_name'] ??
            json['consumerName'] ??
            farmerObj?['sName'] ??
            json['customer'] ??
            json['sFarmerName'],
      ),
      wuaSocietyName: JsonParseUtils.parseStringOrNull(
        json['wua_society_name'] ??
            json['society_name'] ??
            json['societyName'] ??
            societyObj?['sSocietyName'] ??
            json['wuaSocietyName'] ??
            json['sWuaName'],
      ),
      canalSection: JsonParseUtils.parseStringOrNull(
        json['canal_section'] ??
            json['canalSection'] ??
            json['sSection'] ??
            json['sSubDivision'],
      ),
      season: JsonParseUtils.parseString(
        json['season'] ?? json['sSeason'],
        defaultValue: 'N/A',
      ),
      cropType: JsonParseUtils.parseString(
        json['crop_type'] ?? json['cropType'] ?? json['sCrop'],
        defaultValue: 'N/A',
      ),
      landAreaAcres: JsonParseUtils.parseDouble(
        json['land_area_acres'] ??
            json['landAreaAcres'] ??
            json['nIrrigatedArea'] ??
            json['area'],
      ),
      waterQuantityLiters: JsonParseUtils.parseDouble(
        json['water_quantity_liters'] ??
            json['waterQuantityLiters'] ??
            json['nWaterUsage'] ??
            json['nWaterAllocation'] ??
            json['cumecs'],
      ),
      rotationsCount: JsonParseUtils.parseInt(
        json['rotations_count'] ?? json['rotationsCount'],
        defaultValue: 0,
      ),
      billDate: JsonParseUtils.parseDateTime(
        json['bill_date'] ?? json['billDate'] ?? json['dBillDate'],
      ),
      dueDate: dueDateParsed,
      subtotal: subtotalAmount,
      taxes: taxesAmount,
      maintenanceCess: JsonParseUtils.parseDouble(
        json['maintenance_cess'] ??
            json['maintenanceCess'] ??
            json['wua_maintenance'],
      ),
      penalties: penaltyAmount,
      interestAmount: JsonParseUtils.parseDouble(
        json['interest_amount'] ?? json['interestAmount'],
      ),
      discounts: JsonParseUtils.parseDouble(json['discounts']),
      adjustmentAmount: JsonParseUtils.parseDouble(
        json['adjustment_amount'] ?? json['adjustmentAmount'],
      ),
      totalAmount: total,
      paidAmount: paid,
      outstandingAmount: outstanding,
      paymentReference: JsonParseUtils.parseStringOrNull(
        json['payment_reference'] ?? json['paymentReference'] ?? json['txnid'],
      ),
      paymentDate: JsonParseUtils.parseDateTime(
        json['payment_date'] ?? json['paymentDate'] ?? json['dPaymentDate'],
      ),
      paymentMethod: JsonParseUtils.parseStringOrNull(
        json['payment_method'] ?? json['paymentMethod'],
      ),
      notes: JsonParseUtils.parseStringOrNull(json['notes']),
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
      glTranId: JsonParseUtils.parseIntOrNull(
        json['iGlTranId'] ?? json['glTranId'] ?? json['gl_tran_id'],
      ),
      rawStatus: JsonParseUtils.parseStringOrNull(
        json['sStatus'] ?? json['rawStatus'] ?? json['raw_status'],
      ),
      details: detailsList,
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
      'iFarmerMemberId': farmerMemberId,
      'iSocietyId': societyId,
      'sFiscalYear': fiscalYear,
      'dValueDate': valueDate?.toIso8601String(),
      'iGlTranId': glTranId,
      'sStatus': rawStatus ?? status,
      'details': details.map((d) {
        if (d is BillDetailModel) return d.toJson();
        return BillDetailModel(
          id: d.id,
          billNo: d.billNo,
          crop: d.crop,
          irrigatedArea: d.irrigatedArea,
          rate: d.rate,
          amount: d.amount,
          localTax: d.localTax,
          penalty: d.penalty,
          isPaymentDone: d.isPaymentDone,
          paidAmount: d.paidAmount,
        ).toJson();
      }).toList(),
    };
  }

}

/// Data model for `bill_details` line item.
class BillDetailModel extends BillDetailEntity {
  const BillDetailModel({
    super.id,
    super.billNo,
    required super.crop,
    super.irrigatedArea,
    super.rate,
    super.amount,
    super.localTax,
    super.penalty,
    super.isPaymentDone,
    super.paidAmount,
  });

  factory BillDetailModel.fromJson(Map<String, dynamic> json) {
    return BillDetailModel(
      id: JsonParseUtils.parseIntOrNull(json['id']),
      billNo: JsonParseUtils.parseIntOrNull(
        json['iBillNo'] ?? json['billNo'] ?? json['bill_no'],
      ),
      crop: JsonParseUtils.parseString(
        json['sCrop'] ?? json['crop'] ?? json['cropType'],
        defaultValue: 'General Crop',
      ),
      irrigatedArea: JsonParseUtils.parseDouble(
        json['nIrrigatedArea'] ?? json['irrigatedArea'] ?? json['area'],
      ),
      rate: JsonParseUtils.parseDouble(json['nRate'] ?? json['rate']),
      amount: JsonParseUtils.parseDouble(json['nAmount'] ?? json['amount']),
      localTax: JsonParseUtils.parseDouble(
        json['nLocalTax'] ?? json['localTax'],
      ),
      penalty: JsonParseUtils.parseDouble(json['nPenalty'] ?? json['penalty']),
      isPaymentDone: JsonParseUtils.parseBool(
        json['isPaymentDone'] ?? json['is_payment_done'],
      ),
      paidAmount: JsonParseUtils.parseDouble(
        json['paidAmount'] ?? json['paid_amount'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iBillNo': billNo,
      'sCrop': crop,
      'nIrrigatedArea': irrigatedArea,
      'nRate': rate,
      'nAmount': amount,
      'nLocalTax': localTax,
      'nPenalty': penalty,
      'isPaymentDone': isPaymentDone,
      'paidAmount': paidAmount,
    };
  }
}