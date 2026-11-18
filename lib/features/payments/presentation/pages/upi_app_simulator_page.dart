import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/usecases/process_payment_usecase.dart';

enum UpiAppStage {
  intentDetails,
  npciPinKeypad,
  processing,
  success,
}

/// Standalone screen simulating an external UPI application (e.g., Google Pay / PhonePe)
/// and the official NPCI UPI PIN keypad interface.
class UpiAppSimulatorPage extends StatefulWidget {
  const UpiAppSimulatorPage({
    super.key,
    this.bill,
    this.appName = 'Google Pay',
  });

  final BillEntity? bill;
  final String appName;

  static const BillEntity fallbackBill = BillEntity(
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
  State<UpiAppSimulatorPage> createState() => _UpiAppSimulatorPageState();
}

class _UpiAppSimulatorPageState extends State<UpiAppSimulatorPage> {
  late BillEntity _activeBill;
  late String _currentAppName;
  UpiAppStage _stage = UpiAppStage.intentDetails;
  String _enteredPin = '';
  String _simulatedUtr = '';
  Timer? _autoReturnTimer;
  PaymentEntity? _createdPayment;

  @override
  void initState() {
    super.initState();
    _currentAppName = widget.appName;
    _activeBill = widget.bill ?? UpiAppSimulatorPage.fallbackBill;
    final now = DateTime.now();
    _simulatedUtr = 'UPI/${now.year}${now.month.toString().padLeft(2, '0')}${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  @override
  void dispose() {
    _autoReturnTimer?.cancel();
    super.dispose();
  }

  double get _payableAmount => _activeBill.outstandingAmount > 0
      ? _activeBill.outstandingAmount
      : (_activeBill.totalAmount > 0 ? _activeBill.totalAmount : 1240.0);

  Color get _appThemeColor {
    final lower = _currentAppName.toLowerCase();
    if (lower.contains('phonepe')) return const Color(0xFF5F259F);
    if (lower.contains('paytm')) return const Color(0xFF002E6E);
    if (lower.contains('bhim')) return const Color(0xFF00796B);
    if (lower.contains('cred')) return const Color(0xFF1E1E1E);
    return const Color(0xFF1A73E8); // Google Pay default
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
      });
      if (_enteredPin.length == 4) {
        _onPinSubmitted();
      }
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _autoFillPin() {
    setState(() {
      _enteredPin = '1234';
    });
    _onPinSubmitted();
  }

  Future<void> _onPinSubmitted() async {
    setState(() {
      _stage = UpiAppStage.processing;
    });

    // Simulate contacting NPCI and issuing bank
    await Future<void>.delayed(const Duration(milliseconds: 1400));

    final now = DateTime.now();
    final payment = PaymentEntity(
      id: 'pay_${now.millisecondsSinceEpoch}',
      paymentNumber:
          'REC/WUA/${now.year}-${(now.year + 1).toString().substring(2)}/${1000 + (now.millisecond % 9000)}',
      status: PaymentStatus.success,
      amount: _payableAmount,
      paymentDate: now,
      billId: _activeBill.id,
      billNumber: _activeBill.billNumber,
      consumerId: _activeBill.consumerId ?? 'KISAN-MH-41201',
      consumerName: _activeBill.consumerName ?? 'Ramesh Patil',
      wuaSocietyName: _activeBill.wuaSocietyName ?? 'Ganga-Godavari WUA Society #12',
      season: _activeBill.season,
      cropType: _activeBill.cropType,
      paymentMode: 'UPI ($_currentAppName)',
      gatewayTransactionId: _simulatedUtr,
      bankReference: 'NPCI-${now.millisecondsSinceEpoch.toString().substring(5)}',
      gatewayName: 'NPCI UPI 2.0 / SBI Gateway',
      remarks: 'Pani Patti settled via $_currentAppName',
      metadata: {
        'upi_app': _currentAppName,
        'vpa': 'billdesk.wrd@sbi',
        'utr': _simulatedUtr,
      },
    );

    if (mounted) {
      try {
        final useCase = sl<ProcessPaymentUseCase>();
        await useCase(ProcessPaymentParams(payment: payment, bill: _activeBill));
      } catch (_) {
        // Fallback gracefully in test environments
      }

      setState(() {
        _createdPayment = payment;
        _stage = UpiAppStage.success;
      });

      _autoReturnTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          _returnToWuaApp();
        }
      });
    }
  }

  void _returnToWuaApp() {
    _autoReturnTimer?.cancel();
    if (_createdPayment != null) {
      context.go('/payments/${_createdPayment!.id}', extra: _createdPayment);
    } else {
      context.go('/bills/${_activeBill.id}');
    }
  }

  void _onCancelUpi() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel UPI Payment?'),
        content: const Text(
          'Are you sure you want to exit the UPI application? No funds will be deducted from your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Exit to App', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case UpiAppStage.intentDetails:
        return _buildIntentDetailsScreen(context);
      case UpiAppStage.npciPinKeypad:
        return _buildNpciPinScreen(context);
      case UpiAppStage.processing:
        return _buildProcessingScreen(context);
      case UpiAppStage.success:
        return _buildSuccessScreen(context);
    }
  }

  // ─── 1. External UPI App Intent Screen (Google Pay / PhonePe) ───────────────

  Widget _buildIntentDetailsScreen(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: _payableAmount.truncateToDouble() == _payableAmount ? 0 : 2,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar of the UPI App
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.black87),
                    onPressed: _onCancelUpi,
                    tooltip: 'Cancel',
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    initialValue: _currentAppName,
                    tooltip: 'Switch Mock UPI App',
                    onSelected: (val) {
                      setState(() {
                        _currentAppName = val;
                      });
                    },
                    itemBuilder: (ctx) => [
                      'Google Pay',
                      'PhonePe',
                      'Paytm',
                      'BHIM UPI',
                      'CRED',
                    ].map((name) {
                      return PopupMenuItem<String>(
                        value: name,
                        child: Row(
                          children: [
                            Icon(
                              _currentAppName == name
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              size: 16,
                              color: _appThemeColor,
                            ),
                            const SizedBox(width: 8),
                            Text('Mock $name'),
                          ],
                        ),
                      );
                    }).toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _appThemeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _appThemeColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.payment_rounded, size: 16, color: _appThemeColor),
                          const SizedBox(width: 6),
                          Text(
                            '$_currentAppName (Mock) ▾',
                            style: TextStyle(
                              color: _appThemeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded, size: 13, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'NPCI Verified',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Merchant Avatar & Details
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD2E3FC), width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.water_drop_rounded,
                          color: Color(0xFF1967D2),
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Water Resources Dept (WRD)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_rounded, size: 15, color: Colors.blue.shade700),
                        const SizedBox(width: 4),
                        const Text(
                          'Govt of Maharashtra • billdesk.wrd@sbi',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Amount Display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Paying Amount',
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            currencyFormat.format(_payableAmount),
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Challan: ${_activeBill.billNumber} • ${_activeBill.season}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Debiting Account Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF003366).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Color(0xFF003366),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'State Bank of India',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Savings A/C •••• 4821',
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // NPCI Security Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shield_rounded, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 6),
                        Text(
                          'Secured by NPCI 256-bit UPI Gateway',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA to Proceed to PIN screen
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _stage = UpiAppStage.npciPinKeypad;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _appThemeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Proceed to Pay ${currencyFormat.format(_payableAmount)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 2. Authentic NPCI UPI PIN Keypad Screen (Dark Theme) ───────────────────

  Widget _buildNpciPinScreen(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: _payableAmount.truncateToDouble() == _payableAmount ? 0 : 2,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF141518),
      body: SafeArea(
        child: Column(
          children: [
            // NPCI Official Top Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF1F2024),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _stage = UpiAppStage.intentDetails;
                        _enteredPin = '';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NATIONAL PAYMENTS CORPORATION OF INDIA',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.lock_rounded, size: 12, color: Color(0xFF00C853)),
                          SizedBox(width: 4),
                          Text(
                            'UPI SECURE PIN INTERFACE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Transaction Summary Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: const Color(0xFF191A1E),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paying to: WRD Govt of Maharashtra',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'From: SBI A/C •••• 4821',
                          style: TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    currencyFormat.format(_payableAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // PIN Prompt & 4-Digit Dots
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'ENTER 4-DIGIT UPI PIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'UPI PIN will not be recorded or shared with anyone',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    const SizedBox(height: 28),

                    // 4 Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isFilled = index < _enteredPin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled ? Colors.white : Colors.transparent,
                            border: Border.all(
                              color: isFilled ? Colors.white : Colors.white38,
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),

                    // Demo helper button
                    InkWell(
                      onTap: _autoFillPin,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2D33),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF3F424B)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, color: Color(0xFFFFD54F), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Auto-fill Demo PIN: 1234',
                              style: TextStyle(
                                color: Color(0xFFFFD54F),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Numeric Keypad
            Container(
              color: const Color(0xFF1E2024),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  _buildKeypadRow(['1', '2', '3']),
                  _buildKeypadRow(['4', '5', '6']),
                  _buildKeypadRow(['7', '8', '9']),
                  _buildKeypadBottomRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) {
        return InkWell(
          onTap: () => _onDigitPressed(digit),
          borderRadius: BorderRadius.circular(35),
          child: Container(
            width: 70,
            height: 52,
            alignment: Alignment.center,
            child: Text(
              digit,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Backspace
        InkWell(
          onTap: _onBackspacePressed,
          borderRadius: BorderRadius.circular(35),
          child: Container(
            width: 70,
            height: 52,
            alignment: Alignment.center,
            child: const Icon(
              Icons.backspace_outlined,
              color: Colors.white70,
              size: 22,
            ),
          ),
        ),
        // Digit 0
        InkWell(
          onTap: () => _onDigitPressed('0'),
          borderRadius: BorderRadius.circular(35),
          child: Container(
            width: 70,
            height: 52,
            alignment: Alignment.center,
            child: const Text(
              '0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Submit Checkmark
        InkWell(
          onTap: () {
            if (_enteredPin.length == 4) {
              _onPinSubmitted();
            } else {
              _autoFillPin();
            }
          },
          borderRadius: BorderRadius.circular(35),
          child: Container(
            width: 70,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF00C853),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }

  // ─── 3. Processing State Screen ─────────────────────────────────────────────

  Widget _buildProcessingScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(_appThemeColor),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Processing payment with your bank...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please do not press back or switch apps while NPCI authorizes the transaction.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_rounded, size: 14, color: Colors.blue.shade700),
                      const SizedBox(width: 6),
                      const Text(
                        'Ref: NPCI-TXN-PROCESSING',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── 4. UPI Success Screen (Google Pay / PhonePe Style) ──────────────────────

  Widget _buildSuccessScreen(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: _payableAmount.truncateToDouble() == _payableAmount ? 0 : 2,
    );

    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFF00897B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Green Checkmark
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Color(0xFF00897B),
                    size: 60,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                currencyFormat.format(_payableAmount),
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Paid to Water Resources Dept (WRD)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              Text(
                'Govt of Maharashtra • $formattedDate',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),

              const SizedBox(height: 24),

              // Transaction info container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    _buildSuccessRow('UPI Ref ID (UTR)', _simulatedUtr),
                    const Divider(color: Colors.white24, height: 16),
                    _buildSuccessRow('Debited From', 'SBI •••• 4821'),
                    const Divider(color: Colors.white24, height: 16),
                    _buildSuccessRow('Water Cess Bill', _activeBill.billNumber),
                  ],
                ),
              ),

              const Spacer(),

              const Text(
                'Returning to Water App in 2 seconds...',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _returnToWuaApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF00897B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done • View Official Receipt',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
