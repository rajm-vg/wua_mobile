import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Status constants for rotational canal irrigation turns (Wari).
class TurnStatus {
  TurnStatus._();

  static const String active = 'ACTIVE';
  static const String upcoming = 'UPCOMING';
  static const String completed = 'COMPLETED';
  static const String swapped = 'SWAPPED';
  static const String cancelled = 'CANCELLED';

  static String toLabel(String status) {
    switch (status.toUpperCase()) {
      case active:
        return 'In Progress • सुरू आहे';
      case upcoming:
        return 'Upcoming • नियोजित';
      case completed:
        return 'Completed • पूर्ण';
      case swapped:
        return 'Swapped • अदलाबदल';
      case cancelled:
        return 'Cancelled • रद्द';
      default:
        return status;
    }
  }
}

/// Breakdown of water usage per crop aligned with `crop_details` table.
class CropWaterUsage extends Equatable {
  const CropWaterUsage({
    required this.cropName,
    required this.cropNameMarathi,
    required this.allocatedHaCm,
    required this.usedHaCm,
    required this.areaAcres,
    required this.percentage,
    this.id,
    this.memberId,
    this.farmerMemberId,
    this.societyId,
    this.waterUsageId,
    this.fiscalYear,
    this.season,
    this.rotation,
    this.village,
    this.surveyNo,
    this.source,
    this.waterValue,
    this.rateType,
    this.rateValue,
    this.perType,
    this.seasonalWaterUsage,
    this.amount,
    this.approvalStatus,
    this.billGenerated,
    this.isPaymentDone,
    this.transactionDate,
  });

  final String cropName;
  final String cropNameMarathi;
  final double allocatedHaCm;
  final double usedHaCm;
  final double areaAcres;
  final double percentage;

  // ─── Database Fields from `crop_details` ───────────────────
  final int? id;
  final int? memberId;
  final int? farmerMemberId;
  final int? societyId;
  final int? waterUsageId;
  final String? fiscalYear;
  final String? season;
  final String? rotation;
  final String? village;
  final String? surveyNo;
  final String? source;
  final double? waterValue;
  final String? rateType;
  final double? rateValue;
  final String? perType;
  final String? seasonalWaterUsage;
  final double? amount;
  final String? approvalStatus;
  final bool? billGenerated;
  final bool? isPaymentDone;
  final DateTime? transactionDate;

  String get displayCropName =>
      cropNameMarathi.isNotEmpty ? cropNameMarathi : cropName;

  String? get formattedUnitValue {
    final val = waterValue;
    if (val == null || val <= 0) return null;
    final valText = val % 1 == 0
        ? val.toInt().toString()
        : val.toStringAsFixed(2);
    final unit = rateType?.isNotEmpty == true
        ? rateType!
        : (perType?.isNotEmpty == true ? perType! : '');
    return unit.isNotEmpty ? '$valText $unit' : valText;
  }

  @override
  List<Object?> get props => [
    cropName,
    cropNameMarathi,
    allocatedHaCm,
    usedHaCm,
    areaAcres,
    percentage,
    id,
    memberId,
    farmerMemberId,
    societyId,
    waterUsageId,
    fiscalYear,
    season,
    rotation,
    village,
    surveyNo,
    source,
    waterValue,
    rateType,
    rateValue,
    perType,
    seasonalWaterUsage,
    amount,
    approvalStatus,
    billGenerated,
    isPaymentDone,
    transactionDate,
  ];
}

/// Quota and live canal status for the farmer's water share.
class WaterQuotaEntity extends Equatable {
  const WaterQuotaEntity({
    required this.season,
    required this.totalQuotaHaCm,
    required this.usedQuotaHaCm,
    required this.remainingQuotaHaCm,
    required this.percentageUsed,
    required this.canalName,
    required this.canalStatus,
    required this.currentFlowCusecs,
    required this.outletNumber,
    required this.wuaSocietyName,
    required this.farmerName,
    required this.totalTurnsCount,
    required this.completedTurnsCount,
    required this.cropBreakdown,
    this.soilMoistureStatus = 'N/A',
    this.nextCanalRotationDate,
    this.societyId,
    this.fiscalYear,
  });

  final String season;
  final double totalQuotaHaCm;
  final double usedQuotaHaCm;
  final double remainingQuotaHaCm;
  final double percentageUsed;
  final String canalName;
  final String canalStatus;
  final double currentFlowCusecs;
  final String outletNumber;
  final String wuaSocietyName;
  final String farmerName;
  final int totalTurnsCount;
  final int completedTurnsCount;
  final List<CropWaterUsage> cropBreakdown;
  final String soilMoistureStatus;
  final DateTime? nextCanalRotationDate;
  final int? societyId;
  final String? fiscalYear;

  bool get isNearLimit => percentageUsed >= 85.0;
  bool get isLimitExceeded => percentageUsed >= 100.0;
  double get totalIrrigatedArea =>
      cropBreakdown.fold<double>(0.0, (sum, c) => sum + c.areaAcres);
  double get totalCropAmount =>
      cropBreakdown.fold<double>(0.0, (sum, c) => sum + (c.amount ?? 0.0));

  @override
  List<Object?> get props => [
    season,
    totalQuotaHaCm,
    usedQuotaHaCm,
    remainingQuotaHaCm,
    percentageUsed,
    canalName,
    canalStatus,
    currentFlowCusecs,
    outletNumber,
    wuaSocietyName,
    farmerName,
    totalTurnsCount,
    completedTurnsCount,
    cropBreakdown,
    soilMoistureStatus,
    nextCanalRotationDate,
    societyId,
    fiscalYear,
  ];
}

/// Rotational irrigation turn / Wari entity aligned with `wua_water_usage` table.
class IrrigationTurnEntity extends Equatable {
  const IrrigationTurnEntity({
    required this.id,
    required this.turnNumber,
    required this.season,
    required this.status,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    this.actualStartTime,
    this.actualEndTime,
    required this.durationHours,
    required this.outletNo,
    required this.gateNo,
    required this.dischargeCusecs,
    required this.waterDeliveredHaCm,
    required this.crop,
    required this.fieldParcel,
    this.inspectorName = 'N/A',
    this.isVerified = false,
    this.notes,
    this.canRequestSwap = true,
    this.societyId,
    this.fiscalYear,
    this.rotation,
    this.cumecs,
    this.totalHours,
    this.waterStartTime,
    this.waterEndTime,
    this.rawStatus,
  });

  final String id;
  final int turnNumber;
  final String season;
  final String status;
  final DateTime scheduledStartTime;
  final DateTime scheduledEndTime;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  final double durationHours;
  final String outletNo;
  final String gateNo;
  final double dischargeCusecs;
  final double waterDeliveredHaCm;
  final String crop;
  final String fieldParcel;
  final String inspectorName;
  final bool isVerified;
  final String? notes;
  final bool canRequestSwap;

  // ─── Database Fields from `wua_water_usage` (vgwaterresource) ───
  final int? societyId;
  final String? fiscalYear;
  final String? rotation;
  final double? cumecs;
  final double? totalHours;
  final String? waterStartTime;
  final String? waterEndTime;
  final String? rawStatus;

  bool get isActive => status.toUpperCase() == TurnStatus.active;
  bool get isUpcoming => status.toUpperCase() == TurnStatus.upcoming;
  bool get isCompleted => status.toUpperCase() == TurnStatus.completed;

  String get formattedDate =>
      DateFormat('EEEE, dd MMM yyyy').format(scheduledStartTime);

  String get formattedTimeRange {
    final start = DateFormat('hh:mm a').format(scheduledStartTime);
    final end = DateFormat('hh:mm a').format(scheduledEndTime);
    final hours = durationHours.toStringAsFixed(durationHours % 1 == 0 ? 0 : 1);
    return '$start – $end ($hours Hours)';
  }

  @override
  List<Object?> get props => [
    id,
    turnNumber,
    season,
    status,
    scheduledStartTime,
    scheduledEndTime,
    actualStartTime,
    actualEndTime,
    durationHours,
    outletNo,
    gateNo,
    dischargeCusecs,
    waterDeliveredHaCm,
    crop,
    fieldParcel,
    inspectorName,
    isVerified,
    notes,
    canRequestSwap,
    societyId,
    fiscalYear,
    rotation,
    cumecs,
    totalHours,
    waterStartTime,
    waterEndTime,
    rawStatus,
  ];
}

/// Aggregated entity containing quota, upcoming turn, and turn history.
class WaterUsageSummaryEntity extends Equatable {
  const WaterUsageSummaryEntity({
    required this.quota,
    this.nextTurn,
    required this.allTurns,
  });

  final WaterQuotaEntity quota;
  final IrrigationTurnEntity? nextTurn;
  final List<IrrigationTurnEntity> allTurns;

  List<IrrigationTurnEntity> get upcomingTurns =>
      allTurns.where((t) => t.isUpcoming || t.isActive).toList();

  List<IrrigationTurnEntity> get completedTurns =>
      allTurns.where((t) => t.isCompleted).toList();

  @override
  List<Object?> get props => [quota, nextTurn, allTurns];
}
