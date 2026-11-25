import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';
import 'package:wua_mobile/features/authentication/authentication.dart';
import 'package:wua_mobile/features/home/home.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(const AuthCheckRequested());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

    if (sl.isRegistered<AuthBloc>()) {
      sl.unregister<AuthBloc>();
    }
    sl.registerFactory<AuthBloc>(() => mockAuthBloc);
  });

  tearDown(() {
    if (sl.isRegistered<AuthBloc>()) {
      sl.unregister<AuthBloc>();
    }
  });

  Widget createWidgetUnderTest({ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const HomePage(),
      ),
    );
  }

  group('HomePage Widget Tests', () {
    testWidgets(
      'renders all redesigned dashboard components with clean empty states in light mode',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // 1. Executive Header components
        expect(find.text('N/A'), findsOneWidget);
        expect(find.text('Gat No. 142 • Mulshi WUA'), findsNothing);
        expect(find.text('En'), findsOneWidget);
        expect(find.text('मराठी'), findsOneWidget);
        expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

        // 2. Next Canal Turn • Wari Card (Clean Empty State - No fallback)
        expect(find.text('No turns match the selected filter'), findsOneWidget);

        // 3. Current Pani Patti Bill Card (Clean Empty State - No 1240 fallback)
        expect(find.text('No bills found'), findsOneWidget);
        expect(find.text('₹ 1,240'), findsNothing);

        // 4. Water Balance & Total Dues Metrics Row (Clean Empty State)
        expect(find.text('WATER BALANCE'), findsOneWidget);
        expect(find.text('0 L'), findsOneWidget);
        expect(find.text('0 L quota allocated'), findsOneWidget);
        expect(find.text('TOTAL DUES'), findsOneWidget);
        expect(find.text('₹ 0'), findsOneWidget);
        expect(find.text('All dues cleared'), findsOneWidget);

        // 5. Farmer Services 4-Column Grid
        expect(find.text('FARMER SERVICES'), findsOneWidget);
        expect(find.text('Pay Bill'), findsOneWidget);
        expect(find.text('Canal Wari'), findsOneWidget);
        expect(find.text('All Bills'), findsOneWidget);
        expect(find.text('My Farm'), findsOneWidget);

        // 6. Recent Activity Card (Clean Empty State - No fallback)
        expect(find.text('RECENT ACTIVITY'), findsOneWidget);
        expect(find.text('No payments found'), findsOneWidget);
        expect(find.text('₹ 950'), findsNothing);
      },
    );

    testWidgets('renders authenticated user name in header', (tester) async {
      final mockUser = UserEntity(
        id: 'usr_farmer_001',
        name: 'Ramesh Patil',
        email: 'farmer@wua.gov.in',
        phone: '9876543210',
        role: UserRole.farmer,
        isVerified: true,
        createdAt: DateTime(2023, 1, 15),
      );

      when(() => mockAuthBloc.state)
          .thenReturn(AuthAuthenticated(user: mockUser));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Ramesh Patil'), findsOneWidget);
      expect(find.text('N/A'), findsOneWidget);
      expect(find.text('Gat No. 142 • Mulshi WUA'), findsNothing);
    });

    testWidgets('renders real survey and village in header when present', (
      tester,
    ) async {
      final mockUser = UserEntity(
        id: 'usr_farmer_002',
        name: 'Suresh Kulkarni',
        email: 'suresh@wua.gov.in',
        phone: '9988776655',
        role: UserRole.farmer,
        isVerified: true,
        createdAt: DateTime(2024, 2, 10),
        surveyNo: '42/1A',
        village: 'Khed',
      );

      when(() => mockAuthBloc.state)
          .thenReturn(AuthAuthenticated(user: mockUser));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Suresh Kulkarni'), findsOneWidget);
      expect(find.text('Gat No. 42/1A • Khed'), findsOneWidget);
    });

    testWidgets('renders cleanly in dark mode', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(theme: AppTheme.darkTheme));
      await tester.pumpAndSettle();

      expect(find.text('No turns match the selected filter'), findsOneWidget);
      expect(find.text('No bills found'), findsOneWidget);
      expect(find.text('FARMER SERVICES'), findsOneWidget);
      expect(find.text('WATER BALANCE'), findsOneWidget);
      expect(find.text('TOTAL DUES'), findsOneWidget);
    });
  });
}
