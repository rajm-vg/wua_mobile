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
    testWidgets('renders all redesigned dashboard components in light mode', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // 1. Executive Header components
      expect(find.text('Gat No. 142 • Mulshi WUA'), findsOneWidget);
      expect(find.text('En'), findsOneWidget);
      expect(find.text('MR'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // 2. Next Canal Turn • Wari Card
      expect(find.text('NEXT CANAL TURN • WARI'), findsOneWidget);
      expect(find.text('In 2 Days'), findsOneWidget);
      expect(find.text('Thursday, 31 Oct'), findsOneWidget);
      expect(find.text('Timeline →'), findsOneWidget);
      expect(find.text('08:00 AM – 08:00 PM (12 Hours)'), findsOneWidget);
      expect(find.text('Gate #4'), findsOneWidget);
      expect(find.text('Outlet No. 12 • 50 Cusecs Flow'), findsOneWidget);

      // 3. Current Pani Patti Bill Card
      expect(find.text('CURRENT PANI PATTI BILL'), findsOneWidget);
      expect(find.text('Rabi Season (2024-25)'), findsOneWidget);
      expect(find.text('Due 25 Nov'), findsOneWidget);
      expect(find.text('₹ 1,240'), findsWidgets); // Appears in Bill & Dues cards
      expect(find.text('Pay via UPI →'), findsOneWidget);
      expect(find.text('18,500 L water for 4.5 Acres land'), findsOneWidget);
      expect(find.text('Base Water'), findsOneWidget);
      expect(find.text('Govt Cess & Tax'), findsOneWidget);
      expect(find.text('WUA Maintenance'), findsOneWidget);

      // 4. Water Balance & Total Dues Metrics Row
      expect(find.text('WATER BALANCE'), findsOneWidget);
      expect(find.text('5,000 L'), findsOneWidget);
      expect(find.text('79% used of 23,500 L'), findsOneWidget);
      expect(find.text('TOTAL DUES'), findsOneWidget);
      expect(find.text('No late surcharge yet'), findsOneWidget);

      // 5. Farmer Services 4-Column Grid
      expect(find.text('FARMER SERVICES'), findsOneWidget);
      expect(find.text('Pay Bill'), findsOneWidget);
      expect(find.text('Canal Wari'), findsOneWidget);
      expect(find.text('All Bills'), findsOneWidget);
      expect(find.text('My Farm'), findsOneWidget);

      // 6. Recent Activity Card
      expect(find.text('RECENT ACTIVITY'), findsOneWidget);
      expect(find.text('Kharif Season 2024 Payment'), findsOneWidget);
      expect(find.text('₹ 950'), findsOneWidget);
    });

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
      expect(find.text('Gat No. 142 • Mulshi WUA'), findsOneWidget);
    });

    testWidgets('renders cleanly in dark mode', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(theme: AppTheme.darkTheme));
      await tester.pumpAndSettle();

      expect(find.text('NEXT CANAL TURN • WARI'), findsOneWidget);
      expect(find.text('FARMER SERVICES'), findsOneWidget);
      expect(find.text('WATER BALANCE'), findsOneWidget);
    });
  });
}
