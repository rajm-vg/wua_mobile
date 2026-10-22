import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';
import 'package:wua_mobile/features/authentication/authentication.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(
      const AuthLoginRequested(identifier: '', password: ''),
    );
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

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('renders all critical login UI components', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Brand Header elements
      expect(find.text('GOVERNMENT OF WATER RESOURCES'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(
        find.text('Access your irrigation services & water governance portal'),
        findsOneWidget,
      );

      // Form Fields
      expect(find.byKey(const Key('login_identifier_field')), findsOneWidget);
      expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      expect(find.byKey(const Key('remember_me_checkbox')), findsOneWidget);
      expect(find.byKey(const Key('forgot_password_button')), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);

      // Support & Demo UI
      expect(find.text('QUICK ROLE DEMO'), findsOneWidget);
      expect(find.text('Farmer'), findsOneWidget);
      expect(find.text('WUA Official'), findsOneWidget);
      expect(find.text('Department Officer'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
      expect(
        find.text('Kisan Helpline (Toll Free): 1800-180-1551'),
        findsOneWidget,
      );
    });

    testWidgets('shows validation errors when submitting empty form', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const Key('login_submit_button'));
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(
        find.text('Please enter your mobile number or email.'),
        findsOneWidget,
      );
      expect(find.text('Password is required.'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('toggles password obscure text state', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final toggleBtn = find.byKey(const Key('toggle_password_visibility'));
      expect(toggleBtn, findsOneWidget);

      // Enter password
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'MySecret123',
      );
      await tester.pumpAndSettle();

      // Toggle visibility
      await tester.tap(toggleBtn);
      await tester.pumpAndSettle();

      // Tap toggle again
      await tester.tap(toggleBtn);
      await tester.pumpAndSettle();
    });

    testWidgets('populates fields when tapping quick role demo chip', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap Farmer demo chip
      await tester.tap(find.text('Farmer'));
      await tester.pumpAndSettle();

      expect(find.text('9876543210'), findsOneWidget);
      expect(find.text('Farmer@123'), findsOneWidget);
    });

    testWidgets('dispatches AuthLoginRequested with valid credentials', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login_identifier_field')),
        '9876543210',
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'SecurePass123',
      );
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const Key('login_submit_button'));
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      verify(
        () => mockAuthBloc.add(
          const AuthLoginRequested(
            identifier: '9876543210',
            password: 'SecurePass123',
          ),
        ),
      ).called(1);
    });

    testWidgets('displays loading indicator when state is AuthLoading', (
      tester,
    ) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays SnackBar when AuthFailure is emitted', (tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          const AuthFailure(message: 'Invalid mobile number or password'),
        ]),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Invalid mobile number or password'),
        findsOneWidget,
      );
    });
  });
}
