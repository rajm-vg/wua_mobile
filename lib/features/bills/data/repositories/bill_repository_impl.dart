import 'package:dartz/dartz.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/network/network_info.dart';
import 'package:wua_mobile/features/bills/data/datasources/bill_remote_datasource.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/bills/domain/repositories/bill_repository.dart';

/// Implementation of [BillRepository] managing remote access and error handling.
class BillRepositoryImpl implements BillRepository {
  BillRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final BillRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<BillEntity>>> getBills({
    String? consumerId,
    String? status,
    String? query,
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

      final models = await remoteDataSource.getBills(
        consumerId: consumerId,
        status: status,
        query: query,
      );

      return Right(models);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackPrefix: 'Failed to retrieve bills'),
      );
    }
  }

  @override
  Future<Either<Failure, BillEntity>> getBillById(String id) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(
          NetworkFailure(
            message: 'No active network connection. Please check your internet.',
          ),
        );
      }

      final model = await remoteDataSource.getBillById(id);
      return Right(model);
    } catch (e) {
      return Left(
        mapExceptionToFailure(
          e,
          fallbackPrefix: 'Failed to retrieve bill detail',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, BillEntity>> markBillAsPaid(
    String id, {
    required String paymentReference,
    required String paymentMethod,
    required double paidAmount,
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

      final model = await remoteDataSource.markBillAsPaid(
        id,
        paymentReference: paymentReference,
        paymentMethod: paymentMethod,
        paidAmount: paidAmount,
      );
      return Right(model);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackPrefix: 'Failed to mark bill as paid'),
      );
    }
  }
}

