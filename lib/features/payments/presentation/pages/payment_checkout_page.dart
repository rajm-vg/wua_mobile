import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/domain/usecases/process_payment_usecase.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/checkout/bill_summary_card.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/checkout/card_payment_view.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/checkout/net_banking_view.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/checkout/payment_failure_view.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/checkout/payment_processing_view.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/checkout/payment_success_view.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/checkout/upi_payment_view.dart';
import 'package:wua_mobile/shared/widgets/wua_scaffold.dart';

/// Full-detail, theme-aware interactive payment checkout screen for WUA irrigation dues.
/// Supports UPI (Apps, VPA, BharatQR), Net Banking, and Debit / RuPay Kisan Credit Cards.
class PaymentCheckoutPage extends StatelessWidget {
  const PaymentCheckoutPage({
    super.key,
    this.bill,
    this.initialMethod,
  });

  final BillEntity? bill;
  final String? initialMethod;

  static const BillEntity defaultRabiBill = BillEntity(
    id: 'bill_rabi_2024_01',
    billNumber: 'WUA/PANI/2024-25/0842',
    status: BillStatus.pending,
    consumerId: 'KISAN-MH-41201',
    consumerName: 'Ramesh Patil',
    wuaSocietyName: 'Ganga-Godavari WUA Society #12',
    canalSection: 'Minor-3 (Outlet 4B), Distributary 7',
    season: 'Rabi Season (2024-25)',
    cropType: 'Wheat (गहू) & Gram',
    landAreaAcres: 4.5,
    waterQuantityLiters: 18500,
    rotationsCount: 3,
    subtotal: 1110.0,
    taxes: 90.0,
    maintenanceCess: 40.0,
    totalAmount: 1240.0,
    outstandingAmount: 1240.0,
  );

  @override
  Widget build(BuildContext context) {
    final activeBill = bill ?? defaultRabiBill;

    return BlocProvider<PaymentCheckoutBloc>(
      create: (context) => PaymentCheckoutBloc(
        processPaymentUseCase: sl<ProcessPaymentUseCase>(),
        initialBill: activeBill,
        initialMethod: initialMethod,
      ),
      child: const _PaymentCheckoutPageView(),
    );
  }
}

class _PaymentCheckoutPageView extends StatelessWidget {
  const _PaymentCheckoutPageView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentCheckoutBloc, PaymentCheckoutState>(
      builder: (context, state) {
        String title = 'Pani Patti Payment';
        String subtitle = 'MahaGov WRD Cyber Gateway';

        if (state.step == PaymentCheckoutStep.success) {
          title = 'Settlement Receipt';
          subtitle = 'Government Treasury Approved';
        } else if (state.step == PaymentCheckoutStep.processing) {
          title = 'Processing Payment';
          subtitle = 'Securing Gateway Session';
        } else if (state.step == PaymentCheckoutStep.failure) {
          title = 'Payment Status';
          subtitle = 'Gateway Response';
        }

        return WuaScaffold(
          title: title,
          subtitle: subtitle,
          showBackButton: state.step == PaymentCheckoutStep.methodSelection,
          scrollable: state.step != PaymentCheckoutStep.processing,
          padding: const EdgeInsets.all(AppSpacing.md),
          enableMaxConstraint: true,
          maxWidth: 960.0,
          body: _buildStepContent(context, state),
        );
      },
    );
  }

  Widget _buildStepContent(BuildContext context, PaymentCheckoutState state) {
    switch (state.step) {
      case PaymentCheckoutStep.processing:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: PaymentProcessingView(),
        );
      case PaymentCheckoutStep.success:
        return PaymentSuccessView(state: state);
      case PaymentCheckoutStep.failure:
        return PaymentFailureView(state: state);
      case PaymentCheckoutStep.methodSelection:
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Bill Summary & Security Seals
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        BillSummaryCard(bill: state.bill),
                        const SizedBox(height: AppSpacing.md),
                        _buildSecurityCard(context, state),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),

                  // Right Column: Method Selector & Forms
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMethodSelector(context, state),
                        const SizedBox(height: AppSpacing.md),
                        _buildMethodDetails(context, state),
                      ],
                    ),
                  ),
                ],
              );
            }

            // Mobile Layout
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BillSummaryCard(bill: state.bill),
                const SizedBox(height: AppSpacing.md),
                _buildMethodSelector(context, state),
                const SizedBox(height: AppSpacing.md),
                _buildMethodDetails(context, state),
                const SizedBox(height: AppSpacing.md),
                _buildSecurityCard(context, state),
                const SizedBox(height: 32),
              ],
            );
          },
        );
    }
  }

  // ─── Method Selector Segmented Tabs ────────────────────────────────────────

  Widget _buildMethodSelector(
    BuildContext context,
    PaymentCheckoutState state,
  ) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _buildMethodButton(
            context,
            title: 'UPI',
            subtitle: 'GPay, QR',
            icon: Icons.flash_on_rounded,
            isSelected: state.selectedMethod == PaymentMethodType.upi,
            onTap: () {
              context.read<PaymentCheckoutBloc>().add(
                    const SelectPaymentMethodEvent(PaymentMethodType.upi),
                  );
            },
          ),
          _buildMethodButton(
            context,
            title: 'Net Banking',
            subtitle: 'SBI, HDFC',
            icon: Icons.account_balance_rounded,
            isSelected: state.selectedMethod == PaymentMethodType.netBanking,
            onTap: () {
              context.read<PaymentCheckoutBloc>().add(
                    const SelectPaymentMethodEvent(
                      PaymentMethodType.netBanking,
                    ),
                  );
            },
          ),
          _buildMethodButton(
            context,
            title: 'Cards & KCC',
            subtitle: 'RuPay, Debit',
            icon: Icons.credit_card_rounded,
            isSelected: state.selectedMethod == PaymentMethodType.card,
            onTap: () {
              context.read<PaymentCheckoutBloc>().add(
                    const SelectPaymentMethodEvent(PaymentMethodType.card),
                  );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMethodButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(color: colors.primary, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: context.bodySmall.bold.withColor(
                  isSelected ? colors.primary : colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: context.caption.withSize(10).withColor(
                      isSelected ? colors.primary : colors.textSecondary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Active Method Content ─────────────────────────────────────────────────

  Widget _buildMethodDetails(
    BuildContext context,
    PaymentCheckoutState state,
  ) {
    switch (state.selectedMethod) {
      case PaymentMethodType.upi:
        return const UpiPaymentView();
      case PaymentMethodType.netBanking:
        return const NetBankingView();
      case PaymentMethodType.card:
        return const CardPaymentView();
    }
  }

  // ─── Security Seals & Simulator Controls Card ──────────────────────────────

  Widget _buildSecurityCard(
    BuildContext context,
    PaymentCheckoutState state,
  ) {
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
              Text(
                'Trust & Security Guarantees',
                style: context.labelSmall.bold.withColor(colors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• NPCI & Reserve Bank of India regulated online gateway.\n'
            '• Auto-reconciliation with Water User Association accounts.\n'
            '• Instant digital receipt recognized for canal turn entitlement.',
            style: context.caption.withSize(11.5),
          ),
          const SizedBox(height: 10),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: 6),

          // Simulation Switch (For testing & demos)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.bug_report_outlined,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Simulate Gateway Failure',
                        style: context.caption.bold
                            .withColor(colors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: state.simulateFailure,
                activeTrackColor: AppColors.error,
                onChanged: (val) {
                  context.read<PaymentCheckoutBloc>().add(
                        ToggleSimulateFailureEvent(val),
                      );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
