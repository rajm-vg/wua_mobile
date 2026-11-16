import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';

/// Simulated UPI PIN entry bottom sheet resembling official NPCI UPI screens.
class SimulatedUpiPinSheet extends StatefulWidget {
  const SimulatedUpiPinSheet({
    super.key,
    required this.appName,
    required this.amount,
    required this.onPinSubmitted,
  });

  final String appName;
  final double amount;
  final VoidCallback onPinSubmitted;

  static Future<bool?> show(
    BuildContext context, {
    required String appName,
    required double amount,
    required VoidCallback onPinSubmitted,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SimulatedUpiPinSheet(
        appName: appName,
        amount: amount,
        onPinSubmitted: onPinSubmitted,
      ),
    );
  }

  @override
  State<SimulatedUpiPinSheet> createState() => _SimulatedUpiPinSheetState();
}

class _SimulatedUpiPinSheetState extends State<SimulatedUpiPinSheet> {
  String _pin = '';

  void _onDigit(String d) {
    if (_pin.length < 4) {
      setState(() {
        _pin += d;
      });
      if (_pin.length == 4) {
        _submit();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  void _submit() {
    Navigator.of(context).pop(true);
    widget.onPinSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: widget.amount.truncateToDouble() == widget.amount ? 0 : 2,
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primarySeed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: AppColors.primarySeed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.appName} UPI Gateway',
                    style: context.titleSmall.bold.withColor(colors.textPrimary),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: 16),

          // Payee & Amount
          Text(
            'Water Resources Dept, Maharashtra',
            style: context.bodySmall.withColor(colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(widget.amount),
            style: context.headlineMedium.bold.withColor(colors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'From: State Bank of India (••4120)',
            style: context.caption.withColor(colors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Enter UPI PIN
          Text(
            'ENTER 4-DIGIT UPI PIN',
            style: context.labelSmall.bold.withColor(colors.textPrimary),
          ),
          const SizedBox(height: 12),

          // PIN Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              final filled = index < _pin.length;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled ? colors.primary : colors.surfaceVariant,
                  border: Border.all(
                    color: filled ? colors.primary : colors.divider,
                    width: 2,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Auto-fill convenience button
          ActionChip(
            avatar: const Icon(Icons.flash_on_rounded, size: 14),
            label: const Text('Auto-enter PIN: 1234'),
            onPressed: () {
              setState(() {
                _pin = '1234';
              });
              _submit();
            },
          ),
          const SizedBox(height: 20),

          // Custom Keypad
          _buildKeypad(context),
        ],
      ),
    );
  }

  Widget _buildKeypad(BuildContext context) {
    final colors = context.colors;
    final digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return Column(
      children: digits.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((item) {
              if (item.isEmpty) {
                return const SizedBox(width: 72, height: 48);
              }
              if (item == 'back') {
                return SizedBox(
                  width: 72,
                  height: 48,
                  child: IconButton(
                    icon: const Icon(Icons.backspace_outlined),
                    color: colors.textPrimary,
                    onPressed: _onBackspace,
                  ),
                );
              }
              return SizedBox(
                width: 72,
                height: 48,
                child: TextButton(
                  onPressed: () => _onDigit(item),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    item,
                    style: context.titleLarge.bold.withColor(colors.textPrimary),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

/// Simulated NetBanking & 3D Secure OTP verification modal.
class SimulatedCyberTreasurySheet extends StatefulWidget {
  const SimulatedCyberTreasurySheet({
    super.key,
    required this.title,
    required this.sourceBank,
    required this.amount,
    required this.onVerified,
  });

  final String title;
  final String sourceBank;
  final double amount;
  final VoidCallback onVerified;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String sourceBank,
    required double amount,
    required VoidCallback onVerified,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SimulatedCyberTreasurySheet(
        title: title,
        sourceBank: sourceBank,
        amount: amount,
        onVerified: onVerified,
      ),
    );
  }

  @override
  State<SimulatedCyberTreasurySheet> createState() =>
      _SimulatedCyberTreasurySheetState();
}

class _SimulatedCyberTreasurySheetState
    extends State<SimulatedCyberTreasurySheet> {
  final TextEditingController _otpController =
      TextEditingController(text: '784120');

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _confirm() {
    Navigator.of(context).pop(true);
    widget.onVerified();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: widget.amount.truncateToDouble() == widget.amount ? 0 : 2,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Header Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.canalGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: AppColors.canalGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MahaGov WRD Cyber Treasury',
                          style: context.labelMedium.bold
                              .withColor(colors.textPrimary),
                        ),
                        Text(
                          'Dept of Water Resources • GRN: 2026-WRD-09218',
                          style: context.caption.withSize(11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bank details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Issuing Bank',
                  style: context.bodySmall.withColor(colors.textSecondary),
                ),
                Text(
                  widget.sourceBank,
                  style: context.bodySmall.bold.withColor(colors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payable Amount',
                  style: context.bodySmall.withColor(colors.textSecondary),
                ),
                Text(
                  currencyFormat.format(widget.amount),
                  style: context.titleSmall.bold.withColor(colors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: colors.divider, height: 1),
            const SizedBox(height: 16),

            // OTP explanation
            Text(
              'High Security 6-Digit OTP',
              style: context.titleSmall.bold.withColor(colors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'An authentication code has been sent to registered mobile linked with Kisan ID ••••4120',
              style: context.caption.withColor(colors.textSecondary),
            ),
            const SizedBox(height: 14),

            // OTP Input
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: context.titleLarge.bold.withColor(colors.textPrimary),
              decoration: InputDecoration(
                counterText: '',
                hintText: '• • • • • •',
                filled: true,
                fillColor: colors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Auto-fill chip
            Align(
              alignment: Alignment.center,
              child: ActionChip(
                avatar: const Icon(Icons.flash_on_rounded, size: 14),
                label: const Text('Auto-fill OTP: 784120'),
                onPressed: () {
                  setState(() {
                    _otpController.text = '784120';
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.canalGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Authorize & Complete ${currencyFormat.format(widget.amount)}',
                style: context.buttonText.bold.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
