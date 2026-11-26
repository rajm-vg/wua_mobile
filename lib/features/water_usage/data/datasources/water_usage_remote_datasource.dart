import 'package:wua_mobile/core/errors/exceptions.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/network/api_client.dart';
import 'package:wua_mobile/core/network/api_endpoints.dart';
import 'package:wua_mobile/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:wua_mobile/features/water_usage/data/models/water_usage_model.dart';

abstract class WaterUsageRemoteDataSource {
  Future<WaterUsageSummaryModel> getWaterUsageSummary({
    bool forceRefresh = false,
  });
  Future<IrrigationTurnModel> getTurnById(String turnId);
  Future<bool> requestTurnSwap({
    required String turnId,
    required DateTime preferredDate,
    required String reason,
    String? swappedWithFarmer,
  });
}

/// Remote Water Usage data source connecting directly to `wrd_backend`:
/// - `/api/crop-details` & `/api/water-usages` (farmer outward usage, matching Web `Water Used`)
/// - `/api/wua-water-usages` (society canal rotational turns when permitted)
class WaterUsageRemoteDataSourceImpl implements WaterUsageRemoteDataSource {
  WaterUsageRemoteDataSourceImpl({
    required this.apiClient,
    this.authLocalDataSource,
  });

  final ApiClient apiClient;
  final AuthLocalDataSource? authLocalDataSource;

  Future<List<Map<String, dynamic>>> _fetchListOrIgnoreForbidden(
    String endpoint, {
    required String label,
  }) async {
    try {
      final response = await apiClient.get<dynamic>(endpoint);
      if (response.statusCode == 200 && response.data != null) {
        return ApiClient.extractListData(response.data);
      }
      return const <Map<String, dynamic>>[];
    } on ServerException catch (e) {
      if (e.statusCode == 403 || e.statusCode == 404) {
        AppLogger.warning('$label API skipped (${e.statusCode}): ${e.message}');
        return const <Map<String, dynamic>>[];
      }
      rethrow;
    }
  }

  @override
  Future<WaterUsageSummaryModel> getWaterUsageSummary({
    bool forceRefresh = false,
  }) async {
    int? societyId;
    int? farmerMemberId;
    String? farmerName;

    if (authLocalDataSource != null) {
      try {
        final cachedUser = await authLocalDataSource!.getCachedUser();
        societyId = cachedUser.societyId;
        farmerMemberId = cachedUser.effectiveFarmerMemberId;
        farmerName = cachedUser.name;
      } catch (_) {}
    }

    // 1. Fetch outward water headers (/api/water-usages) & crop details (/api/crop-details)
    final cropEndpoint = farmerMemberId != null
        ? ApiEndpoints.farmerCropUsage(farmerMemberId: farmerMemberId)
        : (societyId != null
              ? ApiEndpoints.societyCropUsage(societyId: societyId)
              : ApiEndpoints.cropDetails);

    final outwardEndpoint = farmerMemberId != null
        ? ApiEndpoints.outwardWaterUsages(farmerMemberId: farmerMemberId)
        : (societyId != null
              ? ApiEndpoints.societyOutwardWaterUsages(societyId: societyId)
              : ApiEndpoints.waterUsagesOutward);

    final rawCrops = await _fetchListOrIgnoreForbidden(
      cropEndpoint,
      label: 'CropDetails',
    );
    final rawOutward = await _fetchListOrIgnoreForbidden(
      outwardEndpoint,
      label: 'OutwardWaterUsage',
    );

    final outwardById = <int, Map<String, dynamic>>{};
    for (final header in rawOutward) {
      if (header['status']?.toString().toUpperCase() == 'D') continue;
      final idVal = header['id'];
      final parsedId = idVal is int
          ? idVal
          : int.tryParse(idVal?.toString() ?? '');
      if (parsedId != null) {
        outwardById[parsedId] = header;
      }
    }

    final farmerCrops = <CropWaterUsageModel>[];
    for (final item in rawCrops) {
      if (item['status']?.toString().toUpperCase() == 'D') continue;
      final merged = Map<String, dynamic>.from(item);
      final wuId = item['waterUsageId'] is int
          ? item['waterUsageId'] as int
          : int.tryParse(item['waterUsageId']?.toString() ?? '');
      final parent = wuId != null ? outwardById[wuId] : null;
      if (parent != null) {
        merged['fiscalYear'] ??= parent['fiscalYear'];
        merged['season'] ??= parent['season'];
        merged['approvalStatus'] ??= parent['approvalStatus'];
        merged['billGenerated'] ??= parent['billGenerated'];
      }
      farmerCrops.add(CropWaterUsageModel.fromJson(merged));
    }

    // 2. Fetch society canal rotations (/api/wua-water-usages), tolerating 403 for farmers
    final rotationsEndpoint = societyId != null
        ? ApiEndpoints.canalRotations(societyId: societyId)
        : ApiEndpoints.waterUsage;

    List<IrrigationTurnModel> turns = <IrrigationTurnModel>[];
    try {
      final response = await apiClient.get<dynamic>(rotationsEndpoint);
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final summary = WaterUsageSummaryModel.fromJson(
            response.data as Map<String, dynamic>,
          );
          if (farmerCrops.isNotEmpty) {
            final updatedQuota = WaterQuotaModel(
              season: summary.quota.season,
              totalQuotaHaCm: summary.quota.totalQuotaHaCm,
              usedQuotaHaCm: summary.quota.usedQuotaHaCm,
              remainingQuotaHaCm: summary.quota.remainingQuotaHaCm,
              percentageUsed: summary.quota.percentageUsed,
              canalName: summary.quota.canalName,
              canalStatus: summary.quota.canalStatus,
              currentFlowCusecs: summary.quota.currentFlowCusecs,
              outletNumber: summary.quota.outletNumber,
              wuaSocietyName: summary.quota.wuaSocietyName,
              farmerName: farmerName ?? summary.quota.farmerName,
              totalTurnsCount: summary.quota.totalTurnsCount,
              completedTurnsCount: summary.quota.completedTurnsCount,
              cropBreakdown: farmerCrops,
              soilMoistureStatus: summary.quota.soilMoistureStatus,
              nextCanalRotationDate: summary.quota.nextCanalRotationDate,
              societyId: summary.quota.societyId ?? societyId,
              fiscalYear: summary.quota.fiscalYear,
            );
            return WaterUsageSummaryModel(
              quota: updatedQuota,
              nextTurn: summary.nextTurn,
              allTurns: summary.allTurns,
            );
          }
          return summary;
        }

        final turnItems = ApiClient.extractListData(response.data);
        turns = turnItems.map(IrrigationTurnModel.fromJson).toList()
          ..sort(
            (a, b) => a.scheduledStartTime.compareTo(b.scheduledStartTime),
          );
      }
    } on UnauthorizedException {
      rethrow;
    } on ServerException catch (e) {
      if (e.statusCode == 403 || e.statusCode == 404) {
        AppLogger.warning(
          'Canal rotations (/api/wua-water-usages) unavailable (${e.statusCode}); continuing with outward crop usage.',
        );
      } else if (farmerCrops.isEmpty && outwardById.isEmpty) {
        rethrow;
      } else {
        AppLogger.warning('Canal rotations error ignored ($e)');
      }
    } on NetworkException {
      if (farmerCrops.isEmpty && outwardById.isEmpty) rethrow;
    } on TimeoutException {
      if (farmerCrops.isEmpty && outwardById.isEmpty) rethrow;
    }

    final next = turns.where((t) => t.isUpcoming || t.isActive).firstOrNull;
    final activeOutwardHeaders = outwardById.values.toList();
    final firstHeaderSeason = activeOutwardHeaders.isNotEmpty
        ? activeOutwardHeaders.first['season']?.toString()
        : null;
    final firstHeaderFiscalYear = activeOutwardHeaders.isNotEmpty
        ? activeOutwardHeaders.first['fiscalYear']?.toString()
        : null;

    final resolvedSeason = turns.isNotEmpty
        ? turns.first.season
        : (farmerCrops.firstOrNull?.season ?? firstHeaderSeason ?? 'N/A');
    final resolvedFiscalYear =
        turns.firstOrNull?.fiscalYear ??
        farmerCrops.firstOrNull?.fiscalYear ??
        firstHeaderFiscalYear;

    // Sum water quota only for individual farmer records matching the active
    // fiscal year & season so prior years/seasons or society-wide rows are not mixed.
    double totalAllocated = 0.0;
    double totalUsed = 0.0;
    if (farmerMemberId != null) {
      final activeCrops = farmerCrops.where((c) {
        final matchesYear =
            resolvedFiscalYear == null ||
            resolvedFiscalYear.isEmpty ||
            c.fiscalYear == null ||
            c.fiscalYear!.isEmpty ||
            c.fiscalYear == resolvedFiscalYear;
        final matchesSeason =
            resolvedSeason.isEmpty ||
            resolvedSeason == 'N/A' ||
            c.season == null ||
            c.season!.isEmpty ||
            c.season == resolvedSeason;
        return matchesYear && matchesSeason;
      });
      for (final c in activeCrops) {
        totalAllocated += c.allocatedHaCm;
        totalUsed += c.usedHaCm;
      }
    }

    final firstSurvey = farmerCrops.firstOrNull?.surveyNo;
    final quota = WaterQuotaModel(
      season: resolvedSeason,
      totalQuotaHaCm: totalAllocated,
      usedQuotaHaCm: totalUsed,
      remainingQuotaHaCm: totalAllocated > totalUsed
          ? totalAllocated - totalUsed
          : 0.0,
      percentageUsed: totalAllocated > 0
          ? (totalUsed / totalAllocated) * 100
          : 0.0,
      canalName: turns.isNotEmpty
          ? turns.first.fieldParcel
          : (farmerCrops.firstOrNull?.source ?? 'N/A'),
      canalStatus: turns.any((t) => t.isActive)
          ? 'Active Rotational Flow'
          : (turns.isNotEmpty
                ? 'Scheduled'
                : (farmerCrops.isNotEmpty || activeOutwardHeaders.isNotEmpty
                      ? 'Recorded Usage'
                      : 'N/A')),
      currentFlowCusecs: turns.isNotEmpty ? turns.first.dischargeCusecs : 0.0,
      outletNumber: turns.isNotEmpty
          ? turns.first.outletNo
          : (firstSurvey != null && firstSurvey.isNotEmpty
                ? 'Survey $firstSurvey'
                : 'N/A'),
      wuaSocietyName: '',
      farmerName: farmerName ?? '',
      totalTurnsCount: turns.length,
      completedTurnsCount: turns.where((t) => t.isCompleted).length,
      cropBreakdown: farmerCrops,
      societyId: societyId,
      fiscalYear: resolvedFiscalYear,
    );

    return WaterUsageSummaryModel(
      quota: quota,
      nextTurn: next ?? turns.firstOrNull,
      allTurns: turns,
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
      AppLogger.warning('Turn detail API error: $e');
    }

    throw ServerException(message: 'Turn with ID "$turnId" not found');
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
      AppLogger.warning('Turn swap API error: $e');
    }

    return false;
  }
}
