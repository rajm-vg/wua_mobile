import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../logger/app_logger.dart';
import '../storage/secure_storage_service.dart';
import 'route_names.dart';

/// Application router configuration using go_router.
///
/// Features:
/// - Auth-guarded routes via [redirect]
/// - Named routes for type-safe navigation
/// - Deep link ready
/// - Centralized navigation logging
class AppRouter {
  AppRouter({required this._secureStorage});
  final SecureStorageService _secureStorage;

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: _guard,
    routes: [
      // ─── Splash / Onboarding ────────────────────────────────
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (context, state) => const _PlaceholderPage(title: 'Splash'),
      ),
      GoRoute(
        path: '/onboarding',
        name: RouteNames.onboarding,
        builder: (context, state) =>
            const _PlaceholderPage(title: 'Onboarding'),
      ),

      // ─── Auth Routes ───────────────────────────────────────
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const _PlaceholderPage(title: 'Login'),
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) => const _PlaceholderPage(title: 'Register'),
      ),
      GoRoute(
        path: '/forgot-password',
        name: RouteNames.forgotPassword,
        builder: (context, state) =>
            const _PlaceholderPage(title: 'Forgot Password'),
      ),

      // ─── Main Shell (authenticated) ────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          // TODO: Replace with MainShell / ScaffoldWithNavBar
          return child;
        },
        routes: [
          GoRoute(
            path: '/',
            name: RouteNames.home,
            builder: (context, state) => const _PlaceholderPage(title: 'Home'),
            routes: [
              // Profile
              GoRoute(
                path: 'profile',
                name: RouteNames.profile,
                builder: (context, state) =>
                    const _PlaceholderPage(title: 'Profile'),
              ),

              // Bills
              GoRoute(
                path: 'bills',
                name: RouteNames.bills,
                builder: (context, state) =>
                    const _PlaceholderPage(title: 'Bills'),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: RouteNames.billDetail,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return _PlaceholderPage(title: 'Bill $id');
                    },
                  ),
                ],
              ),

              // Payments
              GoRoute(
                path: 'payments',
                name: RouteNames.payments,
                builder: (context, state) =>
                    const _PlaceholderPage(title: 'Payments'),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: RouteNames.paymentDetail,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return _PlaceholderPage(title: 'Payment $id');
                    },
                  ),
                ],
              ),

              // Transactions
              GoRoute(
                path: 'transactions',
                name: RouteNames.transactions,
                builder: (context, state) =>
                    const _PlaceholderPage(title: 'Transactions'),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: RouteNames.transactionDetail,
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return _PlaceholderPage(title: 'Transaction $id');
                    },
                  ),
                ],
              ),

              // Notifications
              GoRoute(
                path: 'notifications',
                name: RouteNames.notifications,
                builder: (context, state) =>
                    const _PlaceholderPage(title: 'Notifications'),
              ),

              // Water Usage
              GoRoute(
                path: 'water-usage',
                name: RouteNames.waterUsage,
                builder: (context, state) =>
                    const _PlaceholderPage(title: 'Water Usage'),
              ),

              // Settings
              GoRoute(
                path: 'settings',
                name: RouteNames.settings,
                builder: (context, state) =>
                    const _PlaceholderPage(title: 'Settings'),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        _PlaceholderPage(title: '404 – ${state.uri}'),
  );

  /// Route guard: redirects unauthenticated users to login.
  Future<String?> _guard(BuildContext context, GoRouterState state) async {
    final isLoggedIn = await _secureStorage.hasToken();
    final isAuthRoute =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register' ||
        state.matchedLocation == '/forgot-password' ||
        state.matchedLocation == '/splash' ||
        state.matchedLocation == '/onboarding';

    AppLogger.navigation(
      'Guard: path=${state.matchedLocation}, isLoggedIn=$isLoggedIn',
    );

    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }

    if (isLoggedIn && isAuthRoute && state.matchedLocation != '/splash') {
      return '/';
    }

    return null;
  }
}

/// Temporary placeholder used during architecture setup.
/// Each feature module will replace these with real pages.
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
