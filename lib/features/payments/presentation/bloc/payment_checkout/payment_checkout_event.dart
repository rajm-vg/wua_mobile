import 'package:equatable/equatable.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';

abstract class PaymentCheckoutEvent extends Equatable {
  const PaymentCheckoutEvent();

  @override
  List<Object?> get props => [];
}

class InitPaymentCheckoutEvent extends PaymentCheckoutEvent {
  const InitPaymentCheckoutEvent({
    required this.bill,
    this.initialMethod,
  });

  final BillEntity bill;
  final String? initialMethod;

  @override
  List<Object?> get props => [bill, initialMethod];
}

class SelectPaymentMethodEvent extends PaymentCheckoutEvent {
  const SelectPaymentMethodEvent(this.method);

  final PaymentMethodType method;

  @override
  List<Object?> get props => [method];
}

class SelectUpiSubModeEvent extends PaymentCheckoutEvent {
  const SelectUpiSubModeEvent(this.mode);

  final UpiSubMode mode;

  @override
  List<Object?> get props => [mode];
}

class SelectUpiAppEvent extends PaymentCheckoutEvent {
  const SelectUpiAppEvent(this.appName);

  final String appName;

  @override
  List<Object?> get props => [appName];
}

class UpdateUpiVpaEvent extends PaymentCheckoutEvent {
  const UpdateUpiVpaEvent(this.vpa);

  final String vpa;

  @override
  List<Object?> get props => [vpa];
}

class VerifyUpiVpaEvent extends PaymentCheckoutEvent {
  const VerifyUpiVpaEvent(this.vpa);

  final String vpa;

  @override
  List<Object?> get props => [vpa];
}

class SelectBankEvent extends PaymentCheckoutEvent {
  const SelectBankEvent(this.bankName);

  final String bankName;

  @override
  List<Object?> get props => [bankName];
}

class UpdateCardDetailsEvent extends PaymentCheckoutEvent {
  const UpdateCardDetailsEvent({
    this.cardNumber,
    this.cardHolder,
    this.cardExpiry,
    this.cardCvv,
    this.saveCard,
  });

  final String? cardNumber;
  final String? cardHolder;
  final String? cardExpiry;
  final String? cardCvv;
  final bool? saveCard;

  @override
  List<Object?> get props => [cardNumber, cardHolder, cardExpiry, cardCvv, saveCard];
}

class ExecutePaymentEvent extends PaymentCheckoutEvent {
  const ExecutePaymentEvent({this.customRemarks});

  final String? customRemarks;

  @override
  List<Object?> get props => [customRemarks];
}

class AdvanceProcessingStageEvent extends PaymentCheckoutEvent {
  const AdvanceProcessingStageEvent(this.stage);

  final int stage;

  @override
  List<Object?> get props => [stage];
}

class ResetPaymentCheckoutEvent extends PaymentCheckoutEvent {
  const ResetPaymentCheckoutEvent();
}

class UpdatePaymentAmountEvent extends PaymentCheckoutEvent {
  const UpdatePaymentAmountEvent(this.amount);

  final double? amount;

  @override
  List<Object?> get props => [amount];
}

class RecoverPendingPaymentEvent extends PaymentCheckoutEvent {
  const RecoverPendingPaymentEvent();
}
