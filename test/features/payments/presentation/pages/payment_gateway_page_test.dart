import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/domain/entities/payment_entity.dart';
import 'package:wua_mobile/features/payments/domain/usecases/process_payment_usecase.dart';
import 'package:wua_mobile/features/payments/presentation/pages/payment_gateway_page.dart';

class MockProcessPaymentUseCase extends Mock implements ProcessPaymentUseCase {}

class FakeProcessPaymentParams extends Fake implements ProcessPaymentParams {}

void main() {
  late MockProcessPaymentUseCase mockProcessPaymentUseCase;

  const tBill = BillEntity(
    id: 'bill_rabi_01',
    billNumber: 'WUA/PANI/2024/001',
    status: BillStatus.pending,
    totalAmount: 1240.0,
    outstandingAmount: 1240.0,
    consumerName: 'Ramesh Patil',
    wuaSocietyName: 'Ganga-Godavari WUA #12',
    season: 'Rabi Season (2024-25)',
    cropType: 'Wheat',
  );

  final tPayment = PaymentEntity(
    id: 'pay_001',
    paymentNumber: 'REC/WUA/2026/001',
    status: PaymentStatus.success,
    amount: 1240.0,
    paymentDate: DateTime(2026, 11, 16),
    billId: 'bill_rabi_01',
    billNumber: 'WUA/PANI/2024/001',
  );

  setUpAll(() {
    registerFallbackValue(FakeProcessPaymentParams());
  });

  setUp(() {
    mockProcessPaymentUseCase = MockProcessPaymentUseCase();
    when(() => mockProcessPaymentUseCase(any()))
        .thenAnswer((_) async => Right(tPayment));

    if (sl.isRegistered<ProcessPaymentUseCase>()) {
      sl.unregister<ProcessPaymentUseCase>();
    }
    sl.registerLazySingleton<ProcessPaymentUseCase>(
      () => mockProcessPaymentUseCase,
    );
  });

  tearDown(() {
    if (sl.isRegistered<ProcessPaymentUseCase>()) {
      sl.unregister<ProcessPaymentUseCase>();
    }
  });

  Widget buildTestWidget({String mode = 'netbanking'}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PaymentGatewayPage(
        bill: tBill,
        initialMode: mode,
      ),
    );
  }

  group('PaymentGatewayPage Tests', () {
    testWidgets('renders in-app browser bar and e-GRAS Cyber Treasury portal', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Browser URL bar
      expect(find.text('https://gras.mahakosh.gov.in/epay/wrd/checkout'), findsOneWidget);

      // Cyber Treasury Header
      expect(find.text('GOVERNMENT OF MAHARASHTRA'), findsOneWidget);
      expect(find.text('e-GRAS Cyber Treasury Portal'), findsOneWidget);
      expect(find.text('Department of Water Resources (WRD)'), findsOneWidget);
      expect(find.text('GRN: MH-WRD-2026-89211'), findsOneWidget);

      // Modes
      expect(find.text('Net Banking'), findsOneWidget);
      expect(find.text('Debit / Kisan Card'), findsOneWidget);

      // Popular Banks
      expect(find.text('State Bank of India'), findsOneWidget);
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('ICICI Bank'), findsOneWidget);
      expect(find.text('Bank of Maharashtra'), findsOneWidget);
    });

    testWidgets('Net Banking: proceeds to SBI Login and verifies OTP flow', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Proceed to Bank Gateway
      final proceedBtn = find.text('Proceed to Bank Gateway (₹ 1,240)');
      expect(proceedBtn, findsOneWidget);
      await tester.tap(proceedBtn);
      await tester.pumpAndSettle();

      // Should be on SBI Login page
      expect(find.text('https://retail.onlinesbi.sbi/retail/login.htm'), findsOneWidget);
      expect(find.text('STATE BANK OF INDIA'), findsOneWidget);
      expect(find.text('Retail Internet Banking Portal'), findsOneWidget);
      expect(find.text('Login & Authorize'), findsOneWidget);

      // Tap Login & Authorize
      await tester.tap(find.text('Login & Authorize'));
      await tester.pumpAndSettle();

      // Should be on SBI OTP page
      expect(find.text('https://retail.onlinesbi.sbi/retail/otp_verify.htm'), findsOneWidget);
      expect(find.text('State Bank of India - High Security OTP'), findsOneWidget);
      expect(find.text('Auto-fill OTP: 839201'), findsOneWidget);

      // Tap Auto-fill OTP
      await tester.tap(find.text('Auto-fill OTP: 839201'));
      await tester.pumpAndSettle();

      // Confirm & Authorize Payment
      await tester.tap(find.text('Confirm & Authorize Payment of ₹ 1240.00'));
      await tester.pump();

      // Redirecting screen
      expect(find.text('Payment Authorization Successful!'), findsOneWidget);
      expect(find.text('https://gras.mahakosh.gov.in/epay/wrd/response'), findsOneWidget);
    });

    testWidgets('Debit / Kisan Card: switches to card tab and completes 3D Secure ACS flow', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(mode: 'card'));
      await tester.pumpAndSettle();

      expect(find.text('RuPay Kisan Card (•••• 2304)'), findsOneWidget);

      // Tap Pay Securely
      final payBtn = find.text('Pay Securely ₹ 1,240');
      expect(payBtn, findsOneWidget);
      await tester.tap(payBtn);
      await tester.pumpAndSettle();

      // Should be on RuPay 3D Secure ACS
      expect(find.text('https://acs.rupay.org.in/3dsecure/verify'), findsOneWidget);
      expect(find.text('RuPay 3D Secure Access Control Server'), findsOneWidget);
      expect(find.text('Auto-fill OTP: 629104'), findsOneWidget);

      // Auto-fill OTP and submit
      await tester.tap(find.text('Auto-fill OTP: 629104'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit OTP & Confirm'));
      await tester.pump();

      expect(find.text('Payment Authorization Successful!'), findsOneWidget);
    });

    testWidgets('cancel button prompts confirmation dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Cancel & Exit Gateway'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Payment?'), findsOneWidget);
      expect(find.text('Continue Payment'), findsOneWidget);
      expect(find.text('Cancel & Exit'), findsOneWidget);
    });
  });
}
