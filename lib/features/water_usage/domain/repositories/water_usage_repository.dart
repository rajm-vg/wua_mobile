import 'package:dartz/dartz.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';

/// Contract for Water Usage, Quota & Irrigation Turn operations.
abstract class WaterUsageRepository {
  /// Fetches seasonal water quota, canal discharge status, and rotational turns list.
  Future<Either<Failure, WaterUsageSummaryEntity>> getWaterUsageSummary({
    bool forceRefresh = false,
  });

  /// Fetches detailed metrics and verification data for a specific irrigation turn.
  Future<Either<Failure, IrrigationTurnEntity>> getTurnDetails(String turnId);

  /// Submits an indent or rotational turn swap request with neighboring farmer / patkari.
  Future<Either<Failure, bool>> requestTurnSwap({
    required String turnId,
    required DateTime preferredDate,
    required String reason,
    String? swappedWithFarmer,
  });
}

