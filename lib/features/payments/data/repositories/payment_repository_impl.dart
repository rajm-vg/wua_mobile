import 'package:dartz/dartz.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/network/network_info.dart';
import 'package:wua_mobile/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:wua_mobile/features/payments/data/models/payment_model.dart';
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
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackPrefix: 'Failed to retrieve payments'),
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
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackPrefix: 'Failed to retrieve payment'),
      );
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> processPayment(
    PaymentEntity payment,
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

      final model = payment is PaymentModel
          ? payment
          : PaymentModel(
              id: payment.id,
              paymentNumber: payment.paymentNumber,
              status: payment.status,
              amount: payment.amount,
              paymentDate: payment.paymentDate,
              billId: payment.billId,
              billNumber: payment.billNumber,
              consumerId: payment.consumerId,
              consumerName: payment.consumerName,
              wuaSocietyName: payment.wuaSocietyName,
              season: payment.season,
              cropType: payment.cropType,
              paymentMode: payment.paymentMode,
              gatewayTransactionId: payment.gatewayTransactionId,
              bankReference: payment.bankReference,
              gatewayName: payment.gatewayName,
              remarks: payment.remarks,
              metadata: payment.metadata,
            );

      final result = await remoteDataSource.processPayment(model);
      return Right(result);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackPrefix: 'Failed to process payment'),
      );
    }
  }
}

