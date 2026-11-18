import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';

class NetBankingView extends StatelessWidget {
  const NetBankingView({super.key});

  static const List<Map<String, dynamic>> popularBanks = [
    {
      'name': 'State Bank of India',
      'short': 'SBI',
      'color': Color(0xFF1E429B),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'HDFC Bank',
      'short': 'HDFC',
      'color': Color(0xFF004C8F),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'ICICI Bank',
      'short': 'ICICI',
      'color': Color(0xFFC94C16),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'Axis Bank',
      'short': 'Axis',
      'color': Color(0xFF97144D),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'Bank of Baroda',
      'short': 'BOB',
      'color': Color(0xFFF15A24),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'Maharashtra Gramin Bank',
      'short': 'MGB',
      'color': Color(0xFF2B8C42),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'Punjab National Bank',
      'short': 'PNB',
      'color': Color(0xFFA20A27),
      'icon': Icons.account_balance_rounded,
    },
    {
      'name': 'Canara Bank',
      'short': 'Canara',
      'color': Color(0xFF0088CC),
      'icon': Icons.account_balance_rounded,
    },
  ];

  static const List<String> allOtherBanks = [
    'Bank of Maharashtra',
    'Union Bank of India',
    'Indian Bank',
    'Central Bank of India',
    'Kotak Mahindra Bank',
    'IDBI Bank',
    'Yes Bank',
    'Federal Bank',
    'IndusInd Bank',
    'Saraswat Co-operative Bank',
    'Cosmos Co-operative Bank',
    'TJSB Sahakari Bank',
  ];

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
    final colors = context.colors;

    return BlocBuilder<PaymentCheckoutBloc, PaymentCheckoutState>(
      builder: (context, state) {
        final payableAmount = state.bill.outstandingAmount > 0
            ? state.bill.outstandingAmount
            : (state.bill.totalAmount > 0 ? state.bill.totalAmount : 1240.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Popular Banks Grid Header
            Text(
              'Select Popular Bank',
              style: context.labelMedium.bold.withColor(colors.textPrimary),
            ),
            const SizedBox(height: 8),

            // Popular Banks Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.3,
              ),
              itemCount: popularBanks.length,
              itemBuilder: (context, index) {
                final bank = popularBanks[index];
                final name = bank['name'] as String;
                final isSelected = state.selectedBank == name;
                final bankColor = bank['color'] as Color;

                return InkWell(
                  onTap: () {
                    context.read<PaymentCheckoutBloc>().add(
                          SelectBankEvent(name),
                        );
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary.withValues(alpha: 0.08)
                          : colors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? colors.primary : colors.cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: bankColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              bank['short'] as String,
                              style: context.caption.bold.withColor(bankColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            style: context.bodySmall.bold
                                .withColor(colors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: colors.primary,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // All other banks dropdown
            Text(
              'Or Choose Another Indian Bank',
              style: context.caption.bold.withColor(colors.textSecondary),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: colors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text(
                    'Select Bank from 50+ partners...',
                    style: context.bodySmall.withColor(colors.textHint),
                  ),
                  value: allOtherBanks.contains(state.selectedBank)
                      ? state.selectedBank
                      : null,
                  items: allOtherBanks.map((b) {
                    return DropdownMenuItem<String>(
                      value: b,
                      child: Text(b, style: context.bodySmall),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      context.read<PaymentCheckoutBloc>().add(
                            SelectBankEvent(val),
                          );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Cyber Treasury Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.security_rounded,
                    color: AppColors.canalGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You will be securely routed through Government Cyber Treasury portal to ${state.selectedBank}.',
                      style: context.caption.withSize(11.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Proceed CTA
            ElevatedButton.icon(
              onPressed: () {
                context.push(
                  '/payments/gateway?mode=netbanking',
                  extra: state.bill,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.open_in_browser_rounded, size: 18),
              label: Text(
                'Open Cyber Treasury Gateway (${_formatCurrency(payableAmount)})',
                style: context.buttonText.bold.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
