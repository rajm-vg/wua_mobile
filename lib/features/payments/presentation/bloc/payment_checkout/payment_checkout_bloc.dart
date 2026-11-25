import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/constants/env_config.dart';
import 'package:wua_mobile/core/errors/exceptions.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/data/datasources/easebuzz_sdk_service.dart';
import 'package:wua_mobile/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:wua_mobile/features/payments/data/models/easebuzz_order_model.dart';
import 'package:wua_mobile/features/payments/data/models/easebuzz_verify_model.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/usecases/process_payment_usecase.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';

class PaymentCheckoutBloc
    extends Bloc<PaymentCheckoutEvent, PaymentCheckoutState> {
  PaymentCheckoutBloc({
    this.processPaymentUseCase,
    required BillEntity initialBill,
    this.paymentRemoteDataSource,
    this.easebuzzSdkService,
    String? initialMethod,
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
    on<AdvanceProcessingStageEvent>(_onAdvanceProcessingStage);
    on<ExecutePaymentEvent>(_onExecutePayment);
    on<ResetPaymentCheckoutEvent>(_onResetCheckout);
    on<UpdatePaymentAmountEvent>(_onUpdatePaymentAmount);
  }

  final ProcessPaymentUseCase? processPaymentUseCase;
  final PaymentRemoteDataSource? paymentRemoteDataSource;
  final EasebuzzSdkService? easebuzzSdkService;

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
    emit(state.copyWith(selectedMethod: event.method, errorMessage: null));
  }

  void _onSelectUpiSubMode(
    SelectUpiSubModeEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    emit(state.copyWith(upiSubMode: event.mode, errorMessage: null));
  }

  void _onSelectUpiApp(
    SelectUpiAppEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    emit(state.copyWith(selectedUpiApp: event.appName, errorMessage: null));
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
        errorMessage: null,
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
          vpaVerifiedName: vpa,
          errorMessage: null,
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
    emit(state.copyWith(selectedBank: event.bankName, errorMessage: null));
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
        errorMessage: null,
      ),
    );
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
    AppLogger.bloc('⚡ [PAYMENT CHECKOUT BLOC] Starting Easebuzz payment flow');

    final remote = paymentRemoteDataSource;
    final sdk = easebuzzSdkService;
    if (remote == null || sdk == null) {
      emit(
        state.copyWith(
          step: PaymentCheckoutStep.failure,
          errorMessage: 'Easebuzz payment gateway is not configured.',
        ),
      );
      return;
    }

    final maxPayable = state.maxPayableAmount;
    final amountToPay = state.effectivePaymentAmount;

    if (maxPayable <= 0) {
      emit(
        state.copyWith(
          step: PaymentCheckoutStep.failure,
          errorMessage: 'No payable outstanding amount found for this bill.',
        ),
      );
      return;
    }

    if (amountToPay <= 0 || amountToPay > maxPayable) {
      emit(
        state.copyWith(
          step: PaymentCheckoutStep.methodSelection,
          errorMessage:
              'Please enter a valid payment amount between ₹ 1 and ₹ ${maxPayable.toStringAsFixed(2)}.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        step: PaymentCheckoutStep.processing,
        processingStage: 1,
        errorMessage: null,
      ),
    );

    try {
      AppLogger.bloc(
        '⚡ [PAYMENT CHECKOUT BLOC] Initiating Easebuzz Gateway Order',
      );
      // Omit memberId/societyId here so backend does not run its incomplete
      // auto-sync (which lacks fiscalYear & bankLedgerId). We post the full
      // receipt entry after SDK success + server-side verification succeed.
      final order = await remote.createPaymentOrder(
        EasebuzzOrderRequest(
          amount: amountToPay,
          currency: 'INR',
          description: 'Water bill payment',
          provider: 'EASEBUZZ',
          billId: int.tryParse(state.bill.id),
        ),
      );

      final accessKey = order.accessKey.trim();
      if (accessKey.isEmpty ||
          accessKey.startsWith('access_key_mock_') ||
          !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(accessKey)) {
        AppLogger.error(
          '❌ [PAYMENT CHECKOUT BLOC] Invalid Easebuzz accessKey received: "$accessKey"',
        );
        emit(
          state.copyWith(
            step: PaymentCheckoutStep.failure,
            errorMessage: accessKey.isEmpty
                ? 'Unable to initialize Easebuzz payment session (empty access key).'
                : 'Backend returned an invalid/mock Easebuzz access key ($accessKey). Please verify Easebuzz merchant configuration on the server.',
          ),
        );
        return;
      }

      emit(state.copyWith(processingStage: 2));
      final payMode = EnvConfig.easebuzzPayMode;
      AppLogger.bloc(
        '⚡ [PAYMENT CHECKOUT BLOC] Launching Easebuzz SDK (payMode: $payMode)',
      );

      final sdkResult = await sdk.payWithEasebuzz(
        accessKey: accessKey,
        payMode: payMode,
      );

      if (sdkResult.isCancelled) {
        AppLogger.info(
          '⚡ [PAYMENT CHECKOUT BLOC] Easebuzz payment cancelled by user',
        );
        emit(
          state.copyWith(
            step: PaymentCheckoutStep.methodSelection,
            processingStage: 1,
            errorMessage:
                sdkResult.errorMessage ?? 'Payment cancelled by user.',
          ),
        );
        return;
      }

      if (sdkResult.isFailed) {
        AppLogger.warning(
          '⚡ [PAYMENT CHECKOUT BLOC] Easebuzz payment failed: ${sdkResult.errorMessage}',
        );
        emit(
          state.copyWith(
            step: PaymentCheckoutStep.failure,
            errorMessage: sdkResult.errorMessage ?? 'Easebuzz checkout failed.',
          ),
        );
        return;
      }

      emit(state.copyWith(processingStage: 3));
      AppLogger.bloc(
        '⚡ [PAYMENT CHECKOUT BLOC] Verifying Easebuzz transaction: ${order.transactionId}',
      );

      final verifyPayload =
          (sdkResult.paymentResponse != null &&
              sdkResult.paymentResponse!.isNotEmpty)
          ? jsonEncode(sdkResult.paymentResponse)
          : (sdkResult.rawResponse ?? '{}');

      final verifyResult = await remote.verifyPaymentOrder(
        EasebuzzVerifyRequest(
          transactionId: order.transactionId,
          orderId: order.orderId,
          paymentId: sdkResult.paymentId ?? order.transactionId,
          signature: sdkResult.signature ?? '',
          amount: amountToPay,
          payload: verifyPayload,
        ),
      );

      if (!verifyResult.verified) {
        AppLogger.error(
          '❌ [PAYMENT CHECKOUT BLOC] Easebuzz verification failed: ${verifyResult.message}',
        );
        emit(
          state.copyWith(
            step: PaymentCheckoutStep.failure,
            errorMessage:
                verifyResult.message ??
                'Payment verification failed with Easebuzz gateway.',
          ),
        );
        return;
      }

      final verifiedPaymentId =
          verifyResult.paymentId ?? sdkResult.paymentId ?? order.transactionId;
      final verifiedTxnId =
          verifyResult.transactionId ??
          sdkResult.transactionId ??
          order.transactionId;

      final settledRemarks =
          event.customRemarks ??
          'Settled via Easebuzz (${state.paymentModeDisplay})';

      await remote.postReceiptEntry(
        amount: amountToPay,
        transactionRefNo: verifiedPaymentId,
        farmerMemberId:
            state.bill.farmerMemberId ??
            int.tryParse(state.bill.consumerId ?? ''),
        societyId: state.bill.societyId,
        fiscalYear: state.bill.fiscalYear,
        season: state.bill.season,
        remarks: settledRemarks,
      );

      final now = DateTime.now();

      final settledPayment = PaymentEntity(
        id: verifiedPaymentId,
        paymentNumber: verifiedTxnId,
        status: PaymentStatus.success,
        amount: amountToPay,
        paymentDate: now,
        billId: state.bill.id,
        billNumber: state.bill.billNumber,
        consumerId: state.bill.consumerId,
        consumerName: state.bill.consumerName,
        wuaSocietyName: state.bill.wuaSocietyName,
        season: state.bill.season,
        cropType: state.bill.cropType,
        paymentMode: state.paymentModeDisplay,
        gatewayTransactionId: verifiedPaymentId,
        bankReference: verifiedTxnId,
        gatewayName: 'Easebuzz Payment Gateway',
        remarks: settledRemarks,
        farmerMemberId:
            state.bill.farmerMemberId ??
            int.tryParse(state.bill.consumerId ?? ''),
        societyId: state.bill.societyId,
        fiscalYear: state.bill.fiscalYear,
      );

      AppLogger.info(
        '✅ [PAYMENT CHECKOUT BLOC] Easebuzz payment verified: ${settledPayment.paymentNumber}',
      );
      emit(
        state.copyWith(
          step: PaymentCheckoutStep.success,
          completedPayment: settledPayment,
        ),
      );
    } on UnauthorizedException catch (e) {
      AppLogger.error('❌ [PAYMENT CHECKOUT BLOC] Unauthorized: ${e.message}');
      emit(
        state.copyWith(
          step: PaymentCheckoutStep.failure,
          errorMessage: e.message.isNotEmpty
              ? e.message
              : 'Session expired. Please log in again.',
        ),
      );
    } on NetworkException catch (e) {
      AppLogger.error('❌ [PAYMENT CHECKOUT BLOC] Network error: ${e.message}');
      emit(
        state.copyWith(
          step: PaymentCheckoutStep.failure,
          errorMessage: e.message,
        ),
      );
    } on TimeoutException catch (e) {
      AppLogger.error('❌ [PAYMENT CHECKOUT BLOC] Timeout: ${e.message}');
      emit(
        state.copyWith(
          step: PaymentCheckoutStep.failure,
          errorMessage: e.message,
        ),
      );
    } on ServerException catch (e) {
      AppLogger.error('❌ [PAYMENT CHECKOUT BLOC] Server error: ${e.message}');
      emit(
        state.copyWith(
          step: PaymentCheckoutStep.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      AppLogger.error('❌ [PAYMENT CHECKOUT BLOC] Easebuzz checkout error: $e');
      emit(
        state.copyWith(
          step: PaymentCheckoutStep.failure,
          errorMessage: 'Easebuzz payment failed: $e',
        ),
      );
    }
  }

  void _onUpdatePaymentAmount(
    UpdatePaymentAmountEvent event,
    Emitter<PaymentCheckoutState> emit,
  ) {
    emit(
      state.copyWith(
        customAmount: event.amount,
        clearCustomAmount: event.amount == null,
        errorMessage: null,
      ),
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
