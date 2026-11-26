import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';
import 'package:wua_mobile/features/bills/domain/entities/bill_entity.dart';
import 'package:wua_mobile/features/payments/data/datasources/easebuzz_sdk_service.dart';
import 'package:wua_mobile/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:wua_mobile/features/payments/data/models/easebuzz_order_model.dart';
import 'package:wua_mobile/features/payments/data/models/easebuzz_verify_model.dart';
import 'package:wua_mobile/features/payments/domain/usecases/process_payment_usecase.dart';
import 'package:wua_mobile/features/payments/presentation/pages/payment_checkout_page.dart';

class MockProcessPaymentUseCase extends Mock implements ProcessPaymentUseCase {}

class MockPaymentRemoteDataSource extends Mock
    implements PaymentRemoteDataSource {}

class MockEasebuzzSdkService extends Mock implements EasebuzzSdkService {}

class FakeProcessPaymentParams extends Fake implements ProcessPaymentParams {}

class FakeEasebuzzOrderRequest extends Fake implements EasebuzzOrderRequest {}

class FakeEasebuzzVerifyRequest extends Fake implements EasebuzzVerifyRequest {}

void main() {
  late MockProcessPaymentUseCase mockProcessPaymentUseCase;
  late MockPaymentRemoteDataSource mockRemoteDataSource;
  late MockEasebuzzSdkService mockEasebuzzService;

  const tBill = BillEntity(
    id: '105',
    billNumber: 'WUA/PANI/2024/105',
    status: BillStatus.pending,
    totalAmount: 1240.0,
    outstandingAmount: 1240.0,
    consumerName: 'Ramesh Patil',
    wuaSocietyName: 'Ganga-Godavari WUA #12',
    season: 'Rabi Season (2024-25)',
    cropType: 'Wheat',
  );

  setUpAll(() {
    registerFallbackValue(FakeProcessPaymentParams());
    registerFallbackValue(FakeEasebuzzOrderRequest());
    registerFallbackValue(FakeEasebuzzVerifyRequest());
  });

  setUp(() {
    mockProcessPaymentUseCase = MockProcessPaymentUseCase();
    mockRemoteDataSource = MockPaymentRemoteDataSource();
    mockEasebuzzService = MockEasebuzzSdkService();

    if (sl.isRegistered<ProcessPaymentUseCase>()) {
      sl.unregister<ProcessPaymentUseCase>();
    }
    sl.registerLazySingleton<ProcessPaymentUseCase>(
      () => mockProcessPaymentUseCase,
    );

    if (sl.isRegistered<PaymentRemoteDataSource>()) {
      sl.unregister<PaymentRemoteDataSource>();
    }
    sl.registerLazySingleton<PaymentRemoteDataSource>(
      () => mockRemoteDataSource,
    );

    if (sl.isRegistered<EasebuzzSdkService>()) {
      sl.unregister<EasebuzzSdkService>();
    }
    sl.registerLazySingleton<EasebuzzSdkService>(
      () => mockEasebuzzService,
    );
  });

  tearDown(() {
    if (sl.isRegistered<ProcessPaymentUseCase>()) {
      sl.unregister<ProcessPaymentUseCase>();
    }
    if (sl.isRegistered<PaymentRemoteDataSource>()) {
      sl.unregister<PaymentRemoteDataSource>();
    }
    if (sl.isRegistered<EasebuzzSdkService>()) {
      sl.unregister<EasebuzzSdkService>();
    }
  });

  Widget buildTestWidget({
    ThemeMode themeMode = ThemeMode.light,
    bool autoLaunch = false,
  }) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PaymentCheckoutPage(bill: tBill, autoLaunch: autoLaunch),
    );
  }

  group('PaymentCheckoutPage Widget Tests', () {
    testWidgets(
      'renders Bill Summary and direct Easebuzz CTA in Light Theme',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('WUA/PANI/2024/105'), findsOneWidget);
        expect(find.text('Rabi Season (2024-25)'), findsOneWidget);
        expect(find.text('₹ 1,240'), findsOneWidget);
        expect(find.text('Payment Amount (Partial / Full)'), findsOneWidget);
        expect(find.text('Pay ₹ 1,240 via Easebuzz'), findsOneWidget);
        expect(find.text('UPI'), findsNothing);

        await tester.tap(find.text('₹ 500'));
        await tester.pumpAndSettle();
        expect(find.text('Pay ₹ 500 via Easebuzz'), findsOneWidget);
        expect(find.text('Net Banking'), findsNothing);
        expect(find.text('Cards & KCC'), findsNothing);
      },
    );

    testWidgets(
      'renders properly in Dark Theme without errors',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
        await tester.pumpAndSettle();

        expect(find.text('Pani Patti Payment'), findsOneWidget);
        expect(find.text('WUA/PANI/2024/105'), findsOneWidget);
        expect(find.text('Pay ₹ 1,240 via Easebuzz'), findsOneWidget);
      },
    );

    testWidgets(
      'auto-launches Easebuzz SDK and shows Payment Successful on completion',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        when(() => mockRemoteDataSource.createPaymentOrder(any())).thenAnswer(
          (_) async => const EasebuzzOrderResponse(
            transactionId: 'TXN_EASE_105',
            orderId: 'ORD_EASE_105',
            amount: 1240.0,
            currency: 'INR',
            accessKey: 'accessKey105',
          ),
        );
        when(
          () => mockEasebuzzService.payWithEasebuzz(
            accessKey: 'accessKey105',
            payMode: any(named: 'payMode'),
          ),
        ).thenAnswer(
          (_) async => EasebuzzSdkResult.success(
            rawResponse: '{"status":"success"}',
            paymentResponse: const {
              'txnid': 'TXN_EASE_105',
              'easepayid': 'EP_105',
              'amount': '1240.0',
              'hash': 'sig_105',
            },
          ),
        );
        when(() => mockRemoteDataSource.verifyPaymentOrder(any())).thenAnswer(
          (_) async => const EasebuzzVerifyResponse(
            verified: true,
            transactionId: 'TXN_EASE_105',
            paymentId: 'EP_105',
            status: 'SUCCESS',
          ),
        );
        when(
          () => mockRemoteDataSource.postReceiptEntry(
            amount: any(named: 'amount'),
            transactionRefNo: any(named: 'transactionRefNo'),
            farmerMemberId: any(named: 'farmerMemberId'),
            societyId: any(named: 'societyId'),
            fiscalYear: any(named: 'fiscalYear'),
            season: any(named: 'season'),
            remarks: any(named: 'remarks'),
          ),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(buildTestWidget(autoLaunch: true));
        await tester.pumpAndSettle();

        expect(find.text('Payment Successful!'), findsOneWidget);
        expect(find.text('TXN_EASE_105'), findsAtLeastNWidgets(1));
      },
    );
  });
}
