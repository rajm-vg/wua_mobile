import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_bloc.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_event.dart';
import 'package:wua_mobile/features/payments/presentation/bloc/payment_checkout/payment_checkout_state.dart';
import 'package:wua_mobile/features/payments/presentation/widgets/checkout/simulated_auth_sheets.dart';

class UpiPaymentView extends StatefulWidget {
  const UpiPaymentView({super.key});

  @override
  State<UpiPaymentView> createState() => _UpiPaymentViewState();
}

class _UpiPaymentViewState extends State<UpiPaymentView> {
  final TextEditingController _vpaController = TextEditingController();
  int _qrCountdownSeconds = 300;
  Timer? _qrTimer;

  @override
  void initState() {
    super.initState();
    _startQrTimer();
  }

  void _startQrTimer() {
    _qrTimer?.cancel();
    _qrTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_qrCountdownSeconds > 0) {
        if (mounted) {
          setState(() {
            _qrCountdownSeconds--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    _vpaController.dispose();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
            // Sub-mode tabs: Apps / VPA / QR
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.cardBorder),
              ),
              child: Row(
                children: [
                  _buildSubTab(
                    context,
                    title: 'UPI Apps',
                    icon: Icons.apps_rounded,
                    isSelected: state.upiSubMode == UpiSubMode.apps,
                    onTap: () {
                      context.read<PaymentCheckoutBloc>().add(
                            const SelectUpiSubModeEvent(UpiSubMode.apps),
                          );
                    },
                  ),
                  _buildSubTab(
                    context,
                    title: 'UPI ID / VPA',
                    icon: Icons.alternate_email_rounded,
                    isSelected: state.upiSubMode == UpiSubMode.vpa,
                    onTap: () {
                      context.read<PaymentCheckoutBloc>().add(
                            const SelectUpiSubModeEvent(UpiSubMode.vpa),
                          );
                    },
                  ),
                  _buildSubTab(
                    context,
                    title: 'Scan QR',
                    icon: Icons.qr_code_2_rounded,
                    isSelected: state.upiSubMode == UpiSubMode.qr,
                    onTap: () {
                      context.read<PaymentCheckoutBloc>().add(
                            const SelectUpiSubModeEvent(UpiSubMode.qr),
                          );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Content according to submode
            if (state.upiSubMode == UpiSubMode.apps)
              _buildAppsContent(context, state, payableAmount),
            if (state.upiSubMode == UpiSubMode.vpa)
              _buildVpaContent(context, state, payableAmount),
            if (state.upiSubMode == UpiSubMode.qr)
              _buildQrContent(context, state, payableAmount),
          ],
        );
      },
    );
  }

  Widget _buildSubTab(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.cardBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.cardShadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: context.caption.bold.withColor(
                  isSelected ? colors.primary : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 1. Popular UPI Apps Grid ──────────────────────────────────────────────

  Widget _buildAppsContent(
    BuildContext context,
    PaymentCheckoutState state,
    double amount,
  ) {
    final colors = context.colors;
    final apps = [
      {
        'name': 'Google Pay',
        'badge': 'GPay',
        'color': const Color(0xFF1A73E8),
        'icon': Icons.account_balance_wallet_rounded,
      },
      {
        'name': 'PhonePe',
        'badge': 'PhonePe',
        'color': const Color(0xFF5F259F),
        'icon': Icons.phone_android_rounded,
      },
      {
        'name': 'Paytm',
        'badge': 'Paytm UPI',
        'color': const Color(0xFF002E6E),
        'icon': Icons.payments_rounded,
      },
      {
        'name': 'BHIM UPI',
        'badge': 'Govt NPCI',
        'color': const Color(0xFF00796B),
        'icon': Icons.security_rounded,
      },
      {
        'name': 'CRED',
        'badge': 'CRED UPI',
        'color': const Color(0xFF212121),
        'icon': Icons.credit_score_rounded,
      },
      {
        'name': 'Amazon Pay',
        'badge': 'Amazon',
        'color': const Color(0xFFFF9900),
        'icon': Icons.shopping_bag_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Select Installed UPI App',
          style: context.labelMedium.bold.withColor(colors.textPrimary),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.3,
          ),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            final name = app['name'] as String;
            final isSelected = state.selectedUpiApp == name;
            final appColor = app['color'] as Color;

            return InkWell(
              onTap: () {
                context
                    .read<PaymentCheckoutBloc>()
                    .add(SelectUpiAppEvent(name));
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: appColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        app['icon'] as IconData,
                        color: appColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: context.bodySmall.bold
                                .withColor(colors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            app['badge'] as String,
                            style: context.caption.withSize(10).withColor(
                                  colors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: colors.primary,
                        size: 18,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        // Pay CTA Button
        ElevatedButton.icon(
          onPressed: () {
            context.push(
              '/payments/upi-app?app=${Uri.encodeComponent(state.selectedUpiApp)}',
              extra: state.bill,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.canalGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
          icon: const Icon(Icons.open_in_new_rounded, size: 20),
          label: Text(
            'Open ${state.selectedUpiApp} (${_formatCurrency(amount)})',
            style: context.buttonText.bold.white,
          ),
        ),
      ],
    );
  }

  // ─── 2. UPI ID / VPA Entry ─────────────────────────────────────────────────

  Widget _buildVpaContent(
    BuildContext context,
    PaymentCheckoutState state,
    double amount,
  ) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter Farmer / Consumer UPI ID (VPA)',
          style: context.labelMedium.bold.withColor(colors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'A payment collect request will be dispatched to your UPI app for approval.',
          style: context.caption.withColor(colors.textSecondary),
        ),
        const SizedBox(height: 12),

        // VPA Input Field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _vpaController,
                onChanged: (val) {
                  context
                      .read<PaymentCheckoutBloc>()
                      .add(UpdateUpiVpaEvent(val));
                },
                decoration: InputDecoration(
                  hintText: 'e.g. 9876543210@paytm / farmer@oksbi',
                  prefixIcon: const Icon(Icons.alternate_email_rounded, size: 20),
                  filled: true,
                  fillColor: colors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                context
                    .read<PaymentCheckoutBloc>()
                    .add(VerifyUpiVpaEvent(_vpaController.text));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Verify'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Quick suggestions
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
              label: const Text('ramesh.patil@oksbi'),
              onPressed: () {
                _vpaController.text = 'ramesh.patil@oksbi';
                context.read<PaymentCheckoutBloc>().add(
                      const VerifyUpiVpaEvent('ramesh.patil@oksbi'),
                    );
              },
            ),
            ActionChip(
              label: const Text('9822412001@paytm'),
              onPressed: () {
                _vpaController.text = '9822412001@paytm';
                context.read<PaymentCheckoutBloc>().add(
                      const VerifyUpiVpaEvent('9822412001@paytm'),
                    );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Verification banner
        if (state.isVpaVerified) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verified VPA: ${state.vpaVerifiedName}',
                        style: context.bodySmall.bold
                            .withColor(AppColors.success),
                      ),
                      Text(
                        'State Bank of India • Consumer KISAN-MH-41201',
                        style: context.caption.withSize(11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // Request CTA
        ElevatedButton.icon(
          onPressed: () {
            if (!state.isVpaVerified && _vpaController.text.isNotEmpty) {
              context.read<PaymentCheckoutBloc>().add(
                    VerifyUpiVpaEvent(_vpaController.text),
                  );
            }
            SimulatedUpiPinSheet.show(
              context,
              appName: 'UPI VPA',
              amount: amount,
              onPinSubmitted: () {
                context.read<PaymentCheckoutBloc>().add(
                      const ExecutePaymentEvent(),
                    );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.send_rounded, size: 18),
          label: Text(
            'Request ${_formatCurrency(amount)} via UPI',
            style: context.buttonText.bold.white,
          ),
        ),
      ],
    );
  }

  // ─── 3. BharatQR / UPI Dynamic QR Code ─────────────────────────────────────

  Widget _buildQrContent(
    BuildContext context,
    PaymentCheckoutState state,
    double amount,
  ) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: AppColors.canalGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'BharatQR • WRD Maharashtra',
                    style: context.labelMedium.bold
                        .withColor(colors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimer(_qrCountdownSeconds),
                      style: context.caption.bold.withColor(AppColors.warning),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // QR Display Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12, width: 2),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(180, 180),
                      painter: _MockQrCodePainter(),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: const Icon(
                        Icons.water_drop_rounded,
                        color: AppColors.canalGreen,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(amount),
                  style: context.titleMedium.bold.withColor(Colors.black87),
                ),
                Text(
                  'VPA: maha.wrd@gov.upi',
                  style: context.caption.withSize(11).withColor(Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Scan with any UPI app: Google Pay, PhonePe, Paytm, or BHIM',
            style: context.caption.withColor(colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Simulate QR Scan CTA
          ElevatedButton.icon(
            onPressed: () {
              context.read<PaymentCheckoutBloc>().add(
                    const ExecutePaymentEvent(
                      customRemarks: 'Settled via BharatQR Scanner',
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.canalGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: Text(
              'Simulate QR Scan & Approve ${_formatCurrency(amount)}',
              style: context.buttonText.bold.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper custom painter to render a realistic simulated QR pattern.
class _MockQrCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // Corner Finder Patterns
    _drawFinder(canvas, paint, const Offset(0, 0));
    _drawFinder(canvas, paint, Offset(size.width - 40, 0));
    _drawFinder(canvas, paint, Offset(0, size.height - 40));

    // Simulated data grid dots
    const int gridSize = 14;
    final double step = size.width / gridSize;

    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        // Skip finder areas
        if ((r < 4 && c < 4) ||
            (r < 4 && c > gridSize - 5) ||
            (r > gridSize - 5 && c < 4)) {
          continue;
        }
        // Center area skip
        if (r >= 5 && r <= 8 && c >= 5 && c <= 8) {
          continue;
        }

        if ((r * 7 + c * 13) % 3 == 0) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * step + 2, r * step + 2, step - 4, step - 4),
              const Radius.circular(2),
            ),
            paint,
          );
        }
      }
    }
  }

  void _drawFinder(Canvas canvas, Paint paint, Offset offset) {
    // Outer box
    canvas.drawRect(
      Rect.fromLTWH(offset.dx, offset.dy, 40, 40),
      paint,
    );
    // Inner white cutout
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + 6, offset.dy + 6, 28, 28),
      whitePaint,
    );
    // Center black dot
    canvas.drawRect(
      Rect.fromLTWH(offset.dx + 12, offset.dy + 12, 16, 16),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
