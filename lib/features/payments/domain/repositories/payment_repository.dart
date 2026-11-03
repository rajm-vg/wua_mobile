import 'package:dartz/dartz.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';

/// Contract for payments data operations.
abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentEntity>>> getPayments({
    String? consumerId,
    String? status,
    String? query,
  });

  Future<Either<Failure, PaymentEntity>> getPaymentById(String id);
}

