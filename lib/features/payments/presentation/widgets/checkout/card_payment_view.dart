import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';

class CardPaymentView extends StatefulWidget {
  const CardPaymentView({super.key});

  @override
  State<CardPaymentView> createState() => _CardPaymentViewState();
}

class _CardPaymentViewState extends State<CardPaymentView> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController =
      TextEditingController(text: 'RAMESH PATIL');
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool _obscureCvv = true;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _fillKisanDemoCard() {
    _cardNumberController.text = '5085 0241 8920 4120';
    _cardHolderController.text = 'RAMESH PATIL';
    _expiryController.text = '08/29';
    _cvvController.text = '389';
    context.read<PaymentCheckoutBloc>().add(
          const UpdateCardDetailsEvent(
            cardNumber: '5085 0241 8920 4120',
            cardHolder: 'RAMESH PATIL',
            cardExpiry: '08/29',
            cardCvv: '389',
          ),
        );
  }

  void _fillVisaDemoCard() {
    _cardNumberController.text = '4111 2222 3333 4120';
    _cardHolderController.text = 'RAMESH PATIL';
    _expiryController.text = '11/28';
    _cvvController.text = '123';
    context.read<PaymentCheckoutBloc>().add(
          const UpdateCardDetailsEvent(
            cardNumber: '4111 2222 3333 4120',
            cardHolder: 'RAMESH PATIL',
            cardExpiry: '11/28',
            cardCvv: '123',
          ),
        );
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
        final colors = context.colors;
        final payableAmount = state.bill.outstandingAmount > 0
            ? state.bill.outstandingAmount
            : (state.bill.totalAmount > 0 ? state.bill.totalAmount : 1240.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Interactive Card Preview
            _buildCardPreview(context, state),
            const SizedBox(height: 12),

            // Demo prefill chips
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(
                    Icons.agriculture_rounded,
                    size: 14,
                    color: AppColors.canalGreen,
                  ),
                  label: const Text('Demo RuPay Kisan Card'),
                  onPressed: _fillKisanDemoCard,
                ),
                ActionChip(
                  avatar: const Icon(Icons.credit_card_rounded, size: 14),
                  label: const Text('Demo Visa Debit'),
                  onPressed: _fillVisaDemoCard,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Card inputs
            Text(
              'Card Details',
              style: context.labelMedium.bold.withColor(colors.textPrimary),
            ),
            const SizedBox(height: 8),

            // Card Number
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
                _CardNumberFormatter(),
              ],
              onChanged: (val) {
                context.read<PaymentCheckoutBloc>().add(
                      UpdateCardDetailsEvent(cardNumber: val),
                    );
              },
              decoration: InputDecoration(
                labelText: 'Card Number (16 Digits)',
                hintText: 'xxxx xxxx xxxx xxxx',
                prefixIcon: const Icon(Icons.credit_card_rounded, size: 20),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.detectedCardBrand,
                        style: context.caption.bold.withColor(colors.primary),
                      ),
                    ],
                  ),
                ),
                filled: true,
                fillColor: colors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cardholder Name
            TextField(
              controller: _cardHolderController,
              textCapitalization: TextCapitalization.characters,
              onChanged: (val) {
                context.read<PaymentCheckoutBloc>().add(
                      UpdateCardDetailsEvent(cardHolder: val),
                    );
              },
              decoration: InputDecoration(
                labelText: 'Cardholder Name',
                hintText: 'Farmer Name as on card',
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                filled: true,
                fillColor: colors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Expiry & CVV Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                      _CardExpiryFormatter(),
                    ],
                    onChanged: (val) {
                      context.read<PaymentCheckoutBloc>().add(
                            UpdateCardDetailsEvent(cardExpiry: val),
                          );
                    },
                    decoration: InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                      hintText: 'MM/YY',
                      prefixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                      ),
                      filled: true,
                      fillColor: colors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: _obscureCvv,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    onChanged: (val) {
                      context.read<PaymentCheckoutBloc>().add(
                            UpdateCardDetailsEvent(cardCvv: val),
                          );
                    },
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '•••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCvv
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureCvv = !_obscureCvv;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: colors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tokenization Checkbox
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: state.saveCard,
              onChanged: (val) {
                context.read<PaymentCheckoutBloc>().add(
                      UpdateCardDetailsEvent(saveCard: val ?? true),
                    );
              },
              title: Text(
                'Save card securely for future cess payments as per RBI tokenization directives.',
                style: context.caption.withSize(11.5),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Submit Button
            ElevatedButton.icon(
              onPressed: () {
                context.push(
                  '/payments/gateway?mode=card',
                  extra: state.bill,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.canalGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.open_in_browser_rounded, size: 18),
              label: Text(
                'Open Payment Gateway (${_formatCurrency(payableAmount)})',
                style: context.buttonText.bold.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Interactive Card Graphic Preview ──────────────────────────────────────

  Widget _buildCardPreview(
    BuildContext context,
    PaymentCheckoutState state,
  ) {
    final colors = context.colors;
    final isKisan = state.detectedCardBrand.contains('RuPay');

    final displayNum = state.cardNumber.isNotEmpty
        ? state.cardNumber
        : '•••• •••• •••• 4120';
    final displayHolder = state.cardHolder.isNotEmpty
        ? state.cardHolder.toUpperCase()
        : 'RAMESH PATIL';
    final displayExpiry = state.cardExpiry.isNotEmpty
        ? state.cardExpiry
        : '08/29';

    return Container(
      height: 190,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isKisan
              ? const [
                  Color(0xFF0F3D3E),
                  Color(0xFF104E4B),
                  Color(0xFF1C6758),
                ]
              : const [
                  Color(0xFF153462),
                  Color(0xFF1D5D9B),
                  Color(0xFF4F709C),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.cardShadow,
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Chip + Brand Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD54F),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: const Icon(
                      Icons.memory_rounded,
                      size: 20,
                      color: Color(0xFF5D4037),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.contactless_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    if (isKisan)
                      const Icon(
                        Icons.agriculture_rounded,
                        color: Color(0xFFFFF9C4),
                        size: 14,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      isKisan ? 'RuPay Kisan KCC' : state.detectedCardBrand,
                      style: context.caption.bold.withColor(Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Card Number
          Text(
            displayNum,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 19,
              letterSpacing: 2.2,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),

          // Bottom Row: Holder + Expiry
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARDHOLDER NAME',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayHolder,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VALID THRU',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayExpiry,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Formatter to space digits in groups of 4 (xxxx xxxx xxxx xxxx)
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter for MM/YY expiry
class _CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
