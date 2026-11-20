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
      const AuthRegisterRequested(
        name: '',
        email: '',
        phone: '',
        password: '',
      ),
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
        child: const RegisterPage(),
      ),
    );
  }

  group('RegisterPage Widget Tests', () {
    testWidgets('renders all critical registration UI components',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Brand Header elements
      expect(find.text('GOVERNMENT OF WATER RESOURCES'), findsOneWidget);

      // Form Title
      expect(find.text('Create Member Account'), findsOneWidget);

      // Form Fields
      expect(find.byKey(const Key('register_name_field')), findsOneWidget);
      expect(find.byKey(const Key('register_phone_field')), findsOneWidget);
      expect(find.byKey(const Key('register_email_field')), findsOneWidget);
      expect(find.byKey(const Key('register_password_field')), findsOneWidget);
      expect(
        find.byKey(const Key('register_confirm_password_field')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('register_terms_checkbox')), findsOneWidget);
      expect(find.byKey(const Key('register_submit_button')), findsOneWidget);

      // Helpers and navigation
      expect(find.byKey(const Key('register_quick_fill_chip')), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.byKey(const Key('login_nav_button')), findsOneWidget);
      expect(
        find.text('Kisan Helpline (Toll Free): 1800-180-1551'),
        findsOneWidget,
      );
    });

    testWidgets('shows validation errors when submitting empty form',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const Key('register_submit_button'));
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name.'), findsOneWidget);
      expect(
        find.text('Please enter your 10-digit mobile number.'),
        findsOneWidget,
      );
      expect(find.text('Password is required.'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('register_name_field')),
        'Ramesh Patil',
      );
      await tester.enterText(
        find.byKey(const Key('register_phone_field')),
        '9876543210',
      );
      await tester.enterText(
        find.byKey(const Key('register_password_field')),
        'Farmer@123',
      );
      await tester.enterText(
        find.byKey(const Key('register_confirm_password_field')),
        'DifferentPass@123',
      );
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const Key('register_submit_button'));
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match.'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('populates fields when tapping quick fill demo chip',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('register_quick_fill_chip')));
      await tester.pumpAndSettle();

      expect(
        find.text('आनंद रामदास पाटील (Anand Patil)'),
        findsOneWidget,
      );
      expect(find.text('9822334455'), findsOneWidget);
      expect(find.text('anand.patil@wua.gov.in'), findsOneWidget);
    });

    testWidgets('dispatches AuthRegisterRequested with valid details',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('register_name_field')),
        'Ramesh Patil',
      );
      await tester.enterText(
        find.byKey(const Key('register_phone_field')),
        '9876543210',
      );
      await tester.enterText(
        find.byKey(const Key('register_email_field')),
        'ramesh@wua.gov.in',
      );
      await tester.enterText(
        find.byKey(const Key('register_password_field')),
        'Farmer@123',
      );
      await tester.enterText(
        find.byKey(const Key('register_confirm_password_field')),
        'Farmer@123',
      );
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const Key('register_submit_button'));
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      verify(
        () => mockAuthBloc.add(
          const AuthRegisterRequested(
            name: 'Ramesh Patil',
            email: 'ramesh@wua.gov.in',
            phone: '9876543210',
            password: 'Farmer@123',
          ),
        ),
      ).called(1);
    });

    testWidgets('displays loading indicator when state is AuthLoading',
        (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays SnackBar when AuthFailure is emitted',
        (tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([
          const AuthFailure(message: 'Phone number already registered'),
        ]),
        initialState: const AuthInitial(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Phone number already registered'),
        findsOneWidget,
      );
    });
  });
}
