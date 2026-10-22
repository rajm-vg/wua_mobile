import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';
import 'package:wua_mobile/shared/widgets/widgets.dart';

void main() {
  Widget createWidgetUnderTest({required Widget child, ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: child,
    );
  }

  group('WuaScaffold Widget Tests', () {
    testWidgets('renders title, subtitle, and body content', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: const WuaScaffold(
            title: 'Water Quota',
            subtitle: 'Rabi Season',
            body: Text('Current Quota: 14.2 ha-cm'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Water Quota'), findsOneWidget);
      expect(find.text('Rabi Season'), findsOneWidget);
      expect(find.text('Current Quota: 14.2 ha-cm'), findsOneWidget);
    });

    testWidgets('renders scrollable body when scrollable is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: const WuaScaffold(
            title: 'Scrollable Screen',
            scrollable: true,
            body: Column(
              children: [
                Text('Top Element'),
                SizedBox(height: 100),
                Text('Bottom Element'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Top Element'), findsOneWidget);
      expect(find.text('Bottom Element'), findsOneWidget);
    });

    testWidgets('renders loading overlay when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: const WuaScaffold(
            title: 'Loading State',
            isLoading: true,
            body: Text('Background Content'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AppLoadingOverlay), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state and triggers onRetry', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        createWidgetUnderTest(
          child: WuaScaffold(
            title: 'Error Screen',
            errorMessage: 'Network connection failed.',
            onRetry: () => retried = true,
            body: const Text('Hidden Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Network connection failed.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Hidden Content'), findsNothing);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retried, isTrue);
    });

    testWidgets('renders empty state when isEmpty is true', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          child: const WuaScaffold(
            title: 'Empty Screen',
            isEmpty: true,
            emptyMessage: 'No irrigation turns scheduled.',
            body: Text('Hidden Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No irrigation turns scheduled.'), findsOneWidget);
      expect(find.text('Hidden Content'), findsNothing);
    });

    testWidgets('renders cleanly in dark theme', (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          theme: AppTheme.darkTheme,
          child: const WuaScaffold(
            title: 'Dark Mode Test',
            body: Text('Dark Body Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dark Mode Test'), findsOneWidget);
      expect(find.text('Dark Body Content'), findsOneWidget);
    });
  });
}
