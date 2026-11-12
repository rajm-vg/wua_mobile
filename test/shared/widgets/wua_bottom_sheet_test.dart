import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:wua_mobile/shared/widgets/main_shell.dart';
import 'package:wua_mobile/shared/widgets/wua_bottom_sheet.dart';

void main() {
  testWidgets(
    'showWuaBottomSheet renders above MainShell nav bar so bottom actions remain clickable',
    (tester) async {
      var sheetActionPressed = false;
      var navBarTapped = false;

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showWuaBottomSheet<void>(
                          context: context,
                          builder: (sheetCtx) => Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 120),
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      sheetActionPressed = true;
                                      Navigator.of(sheetCtx).pop();
                                    },
                                    child: const Text('Submit Sheet Action'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Text('Open Sheet'),
                    ),
                  ),
                ),
              ),
              GoRoute(
                path: '/bills',
                builder: (context, state) {
                  navBarTapped = true;
                  return const Scaffold(body: Text('Bills'));
                },
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Sheet button sits over the bottom area where MainShell nav bar lives;
      // because useRootNavigator is true, tapping it triggers the sheet action,
      // not the underlying nav bar.
      await tester.tap(find.text('Submit Sheet Action'));
      await tester.pumpAndSettle();

      expect(sheetActionPressed, isTrue);
      expect(navBarTapped, isFalse);
      expect(find.text('Submit Sheet Action'), findsNothing);
    },
  );
}

