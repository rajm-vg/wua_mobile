import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logger/app_logger.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../network/network_module.dart';
import '../router/app_router.dart';
import '../storage/preference_storage_service.dart';
import '../storage/secure_storage_service.dart';

// Feature imports — uncomment as features are implemented.
// import '../../features/authentication/authentication.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Initializes all dependencies.
/// Must be called before [runApp].
Future<void> initDependencies() async {
  AppLogger.info('Initializing dependencies…');

  // ─── External ───────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  sl.registerLazySingleton<Connectivity>(Connectivity.new);

  // ─── Core: Storage ──────────────────────────────────────────
  sl.registerLazySingleton<SecureStorageService>(SecureStorageService.new);
  sl.registerLazySingleton<PreferenceStorageService>(
    () => PreferenceStorageService(prefs: sl<SharedPreferences>()),
  );

  // ─── Core: Network ─────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: sl<Connectivity>()),
  );
  sl.registerLazySingleton<ApiClient>(
    () => NetworkModule.provideApiClient(
      secureStorage: sl<SecureStorageService>(),
      onTokenExpired: () {
        // TODO: Navigate to login and clear session.
        AppLogger.warning('Token expired — triggering logout.');
      },
    ),
  );

  // ─── Core: Router ──────────────────────────────────────────
  sl.registerLazySingleton<AppRouter>(
    () => AppRouter(secureStorage: sl<SecureStorageService>()),
  );

  // ─── Feature: Authentication ───────────────────────────────
  await _initAuthenticationFeature();

  // ─── Feature: Profile ──────────────────────────────────────
  // await _initProfileFeature();

  // ─── Feature: Bills ────────────────────────────────────────
  // await _initBillsFeature();

  // ─── Feature: Payments ─────────────────────────────────────
  // await _initPaymentsFeature();

  // ─── Feature: Transactions ─────────────────────────────────
  // await _initTransactionsFeature();

  // ─── Feature: Notifications ────────────────────────────────
  // await _initNotificationsFeature();

  // ─── Feature: Water Usage ──────────────────────────────────
  // await _initWaterUsageFeature();

  AppLogger.info('Dependencies initialized ✓');
}

// ═══════════════════════════════════════════════════════════════
// Feature DI registration methods
// ═══════════════════════════════════════════════════════════════

Future<void> _initAuthenticationFeature() async {
  // Data Sources
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(apiClient: sl()),
  // );
  // sl.registerLazySingleton<AuthLocalDataSource>(
  //   () => AuthLocalDataSourceImpl(secureStorage: sl()),
  // );

  // Repository
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(
  //     remoteDataSource: sl(),
  //     localDataSource: sl(),
  //     networkInfo: sl(),
  //   ),
  // );

  // Use Cases
  // sl.registerLazySingleton(() => LoginUseCase(sl()));
  // sl.registerLazySingleton(() => RegisterUseCase(sl()));
  // sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Bloc
  // sl.registerFactory(() => AuthBloc(
  //   loginUseCase: sl(),
  //   registerUseCase: sl(),
  //   logoutUseCase: sl(),
  // ));
}
