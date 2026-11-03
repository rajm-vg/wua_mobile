import 'package:dartz/dartz.dart';
import 'package:wua_mobile/core/errors/exceptions.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/network/network_info.dart';
import 'package:wua_mobile/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final PaymentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPayments({
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

      final payments = await remoteDataSource.getPayments(
        consumerId: consumerId,
        status: status,
        query: query,
      );

      return Right(payments);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to retrieve payments: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> getPaymentById(String id) async {
    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        return const Left(
          NetworkFailure(
            message: 'No active network connection. Please check your internet.',
          ),
        );
      }

      final payment = await remoteDataSource.getPaymentById(id);
      return Right(payment);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.statusCode));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Failed to retrieve payment: ${e.toString()}'),
      );
    }
  }
}

