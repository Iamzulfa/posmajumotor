import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/constants/app_constants.dart';
import 'config/constants/supabase_config.dart';
import 'domain/repositories/repositories.dart';
import 'data/repositories/repositories.dart';
import 'core/services/local_cache_manager.dart';
import 'core/services/local_cache_manager_impl.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/connectivity_service_impl.dart';
import 'core/services/offline_sync_manager.dart';
import 'core/services/offline_sync_manager_impl.dart';
import 'core/utils/logger.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core Services
  await _setupCoreServices();

  // Core
  _setupCore();

  // Repositories
  _setupRepositories();

  // Offline Services (depends on repositories)
  _setupOfflineServices();
}

void _setupCore() {
  // Dio HTTP Client (for external APIs if needed)
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.connectionTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.receiveTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    return dio;
  });

  // Supabase Client
  if (SupabaseConfig.isConfigured) {
    getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  }
}

void _setupRepositories() {
  // Only register if Supabase is configured
  if (!SupabaseConfig.isConfigured) return;

  // Auth Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<SupabaseClient>()),
  );

  // Product Repository
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(getIt<SupabaseClient>()),
  );

  // Transaction Repository
  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(getIt<SupabaseClient>()),
  );

  // Expense Repository
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(getIt<SupabaseClient>()),
  );

  // Fixed Expense Repository
  getIt.registerLazySingleton<FixedExpenseRepository>(() {
    AppLogger.info('🔧 Registering FixedExpenseRepository');
    return FixedExpenseRepositoryImpl(getIt<SupabaseClient>());
  });

  // Tax Repository
  getIt.registerLazySingleton<TaxRepository>(
    () => TaxRepositoryImpl(getIt<SupabaseClient>()),
  );

  // Dashboard Repository
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(getIt<SupabaseClient>()),
  );
}

Future<void> _setupCoreServices() async {
  // Local Cache Manager
  getIt.registerLazySingleton<LocalCacheManager>(() => LocalCacheManagerImpl());

  // Connectivity Service
  final connectivityService = ConnectivityServiceImpl();
  await connectivityService.initialize();
  getIt.registerLazySingleton<ConnectivityService>(() => connectivityService);
}

void _setupOfflineServices() {
  // Offline Sync Manager
  getIt.registerLazySingleton<OfflineSyncManager>(
    () => OfflineSyncManagerImpl(
      connectivityService: getIt<ConnectivityService>(),
      transactionRepository: SupabaseConfig.isConfigured
          ? getIt<TransactionRepository>()
          : null,
    ),
  );
}
