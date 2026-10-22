import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:wua_mobile/core/constants/env_config.dart';
import 'package:wua_mobile/core/di/injection_container.dart';
import 'package:wua_mobile/core/errors/errors.dart';
import 'package:wua_mobile/core/l10n/l10n.dart';
import 'package:wua_mobile/core/logger/app_logger.dart';
import 'package:wua_mobile/core/router/app_router.dart';
import 'package:wua_mobile/core/theme/app_theme.dart';

/// Application entry point.
///
/// Startup sequence:
/// 1. Ensure Flutter binding
/// 2. Initialize global error handling
/// 3. Load environment configuration
/// 4. Initialize dependency injection
/// 5. Configure Bloc observer
/// 6. Lock orientation
/// 7. Run app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Global Error Handling ───────────────────────────────────
  GlobalErrorHandler.initialize();

  // ── Environment ─────────────────────────────────────────────
  // Change this to switch environments:
  // AppEnvironment.development | .qa | .uat | .production
  const environment = AppEnvironment.development;
  EnvConfig.setEnvironment(environment);
  await dotenv.load(fileName: EnvConfig.envFileName);

  AppLogger.info('Environment: ${EnvConfig.buildFlavor}');
  AppLogger.info('Base URL: ${EnvConfig.baseUrl}');

  // ── Dependency Injection ────────────────────────────────────
  await initDependencies();

  // ── Bloc Observer ───────────────────────────────────────────
  Bloc.observer = AppBlocObserver();

  // ── System UI ───────────────────────────────────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ── Run ─────────────────────────────────────────────────────
  runApp(const WuaApp());
}

/// Root widget for the WUA application.
class WuaApp extends StatelessWidget {
  const WuaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = sl<AppRouter>();

    return ValueListenableBuilder<Locale?>(
      valueListenable: appLocaleNotifier,
      builder: (context, currentLocale, _) {
        return MaterialApp.router(
          title: 'WUA Mobile',
          debugShowCheckedModeBanner: false,
          locale: currentLocale,

          // Localization
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          // Theme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,

          // Router
          routerConfig: appRouter.router,
        );
      },
    );
  }
}
