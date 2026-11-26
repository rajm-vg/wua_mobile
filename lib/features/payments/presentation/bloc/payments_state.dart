import 'package:equatable/equatable.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_event.dart';

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
    this.selectedFiscalYear = 'ALL',
    this.selectedSeason = 'ALL',
    this.selectedPaymentMode = 'ALL',
    this.sortOption = PaymentSortOption.newestFirst,
    this.searchQuery = '',
  });

  final List<PaymentEntity> allPayments;
  final List<PaymentEntity> filteredPayments;
  final String selectedStatus;
  final String selectedFiscalYear;
  final String selectedSeason;
  final String selectedPaymentMode;
  final PaymentSortOption sortOption;
  final String searchQuery;

  /// Total sum of all successful payments.
  double get totalSuccessfulAmount {
    return allPayments
        .where((p) => p.isSuccess)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  /// Total sum of successful payments in the currently filtered list.
  double get filteredSuccessfulAmount {
    return filteredPayments
        .where((p) => p.isSuccess)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  int get successCount => allPayments.where((p) => p.isSuccess).length;
  int get pendingCount => allPayments.where((p) => p.isPending).length;
  int get failedCount => allPayments.where((p) => p.isFailed).length;

  /// Distinct fiscal years present across all payments, sorted descending.
  List<String> get availableFiscalYears {
    final years = allPayments
        .map((p) => p.effectiveFiscalYear)
        .where((fy) => fy.isNotEmpty)
        .toSet()
        .toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  /// Distinct non-empty seasons present across all payments.
  List<String> get availableSeasons {
    final seasons = allPayments
        .map((p) => p.season.trim())
        .where((s) => s.isNotEmpty && s.toUpperCase() != 'N/A')
        .toSet()
        .toList();
    seasons.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return seasons;
  }

  /// Distinct non-empty payment modes present across all payments.
  List<String> get availablePaymentModes {
    final modes = allPayments
        .map((p) => p.paymentMode.trim())
        .where((m) => m.isNotEmpty && m.toUpperCase() != 'N/A')
        .toSet()
        .toList();
    modes.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return modes;
  }

  int get activeFilterCount {
    var count = 0;
    if (selectedStatus.toUpperCase() != 'ALL') count++;
    if (selectedFiscalYear.toUpperCase() != 'ALL') count++;
    if (selectedSeason.toUpperCase() != 'ALL') count++;
    if (selectedPaymentMode.toUpperCase() != 'ALL') count++;
    return count;
  }

  bool get hasActiveFilters =>
      activeFilterCount > 0 ||
      searchQuery.trim().isNotEmpty ||
      sortOption != PaymentSortOption.newestFirst;

  PaymentsLoaded copyWith({
    List<PaymentEntity>? allPayments,
    List<PaymentEntity>? filteredPayments,
    String? selectedStatus,
    String? selectedFiscalYear,
    String? selectedSeason,
    String? selectedPaymentMode,
    PaymentSortOption? sortOption,
    String? searchQuery,
  }) {
    return PaymentsLoaded(
      allPayments: allPayments ?? this.allPayments,
      filteredPayments: filteredPayments ?? this.filteredPayments,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedFiscalYear: selectedFiscalYear ?? this.selectedFiscalYear,
      selectedSeason: selectedSeason ?? this.selectedSeason,
      selectedPaymentMode: selectedPaymentMode ?? this.selectedPaymentMode,
      sortOption: sortOption ?? this.sortOption,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    allPayments,
    filteredPayments,
    selectedStatus,
    selectedFiscalYear,
    selectedSeason,
    selectedPaymentMode,
    sortOption,
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
