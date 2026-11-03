import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';

void main() {
  Widget buildTestApp({required Widget body}) {
    return MaterialApp(
      scaffoldMessengerKey: SnackBarService.scaffoldMessengerKey,
      home: Scaffold(body: body),
    );
  }

  group('SnackBarService Tests', () {
    testWidgets('shows Success snackbar with title, message and icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                SnackBarService.showSuccess(
                  'Operation succeeded',
                  title: 'Success Title',
                  context: context,
                );
              },
              child: const Text('Show Success'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Success Title'), findsOneWidget);
      expect(find.text('Operation succeeded'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('shows Error snackbar with error icon', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                context.showErrorSnackBar('Something went wrong');
              },
              child: const Text('Show Error'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Error'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('shows Warning snackbar with warning icon', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                context.showWarningSnackBar('Payment overdue soon');
              },
              child: const Text('Show Warning'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Warning'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Payment overdue soon'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('shows Info snackbar with custom bottom offset', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                context.showInfoSnackBar(
                  'Canal turn scheduled',
                  bottomOffset: 86.0,
                );
              },
              child: const Text('Show Info'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Info'));
      await tester.pump();

      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);
      expect(find.text('Canal turn scheduled'), findsOneWidget);

      final snackBar = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBar.margin, const EdgeInsets.fromLTRB(16, 0, 16, 86.0));
    });

    testWidgets('works context-less via SnackBarService.scaffoldMessengerKey', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(body: const Text('Context-less Test View')),
      );

      // Trigger without any BuildContext
      SnackBarService.showSuccess('Context-less notification');
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Context-less notification'), findsOneWidget);
    });

    testWidgets('action button invokes callback and closes snackbar', (
      tester,
    ) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        buildTestApp(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                SnackBarService.show(
                  message: 'Item removed',
                  actionLabel: 'UNDO',
                  onAction: () {
                    actionTapped = true;
                  },
                  context: context,
                );
              },
              child: const Text('Trigger Action'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger Action'));
      await tester.pump();

      expect(find.text('UNDO'), findsOneWidget);
      await tester.tap(find.text('UNDO'));
      await tester.pump();

      expect(actionTapped, isTrue);
    });

    testWidgets('hideSnackBar dismisses visible snackbar', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          body: Builder(
            builder: (context) => Column(
              children: [
                ElevatedButton(
                  onPressed: () => context.showInfoSnackBar('Active Message'),
                  child: const Text('Show'),
                ),
                ElevatedButton(
                  onPressed: () => context.hideSnackBar(),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);

      await tester.tap(find.text('Dismiss'));
      await tester.pump();
      expect(find.text('Active Message'), findsNothing);
    });
  });
}
