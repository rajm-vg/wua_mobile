import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/shared/widgets/double_swipe_to_exit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestApp({required Widget child}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets('DoubleSwipeToExit renders child correctly', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        child: const DoubleSwipeToExit(
          child: Text('Home Content'),
        ),
      ),
    );

    expect(find.text('Home Content'), findsOneWidget);
    expect(find.byType(PopScope), findsOneWidget);
  });

  testWidgets('First back press shows exit snackbar/prompt', (tester) async {
    await tester.pumpWidget(
      buildTestApp(
        child: const DoubleSwipeToExit(
          child: Text('Dashboard Screen'),
        ),
      ),
    );

    // Simulate system back gesture via dynamic PopScope invocation
    final popScopeFinder = find.byType(PopScope);
    expect(popScopeFinder, findsOneWidget);

    final popScope = tester.widget<PopScope>(popScopeFinder);
    expect(popScope.canPop, isFalse);

    // Trigger first back invocation
    popScope.onPopInvokedWithResult?.call(false, null);
    await tester.pump();

    // Verify exit prompt SnackBar is displayed
    expect(find.text('Swipe back again to exit'), findsOneWidget);
  });

  testWidgets('Second back press within duration calls SystemNavigator.pop',
      (tester) async {
    int systemPopCalls = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall methodCall) async {
        if (methodCall.method == 'SystemNavigator.pop') {
          systemPopCalls++;
        }
        return null;
      },
    );

    await tester.pumpWidget(
      buildTestApp(
        child: const DoubleSwipeToExit(
          duration: Duration(seconds: 2),
          child: Text('Dashboard Screen'),
        ),
      ),
    );

    final popScope = tester.widget<PopScope>(find.byType(PopScope));

    // First back invocation
    popScope.onPopInvokedWithResult?.call(false, null);
    await tester.pump();
    expect(systemPopCalls, 0);

    // Second back invocation immediately after
    popScope.onPopInvokedWithResult?.call(false, null);
    await tester.pump();

    // SystemNavigator.pop was called
    expect(systemPopCalls, 1);
  });
}

