import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/usecases/get_payment_by_id_usecase.dart';
import 'package:wua_mobile/features/payments/domain/usecases/get_payments_usecase.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  PaymentsBloc({
    required this.getPaymentsUseCase,
    required this.getPaymentByIdUseCase,
  }) : super(const PaymentsInitial()) {
    on<LoadPaymentsEvent>(_onLoadPayments);
    on<FilterPaymentsByStatusEvent>(_onFilterPaymentsByStatus);
    on<SearchPaymentsEvent>(_onSearchPayments);
    on<ClearPaymentFiltersEvent>(_onClearPaymentFilters);
    on<LoadPaymentDetailEvent>(_onLoadPaymentDetail);
  }

  final GetPaymentsUseCase getPaymentsUseCase;
  final GetPaymentByIdUseCase getPaymentByIdUseCase;

  List<PaymentEntity> _cachedPayments = [];
  String _activeStatus = 'ALL';
  String _activeQuery = '';

  Future<void> _onLoadPayments(
    LoadPaymentsEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    if (!event.refresh && state is! PaymentsLoaded) {
      emit(const PaymentsLoading());
    }

    AppLogger.bloc('⚡ [PAYMENTS BLOC] Loading payments (refresh: ${event.refresh})');

    final result = await getPaymentsUseCase(
      GetPaymentsParams(consumerId: event.consumerId),
    );

    result.fold(
      (failure) {
        AppLogger.error('❌ [PAYMENTS BLOC] Error loading payments: ${failure.message}');
        emit(PaymentsError(failure.message));
      },
      (payments) {
        _cachedPayments = payments;
        final filtered = _applyFilters(
          payments: _cachedPayments,
          status: _activeStatus,
          query: _activeQuery,
        );
        emit(
          PaymentsLoaded(
            allPayments: _cachedPayments,
            filteredPayments: filtered,
            selectedStatus: _activeStatus,
            searchQuery: _activeQuery,
          ),
        );
      },
    );
  }

  void _onFilterPaymentsByStatus(
    FilterPaymentsByStatusEvent event,
    Emitter<PaymentsState> emit,
  ) {
    final allPayments = state is PaymentsLoaded
        ? (state as PaymentsLoaded).allPayments
        : _cachedPayments;
    _activeStatus = event.status;
    final currentFiltered = _applyFilters(
      payments: allPayments,
      status: _activeStatus,
      query: _activeQuery,
    );

    emit(
      PaymentsLoaded(
        allPayments: allPayments,
        filteredPayments: currentFiltered,
        selectedStatus: _activeStatus,
        searchQuery: _activeQuery,
      ),
    );
  }

  void _onSearchPayments(
    SearchPaymentsEvent event,
    Emitter<PaymentsState> emit,
  ) {
    final allPayments = state is PaymentsLoaded
        ? (state as PaymentsLoaded).allPayments
        : _cachedPayments;
    _activeQuery = event.query;
    final currentFiltered = _applyFilters(
      payments: allPayments,
      status: _activeStatus,
      query: _activeQuery,
    );

    emit(
      PaymentsLoaded(
        allPayments: allPayments,
        filteredPayments: currentFiltered,
        selectedStatus: _activeStatus,
        searchQuery: _activeQuery,
      ),
    );
  }

  void _onClearPaymentFilters(
    ClearPaymentFiltersEvent event,
    Emitter<PaymentsState> emit,
  ) {
    final allPayments = state is PaymentsLoaded
        ? (state as PaymentsLoaded).allPayments
        : _cachedPayments;
    _activeStatus = 'ALL';
    _activeQuery = '';
    emit(
      PaymentsLoaded(
        allPayments: allPayments,
        filteredPayments: allPayments,
        selectedStatus: 'ALL',
        searchQuery: '',
      ),
    );
  }

  Future<void> _onLoadPaymentDetail(
    LoadPaymentDetailEvent event,
    Emitter<PaymentsState> emit,
  ) async {
    emit(const PaymentDetailLoading());
    AppLogger.bloc('⚡ [PAYMENTS BLOC] Loading payment detail for id: ${event.paymentId}');

    final cached = _cachedPayments
        .where((p) => p.id == event.paymentId || p.paymentNumber == event.paymentId)
        .firstOrNull;

    if (cached != null) {
      emit(PaymentDetailLoaded(cached));
      return;
    }

    final result = await getPaymentByIdUseCase(event.paymentId);
    result.fold(
      (failure) => emit(PaymentDetailError(failure.message)),
      (payment) => emit(PaymentDetailLoaded(payment)),
    );
  }

  List<PaymentEntity> _applyFilters({
    required List<PaymentEntity> payments,
    required String status,
    required String query,
  }) {
    var list = payments;

    if (status.toUpperCase() != 'ALL') {
      final s = status.toUpperCase();
      list = list.where((p) => p.status.toUpperCase() == s).toList();
    }

    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list.where((p) {
        return p.paymentNumber.toLowerCase().contains(q) ||
            p.season.toLowerCase().contains(q) ||
            p.cropType.toLowerCase().contains(q) ||
            (p.gatewayTransactionId?.toLowerCase().contains(q) ?? false) ||
            (p.billNumber?.toLowerCase().contains(q) ?? false) ||
            p.paymentMode.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }
}

