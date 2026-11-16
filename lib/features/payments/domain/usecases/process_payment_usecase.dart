import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wua_mobile/core/errors/failures.dart';
import 'package:wua_mobile/core/usecases/usecase.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/bills/domain/repositories/bill_repository.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/repositories/payment_repository.dart';

class ProcessPaymentParams extends Equatable {
  const ProcessPaymentParams({
    required this.payment,
    this.bill,
  });

  final PaymentEntity payment;
  final BillEntity? bill;

  @override
  List<Object?> get props => [payment, bill];
}

class ProcessPaymentUseCase extends UseCase<PaymentEntity, ProcessPaymentParams> {
  ProcessPaymentUseCase({
    required this.paymentRepository,
    required this.billRepository,
  });

  final PaymentRepository paymentRepository;
  final BillRepository billRepository;

  @override
  Future<Either<Failure, PaymentEntity>> call(ProcessPaymentParams params) async {
    final paymentResult = await paymentRepository.processPayment(params.payment);

    return paymentResult.fold(
      Left.new,
      (savedPayment) async {
        // Also update the associated bill if available
        if (params.payment.billId != null && params.payment.isSuccess) {
          await billRepository.markBillAsPaid(
            params.payment.billId!,
            paymentReference: params.payment.gatewayTransactionId ??
                params.payment.paymentNumber,
            paymentMethod: params.payment.paymentMode,
            paidAmount: params.payment.amount,
          );
        }
        return Right(savedPayment);
      },
    );
  }
}
