import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';

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
      cropName: json['crop_name'] as String? ?? 'General Crop',
      cropNameMarathi: json['crop_name_marathi'] as String? ?? 'पीक',
      allocatedHaCm: (json['allocated_ha_cm'] as num?)?.toDouble() ?? 0.0,
      usedHaCm: (json['used_ha_cm'] as num?)?.toDouble() ?? 0.0,
      areaAcres: (json['area_acres'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
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

    return WaterQuotaModel(
      season: json['season'] as String? ?? 'Rabi Season (2024-25)',
      totalQuotaHaCm: (json['total_quota_ha_cm'] as num?)?.toDouble() ?? 20.0,
      usedQuotaHaCm: (json['used_quota_ha_cm'] as num?)?.toDouble() ?? 14.2,
      remainingQuotaHaCm:
          (json['remaining_quota_ha_cm'] as num?)?.toDouble() ?? 5.8,
      percentageUsed: (json['percentage_used'] as num?)?.toDouble() ?? 71.0,
      canalName: json['canal_name'] as String? ?? 'Minor-3, Distributary 7',
      canalStatus: json['canal_status'] as String? ?? 'Active • 125 Cusecs',
      currentFlowCusecs:
          (json['current_flow_cusecs'] as num?)?.toDouble() ?? 125.0,
      outletNumber: json['outlet_number'] as String? ?? 'Outlet 12 (Gate #4)',
      wuaSocietyName: json['wua_society_name'] as String? ??
          'Ganga-Godavari WUA Society #12',
      farmerName: json['farmer_name'] as String? ?? 'Ramesh Patil',
      totalTurnsCount: json['total_turns_count'] as int? ?? 5,
      completedTurnsCount: json['completed_turns_count'] as int? ?? 3,
      cropBreakdown: crops,
      soilMoistureStatus:
          json['soil_moisture_status'] as String? ?? 'Optimal (68%)',
      nextCanalRotationDate: json['next_canal_rotation_date'] != null
          ? DateTime.tryParse(json['next_canal_rotation_date'] as String)
          : null,
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
    return IrrigationTurnModel(
      id: json['id'] as String,
      turnNumber: json['turn_number'] as int? ?? 1,
      season: json['season'] as String? ?? 'Rabi Season (2024-25)',
      status: json['status'] as String? ?? TurnStatus.upcoming,
      scheduledStartTime: DateTime.parse(json['scheduled_start_time'] as String),
      scheduledEndTime: DateTime.parse(json['scheduled_end_time'] as String),
      actualStartTime: json['actual_start_time'] != null
          ? DateTime.tryParse(json['actual_start_time'] as String)
          : null,
      actualEndTime: json['actual_end_time'] != null
          ? DateTime.tryParse(json['actual_end_time'] as String)
          : null,
      durationHours: (json['duration_hours'] as num?)?.toDouble() ?? 12.0,
      outletNo: json['outlet_no'] as String? ?? 'Outlet No. 12',
      gateNo: json['gate_no'] as String? ?? 'Gate #4',
      dischargeCusecs: (json['discharge_cusecs'] as num?)?.toDouble() ?? 50.0,
      waterDeliveredHaCm:
          (json['water_delivered_ha_cm'] as num?)?.toDouble() ?? 3.5,
      crop: json['crop'] as String? ?? 'Wheat (गहू)',
      fieldParcel:
          json['field_parcel'] as String? ?? 'Survey No. 42/1A (3.5 Acres)',
      inspectorName:
          json['inspector_name'] as String? ?? 'S. K. Deshmukh (Patkari)',
      isVerified: json['is_verified'] as bool? ?? false,
      notes: json['notes'] as String?,
      canRequestSwap: json['can_request_swap'] as bool? ?? true,
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

