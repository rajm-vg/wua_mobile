import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';
import 'package:wua_mobile/shared/widgets/language_toggle.dart';

void main() {
  group('LanguageToggle Widget Tests', () {
    testWidgets('renders default labels En and MR', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            body: Center(
              child: LanguageToggle(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('En'), findsOneWidget);
      expect(find.text('MR'), findsOneWidget);
    });

    testWidgets('renders custom labels and triggers onChanged callback', (
      tester,
    ) async {
      bool? isSecondSelected;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: LanguageToggle(
                firstLabel: 'English',
                secondLabel: 'मराठी',
                isSecondActive: false,
                onChanged: (selected) {
                  isSecondSelected = selected;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('English'), findsOneWidget);
      expect(find.text('मराठी'), findsOneWidget);

      await tester.tap(find.text('मराठी'));
      await tester.pumpAndSettle();

      expect(isSecondSelected, isTrue);
    });

    testWidgets('toggles appLocaleNotifier to mr and en when tapped', (
      tester,
    ) async {
      appLocaleNotifier.value = const Locale('en');

      await tester.pumpWidget(
        ValueListenableBuilder<Locale?>(
          valueListenable: appLocaleNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              theme: AppTheme.lightTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: locale,
              home: const Scaffold(
                body: Center(
                  child: LanguageToggle(
                    firstLabel: 'En',
                    secondLabel: 'MR',
                  ),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('En'), findsOneWidget);
      expect(find.text('MR'), findsOneWidget);

      // Tap second language (MR -> Marathi)
      await tester.tap(find.text('MR'));
      await tester.pumpAndSettle();

      expect(appLocaleNotifier.value?.languageCode, 'mr');

      // Tap first language (En -> English)
      await tester.tap(find.text('En'));
      await tester.pumpAndSettle();

      expect(appLocaleNotifier.value?.languageCode, 'en');
    });

    testWidgets('renders LanguageToggle.header and LanguageToggle.standard presets', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Column(
              children: [
                LanguageToggle.header(),
                LanguageToggle.standard(),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('En'), findsNWidgets(2));
      expect(find.text('MR'), findsOneWidget);
      expect(find.text('मराठी'), findsOneWidget);
    });
  });
}
