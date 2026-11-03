import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/shared/widgets/main_shell.dart';

void main() {
  Widget buildTestApp(GoRouter router) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }

  bool isTabSelected(WidgetTester tester, String label) {
    final navItemFinder = find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_NavItem',
      ),
    );
    final widget = tester.widget(navItemFinder);
    return (widget as dynamic).isSelected as bool;
  }

  GoRouter createTestRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return MainShell(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) =>
                  const Scaffold(body: Text('Home Screen')),
              routes: [
                GoRoute(
                  path: 'bills',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Bills Screen')),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) => Scaffold(
                        body: Text(
                          'Bill Detail Screen ${state.pathParameters['id']}',
                        ),
                      ),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'payments',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Payments Screen')),
                ),
                GoRoute(
                  path: 'profile',
                  builder: (context, state) =>
                      const Scaffold(body: Text('Profile Screen')),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  testWidgets(
      'Nav bar correctly reflects active tab on go(), push(), and pop()',
      (tester) async {
    final router = createTestRouter();
    await tester.pumpWidget(buildTestApp(router));
    await tester.pumpAndSettle();

    // 1. Initial State -> Dashboard
    expect(find.text('Home Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Dashboard'), isTrue);
    expect(isTabSelected(tester, 'Bills'), isFalse);
    expect(isTabSelected(tester, 'Payments'), isFalse);
    expect(isTabSelected(tester, 'Profile'), isFalse);

    // 2. Go to Bills
    router.go('/bills');
    await tester.pumpAndSettle();
    expect(find.text('Bills Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Dashboard'), isFalse);
    expect(isTabSelected(tester, 'Bills'), isTrue);

    // 3. Gesture Back from Bills -> Dashboard
    final navBills = Navigator.of(tester.element(find.text('Bills Screen')));
    navBills.pop();
    await tester.pumpAndSettle();
    expect(find.text('Home Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Dashboard'), isTrue);
    expect(isTabSelected(tester, 'Bills'), isFalse);

    // 4. Go to Payments
    router.go('/payments');
    await tester.pumpAndSettle();
    expect(find.text('Payments Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Payments'), isTrue);

    // 5. Gesture Back from Payments -> Dashboard
    final navPayments =
        Navigator.of(tester.element(find.text('Payments Screen')));
    navPayments.pop();
    await tester.pumpAndSettle();
    expect(find.text('Home Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Dashboard'), isTrue);
    expect(isTabSelected(tester, 'Payments'), isFalse);

    // 6. Go to Profile
    router.go('/profile');
    await tester.pumpAndSettle();
    expect(find.text('Profile Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Profile'), isTrue);

    // 7. Gesture Back from Profile -> Dashboard
    final navProfile =
        Navigator.of(tester.element(find.text('Profile Screen')));
    navProfile.pop();
    await tester.pumpAndSettle();
    expect(find.text('Home Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Dashboard'), isTrue);
    expect(isTabSelected(tester, 'Profile'), isFalse);

    // 8. Push to Bills (simulate clicking card on Home)
    final homeContext = tester.element(find.text('Home Screen'));
    unawaited(homeContext.push('/bills'));
    await tester.pumpAndSettle();
    expect(find.text('Bills Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Bills'), isTrue);

    // 9. Gesture Back from Pushed Bills -> Dashboard
    final navPushedBills =
        Navigator.of(tester.element(find.text('Bills Screen')));
    navPushedBills.pop();
    await tester.pumpAndSettle();
    expect(find.text('Home Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Dashboard'), isTrue);
    expect(isTabSelected(tester, 'Bills'), isFalse);

    // 10. Nested route /bills/123
    router.go('/bills/123');
    await tester.pumpAndSettle();
    expect(find.text('Bill Detail Screen 123'), findsOneWidget);
    expect(isTabSelected(tester, 'Bills'), isTrue);

    // 11. Gesture Back from /bills/123 -> /bills
    final navDetail =
        Navigator.of(tester.element(find.text('Bill Detail Screen 123')));
    navDetail.pop();
    await tester.pumpAndSettle();
    expect(find.text('Bills Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Bills'), isTrue);

    // 12. Gesture Back from /bills -> Dashboard
    final navBills2 = Navigator.of(tester.element(find.text('Bills Screen')));
    navBills2.pop();
    await tester.pumpAndSettle();
    expect(find.text('Home Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Dashboard'), isTrue);
    expect(isTabSelected(tester, 'Bills'), isFalse);
  });

  testWidgets('Tapping bottom nav bar items navigates to correct routes',
      (tester) async {
    final router = createTestRouter();
    await tester.pumpWidget(buildTestApp(router));
    await tester.pumpAndSettle();

    // Tap Bills
    await tester.tap(find.text('Bills'));
    await tester.pumpAndSettle();
    expect(find.text('Bills Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Bills'), isTrue);

    // Tap Payments
    await tester.tap(find.text('Payments'));
    await tester.pumpAndSettle();
    expect(find.text('Payments Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Payments'), isTrue);

    // Tap Profile
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Profile Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Profile'), isTrue);

    // Tap Dashboard
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('Home Screen'), findsOneWidget);
    expect(isTabSelected(tester, 'Dashboard'), isTrue);
  });
}
