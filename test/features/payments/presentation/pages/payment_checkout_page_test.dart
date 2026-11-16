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
import 'package:wua_mobile/features/payments/presentation/pages/payment_checkout_page.dart';

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

  Widget buildTestWidget({ThemeMode themeMode = ThemeMode.light}) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const PaymentCheckoutPage(bill: tBill),
    );
  }

  group('PaymentCheckoutPage Widget Tests', () {
    testWidgets('renders Bill Summary and UPI payment view by default in Light Theme', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Check Bill number & season
      expect(find.text('WUA/PANI/2024/001'), findsOneWidget);
      expect(find.text('Rabi Season (2024-25)'), findsOneWidget);
      expect(find.text('₹ 1,240'), findsOneWidget);

      // Check method selector tabs
      expect(find.text('UPI'), findsOneWidget);
      expect(find.text('Net Banking'), findsOneWidget);
      expect(find.text('Cards & KCC'), findsOneWidget);

      // Check UPI sub-tabs
      expect(find.text('UPI Apps'), findsOneWidget);
      expect(find.text('UPI ID / VPA'), findsOneWidget);
      expect(find.text('Scan QR'), findsOneWidget);

      // Check popular UPI apps
      expect(find.text('Google Pay'), findsOneWidget);
      expect(find.text('PhonePe'), findsAtLeastNWidgets(1));
      expect(find.text('Paytm'), findsOneWidget);
      expect(find.text('BHIM UPI'), findsOneWidget);
    });

    testWidgets('renders properly in Dark Theme without errors', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();

      expect(find.text('Pani Patti Payment'), findsOneWidget);
      expect(find.text('WUA/PANI/2024/001'), findsOneWidget);
      expect(find.text('Google Pay'), findsOneWidget);
    });

    testWidgets('switches to Net Banking and shows popular banks', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Net Banking tab
      await tester.tap(find.text('Net Banking'));
      await tester.pumpAndSettle();

      expect(find.text('Select Popular Bank'), findsOneWidget);
      expect(find.text('State Bank of India'), findsOneWidget);
      expect(find.text('HDFC Bank'), findsOneWidget);
      expect(find.text('ICICI Bank'), findsOneWidget);
      expect(find.text('Maharashtra Gramin Bank'), findsOneWidget);
    });

    testWidgets('switches to Cards & KCC and renders Interactive Card preview', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Cards & KCC tab
      await tester.tap(find.text('Cards & KCC'));
      await tester.pumpAndSettle();

      expect(find.text('Card Details'), findsOneWidget);
      expect(find.text('Demo RuPay Kisan Card'), findsOneWidget);
      expect(find.text('Demo Visa Debit'), findsOneWidget);
      expect(find.text('RAMESH PATIL'), findsAtLeastNWidgets(1));

      // Tap Demo RuPay Kisan Card
      await tester.tap(find.text('Demo RuPay Kisan Card'));
      await tester.pumpAndSettle();

      expect(find.text('5085 0241 8920 4120'), findsAtLeastNWidgets(1));
    });

    testWidgets('switches to Scan QR sub-mode and displays countdown & QR scanner button', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Scan QR sub-tab
      await tester.tap(find.text('Scan QR'));
      await tester.pumpAndSettle();

      expect(find.text('BharatQR • WRD Maharashtra'), findsOneWidget);
      expect(find.text('VPA: maha.wrd@gov.upi'), findsOneWidget);
      expect(find.text('Simulate QR Scan & Approve ₹ 1,240'), findsOneWidget);
    });

    testWidgets('executes payment from Scan QR and shows Payment Successful view', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Scan QR sub-tab
      await tester.tap(find.text('Scan QR'));
      await tester.pumpAndSettle();

      // Tap Simulate QR Scan & Approve
      await tester.tap(find.text('Simulate QR Scan & Approve ₹ 1,240'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Should be on success view
      expect(find.text('Payment Successful!'), findsOneWidget);
      expect(find.text('REC/WUA/2026/001'), findsOneWidget);
      expect(find.text('View in Payments History'), findsOneWidget);
      expect(find.text('Back to Dashboard'), findsOneWidget);
    });
  });
}
