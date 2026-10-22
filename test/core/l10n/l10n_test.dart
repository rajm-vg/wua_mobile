import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';

void main() {
  group('Localization and context.l10n extension', () {
    testWidgets('renders English strings by default', (tester) async {
      late String welcomeText;
      late String payNowText;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              welcomeText = context.l10n.welcome;
              payNowText = context.l10n.payNow;
              return Scaffold(
                body: Text(context.l10n.appTitle),
              );
            },
          ),
        ),
      );

      expect(find.text('WUA Mobile'), findsOneWidget);
      expect(welcomeText, 'Welcome to Water User Association');
      expect(payNowText, 'Pay Now');
    });

    testWidgets('renders Hindi strings when Hindi locale is active', (tester) async {
      late String welcomeText;
      late String payNowText;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('hi'),
          home: Builder(
            builder: (context) {
              welcomeText = context.l10n.welcome;
              payNowText = context.l10n.payNow;
              return Scaffold(
                body: Text(context.l10n.appTitle),
              );
            },
          ),
        ),
      );

      expect(find.text('जल उपभोक्ता संस्था'), findsOneWidget);
      expect(welcomeText, 'जल उपभोक्ता संस्था में आपका स्वागत है');
      expect(payNowText, 'अभी भुगतान करें');
    });
  });
}
