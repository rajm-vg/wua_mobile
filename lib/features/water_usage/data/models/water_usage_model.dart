import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';

// ─── Parsing Helpers ──────────────────────────────────────────

String _parseString(dynamic value, {String defaultValue = ''}) {
  if (value == null) return defaultValue;
  return value.toString().trim();
}

int _parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// Data model for [CropWaterUsage].
class CropWaterUsageModel extends CropWaterUsage {
  const CropWaterUsageModel({
    required super.cropName,
    required super.cropNameMarathi,
    required super.allocatedHaCm,
    required super.usedHaCm,
    required super.areaAcres,
    required super.percentage,
  });

  factory CropWaterUsageModel.fromJson(Map<String, dynamic> json) {
    return CropWaterUsageModel(
      cropName: _parseString(
        json['crop_name'] ?? json['cropName'] ?? json['sCrop'],
        defaultValue: 'General Crop',
      ),
      cropNameMarathi: _parseString(
        json['crop_name_marathi'] ?? json['cropNameMarathi'],
        defaultValue: 'पीक',
      ),
      allocatedHaCm: _parseDouble(
        json['allocated_ha_cm'] ?? json['allocatedHaCm'],
      ),
      usedHaCm: _parseDouble(
        json['used_ha_cm'] ?? json['usedHaCm'] ?? json['waterUsed'],
      ),
      areaAcres: _parseDouble(
        json['area_acres'] ?? json['areaAcres'] ?? json['area'],
      ),
      percentage: _parseDouble(json['percentage']),
    );
  }

  Map<String, dynamic> toJson() => {
        'crop_name': cropName,
        'crop_name_marathi': cropNameMarathi,
        'allocated_ha_cm': allocatedHaCm,
        'used_ha_cm': usedHaCm,
        'area_acres': areaAcres,
        'percentage': percentage,
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
  });

  factory WaterQuotaModel.fromJson(Map<String, dynamic> json) {
    final cropsList = json['crop_breakdown'] as List<dynamic>?;
    final crops = cropsList != null
        ? cropsList
            .map((c) => CropWaterUsageModel.fromJson(c as Map<String, dynamic>))
            .toList()
        : <CropWaterUsageModel>[];

    final totalQuota = _parseDouble(
      json['total_quota_ha_cm'] ?? json['totalQuotaHaCm'] ?? json['quota'],
      defaultValue: 20.0,
    );
    final usedQuota = _parseDouble(
      json['used_quota_ha_cm'] ?? json['usedQuotaHaCm'] ?? json['waterUsed'],
      defaultValue: 14.2,
    );
    final remainingQuota = _parseDouble(
      json['remaining_quota_ha_cm'] ?? json['remainingQuotaHaCm'],
      defaultValue: (totalQuota > usedQuota ? (totalQuota - usedQuota) : 0.0),
    );
    final percentage = _parseDouble(
      json['percentage_used'] ?? json['percentageUsed'],
      defaultValue:
          (totalQuota > 0 ? ((usedQuota / totalQuota) * 100).roundToDouble() : 0.0),
    );

    return WaterQuotaModel(
      season: _parseString(
        json['season'] ?? json['sSeason'],
        defaultValue: 'Rabi Season (2024-25)',
      ),
      totalQuotaHaCm: totalQuota,
      usedQuotaHaCm: usedQuota,
      remainingQuotaHaCm: remainingQuota,
      percentageUsed: percentage,
      canalName: _parseString(
        json['canal_name'] ?? json['canalName'],
        defaultValue: 'Minor-3, Distributary 7',
      ),
      canalStatus: _parseString(
        json['canal_status'] ?? json['canalStatus'],
        defaultValue: 'Active Rotational Flow',
      ),
      currentFlowCusecs: _parseDouble(
        json['current_flow_cusecs'] ?? json['currentFlowCusecs'] ?? json['cumecs'],
        defaultValue: 125.0,
      ),
      outletNumber: _parseString(
        json['outlet_number'] ?? json['outletNumber'] ?? json['sOutlet'],
        defaultValue: 'Outlet 12 (Gate #4)',
      ),
      wuaSocietyName: _parseString(
        json['wua_society_name'] ??
            json['society_name'] ??
            json['wuaSocietyName'] ??
            json['sWuaName'],
        defaultValue: 'Ganga-Godavari WUA Society #12',
      ),
      farmerName: _parseString(
        json['farmer_name'] ?? json['farmerName'] ?? json['sFarmerName'],
        defaultValue: 'Ramesh Patil',
      ),
      totalTurnsCount: _parseInt(
        json['total_turns_count'] ?? json['totalTurnsCount'],
        defaultValue: 5,
      ),
      completedTurnsCount: _parseInt(
        json['completed_turns_count'] ?? json['completedTurnsCount'],
        defaultValue: 3,
      ),
      cropBreakdown: crops,
      soilMoistureStatus: json['soil_moisture_status'] as String? ??
          json['soilMoistureStatus'] as String? ??
          'Scheduled Warabandi',
      nextCanalRotationDate: _parseDateTime(
        json['next_canal_rotation_date'] ?? json['startDate'],
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
      };
}

/// Data model for [IrrigationTurnEntity].
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
  });

  factory IrrigationTurnModel.fromJson(Map<String, dynamic> json) {
    final startTimeParsed = _parseDateTime(
      json['scheduled_start_time'] ??
          json['scheduledStartTime'] ??
          json['startDate'],
    );
    final endTimeParsed = _parseDateTime(
      json['scheduled_end_time'] ??
          json['scheduledEndTime'] ??
          json['endDate'],
    );

    final start = startTimeParsed ?? DateTime.now();
    final duration = _parseDouble(
      json['duration_hours'] ?? json['durationHours'] ?? json['totalHours'],
      defaultValue: 10.0,
    );
    final end = endTimeParsed ?? start.add(Duration(hours: duration.toInt()));

    String status = json['status'] as String? ?? '';
    if (status.isEmpty) {
      final now = DateTime.now();
      if (now.isAfter(end)) {
        status = TurnStatus.completed;
      } else if (now.isBefore(start)) {
        status = TurnStatus.upcoming;
      } else {
        status = TurnStatus.active;
      }
    }

    return IrrigationTurnModel(
      id: _parseString(json['id']),
      turnNumber: _parseInt(
        json['turn_number'] ??
            json['turnNumber'] ??
            json['sRotation'],
        defaultValue: 1,
      ),
      season: _parseString(
        json['season'] ?? json['sSeason'],
        defaultValue: 'Rabi Season (2024-25)',
      ),
      status: status,
      scheduledStartTime: start,
      scheduledEndTime: end,
      actualStartTime: _parseDateTime(
        json['actual_start_time'] ?? json['actualStartTime'],
      ),
      actualEndTime: _parseDateTime(
        json['actual_end_time'] ?? json['actualEndTime'],
      ),
      durationHours: duration,
      outletNo: _parseString(
        json['outlet_no'] ?? json['outletNo'] ?? json['sOutlet'],
        defaultValue: 'Outlet No. 12',
      ),
      gateNo: _parseString(
        json['gate_no'] ?? json['gateNo'] ?? json['sGate'],
        defaultValue: 'Gate #4',
      ),
      dischargeCusecs: _parseDouble(
        json['discharge_cusecs'] ??
            json['dischargeCusecs'] ??
            json['cumecs'],
        defaultValue: 50.0,
      ),
      waterDeliveredHaCm: _parseDouble(
        json['water_delivered_ha_cm'] ??
            json['waterDeliveredHaCm'] ??
            json['waterUsed'],
        defaultValue: 3.5,
      ),
      crop: _parseString(
        json['crop'] ?? json['sCrop'],
        defaultValue: 'Wheat (गहू)',
      ),
      fieldParcel: _parseString(
        json['field_parcel'] ??
            json['fieldParcel'] ??
            (json['surveyNo'] != null ? 'Survey No. ${json['surveyNo']}' : null),
        defaultValue: 'Survey No. 42/1A (3.5 Acres)',
      ),
      inspectorName: _parseString(
        json['inspector_name'] ?? json['inspectorName'],
        defaultValue: 'S. K. Deshmukh (Patkari)',
      ),
      isVerified: json['is_verified'] as bool? ??
          json['isVerified'] as bool? ??
          false,
      notes: json['notes'] as String? ?? json['sRemarks'] as String?,
      canRequestSwap: json['can_request_swap'] as bool? ??
          json['canRequestSwap'] as bool? ??
          true,
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
      json['quota'] as Map<String, dynamic>? ?? {},
    );

    final turnsList = json['turns'] as List<dynamic>?;
    final turns = turnsList != null
        ? turnsList
            .map((t) => IrrigationTurnModel.fromJson(t as Map<String, dynamic>))
            .toList()
        : <IrrigationTurnModel>[];

    IrrigationTurnModel? next;
    if (json['next_turn'] != null) {
      next = IrrigationTurnModel.fromJson(
        json['next_turn'] as Map<String, dynamic>,
      );
    } else {
      next = turns.where((t) => t.isUpcoming || t.isActive).firstOrNull;
    }

    return WaterUsageSummaryModel(
      quota: quota,
      nextTurn: next,
      allTurns: turns,
    );
  }
}
