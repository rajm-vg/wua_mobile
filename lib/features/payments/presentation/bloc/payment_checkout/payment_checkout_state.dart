import 'package:equatable/equatable.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';

enum PaymentMethodType { upi, netBanking, card }

enum UpiSubMode { apps, vpa, qr }

enum PaymentCheckoutStep { methodSelection, processing, success, failure }

class PaymentCheckoutState extends Equatable {
  const PaymentCheckoutState({
    required this.bill,
    this.step = PaymentCheckoutStep.methodSelection,
    this.selectedMethod = PaymentMethodType.upi,
    this.upiSubMode = UpiSubMode.apps,
    this.selectedUpiApp = 'Google Pay',
    this.upiVpa = '',
    this.isVpaVerified = false,
    this.vpaVerifiedName,
    this.selectedBank = 'State Bank of India',
    this.cardNumber = '',
    this.cardHolder = '',
    this.cardExpiry = '',
    this.cardCvv = '',
    this.saveCard = true,
    this.processingStage = 1,
    this.completedPayment,
    this.errorMessage,
    this.customAmount,
  });

  final BillEntity bill;
  final PaymentCheckoutStep step;
  final PaymentMethodType selectedMethod;
  final UpiSubMode upiSubMode;
  final String selectedUpiApp;
  final String upiVpa;
  final bool isVpaVerified;
  final String? vpaVerifiedName;
  final String selectedBank;
  final String cardNumber;
  final String cardHolder;
  final String cardExpiry;
  final String cardCvv;
  final bool saveCard;
  final int processingStage;
  final PaymentEntity? completedPayment;
  final String? errorMessage;
  final double? customAmount;

  double get maxPayableAmount =>
      bill.outstandingAmount > 0 ? bill.outstandingAmount : bill.totalAmount;

  double get effectivePaymentAmount => customAmount ?? maxPayableAmount;

  /// Detect card brand from card number
  String get detectedCardBrand {
    final clean = cardNumber.replaceAll(' ', '');
    if (clean.startsWith('508') ||
        clean.startsWith('60') ||
        clean.startsWith('65') ||
        clean.startsWith('81') ||
        clean.startsWith('82')) {
      return 'RuPay (KCC)';
    } else if (clean.startsWith('4')) {
      return 'Visa';
    } else if (clean.startsWith('51') ||
        clean.startsWith('52') ||
        clean.startsWith('53') ||
        clean.startsWith('54') ||
        clean.startsWith('55')) {
      return 'MasterCard';
    }
    return 'RuPay';
  }

  /// Display string for payment mode
  String get paymentModeDisplay {
    return 'Easebuzz Gateway';
  }

  PaymentCheckoutState copyWith({
    BillEntity? bill,
    PaymentCheckoutStep? step,
    PaymentMethodType? selectedMethod,
    UpiSubMode? upiSubMode,
    String? selectedUpiApp,
    String? upiVpa,
    bool? isVpaVerified,
    String? vpaVerifiedName,
    bool clearVerifiedName = false,
    String? selectedBank,
    String? cardNumber,
    String? cardHolder,
    String? cardExpiry,
    String? cardCvv,
    bool? saveCard,
    int? processingStage,
    PaymentEntity? completedPayment,
    String? errorMessage,
    double? customAmount,
    bool clearCustomAmount = false,
  }) {
    return PaymentCheckoutState(
      bill: bill ?? this.bill,
      step: step ?? this.step,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      upiSubMode: upiSubMode ?? this.upiSubMode,
      selectedUpiApp: selectedUpiApp ?? this.selectedUpiApp,
      upiVpa: upiVpa ?? this.upiVpa,
      isVpaVerified: isVpaVerified ?? this.isVpaVerified,
      vpaVerifiedName: clearVerifiedName
          ? null
          : (vpaVerifiedName ?? this.vpaVerifiedName),
      selectedBank: selectedBank ?? this.selectedBank,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolder: cardHolder ?? this.cardHolder,
      cardExpiry: cardExpiry ?? this.cardExpiry,
      cardCvv: cardCvv ?? this.cardCvv,
      saveCard: saveCard ?? this.saveCard,
      processingStage: processingStage ?? this.processingStage,
      completedPayment: completedPayment ?? this.completedPayment,
      errorMessage: errorMessage,
      customAmount: clearCustomAmount
          ? null
          : (customAmount ?? this.customAmount),
    );
  }

  @override
  List<Object?> get props => [
    bill,
    step,
    selectedMethod,
    upiSubMode,
    selectedUpiApp,
    upiVpa,
    isVpaVerified,
    vpaVerifiedName,
    selectedBank,
    cardNumber,
    cardHolder,
    cardExpiry,
    cardCvv,
    saveCard,
    processingStage,
    completedPayment,
    errorMessage,
    customAmount,
  ];
}
