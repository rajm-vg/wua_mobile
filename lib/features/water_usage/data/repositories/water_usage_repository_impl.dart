import 'package:dartz/dartz.dart';
import 'package:wua_mobile/core/errors/exceptions.dart';
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
        // Fall back to cached / offline mock summary
        final cached = await remoteDataSource.getWaterUsageSummary(
          forceRefresh: false,
        );
        return Right(cached);
      }

      final summary = await remoteDataSource.getWaterUsageSummary(
        forceRefresh: forceRefresh,
      );
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to retrieve water usage summary: ${e.toString()}',
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
        final turn = await remoteDataSource.getTurnById(turnId);
        return Right(turn);
      }

      final turn = await remoteDataSource.getTurnById(turnId);
      return Right(turn);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to retrieve turn detail: ${e.toString()}',
        ),
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
      final result = await remoteDataSource.requestTurnSwap(
        turnId: turnId,
        preferredDate: preferredDate,
        reason: reason,
        swappedWithFarmer: swappedWithFarmer,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to submit turn swap request: ${e.toString()}',
        ),
      );
    }
  }
}

