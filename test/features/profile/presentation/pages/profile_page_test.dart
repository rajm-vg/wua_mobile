import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/router/route_names.dart';
import 'package:wua_mobile/core/services/services.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';
import 'package:wua_mobile/features/authentication/authentication.dart';
import 'package:wua_mobile/features/profile/profile.dart';
import 'package:wua_mobile/shared/widgets/main_shell.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late StreamController<AuthState> authStateController;
  late bool isLoggedIn;

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
    registerFallbackValue(const AuthLogoutRequested());
  });

  setUp(() async {
    await sl.reset();
    isLoggedIn = true;
    mockAuthBloc = MockAuthBloc();
    authStateController = StreamController<AuthState>.broadcast();

    when(() => mockAuthBloc.state).thenReturn(AuthAuthenticated(user: tUser));
    whenListen(
      mockAuthBloc,
      authStateController.stream,
      initialState: AuthAuthenticated(user: tUser),
    );

    sl.registerFactory<AuthBloc>(() => mockAuthBloc);
  });

  tearDown(() async {
    await authStateController.close();
    await sl.reset();
  });

  GoRouter createRouter() {
    return GoRouter(
      initialLocation: '/profile',
      redirect: (context, state) {
        final isAuthRoute = state.matchedLocation == '/login';
        if (!isLoggedIn && !isAuthRoute) {
          return '/login';
        }
        if (isLoggedIn && isAuthRoute) {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('Login Screen')),
          ),
        ),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              name: RouteNames.home,
              builder: (context, state) => const Scaffold(
                body: Center(child: Text('Dashboard Screen')),
              ),
              routes: [
                GoRoute(
                  path: 'profile',
                  name: RouteNames.profile,
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildApp(GoRouter router) {
    return MaterialApp.router(
      scaffoldMessengerKey: SnackBarService.scaffoldMessengerKey,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      routerConfig: router,
    );
  }

  group('ProfilePage Logout Flow', () {
    testWidgets(
      'navigates to login (not dashboard) only after logout clears session',
      (tester) async {
        final router = createRouter();
        await tester.pumpWidget(buildApp(router));
        await tester.pumpAndSettle();

        expect(find.text('Ramesh Patil'), findsOneWidget);

        // Open logout dialog
        final logoutTile = find.text('Logout');
        await tester.ensureVisible(logoutTile);
        await tester.tap(logoutTile);
        await tester.pumpAndSettle();

        expect(
          find.text('Are you sure you want to log out of your WUA account?'),
          findsOneWidget,
        );

        // Confirm logout in dialog
        final confirmButton = find.widgetWithText(ElevatedButton, 'Logout');
        await tester.tap(confirmButton);
        await tester.pump();

        verify(() => mockAuthBloc.add(const AuthLogoutRequested())).called(1);

        // Simulate async logout in progress (token still exists while API runs)
        when(() => mockAuthBloc.state).thenReturn(const AuthLoading());
        authStateController.add(const AuthLoading());
        await tester.pump();

        // Should show loading in dialog and NOT bounce to Dashboard
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Dashboard Screen'), findsNothing);
        expect(find.text('Login Screen'), findsNothing);

        // Simulate logout completion: token cleared -> AuthUnauthenticated
        isLoggedIn = false;
        when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
        authStateController.add(const AuthUnauthenticated());
        await tester.pumpAndSettle();

        // Must land on Login Screen and NOT stay on Dashboard
        expect(find.text('Login Screen'), findsOneWidget);
        expect(find.text('Dashboard Screen'), findsNothing);
        expect(find.text('Ramesh Patil'), findsNothing);
      },
    );

    testWidgets('cancelling logout dialog stays on ProfilePage', (
      tester,
    ) async {
      final router = createRouter();
      await tester.pumpWidget(buildApp(router));
      await tester.pumpAndSettle();

      final logoutTile = find.text('Logout');
      await tester.ensureVisible(logoutTile);
      await tester.tap(logoutTile);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockAuthBloc.add(const AuthLogoutRequested()));
      expect(find.text('Ramesh Patil'), findsOneWidget);
      expect(find.text('Login Screen'), findsNothing);
    });

    testWidgets('shows error snackbar and stays on ProfilePage if logout fails', (
      tester,
    ) async {
      final router = createRouter();
      await tester.pumpWidget(buildApp(router));
      await tester.pumpAndSettle();

      final logoutTile = find.text('Logout');
      await tester.ensureVisible(logoutTile);
      await tester.tap(logoutTile);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
      await tester.pump();

      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());
      authStateController.add(const AuthLoading());
      await tester.pump();

      const failure = AuthFailure(message: 'Failed to clear session');
      when(() => mockAuthBloc.state).thenReturn(failure);
      authStateController.add(failure);
      await tester.pumpAndSettle();

      expect(find.text('Failed to clear session'), findsOneWidget);
      expect(find.text('Ramesh Patil'), findsOneWidget);
      expect(find.text('Login Screen'), findsNothing);
    });
  });
}

