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
