import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';
import 'package:wua_mobile/features/authentication/domain/entities/user_entity.dart';
import 'package:wua_mobile/features/profile/presentation/widgets/my_profile_bottom_sheet.dart';

void main() {
  Widget buildSubject(UserEntity? user) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: MyProfileBottomSheet(user: user),
        ),
      ),
    );
  }

  group('MyProfileBottomSheet Tests', () {
    testWidgets('shows N/A and never fake fallback data when user fields are missing', (
      tester,
    ) async {
      final emptyUser = UserEntity(
        id: '',
        name: '',
        email: '',
        phone: '',
        role: UserRole.farmer,
        isVerified: true,
        createdAt: DateTime(2025, 1, 1),
      );

      await tester.pumpWidget(buildSubject(emptyUser));
      await tester.pumpAndSettle();

      expect(find.text('Land Holding'), findsOneWidget);
      expect(find.text('4.5 Acres (Survey 142/2A & 142/2B)'), findsNothing);
      expect(find.text('Ramesh Patil'), findsNothing);
      expect(find.text('9876543210'), findsNothing);
      expect(find.text('WUA-10245'), findsNothing);
      expect(find.text('FARMER_IRRIGATOR'), findsNothing);
      expect(find.text('Mulshi Water User Association'), findsNothing);
      expect(find.text('N/A'), findsAtLeastNWidgets(4));
      expect(find.text('FARMER'), findsOneWidget);
    });

    testWidgets('shows real farm area, survey number, village and society when present', (
      tester,
    ) async {
      final populatedUser = UserEntity(
        id: 'usr_98765',
        name: 'Ganesh Jadhav',
        email: 'ganesh@example.com',
        phone: '9811223344',
        role: UserRole.farmer,
        roles: const ['SABHASAD'],
        isVerified: true,
        createdAt: DateTime(2025, 1, 1),
        farmArea: 6.25,
        surveyNo: '88/3',
        village: 'Paud',
        societyId: 14,
      );

      await tester.pumpWidget(buildSubject(populatedUser));
      await tester.pumpAndSettle();

      expect(find.text('Ganesh Jadhav'), findsOneWidget);
      expect(find.text('9811223344'), findsOneWidget);
      expect(find.text('WUA-usr_9'), findsOneWidget);
      expect(find.text('SABHASAD'), findsOneWidget);
      expect(find.text('6.25 Acres (88/3)'), findsOneWidget);
      expect(find.text('Paud WUA (#14)'), findsOneWidget);
    });
  });
}
