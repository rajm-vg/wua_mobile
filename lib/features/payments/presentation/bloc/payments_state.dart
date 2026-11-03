import 'package:equatable/equatable.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';

abstract class PaymentsState extends Equatable {
  const PaymentsState();

  @override
  List<Object?> get props => [];
}

class PaymentsInitial extends PaymentsState {
  const PaymentsInitial();
}

class PaymentsLoading extends PaymentsState {
  const PaymentsLoading();
}

class PaymentsLoaded extends PaymentsState {
  const PaymentsLoaded({
    required this.allPayments,
    required this.filteredPayments,
    this.selectedStatus = 'ALL',
    this.searchQuery = '',
  });

  final List<PaymentEntity> allPayments;
  final List<PaymentEntity> filteredPayments;
  final String selectedStatus;
  final String searchQuery;

  /// Total sum of all successful payments.
  double get totalSuccessfulAmount {
    return allPayments
        .where((p) => p.isSuccess)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  int get successCount => allPayments.where((p) => p.isSuccess).length;
  int get pendingCount => allPayments.where((p) => p.isPending).length;
  int get failedCount => allPayments.where((p) => p.isFailed).length;

  PaymentsLoaded copyWith({
    List<PaymentEntity>? allPayments,
    List<PaymentEntity>? filteredPayments,
    String? selectedStatus,
    String? searchQuery,
  }) {
    return PaymentsLoaded(
      allPayments: allPayments ?? this.allPayments,
      filteredPayments: filteredPayments ?? this.filteredPayments,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    allPayments,
    filteredPayments,
    selectedStatus,
    searchQuery,
  ];
}

class PaymentsError extends PaymentsState {
  const PaymentsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ─── Individual Payment Detail States ─────────────────────────

class PaymentDetailLoading extends PaymentsState {
  const PaymentDetailLoading();
}

class PaymentDetailLoaded extends PaymentsState {
  const PaymentDetailLoaded(this.payment);

  final PaymentEntity payment;

  @override
  List<Object?> get props => [payment];
}

class PaymentDetailError extends PaymentsState {
  const PaymentDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

