import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/constants/env_config.dart';
import 'core/di/injection_container.dart';
import 'core/logger/app_logger.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Application entry point.
///
/// Startup sequence:
/// 1. Ensure Flutter binding
/// 2. Load environment configuration
/// 3. Initialize dependency injection
/// 4. Configure Bloc observer
/// 5. Lock orientation
/// 6. Run app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

    return MaterialApp.router(
      title: 'WUA Mobile',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Router
      routerConfig: appRouter.router,
    );
  }
}
