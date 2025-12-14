import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/constants/app_constants.dart';
import 'config/constants/supabase_config.dart';
import 'domain/repositories/repositories.dart';
import 'data/repositories/repositories.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  _setupCore();

  // Repositories
  _setupRepositories();
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

  // Tax Repository
  getIt.registerLazySingleton<TaxRepository>(
    () => TaxRepositoryImpl(getIt<SupabaseClient>()),
  );
}
