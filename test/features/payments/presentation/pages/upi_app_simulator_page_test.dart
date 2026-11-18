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
import 'package:wua_mobile/features/payments/presentation/pages/upi_app_simulator_page.dart';

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

  Widget buildTestWidget({
    String appName = 'Google Pay',
    ThemeMode themeMode = ThemeMode.light,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: UpiAppSimulatorPage(
        bill: tBill,
        appName: appName,
      ),
    );
  }

  group('UpiAppSimulatorPage Tests', () {
    testWidgets('renders external UPI app screen with merchant, amount and account', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(appName: 'Google Pay'));
      await tester.pumpAndSettle();

      expect(find.text('Google Pay (Mock) ▾'), findsOneWidget);
      expect(find.text('Water Resources Dept (WRD)'), findsOneWidget);
      expect(find.text('Govt of Maharashtra • billdesk.wrd@sbi'), findsOneWidget);
      expect(find.text('₹ 1,240'), findsOneWidget);
      expect(find.text('State Bank of India'), findsOneWidget);
      expect(find.text('Savings A/C •••• 4821'), findsOneWidget);
      expect(find.text('Proceed to Pay ₹ 1,240'), findsOneWidget);
    });

    testWidgets('renders with PhonePe branding when selected', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget(appName: 'PhonePe'));
      await tester.pumpAndSettle();

      expect(find.text('PhonePe (Mock) ▾'), findsOneWidget);
      expect(find.text('Water Resources Dept (WRD)'), findsOneWidget);
    });

    testWidgets('transitions to dark NPCI UPI PIN keypad when proceed is pressed', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Proceed to Pay ₹ 1,240'));
      await tester.pumpAndSettle();

      expect(find.text('NATIONAL PAYMENTS CORPORATION OF INDIA'), findsOneWidget);
      expect(find.text('UPI SECURE PIN INTERFACE'), findsOneWidget);
      expect(find.text('ENTER 4-DIGIT UPI PIN'), findsOneWidget);
      expect(find.text('Auto-fill Demo PIN: 1234'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('completes payment when Auto-fill PIN is tapped and reaches success', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Proceed to Pay ₹ 1,240'));
      await tester.pumpAndSettle();

      // Tap auto-fill PIN
      await tester.tap(find.text('Auto-fill Demo PIN: 1234'));
      await tester.pump(); // moves to processing

      expect(find.text('Processing payment with your bank...'), findsOneWidget);

      // Advance delay
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Paid to Water Resources Dept (WRD)'), findsOneWidget);
      expect(find.text('Done • View Official Receipt'), findsOneWidget);
      expect(find.text('Debited From'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog on cancel press', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel UPI Payment?'), findsOneWidget);
      expect(find.text('Stay'), findsOneWidget);
      expect(find.text('Exit to App'), findsOneWidget);
    });
  });
}
