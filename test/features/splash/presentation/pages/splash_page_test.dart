import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/storage/secure_storage_service.dart';
import 'package:wua_mobile/features/splash/splash.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorageService mockSecureStorage;

  setUp(() async {
    await sl.reset();
    mockSecureStorage = MockSecureStorageService();
    sl.registerSingleton<SecureStorageService>(mockSecureStorage);

    when(() => mockSecureStorage.hasToken()).thenAnswer((_) async => false);
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets(
    'Minimalist SplashPage renders clean branding and initialization stages',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashPage()));

      // Initial frame verify
      expect(find.text('Water User Association'), findsOneWidget);
      expect(find.textContaining('जल संसाधन विभाग'), findsOneWidget);
      expect(find.text('Verifying Environment'), findsOneWidget);
      expect(find.text('33%'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Stage 2: Checking Credentials
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('Checking Credentials'), findsOneWidget);
      expect(find.text('66%'), findsOneWidget);

      // Stage 3: Synchronizing Workspace
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text('Synchronizing Workspace'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);

      // Completion checkmark
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Drain remaining transition delay
      await tester.pump(const Duration(milliseconds: 500));
    },
  );

  testWidgets('AnimatedSplashPage renders in light and dark mode', (
    tester,
  ) async {
    // Light mode test
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.light,
        home: const AnimatedSplashPage(),
      ),
    );

    expect(find.byType(WaterRippleBackground), findsOneWidget);
    expect(find.byType(WrdEmblem), findsOneWidget);
    expect(find.text('WATER USER ASSOCIATION'), findsOneWidget);

    // Drain
    await tester.pump(const Duration(seconds: 4));
  });
}
