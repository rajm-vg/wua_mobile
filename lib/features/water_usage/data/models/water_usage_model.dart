import 'package:wua_mobile/core/utils/json_parse_utils.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';

/// Data model for [CropWaterUsage] aligned with `crop_details` table.
class CropWaterUsageModel extends CropWaterUsage {
  const CropWaterUsageModel({
    required super.cropName,
    required super.cropNameMarathi,
    required super.allocatedHaCm,
    required super.usedHaCm,
    required super.areaAcres,
    required super.percentage,
    super.id,
    super.memberId,
    super.farmerMemberId,
    super.societyId,
    super.waterUsageId,
    super.fiscalYear,
    super.season,
    super.rotation,
    super.village,
    super.surveyNo,
    super.source,
    super.waterValue,
    super.rateType,
    super.rateValue,
    super.perType,
    super.seasonalWaterUsage,
    super.amount,
    super.approvalStatus,
    super.billGenerated,
    super.isPaymentDone,
    super.transactionDate,
  });

  factory CropWaterUsageModel.fromJson(Map<String, dynamic> json) {
    final cropTitle = JsonParseUtils.parseString(
      json['crop_name'] ?? json['cropName'] ?? json['crop'] ?? json['sCrop'],
      defaultValue: 'N/A',
    );
    final cropTitleMarathi = JsonParseUtils.parseString(
      json['crop_name_marathi'] ?? json['cropNameMarathi'],
      defaultValue: cropTitle == 'N/A' ? '' : cropTitle,
    );
    final areaVal = JsonParseUtils.parseDouble(
      json['area_acres'] ?? json['areaAcres'] ?? json['area'],
      defaultValue: 0.0,
    );
    final allocated = JsonParseUtils.parseDouble(
      json['allocated_ha_cm'] ??
          json['allocatedHaCm'] ??
          json['waterAllocation'],
      defaultValue: 0.0,
    );
    final used = JsonParseUtils.parseDouble(
      json['used_ha_cm'] ??
          json['usedHaCm'] ??
          json['waterUsed'] ??
          json['waterUsageArea'],
      defaultValue: 0.0,
    );

    return CropWaterUsageModel(
      cropName: cropTitle,
      cropNameMarathi: cropTitleMarathi,
      allocatedHaCm: allocated,
      usedHaCm: used,
      areaAcres: areaVal,
      percentage: JsonParseUtils.parseDouble(
        json['percentage'] ?? (allocated > 0 ? ((used / allocated) * 100) : 0.0),
      ),
      id: JsonParseUtils.parseIntOrNull(json['id']),
      memberId: JsonParseUtils.parseIntOrNull(
        json['memberId'] ?? json['member_id'] ?? json['farmerMemberId'],
      ),
      farmerMemberId: JsonParseUtils.parseIntOrNull(
        json['farmerMemberId'] ?? json['farmer_member_id'],
      ),
      societyId: JsonParseUtils.parseIntOrNull(
        json['societyId'] ?? json['society_id'],
      ),
      waterUsageId: JsonParseUtils.parseIntOrNull(
        json['waterUsageId'] ?? json['water_usage_id'],
      ),
      fiscalYear: JsonParseUtils.parseStringOrNull(
        json['fiscalYear'] ?? json['fiscal_year'],
      ),
      season: JsonParseUtils.parseStringOrNull(
        json['season'] ?? json['sSeason'],
      ),
      rotation: JsonParseUtils.parseStringOrNull(
        json['rotation'] ?? json['sRotation'],
      ),
      village: JsonParseUtils.parseStringOrNull(
        json['village'] ?? json['sVillage'],
      ),
      surveyNo: JsonParseUtils.parseStringOrNull(
        json['surveyNo'] ?? json['survey_no'],
      ),
      source: JsonParseUtils.parseStringOrNull(json['source']),
      waterValue: JsonParseUtils.parseDoubleOrNull(
        json['value'] ?? json['waterValue'] ?? json['water_value'],
      ),
      rateType: JsonParseUtils.parseStringOrNull(
        json['rateType'] ?? json['rate_type'],
      ),
      rateValue: JsonParseUtils.parseDoubleOrNull(
        json['rateValue'] ?? json['rate_value'],
      ),
      perType: JsonParseUtils.parseStringOrNull(
        json['perType'] ?? json['per_type'],
      ),
      seasonalWaterUsage: JsonParseUtils.parseStringOrNull(
        json['seasonalWaterUsage'] ?? json['seasonal_water_usage'],
      ),
      amount: JsonParseUtils.parseDoubleOrNull(json['amount']),
      approvalStatus: JsonParseUtils.parseStringOrNull(
        json['approvalStatus'] ?? json['approval_status'],
      ),
      billGenerated: JsonParseUtils.parseBoolOrNull(
        json['billGenerated'] ?? json['bill_generated'],
      ),
      isPaymentDone: JsonParseUtils.parseBoolOrNull(
        json['isPaymentDone'] ?? json['is_payment_done'],
      ),
      transactionDate: JsonParseUtils.parseDateTime(
        json['transactionDate'] ?? json['transaction_date'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'crop_name': cropName,
    'crop_name_marathi': cropNameMarathi,
    'allocated_ha_cm': allocatedHaCm,
    'used_ha_cm': usedHaCm,
    'area_acres': areaAcres,
    'percentage': percentage,
    'id': id,
    'memberId': memberId,
    'farmerMemberId': farmerMemberId,
    'societyId': societyId,
    'waterUsageId': waterUsageId,
    'fiscalYear': fiscalYear,
    'season': season,
    'rotation': rotation,
    'village': village,
    'surveyNo': surveyNo,
    'source': source,
    'value': waterValue,
    'rateType': rateType,
    'rateValue': rateValue,
    'perType': perType,
    'seasonalWaterUsage': seasonalWaterUsage,
    'amount': amount,
    'approvalStatus': approvalStatus,
    'billGenerated': billGenerated,
    'isPaymentDone': isPaymentDone,
    'transactionDate': transactionDate?.toIso8601String(),
  };
}

/// Data model for [WaterQuotaEntity].
class WaterQuotaModel extends WaterQuotaEntity {
  const WaterQuotaModel({
    required super.season,
    required super.totalQuotaHaCm,
    required super.usedQuotaHaCm,
    required super.remainingQuotaHaCm,
    required super.percentageUsed,
    required super.canalName,
    required super.canalStatus,
    required super.currentFlowCusecs,
    required super.outletNumber,
    required super.wuaSocietyName,
    required super.farmerName,
    required super.totalTurnsCount,
    required super.completedTurnsCount,
    required super.cropBreakdown,
    super.soilMoistureStatus,
    super.nextCanalRotationDate,
    super.societyId,
    super.fiscalYear,
  });

  factory WaterQuotaModel.fromJson(Map<String, dynamic> json) {
    final crops = JsonParseUtils.parseMapList(json['crop_breakdown'])
        .map(CropWaterUsageModel.fromJson)
        .toList();

    final totalQuota = JsonParseUtils.parseDouble(
      json['total_quota_ha_cm'] ?? json['totalQuotaHaCm'] ?? json['quota'],
      defaultValue: 0.0,
    );
    final usedQuota = JsonParseUtils.parseDouble(
      json['used_quota_ha_cm'] ?? json['usedQuotaHaCm'] ?? json['waterUsed'],
      defaultValue: 0.0,
    );
    final remainingQuota = JsonParseUtils.parseDouble(
      json['remaining_quota_ha_cm'] ?? json['remainingQuotaHaCm'],
      defaultValue: totalQuota > usedQuota ? (totalQuota - usedQuota) : 0.0,
    );
    final percentage = JsonParseUtils.parseDouble(
      json['percentage_used'] ?? json['percentageUsed'],
      defaultValue: totalQuota > 0
          ? ((usedQuota / totalQuota) * 100).roundToDouble()
          : 0.0,
    );

    return WaterQuotaModel(
      season: JsonParseUtils.parseString(
        json['season'] ?? json['sSeason'],
        defaultValue: 'N/A',
      ),
      totalQuotaHaCm: totalQuota,
      usedQuotaHaCm: usedQuota,
      remainingQuotaHaCm: remainingQuota,
      percentageUsed: percentage,
      canalName: JsonParseUtils.parseString(
        json['canal_name'] ?? json['canalName'],
        defaultValue: 'N/A',
      ),
      canalStatus: JsonParseUtils.parseString(
        json['canal_status'] ?? json['canalStatus'],
        defaultValue: 'N/A',
      ),
      currentFlowCusecs: JsonParseUtils.parseDouble(
        json['current_flow_cusecs'] ??
            json['currentFlowCusecs'] ??
            json['cumecs'],
        defaultValue: 0.0,
      ),
      outletNumber: JsonParseUtils.parseString(
        json['outlet_number'] ?? json['outletNumber'] ?? json['sOutlet'],
        defaultValue: 'N/A',
      ),
      wuaSocietyName: JsonParseUtils.parseString(
        json['wua_society_name'] ??
            json['society_name'] ??
            json['wuaSocietyName'] ??
            json['sWuaName'],
        defaultValue: 'N/A',
      ),
      farmerName: JsonParseUtils.parseString(
        json['farmer_name'] ?? json['farmerName'] ?? json['sFarmerName'],
        defaultValue: 'N/A',
      ),
      totalTurnsCount: JsonParseUtils.parseInt(
        json['total_turns_count'] ?? json['totalTurnsCount'],
        defaultValue: 0,
      ),
      completedTurnsCount: JsonParseUtils.parseInt(
        json['completed_turns_count'] ?? json['completedTurnsCount'],
        defaultValue: 0,
      ),
      cropBreakdown: crops,
      soilMoistureStatus: JsonParseUtils.parseString(
        json['soil_moisture_status'] ?? json['soilMoistureStatus'],
        defaultValue: 'N/A',
      ),
      nextCanalRotationDate: JsonParseUtils.parseDateTime(
        json['next_canal_rotation_date'] ?? json['startDate'],
      ),
      societyId: JsonParseUtils.parseIntOrNull(
        json['iSocietyId'] ?? json['societyId'] ?? json['society_id'],
      ),
      fiscalYear: JsonParseUtils.parseStringOrNull(
        json['sFiscalYear'] ?? json['fiscalYear'] ?? json['fiscal_year'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'season': season,
    'total_quota_ha_cm': totalQuotaHaCm,
    'used_quota_ha_cm': usedQuotaHaCm,
    'remaining_quota_ha_cm': remainingQuotaHaCm,
    'percentage_used': percentageUsed,
    'canal_name': canalName,
    'canal_status': canalStatus,
    'current_flow_cusecs': currentFlowCusecs,
    'outlet_number': outletNumber,
    'wua_society_name': wuaSocietyName,
    'farmer_name': farmerName,
    'total_turns_count': totalTurnsCount,
    'completed_turns_count': completedTurnsCount,
    'crop_breakdown': cropBreakdown
        .map((c) => (c as CropWaterUsageModel).toJson())
        .toList(),
    'soil_moisture_status': soilMoistureStatus,
    'next_canal_rotation_date': nextCanalRotationDate?.toIso8601String(),
    'iSocietyId': societyId,
    'sFiscalYear': fiscalYear,
  };
}

/// Data model for [IrrigationTurnEntity] aligned with `wua_water_usage` table.
class IrrigationTurnModel extends IrrigationTurnEntity {
  const IrrigationTurnModel({
    required super.id,
    required super.turnNumber,
    required super.season,
    required super.status,
    required super.scheduledStartTime,
    required super.scheduledEndTime,
    super.actualStartTime,
    super.actualEndTime,
    required super.durationHours,
    required super.outletNo,
    required super.gateNo,
    required super.dischargeCusecs,
    required super.waterDeliveredHaCm,
    required super.crop,
    required super.fieldParcel,
    super.inspectorName,
    super.isVerified,
    super.notes,
    super.canRequestSwap,
    super.societyId,
    super.fiscalYear,
    super.rotation,
    super.cumecs,
    super.totalHours,
    super.waterStartTime,
    super.waterEndTime,
    super.rawStatus,
  });

  factory IrrigationTurnModel.fromJson(Map<String, dynamic> json) {
    final startTimeParsed = JsonParseUtils.parseDateTime(
      json['scheduled_start_time'] ??
          json['scheduledStartTime'] ??
          json['startDate'] ??
          json['start_date'],
    );
    final endTimeParsed = JsonParseUtils.parseDateTime(
      json['scheduled_end_time'] ??
          json['scheduledEndTime'] ??
          json['endDate'] ??
          json['end_date'],
    );

    final start = startTimeParsed ?? DateTime.now();
    final duration = JsonParseUtils.parseDouble(
      json['duration_hours'] ??
          json['durationHours'] ??
          json['totalHours'] ??
          json['total_hours'],
      defaultValue: 0.0,
    );
    final end = endTimeParsed ?? start.add(Duration(hours: duration.toInt()));

    String status = JsonParseUtils.parseString(
      json['status'] ?? json['sStatus'],
    );
    if (status.isEmpty || status == 'A') {
      final now = DateTime.now();
      if (now.isAfter(end)) {
        status = TurnStatus.completed;
      } else if (now.isBefore(start)) {
        status = TurnStatus.upcoming;
      } else {
        status = TurnStatus.active;
      }
    }

    final cumecsVal = JsonParseUtils.parseDoubleOrNull(json['cumecs']);

    return IrrigationTurnModel(
      id: JsonParseUtils.parseString(json['id']),
      turnNumber: JsonParseUtils.parseInt(
        json['turn_number'] ??
            json['turnNumber'] ??
            json['sRotation'] ??
            json['rotation'],
        defaultValue: 0,
      ),
      season: JsonParseUtils.parseString(
        json['season'] ?? json['sSeason'],
        defaultValue: 'N/A',
      ),
      status: status,
      scheduledStartTime: start,
      scheduledEndTime: end,
      actualStartTime: JsonParseUtils.parseDateTime(
        json['actual_start_time'] ?? json['actualStartTime'],
      ),
      actualEndTime: JsonParseUtils.parseDateTime(
        json['actual_end_time'] ?? json['actualEndTime'],
      ),
      durationHours: duration,
      outletNo: JsonParseUtils.parseString(
        json['outlet_no'] ?? json['outletNo'] ?? json['sOutlet'],
        defaultValue: 'N/A',
      ),
      gateNo: JsonParseUtils.parseString(
        json['gate_no'] ?? json['gateNo'] ?? json['sGate'],
        defaultValue: 'N/A',
      ),
      dischargeCusecs: cumecsVal != null
          ? cumecsVal * 35.3147
          : JsonParseUtils.parseDouble(
              json['discharge_cusecs'] ?? json['dischargeCusecs'],
              defaultValue: 0.0,
            ),
      waterDeliveredHaCm: JsonParseUtils.parseDouble(
        json['water_delivered_ha_cm'] ??
            json['waterDeliveredHaCm'] ??
            json['waterUsed'],
        defaultValue: 0.0,
      ),
      crop: JsonParseUtils.parseString(
        json['crop'] ?? json['sCrop'],
        defaultValue: 'N/A',
      ),
      fieldParcel: JsonParseUtils.parseString(
        json['field_parcel'] ??
            json['fieldParcel'] ??
            (json['surveyNo'] != null
                ? 'Survey No. ${json['surveyNo']}'
                : null),
        defaultValue: 'N/A',
      ),
      inspectorName: JsonParseUtils.parseString(
        json['inspector_name'] ?? json['inspectorName'],
        defaultValue: 'N/A',
      ),
      isVerified: JsonParseUtils.parseBool(
        json['is_verified'] ?? json['isVerified'],
        defaultValue: false,
      ),
      notes: JsonParseUtils.parseStringOrNull(
        json['notes'] ?? json['sRemarks'],
      ),
      canRequestSwap: JsonParseUtils.parseBool(
        json['can_request_swap'] ?? json['canRequestSwap'],
        defaultValue: true,
      ),
      societyId: JsonParseUtils.parseIntOrNull(
        json['iSocietyId'] ?? json['societyId'] ?? json['society_id'],
      ),
      fiscalYear: JsonParseUtils.parseStringOrNull(
        json['sFiscalYear'] ?? json['fiscalYear'] ?? json['fiscal_year'],
      ),
      rotation: JsonParseUtils.parseStringOrNull(
        json['sRotation'] ?? json['rotation'],
      ),
      cumecs: cumecsVal,
      totalHours: duration,
      waterStartTime: JsonParseUtils.parseStringOrNull(
        json['waterStartTime'] ?? json['water_start_time'],
      ),
      waterEndTime: JsonParseUtils.parseStringOrNull(
        json['waterEndTime'] ?? json['water_end_time'],
      ),
      rawStatus: JsonParseUtils.parseStringOrNull(
        json['sStatus'] ?? json['status'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'turn_number': turnNumber,
    'season': season,
    'status': status,
    'scheduled_start_time': scheduledStartTime.toIso8601String(),
    'scheduled_end_time': scheduledEndTime.toIso8601String(),
    'actual_start_time': actualStartTime?.toIso8601String(),
    'actual_end_time': actualEndTime?.toIso8601String(),
    'duration_hours': durationHours,
    'outlet_no': outletNo,
    'gate_no': gateNo,
    'discharge_cusecs': dischargeCusecs,
    'water_delivered_ha_cm': waterDeliveredHaCm,
    'crop': crop,
    'field_parcel': fieldParcel,
    'inspector_name': inspectorName,
    'is_verified': isVerified,
    'notes': notes,
    'can_request_swap': canRequestSwap,
    'iSocietyId': societyId,
    'sFiscalYear': fiscalYear,
    'sRotation': rotation,
    'cumecs': cumecs,
    'totalHours': totalHours,
    'waterStartTime': waterStartTime,
    'waterEndTime': waterEndTime,
    'sStatus': rawStatus ?? status,
  };
}

/// Data model for [WaterUsageSummaryEntity].
class WaterUsageSummaryModel extends WaterUsageSummaryEntity {
  const WaterUsageSummaryModel({
    required super.quota,
    super.nextTurn,
    required super.allTurns,
  });

  factory WaterUsageSummaryModel.fromJson(Map<String, dynamic> json) {
    final quota = WaterQuotaModel.fromJson(
      JsonParseUtils.parseMapOrNull(json['quota']) ?? const {},
    );

    final turns = JsonParseUtils.parseMapList(json['turns'])
        .map(IrrigationTurnModel.fromJson)
        .toList();

    final nextTurnMap = JsonParseUtils.parseMapOrNull(json['next_turn']);
    final next = nextTurnMap != null
        ? IrrigationTurnModel.fromJson(nextTurnMap)
        : turns.where((t) => t.isUpcoming || t.isActive).firstOrNull;

    return WaterUsageSummaryModel(
      quota: quota,
      nextTurn: next,
      allTurns: turns,
    );
  }
}
