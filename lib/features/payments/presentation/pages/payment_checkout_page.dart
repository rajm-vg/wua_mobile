import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/data/datasources/easebuzz_sdk_service.dart';
import 'package:wua_mobile/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:wua_mobile/features/payments/domain/usecases/process_payment_usecase.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/checkout/bill_summary_card.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/checkout/payment_failure_view.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/checkout/payment_processing_view.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/checkout/payment_success_view.dart';
import 'package:wua_mobile/shared/widgets/wua_scaffold.dart';

/// Direct Easebuzz payment checkout screen for WUA irrigation dues.
/// Supports full or partial payment amounts before launching the Easebuzz SDK.
class PaymentCheckoutPage extends StatelessWidget {
  const PaymentCheckoutPage({
    super.key,
    this.bill,
    this.initialMethod,
    this.autoLaunch = false,
  });

  final BillEntity? bill;
  final String? initialMethod;
  final bool autoLaunch;

  static const BillEntity defaultRabiBill = BillEntity(
    id: '',
    billNumber: 'N/A',
    status: BillStatus.pending,
    consumerId: null,
    consumerName: null,
    wuaSocietyName: null,
    canalSection: null,
    season: 'N/A',
    cropType: 'N/A',
    landAreaAcres: 0.0,
    waterQuantityLiters: 0,
    rotationsCount: 0,
    subtotal: 0.0,
    taxes: 0.0,
    maintenanceCess: 0.0,
    totalAmount: 0.0,
    outstandingAmount: 0.0,
  );

  @override
  Widget build(BuildContext context) {
    final activeBill = bill ?? defaultRabiBill;
    final hasPayableAmount =
        activeBill.outstandingAmount > 0 || activeBill.totalAmount > 0;

    return BlocProvider<PaymentCheckoutBloc>(
      create: (context) {
        final bloc = PaymentCheckoutBloc(
          processPaymentUseCase: sl.isRegistered<ProcessPaymentUseCase>()
              ? sl<ProcessPaymentUseCase>()
              : null,
          paymentRemoteDataSource: sl.isRegistered<PaymentRemoteDataSource>()
              ? sl<PaymentRemoteDataSource>()
              : null,
          easebuzzSdkService: sl.isRegistered<EasebuzzSdkService>()
              ? sl<EasebuzzSdkService>()
              : null,
          initialBill: activeBill,
          initialMethod: initialMethod,
        );
        if (autoLaunch && hasPayableAmount) {
          bloc.add(const ExecutePaymentEvent());
        }
        return bloc;
      },
      child: const _PaymentCheckoutPageView(),
    );
  }
}

class _PaymentCheckoutPageView extends StatefulWidget {
  const _PaymentCheckoutPageView();

  @override
  State<_PaymentCheckoutPageView> createState() =>
      _PaymentCheckoutPageViewState();
}

class _PaymentCheckoutPageViewState extends State<_PaymentCheckoutPageView> {
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final state = context.read<PaymentCheckoutBloc>().state;
    final initialAmount = state.effectivePaymentAmount;
    _amountController = TextEditingController(
      text: initialAmount > 0
          ? (initialAmount.truncateToDouble() == initialAmount
                ? initialAmount.toStringAsFixed(0)
                : initialAmount.toStringAsFixed(2))
          : '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setPaymentAmount(double amount) {
    final formatted = amount.truncateToDouble() == amount
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    context.read<PaymentCheckoutBloc>().add(UpdatePaymentAmountEvent(amount));
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return format.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCheckoutBloc, PaymentCheckoutState>(
      builder: (context, state) {
        String title = 'Pani Patti Payment';
        String subtitle = 'Easebuzz Payment Gateway';

        if (state.step == PaymentCheckoutStep.success) {
          title = 'Settlement Receipt';
          subtitle = 'Government Treasury Approved';
        } else if (state.step == PaymentCheckoutStep.processing) {
          title = 'Processing Payment';
          subtitle = 'Securing Easebuzz Session';
        } else if (state.step == PaymentCheckoutStep.failure) {
          title = 'Payment Status';
          subtitle = 'Gateway Response';
        }

        return WuaScaffold(
          title: title,
          subtitle: subtitle,
          showBackButton: state.step == PaymentCheckoutStep.methodSelection,
          scrollable: false,
          padding: EdgeInsets.zero,
          enableMaxConstraint: true,
          maxWidth: 720.0,
          body: _buildStepContent(context, state),
        );
      },
    );
  }

  Widget _buildStepContent(BuildContext context, PaymentCheckoutState state) {
    switch (state.step) {
      case PaymentCheckoutStep.processing:
        return const Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: PaymentProcessingView(),
          ),
        );
      case PaymentCheckoutStep.success:
        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: PaymentSuccessView(state: state),
          ),
        );
      case PaymentCheckoutStep.failure:
        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: PaymentFailureView(state: state),
          ),
        );
      case PaymentCheckoutStep.methodSelection:
        final maxPayable = state.maxPayableAmount;
        final payableAmount = state.effectivePaymentAmount;
        final isValidAmount = payableAmount > 0 && payableAmount <= maxPayable;

        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (state.errorMessage?.isNotEmpty == true) ...[
                  _buildNoticeBanner(context, state.errorMessage!),
                  const SizedBox(height: AppSpacing.sm),
                ],
                BillSummaryCard(bill: state.bill),
                const SizedBox(height: AppSpacing.md),
                _buildPartialPaymentCard(context, state, maxPayable),
                const SizedBox(height: AppSpacing.md),
                _buildSecurityCard(context),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: isValidAmount
                      ? () {
                          context
                              .read<PaymentCheckoutBloc>()
                              .add(const ExecutePaymentEvent());
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.canalGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.payment_rounded, size: 20),
                  label: Text(
                    isValidAmount
                        ? 'Pay ${_formatCurrency(payableAmount)} via Easebuzz'
                        : 'Enter Valid Payment Amount',
                    style: context.buttonText.bold.white,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildPartialPaymentCard(
    BuildContext context,
    PaymentCheckoutState state,
    double maxPayable,
  ) {
    final colors = context.colors;
    final entered = state.effectivePaymentAmount;
    final isExceeding = entered > maxPayable;
    final isZeroOrNegative = entered <= 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Amount (Partial / Full)',
                style: context.labelMedium.bold.withColor(colors.textPrimary),
              ),
              Text(
                'Dues: ${_formatCurrency(maxPayable)}',
                style: context.caption.bold.withColor(colors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            onChanged: (value) {
              final parsed = double.tryParse(value.trim()) ?? 0.0;
              context
                  .read<PaymentCheckoutBloc>()
                  .add(UpdatePaymentAmountEvent(parsed));
            },
            decoration: InputDecoration(
              prefixText: '₹ ',
              hintText: 'Enter amount to pay',
              errorText: isExceeding
                  ? 'Cannot exceed remaining dues (${_formatCurrency(maxPayable)})'
                  : (isZeroOrNegative && _amountController.text.isNotEmpty
                        ? 'Amount must be greater than ₹ 0'
                        : null),
              filled: true,
              fillColor: colors.surfaceVariant.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (maxPayable > 0) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: Text('Full (${_formatCurrency(maxPayable)})'),
                  onPressed: () => _setPaymentAmount(maxPayable),
                ),
                if (maxPayable >= 2)
                  ActionChip(
                    label: Text(
                      '50% (${_formatCurrency((maxPayable / 2).roundToDouble())})',
                    ),
                    onPressed: () =>
                        _setPaymentAmount((maxPayable / 2).roundToDouble()),
                  ),
                if (maxPayable > 500)
                  ActionChip(
                    label: const Text('₹ 500'),
                    onPressed: () => _setPaymentAmount(500),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoticeBanner(BuildContext context, String message) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: context.caption.medium.withColor(colors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user_rounded,
                size: 18,
                color: AppColors.canalGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Easebuzz & Cyber Treasury Security',
                  style: context.labelSmall.bold.withColor(colors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Supports full or partial payments via UPI, Cards, and Net Banking.\n'
            '• Secured by Easebuzz Payment Gateway (RBI Regulated).\n'
            '• Instant digital receipt synced with Water User Association accounts.',
            style: context.caption.withSize(11.5),
          ),
        ],
      ),
    );
  }
}
