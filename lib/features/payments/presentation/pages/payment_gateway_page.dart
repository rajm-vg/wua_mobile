import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/usecases/process_payment_usecase.dart';

enum GatewayStage {
  portalHome,
  bankLogin,
  bankOtp,
  card3dSecureOtp,
  redirectingToMerchant,
}

enum GatewayMethodTab {
  netBanking,
  card,
}

/// Simulated external Payment Gateway WebView mimicking MahaGov e-GRAS Cyber Treasury / BillDesk Gateway.
/// Features a realistic in-app browser frame, SSL padlock, URL bar, session timer,
/// internet banking redirect portal, and RuPay 3D Secure ACS card verification.
class PaymentGatewayPage extends StatefulWidget {
  const PaymentGatewayPage({
    super.key,
    this.bill,
    this.initialMode = 'netbanking',
  });

  final BillEntity? bill;
  final String initialMode;

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
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  late BillEntity _activeBill;
  late GatewayMethodTab _currentTab;
  GatewayStage _stage = GatewayStage.portalHome;

  // Session timer (counts down from 14:59)
  late int _remainingSeconds;
  Timer? _sessionTimer;
  Timer? _redirectTimer;

  // Form states
  String _selectedBank = 'State Bank of India';
  final TextEditingController _bankUsernameController =
      TextEditingController(text: 'kisan_ramesh412');
  final TextEditingController _bankPasswordController =
      TextEditingController(text: 'Password@123');
  final TextEditingController _bankOtpController = TextEditingController();

  final TextEditingController _cardNumberController =
      TextEditingController(text: '6071 8842 9102 2304');
  final TextEditingController _cardExpiryController =
      TextEditingController(text: '08/28');
  final TextEditingController _cardCvvController =
      TextEditingController(text: '739');
  final TextEditingController _cardHolderController =
      TextEditingController(text: 'Ramesh D. Patil');
  final TextEditingController _cardOtpController = TextEditingController();

  PaymentEntity? _createdPayment;

  @override
  void initState() {
    super.initState();
    _activeBill = widget.bill ?? PaymentGatewayPage.fallbackBill;
    _currentTab = widget.initialMode.toLowerCase().contains('card')
        ? GatewayMethodTab.card
        : GatewayMethodTab.netBanking;

    _remainingSeconds = 14 * 60 + 59; // 14 mins 59 secs
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _sessionTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _redirectTimer?.cancel();
    _bankUsernameController.dispose();
    _bankPasswordController.dispose();
    _bankOtpController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    _cardOtpController.dispose();
    super.dispose();
  }

  double get _payableAmount => _activeBill.outstandingAmount > 0
      ? _activeBill.outstandingAmount
      : (_activeBill.totalAmount > 0 ? _activeBill.totalAmount : 1240.0);

  String get _currentBrowserUrl {
    switch (_stage) {
      case GatewayStage.portalHome:
        return 'https://gras.mahakosh.gov.in/epay/wrd/checkout';
      case GatewayStage.bankLogin:
        return 'https://retail.onlinesbi.sbi/retail/login.htm';
      case GatewayStage.bankOtp:
        return 'https://retail.onlinesbi.sbi/retail/otp_verify.htm';
      case GatewayStage.card3dSecureOtp:
        return 'https://acs.rupay.org.in/3dsecure/verify';
      case GatewayStage.redirectingToMerchant:
        return 'https://gras.mahakosh.gov.in/epay/wrd/response';
    }
  }

  String get _formattedTime {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _onCancelGateway() {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Leaving the Cyber Treasury payment gateway will cancel this transaction. Do you wish to return to the WUA app?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continue Payment'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(true);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel & Exit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSslCertInfo() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lock_rounded, color: Colors.green, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Connection is Secure',
                    style: context.titleMedium.bold.withColor(Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Your information (passwords, OTPs, or card numbers) is private when it is sent to this site.',
                style: TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Certificate: Valid (SHA-256 with RSA)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Issued to: gras.mahakosh.gov.in', style: TextStyle(fontSize: 12)),
                    Text('Issued by: National Informatics Centre (NIC) CA', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeGatewayPayment({required String mode}) async {
    setState(() {
      _stage = GatewayStage.redirectingToMerchant;
    });

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
      paymentMode: mode,
      gatewayTransactionId: 'GRAS/MH/${now.year}${now.month.toString().padLeft(2, '0')}/${100000 + (now.microsecond % 900000)}',
      bankReference: 'MHA-GRN-${now.millisecondsSinceEpoch.toString().substring(5)}',
      gatewayName: 'MahaGov e-GRAS Cyber Treasury Portal',
      remarks: 'Pani Patti settled via $mode (Challan ${_activeBill.billNumber})',
      metadata: {
        'challan_grn': 'MH-WRD-2026-${now.millisecondsSinceEpoch.toString().substring(6)}',
        'gateway': 'e-GRAS Cyber Treasury',
        'bank': _selectedBank,
      },
    );

    if (mounted) {
      try {
        final useCase = sl<ProcessPaymentUseCase>();
        await useCase(ProcessPaymentParams(payment: payment, bill: _activeBill));
      } catch (_) {
        // Safe fallback in test harnesses
      }

      _createdPayment = payment;

      _redirectTimer = Timer(const Duration(milliseconds: 2200), () {
        if (mounted) {
          _returnToWuaApp();
        }
      });
    }
  }

  void _returnToWuaApp() {
    _redirectTimer?.cancel();
    if (_createdPayment != null) {
      context.go('/payments/${_createdPayment!.id}', extra: _createdPayment);
    } else {
      context.go('/bills/${_activeBill.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SafeArea(
        child: Column(
          children: [
            // Browser Address Bar
            _buildBrowserBar(context),

            // In-app WebView content
            Expanded(
              child: _buildGatewayContent(context),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Browser Frame & Address Bar ──────────────────────────────────────────

  Widget _buildBrowserBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 22, color: Colors.black87),
            onPressed: _onCancelGateway,
            tooltip: 'Cancel & Exit Gateway',
          ),
          Expanded(
            child: InkWell(
              onTap: _showSslCertInfo,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_rounded, size: 14, color: Color(0xFF1E8E3E)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _currentBrowserUrl,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reloading Cyber Treasury gateway page...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayContent(BuildContext context) {
    switch (_stage) {
      case GatewayStage.portalHome:
        return _buildPortalHomeScreen(context);
      case GatewayStage.bankLogin:
        return _buildBankLoginScreen(context);
      case GatewayStage.bankOtp:
        return _buildBankOtpScreen(context);
      case GatewayStage.card3dSecureOtp:
        return _buildCard3dSecureScreen(context);
      case GatewayStage.redirectingToMerchant:
        return _buildRedirectingScreen(context);
    }
  }

  // ─── 1. e-GRAS Portal Home Screen ──────────────────────────────────────────

  Widget _buildPortalHomeScreen(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: _payableAmount.truncateToDouble() == _payableAmount ? 0 : 2,
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          // Government Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF0D47A1), // MahaGov Treasury Blue
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.account_balance_rounded,
                      color: Color(0xFF0D47A1),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GOVERNMENT OF MAHARASHTRA',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'e-GRAS Cyber Treasury Portal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Department of Water Resources (WRD)',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Order / Challan Details Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFE3F2FD),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GRN: MH-WRD-2026-89211',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bill: ${_activeBill.billNumber}',
                      style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(_payableAmount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 12, color: Colors.red),
                        const SizedBox(width: 3),
                        Text(
                          _formattedTime,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tabs: Internet Banking vs Debit / Credit Card
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Mode Selector
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentTab = GatewayMethodTab.netBanking;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _currentTab == GatewayMethodTab.netBanking
                                    ? const Color(0xFF0D47A1)
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_rounded,
                                size: 18,
                                color: _currentTab == GatewayMethodTab.netBanking
                                    ? const Color(0xFF0D47A1)
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Net Banking',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _currentTab == GatewayMethodTab.netBanking
                                      ? const Color(0xFF0D47A1)
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentTab = GatewayMethodTab.card;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: _currentTab == GatewayMethodTab.card
                                    ? const Color(0xFF0D47A1)
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card_rounded,
                                size: 18,
                                color: _currentTab == GatewayMethodTab.card
                                    ? const Color(0xFF0D47A1)
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Debit / Kisan Card',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _currentTab == GatewayMethodTab.card
                                      ? const Color(0xFF0D47A1)
                                      : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const Divider(height: 1),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _currentTab == GatewayMethodTab.netBanking
                      ? _buildNetBankingSection(context)
                      : _buildCardSection(context),
                ),
              ],
            ),
          ),

          // Security footer
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  'MahaGov e-GRAS • Certified 256-bit TLS Encryption',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. Net Banking Selector View ──────────────────────────────────────────

  Widget _buildNetBankingSection(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: _payableAmount.truncateToDouble() == _payableAmount ? 0 : 2,
    );

    final popularBanks = [
      'State Bank of India',
      'HDFC Bank',
      'ICICI Bank',
      'Bank of Maharashtra',
      'Bank of Baroda',
      'Axis Bank',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Select Your Bank for Internet Banking',
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),

        // Grid of popular banks
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.8,
          ),
          itemCount: popularBanks.length,
          itemBuilder: (context, index) {
            final bank = popularBanks[index];
            final isSelected = _selectedBank == bank;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedBank = bank;
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0D47A1) : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 16,
                      color: isSelected ? const Color(0xFF0D47A1) : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bank,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? const Color(0xFF0D47A1) : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Redirect Notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFFF57F17), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Clicking below will redirect you to $_selectedBank retail banking portal.',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF5D4037)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () {
            setState(() {
              _stage = GatewayStage.bankLogin;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Proceed to Bank Gateway (${currencyFormat.format(_payableAmount)})',
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ─── 3. Debit / Kisan Credit Card View ─────────────────────────────────────

  Widget _buildCardSection(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: _payableAmount.truncateToDouble() == _payableAmount ? 0 : 2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Demo card presets
        const Text(
          'Quick Demo Cards (Tap to Fill):',
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ActionChip(
              avatar: const Icon(Icons.agriculture_rounded, size: 16, color: Color(0xFF2E7D32)),
              label: const Text('RuPay Kisan Card (•••• 2304)', style: TextStyle(fontSize: 11.5)),
              backgroundColor: const Color(0xFFE8F5E9),
              onPressed: () {
                setState(() {
                  _cardNumberController.text = '6071 8842 9102 2304';
                  _cardExpiryController.text = '08/28';
                  _cardCvvController.text = '739';
                  _cardHolderController.text = 'Ramesh D. Patil';
                });
              },
            ),
            ActionChip(
              avatar: const Icon(Icons.credit_card_rounded, size: 16, color: Color(0xFF003366)),
              label: const Text('SBI Global RuPay (•••• 8912)', style: TextStyle(fontSize: 11.5)),
              backgroundColor: const Color(0xFFE1F5FE),
              onPressed: () {
                setState(() {
                  _cardNumberController.text = '4532 9012 3456 8912';
                  _cardExpiryController.text = '11/27';
                  _cardCvvController.text = '412';
                  _cardHolderController.text = 'Ramesh D. Patil';
                });
              },
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Card number
        const Text('Card Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'xxxx xxxx xxxx xxxx',
            prefixIcon: const Icon(Icons.credit_card_rounded, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),

        const SizedBox(height: 12),

        // Expiry & CVV
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Valid Thru (MM/YY)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _cardExpiryController,
                    decoration: InputDecoration(
                      hintText: 'MM/YY',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CVV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _cardCvvController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '•••',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Cardholder Name
        const Text('Cardholder Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        TextField(
          controller: _cardHolderController,
          decoration: InputDecoration(
            hintText: 'Name as on card',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () {
            setState(() {
              _stage = GatewayStage.card3dSecureOtp;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Pay Securely ${currencyFormat.format(_payableAmount)}',
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // ─── 4. Bank Login Portal (SBI Retail Internet Banking) ────────────────────

  Widget _buildBankLoginScreen(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Bank Brand Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: const Color(0xFF003366), // SBI Deep Blue
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.account_balance, color: Color(0xFF003366), size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedBank.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Retail Internet Banking Portal',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Portal body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security, size: 18, color: Color(0xFF003366)),
                        const SizedBox(width: 8),
                        Text(
                          'Mandate Authentication',
                          style: context.titleSmall.bold.withColor(const Color(0xFF003366)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Payment of ₹ ${_payableAmount.toStringAsFixed(2)} to MahaGov WRD',
                      style: const TextStyle(fontSize: 12.5, color: Colors.black87),
                    ),
                    const Divider(height: 24),

                    const Text('Internet Banking User ID', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _bankUsernameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text('Login Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _bankPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Auto-fill demo
                    InkWell(
                      onTap: () {
                        setState(() {
                          _bankUsernameController.text = 'kisan_ramesh412';
                          _bankPasswordController.text = 'Password@123';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, size: 14, color: Colors.blue),
                            SizedBox(width: 4),
                            Text('Auto-fill Demo Credentials', style: TextStyle(fontSize: 11.5, color: Colors.blue, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _stage = GatewayStage.bankOtp;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Login & Authorize', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 5. Bank OTP Verification Screen ───────────────────────────────────────

  Widget _buildBankOtpScreen(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: const Color(0xFF003366),
            child: Row(
              children: [
                const Icon(Icons.lock_clock, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  '$_selectedBank - High Security OTP',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Two-Factor Authorization',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'A High Security One Time Password (OTP) has been sent to your mobile registered with your bank ending in ••89.',
                      style: TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                    const Divider(height: 24),

                    const Text('Enter 6-Digit Bank OTP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _bankOtpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '839201',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Demo auto-fill OTP chip
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ActionChip(
                        avatar: const Icon(Icons.bolt, size: 15, color: Colors.amber),
                        label: const Text('Auto-fill OTP: 839201', style: TextStyle(fontSize: 11.5)),
                        onPressed: () {
                          setState(() {
                            _bankOtpController.text = '839201';
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () => _completeGatewayPayment(mode: 'Net Banking ($_selectedBank)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'Confirm & Authorize Payment of ₹ ${_payableAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 6. RuPay 3D Secure / ACS Screen ────────────────────────────────────────

  Widget _buildCard3dSecureScreen(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: const Color(0xFF005A9C), // RuPay ACS Blue
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  'RuPay 3D Secure Access Control Server',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Verified by RuPay / ACS Authentication',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Merchant', 'WRD MahaGov Cyber Treasury'),
                          const SizedBox(height: 6),
                          _buildDetailRow('Amount', '₹ ${_payableAmount.toStringAsFixed(2)}'),
                          const SizedBox(height: 6),
                          _buildDetailRow('Card Number', _cardNumberController.text),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Enter OTP sent by your bank to your registered mobile ending in ••89',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _cardOtpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '629104',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: ActionChip(
                        avatar: const Icon(Icons.bolt, size: 15, color: Colors.amber),
                        label: const Text('Auto-fill OTP: 629104', style: TextStyle(fontSize: 11.5)),
                        onPressed: () {
                          setState(() {
                            _cardOtpController.text = '629104';
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () => _completeGatewayPayment(mode: 'Debit / Kisan Card (${_cardNumberController.text.substring(_cardNumberController.text.length - 4)})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005A9C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Submit OTP & Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 7. Redirecting to Merchant Screen ──────────────────────────────────────

  Widget _buildRedirectingScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Authorization Successful!',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Transmitting Cyber Treasury acknowledgment to Water Resources Department...',
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Redirecting back to WUA app in 2 seconds...',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _returnToWuaApp,
              child: const Text('Return to WUA App'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }
}
