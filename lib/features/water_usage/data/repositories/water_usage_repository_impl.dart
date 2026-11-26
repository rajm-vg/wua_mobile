import 'package:dartz/dartz.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/network/network_info.dart';
import 'package:wua_mobile/features/water_usage/data/datasources/water_usage_remote_datasource.dart';
import 'package:wua_mobile/features/water_usage/domain/entities/water_usage_entity.dart';
import 'package:wua_mobile/features/water_usage/domain/repositories/water_usage_repository.dart';

class WaterUsageRepositoryImpl implements WaterUsageRepository {
  WaterUsageRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final WaterUsageRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, WaterUsageSummaryEntity>> getWaterUsageSummary({
    bool forceRefresh = false,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(
          NetworkFailure(
            message: 'No active network connection. Please check your internet.',
          ),
        );
      }

      final summary = await remoteDataSource.getWaterUsageSummary(
        forceRefresh: forceRefresh,
      );
      return Right(summary);
    } catch (e) {
      return Left(
        mapExceptionToFailure(
          e,
          fallbackPrefix: 'Failed to retrieve water usage summary',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, IrrigationTurnEntity>> getTurnDetails(
    String turnId,
  ) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(
          NetworkFailure(
            message: 'No active network connection. Please check your internet.',
          ),
        );
      }

      final turn = await remoteDataSource.getTurnById(turnId);
      return Right(turn);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackPrefix: 'Failed to retrieve turn detail'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> requestTurnSwap({
    required String turnId,
    required DateTime preferredDate,
    required String reason,
    String? swappedWithFarmer,
  }) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(
          NetworkFailure(
            message: 'No active network connection. Please check your internet.',
          ),
        );
      }

      final result = await remoteDataSource.requestTurnSwap(
        turnId: turnId,
        preferredDate: preferredDate,
        reason: reason,
        swappedWithFarmer: swappedWithFarmer,
      );
      return Right(result);
    } catch (e) {
      return Left(
        mapExceptionToFailure(
          e,
          fallbackPrefix: 'Failed to submit turn swap request',
        ),
      );
    }
  }
}

