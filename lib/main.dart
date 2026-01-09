import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/theme/app_theme.dart';
import 'config/constants/app_constants.dart';
import 'config/constants/supabase_config.dart';
import 'config/routes/route_generator.dart';
import 'injection_container.dart';
import 'core/utils/logger.dart';
import 'core/services/hive_adapters.dart';
import 'core/services/offline_service.dart';
import 'core/services/cache_seeder.dart';
// Debug imports removed for production

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show splash screen immediately
  runApp(const SplashApp());

  // Initialize in parallel for faster startup
  try {
    await Future.wait([_initializeHive(), _initializeSupabase()]);

    // Initialize offline service
    final offlineService = OfflineService();
    await offlineService.initialize();
    AppLogger.info('Offline Service initialized successfully');

    // Seed initial cache for offline testing
    await CacheSeeder.seedInitialCache();

    await setupServiceLocator();

    // Debug database checks removed for production
    // if (kDebugMode) {
    //   await SimpleDebug.checkDatabase();
    //   await FixedExpenseDebug.checkFixedExpenses();
    // }

    // Replace splash with main app
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    AppLogger.error('Initialization failed', e);
    runApp(const ErrorApp());
  }
}

Future<void> _initializeHive() async {
  await Hive.initFlutter();
  await registerHiveAdapters();
  await openHiveBoxes();
  AppLogger.info('Hive initialized successfully');
}

Future<void> _initializeSupabase() async {
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
    AppLogger.info('Supabase initialized successfully');
  } else {
    AppLogger.warning('Supabase not configured - running in offline mode');
  }
}

class SplashApp extends StatelessWidget {
  const SplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 20),
              const Text('Initialization Error'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => main(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
