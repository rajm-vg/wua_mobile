import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/router/app_router.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/services/services.dart';
import 'package:wua_mobile/core/storage/secure_storage_service.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';
import 'package:wua_mobile/features/authentication/authentication.dart';
import 'package:wua_mobile/features/home/home.dart';
import 'package:wua_mobile/features/profile/profile.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockSecureStorageService mockSecureStorage;
  late MockAuthBloc mockAuthBloc;
  late bool hasToken;

  final tUser = UserEntity(
    id: 'usr_farmer_001',
    name: 'Ramesh Patil',
    email: 'farmer@wua.gov.in',
    phone: '9876543210',
    role: UserRole.farmer,
    isVerified: true,
    createdAt: DateTime(2023, 1, 15),
  );

  setUpAll(() {
    registerFallbackValue(const AuthCheckRequested());
  });

  setUp(() async {
    await sl.reset();
    hasToken = false;
    mockSecureStorage = MockSecureStorageService();
    mockAuthBloc = MockAuthBloc();

    when(() => mockSecureStorage.hasToken()).thenAnswer((_) async => hasToken);
    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(user: tUser));

    sl.registerSingleton<SecureStorageService>(mockSecureStorage);
    sl.registerFactory<AuthBloc>(() => mockAuthBloc);
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildApp(AppRouter appRouter) {
    return MaterialApp.router(
      scaffoldMessengerKey: SnackBarService.scaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          // Prevent Ahem test-font overflow inside HomePage's 600px WuaScaffold.
          data: mediaQuery.copyWith(textScaler: const TextScaler.linear(0.75)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: appRouter.router,
    );
  }

  group('AppRouter Auth Guard & Refresh', () {
    testWidgets('redirects unauthenticated splash completion to LoginPage', (
      tester,
    ) async {
      hasToken = false;
      final appRouter = AppRouter(secureStorage: mockSecureStorage);

      await tester.pumpWidget(buildApp(appRouter));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets(
      'redirects back to LoginPage when session is cleared and refresh() runs',
      (tester) async {
        hasToken = true;
        final appRouter = AppRouter(secureStorage: mockSecureStorage);

        await tester.pumpWidget(buildApp(appRouter));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);

        // Navigate to ProfilePage
        appRouter.router.goNamed(RouteNames.profile);
        await tester.pumpAndSettle();
        expect(find.byType(ProfilePage), findsOneWidget);

        // Simulate token clearance + router refresh (e.g. token expiry / logout)
        hasToken = false;
        appRouter.refresh();
        await tester.pumpAndSettle();

        expect(find.byType(LoginPage), findsOneWidget);
        expect(find.byType(ProfilePage), findsNothing);
        expect(find.byType(HomePage), findsNothing);
      },
    );

    testWidgets('redirects authenticated user from /login back to HomePage', (
      tester,
    ) async {
      hasToken = true;
      final appRouter = AppRouter(secureStorage: mockSecureStorage);

      await tester.pumpWidget(buildApp(appRouter));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      appRouter.router.goNamed(RouteNames.login);
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });
  });
}

