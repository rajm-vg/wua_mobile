import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/usecases/process_payment_usecase.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';

class PaymentCheckoutBloc
    extends Bloc<PaymentCheckoutEvent, PaymentCheckoutState> {
  PaymentCheckoutBloc({
    required this.processPaymentUseCase,
    required BillEntity initialBill,
    String? initialMethod,
    this.delayDuration = const Duration(milliseconds: 600),
  }) : super(
          PaymentCheckoutState(
            bill: initialBill,
            selectedMethod: _parseInitialMethod(initialMethod),
          ),
        ) {
    on<InitPaymentCheckoutEvent>(_onInitCheckout);
    on<SelectPaymentMethodEvent>(_onSelectMethod);
    on<SelectUpiSubModeEvent>(_onSelectUpiSubMode);
    on<SelectUpiAppEvent>(_onSelectUpiApp);
    on<UpdateUpiVpaEvent>(_onUpdateUpiVpa);
    on<VerifyUpiVpaEvent>(_onVerifyUpiVpa);
    on<SelectBankEvent>(_onSelectBank);
    on<UpdateCardDetailsEvent>(_onUpdateCardDetails);
    on<ToggleSimulateFailureEvent>(_onToggleSimulateFailure);
    on<AdvanceProcessingStageEvent>(_onAdvanceProcessingStage);
    on<ExecutePaymentEvent>(_onExecutePayment);
    on<ResetPaymentCheckoutEvent>(_onResetCheckout);
  }

  final ProcessPaymentUseCase processPaymentUseCase;
  final Duration delayDuration;

  static PaymentMethodType _parseInitialMethod(String? method) {
    if (method == null) return PaymentMethodType.upi;
    final lower = method.toLowerCase();
    if (lower.contains('netbanking') || lower.contains('bank')) {
      return PaymentMethodType.netBanking;
    } else if (lower.contains('card') || lower.contains('debit')) {
      return PaymentMethodType.card;
    }
    return PaymentMethodType.upi;
  }

  void _onInitCheckout(
    InitPaymentCheckoutEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    emit(
      PaymentCheckoutState(
        bill: event.bill,
        selectedMethod: _parseInitialMethod(event.initialMethod),
      ),
    );
  }

  void _onSelectMethod(
    SelectPaymentMethodEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    emit(state.copyWith(selectedMethod: event.method));
  }

  void _onSelectUpiSubMode(
    SelectUpiSubModeEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    emit(state.copyWith(upiSubMode: event.mode));
  }

  void _onSelectUpiApp(
    SelectUpiAppEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    emit(state.copyWith(selectedUpiApp: event.appName));
  }

  void _onUpdateUpiVpa(
    UpdateUpiVpaEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    emit(
      state.copyWith(
        upiVpa: event.vpa,
        isVpaVerified: false,
        clearVerifiedName: true,
      ),
    );
  }

  void _onVerifyUpiVpa(
    VerifyUpiVpaEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    final vpa = event.vpa.trim();
    if (vpa.contains('@') && vpa.length >= 5) {
      emit(
        state.copyWith(
          upiVpa: vpa,
          isVpaVerified: true,
          vpaVerifiedName: 'Ramesh D. Patil',
        ),
      );
    } else {
      emit(
        state.copyWith(
          upiVpa: vpa,
          isVpaVerified: false,
          clearVerifiedName: true,
        ),
      );
    }
  }

  void _onSelectBank(
    SelectBankEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    emit(state.copyWith(selectedBank: event.bankName));
  }

  void _onUpdateCardDetails(
    UpdateCardDetailsEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    emit(
      state.copyWith(
        cardNumber: event.cardNumber ?? state.cardNumber,
        cardHolder: event.cardHolder ?? state.cardHolder,
        cardExpiry: event.cardExpiry ?? state.cardExpiry,
        cardCvv: event.cardCvv ?? state.cardCvv,
        saveCard: event.saveCard ?? state.saveCard,
      ),
    );
  }

  void _onToggleSimulateFailure(
    ToggleSimulateFailureEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    emit(state.copyWith(simulateFailure: event.simulate));
  }

  void _onAdvanceProcessingStage(
    AdvanceProcessingStageEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    emit(state.copyWith(processingStage: event.stage));
  }

  Future<void> _onExecutePayment(
    ExecutePaymentEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) async {
    AppLogger.bloc('⚡ [PAYMENT CHECKOUT BLOC] Starting payment execution');

    emit(
      state.copyWith(
        step: PaymentCheckoutStep.processing,
        processingStage: 1,
        errorMessage: null,
      ),
    );

    // Processing simulation step 1: Contacting banking gateway
    if (delayDuration.inMilliseconds > 0) {
      await Future<void>.delayed(delayDuration);
    }
    emit(state.copyWith(processingStage: 2));

    // Processing simulation step 2: Authorizing with NPCI / Bank
    if (delayDuration.inMilliseconds > 0) {
      await Future<void>.delayed(delayDuration);
    }
    emit(state.copyWith(processingStage: 3));

    // Processing simulation step 3: Treasury challan generation
    if (delayDuration.inMilliseconds > 0) {
      await Future<void>.delayed(delayDuration);
    }

    if (state.simulateFailure) {
      AppLogger.warning('⚡ [PAYMENT CHECKOUT BLOC] Simulating failed payment');
      emit(
        state.copyWith(
          step: PaymentCheckoutStep.failure,
          errorMessage:
              'Bank gateway response timed out (ERR_NPCI_TIMED_OUT). No funds were deducted.',
        ),
      );
      return;
    }

    final now = DateTime.now();
    final amountToPay = state.bill.outstandingAmount > 0
        ? state.bill.outstandingAmount
        : (state.bill.totalAmount > 0 ? state.bill.totalAmount : 1240.0);

    final paymentEntity = PaymentEntity(
      id: 'pay_${now.millisecondsSinceEpoch}',
      paymentNumber:
          'REC/WUA/${now.year}-${(now.year + 1).toString().substring(2)}/${1000 + (now.millisecond % 9000)}',
      status: PaymentStatus.success,
      amount: amountToPay,
      paymentDate: now,
      billId: state.bill.id,
      billNumber: state.bill.billNumber,
      consumerId: state.bill.consumerId ?? 'KISAN-MH-41201',
      consumerName: state.bill.consumerName ?? 'Ramesh Patil',
      wuaSocietyName: state.bill.wuaSocietyName ?? 'Ganga-Godavari WUA Society #12',
      season: state.bill.season,
      cropType: state.bill.cropType,
      paymentMode: state.paymentModeDisplay,
      gatewayTransactionId:
          'TXN/WRD/${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}/${100000 + (now.microsecond % 900000)}',
      bankReference:
          'MHA-TREASURY-${now.millisecondsSinceEpoch.toString().substring(6)}',
      gatewayName: 'MahaGov WRD Cyber Treasury Gateway',
      remarks: event.customRemarks ??
          'Pani Patti Irrigation Cess settled via ${state.paymentModeDisplay}',
      metadata: {
        'challan_grn': 'GRN-WRD-${now.millisecondsSinceEpoch}',
        'canal_section': state.bill.canalSection ?? 'Minor-3 (Outlet 4B)',
        'water_quantity_liters': state.bill.waterQuantityLiters,
        'land_area_acres': state.bill.landAreaAcres,
      },
    );

    final result = await processPaymentUseCase(
      ProcessPaymentParams(
        payment: paymentEntity,
        bill: state.bill,
      ),
    );

    result.fold(
      (failure) {
        AppLogger.error(
          '❌ [PAYMENT CHECKOUT BLOC] Failed to record payment: ${failure.message}',
        );
        emit(
          state.copyWith(
            step: PaymentCheckoutStep.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (savedPayment) {
        AppLogger.info(
          '✅ [PAYMENT CHECKOUT BLOC] Payment successful: ${savedPayment.paymentNumber}',
        );
        emit(
          state.copyWith(
            step: PaymentCheckoutStep.success,
            completedPayment: savedPayment,
          ),
        );
      },
    );
  }

  void _onResetCheckout(
    ResetPaymentCheckoutEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    emit(
      state.copyWith(
        step: PaymentCheckoutStep.methodSelection,
        processingStage: 1,
        errorMessage: null,
      ),
    );
  }
}
