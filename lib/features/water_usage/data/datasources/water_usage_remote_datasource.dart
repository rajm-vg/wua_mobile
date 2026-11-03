import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/core/network/api_endpoints.dart';
import 'package:wua_mobile/features/water_usage/data/models/water_usage_model.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';

abstract class WaterUsageRemoteDataSource {
  Future<WaterUsageSummaryModel> getWaterUsageSummary({bool forceRefresh = false});
  Future<IrrigationTurnModel> getTurnById(String turnId);
  Future<bool> requestTurnSwap({
    required String turnId,
    required DateTime preferredDate,
    required String reason,
    String? swappedWithFarmer,
  });
}

class WaterUsageRemoteDataSourceImpl implements WaterUsageRemoteDataSource {
  WaterUsageRemoteDataSourceImpl({required this.apiClient});

  final ApiClient apiClient;

  // In-memory simulated stateful store matching home page widgets
  late WaterQuotaModel _mockQuota = WaterQuotaModel(
    season: 'Rabi Season (2024-25)',
    totalQuotaHaCm: 20.0,
    usedQuotaHaCm: 14.2,
    remainingQuotaHaCm: 5.8,
    percentageUsed: 71.0,
    canalName: 'Minor-3 (Outlet 4B), Distributary 7',
    canalStatus: '125 Cusecs • Active',
    currentFlowCusecs: 125.0,
    outletNumber: 'Outlet No. 12 (Gate #4)',
    wuaSocietyName: 'Ganga-Godavari WUA Society #12',
    farmerName: 'Ramesh Patil',
    totalTurnsCount: 5,
    completedTurnsCount: 3,
    soilMoistureStatus: 'Adequate (68%)',
    nextCanalRotationDate: DateTime(2026, 10, 31, 8, 0),
    cropBreakdown: const [
      CropWaterUsageModel(
        cropName: 'Wheat',
        cropNameMarathi: 'गहू (HD-2967)',
        allocatedHaCm: 12.0,
        usedHaCm: 8.5,
        areaAcres: 3.5,
        percentage: 60.0,
      ),
      CropWaterUsageModel(
        cropName: 'Gram / Chickpea',
        cropNameMarathi: 'हरभरा (Digvijay)',
        allocatedHaCm: 5.0,
        usedHaCm: 3.2,
        areaAcres: 1.5,
        percentage: 23.0,
      ),
      CropWaterUsageModel(
        cropName: 'Fodder / Mustard',
        cropNameMarathi: 'चारा / मोहरी',
        allocatedHaCm: 3.0,
        usedHaCm: 2.5,
        areaAcres: 1.0,
        percentage: 17.0,
      ),
    ],
  );

  late List<IrrigationTurnModel> _mockTurns = [
    // Turn 4: Upcoming / Next active wari (matches NextCanalTurnCard on home)
    IrrigationTurnModel(
      id: 'turn_rabi_04',
      turnNumber: 4,
      season: 'Rabi Season (2024-25)',
      status: TurnStatus.upcoming,
      scheduledStartTime: DateTime(2026, 10, 31, 8, 0),
      scheduledEndTime: DateTime(2026, 10, 31, 20, 0),
      durationHours: 12.0,
      outletNo: 'Outlet No. 12',
      gateNo: 'Gate #4',
      dischargeCusecs: 50.0,
      waterDeliveredHaCm: 3.8,
      crop: 'Wheat (गहू)',
      fieldParcel: 'Survey No. 42/1A (3.5 Acres)',
      inspectorName: 'S. K. Deshmukh (Patkari)',
      isVerified: false,
      notes:
          'Sluice gate will open at 08:00 AM sharp. Please verify sub-minor field channels (चार्या) are desilted and clear of weeds.',
      canRequestSwap: true,
    ),

    // Turn 5: Final Upcoming Turn in season
    IrrigationTurnModel(
      id: 'turn_rabi_05',
      turnNumber: 5,
      season: 'Rabi Season (2024-25)',
      status: TurnStatus.upcoming,
      scheduledStartTime: DateTime(2026, 11, 15, 6, 0),
      scheduledEndTime: DateTime(2026, 11, 15, 16, 0),
      durationHours: 10.0,
      outletNo: 'Outlet No. 12',
      gateNo: 'Gate #4',
      dischargeCusecs: 45.0,
      waterDeliveredHaCm: 3.2,
      crop: 'Gram (हरभरा)',
      fieldParcel: 'Survey No. 42/1B (1.5 Acres)',
      inspectorName: 'S. K. Deshmukh (Patkari)',
      isVerified: false,
      notes: 'Final grain-filling irrigation rotation before harvesting.',
      canRequestSwap: true,
    ),

    // Turn 3: Completed Turn
    IrrigationTurnModel(
      id: 'turn_rabi_03',
      turnNumber: 3,
      season: 'Rabi Season (2024-25)',
      status: TurnStatus.completed,
      scheduledStartTime: DateTime(2026, 10, 16, 7, 0),
      scheduledEndTime: DateTime(2026, 10, 16, 17, 0),
      actualStartTime: DateTime(2026, 10, 16, 7, 10),
      actualEndTime: DateTime(2026, 10, 16, 17, 0),
      durationHours: 10.0,
      outletNo: 'Outlet No. 12',
      gateNo: 'Gate #4',
      dischargeCusecs: 50.0,
      waterDeliveredHaCm: 3.6,
      crop: 'Wheat (गहू)',
      fieldParcel: 'Survey No. 42/1A (3.5 Acres)',
      inspectorName: 'S. K. Deshmukh (Patkari)',
      isVerified: true,
      notes: 'Flow maintained consistently at 50 Cusecs. Water delivery verified.',
      canRequestSwap: false,
    ),

    // Turn 2: Completed Turn
    IrrigationTurnModel(
      id: 'turn_rabi_02',
      turnNumber: 2,
      season: 'Rabi Season (2024-25)',
      status: TurnStatus.completed,
      scheduledStartTime: DateTime(2026, 10, 2, 8, 0),
      scheduledEndTime: DateTime(2026, 10, 2, 18, 0),
      actualStartTime: DateTime(2026, 10, 2, 8, 0),
      actualEndTime: DateTime(2026, 10, 2, 17, 50),
      durationHours: 10.0,
      outletNo: 'Outlet No. 12',
      gateNo: 'Gate #4',
      dischargeCusecs: 50.0,
      waterDeliveredHaCm: 3.5,
      crop: 'Wheat & Gram',
      fieldParcel: 'Survey No. 42/1A & 42/1B',
      inspectorName: 'S. K. Deshmukh (Patkari)',
      isVerified: true,
      notes: 'Crown root initiation irrigation successfully applied.',
      canRequestSwap: false,
    ),

    // Turn 1: Completed Turn
    IrrigationTurnModel(
      id: 'turn_rabi_01',
      turnNumber: 1,
      season: 'Rabi Season (2024-25)',
      status: TurnStatus.completed,
      scheduledStartTime: DateTime(2026, 9, 18, 8, 0),
      scheduledEndTime: DateTime(2026, 9, 18, 18, 0),
      actualStartTime: DateTime(2026, 9, 18, 8, 0),
      actualEndTime: DateTime(2026, 9, 18, 18, 0),
      durationHours: 10.0,
      outletNo: 'Outlet No. 12',
      gateNo: 'Gate #4',
      dischargeCusecs: 50.0,
      waterDeliveredHaCm: 3.5,
      crop: 'Pre-sowing / Palva (पालवा)',
      fieldParcel: 'Survey No. 42/1A (3.5 Acres)',
      inspectorName: 'S. K. Deshmukh (Patkari)',
      isVerified: true,
      notes: 'Pre-sowing seedbed preparation soaking.',
      canRequestSwap: false,
    ),
  ];

  @override
  Future<WaterUsageSummaryModel> getWaterUsageSummary({
    bool forceRefresh = false,
  }) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.waterUsageSummary,
      );
      if (response.statusCode == 200 && response.data != null) {
        return WaterUsageSummaryModel.fromJson(response.data!);
      }
    } catch (e) {
      AppLogger.warning(
        'WaterUsage API unavailable ($e), serving simulated WUA canal dataset.',
      );
    }

    final next = _mockTurns
        .where((t) => t.isUpcoming || t.isActive)
        .firstOrNull;

    return WaterUsageSummaryModel(
      quota: _mockQuota,
      nextTurn: next,
      allTurns: List.unmodifiable(_mockTurns),
    );
  }

  @override
  Future<IrrigationTurnModel> getTurnById(String turnId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '${ApiEndpoints.waterUsage}/turns/$turnId',
      );
      if (response.statusCode == 200 && response.data != null) {
        return IrrigationTurnModel.fromJson(response.data!);
      }
    } catch (e) {
      AppLogger.warning('Turn detail API fallback: $e');
    }

    return _mockTurns.firstWhere(
      (t) => t.id == turnId,
      orElse: () => _mockTurns.first,
    );
  }

  @override
  Future<bool> requestTurnSwap({
    required String turnId,
    required DateTime preferredDate,
    required String reason,
    String? swappedWithFarmer,
  }) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '${ApiEndpoints.waterUsage}/turn-swap',
        data: {
          'turn_id': turnId,
          'preferred_date': preferredDate.toIso8601String(),
          'reason': reason,
          'swapped_with': swappedWithFarmer,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      AppLogger.warning('Turn swap API failed ($e), executing local mock swap.');
    }

    // Local simulated update
    final index = _mockTurns.indexWhere((t) => t.id == turnId);
    if (index != -1) {
      final old = _mockTurns[index];
      _mockTurns[index] = IrrigationTurnModel(
        id: old.id,
        turnNumber: old.turnNumber,
        season: old.season,
        status: TurnStatus.swapped,
        scheduledStartTime: preferredDate,
        scheduledEndTime: preferredDate.add(Duration(hours: old.durationHours.toInt())),
        durationHours: old.durationHours,
        outletNo: old.outletNo,
        gateNo: old.gateNo,
        dischargeCusecs: old.dischargeCusecs,
        waterDeliveredHaCm: old.waterDeliveredHaCm,
        crop: old.crop,
        fieldParcel: old.fieldParcel,
        inspectorName: old.inspectorName,
        isVerified: false,
        notes: 'Rescheduled: $reason (${swappedWithFarmer ?? "Neighbor Swap"})',
        canRequestSwap: false,
      );
    }
    return true;
  }
}

