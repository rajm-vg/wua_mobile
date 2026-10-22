import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/extensions/extensions.dart';
import 'package:wua_mobile/core/theme/theme.dart';

void main() {
  group('Typography and Theme Extensions', () {
    testWidgets('provides direct text style shortcuts from context', (tester) async {
      late TextStyle headline;
      late TextStyle pageTitle;
      late TextStyle badgeText;
      late Color primary;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) {
              headline = context.headlineSmall;
              pageTitle = context.pageTitle;
              badgeText = context.badgeText;
              primary = context.primaryColor;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(headline.fontSize, 24);
      expect(pageTitle.fontWeight, FontWeight.w600);
      expect(badgeText.letterSpacing, 0.6);
      expect(primary, AppColors.primary);
    });

    test('TextStyleModifiers correctly apply chainable properties', () {
      const base = TextStyle(fontSize: 14);

      final modified = base.bold
          .white
          .withSpacing(1.5)
          .withHeight(1.2)
          .withOpacity(0.8);

      expect(modified.fontWeight, FontWeight.bold);
      expect(modified.letterSpacing, 1.5);
      expect(modified.height, 1.2);
      expect(modified.color, Colors.white.withValues(alpha: 0.8));
    });

    test('TextStyleModifiers color presets apply expected colors', () {
      const base = TextStyle(fontSize: 14);

      expect(base.primary.color, AppColors.primary);
      expect(base.secondary.color, AppColors.secondary);
      expect(base.gold.color, AppColors.gold);
      expect(base.error.color, AppColors.error);
    });
  });
}
