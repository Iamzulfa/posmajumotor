import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'config/constants/app_constants.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Core
  _setupCore();

  // Data Sources
  _setupDataSources();

  // Repositories
  _setupRepositories();

  // Use Cases
  _setupUseCases();

  // Providers (will be added later with Riverpod)
}

void _setupCore() {
  // Dio HTTP Client
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

    // Add interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          // final token = getIt<LocalStorage>().getToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );

    return dio;
  });
}

void _setupDataSources() {
  // Remote Data Sources
  // getIt.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(getIt()),
  // );

  // Local Data Sources
  // getIt.registerLazySingleton<AuthLocalDataSource>(
  //   () => AuthLocalDataSourceImpl(),
  // );
}

void _setupRepositories() {
  // getIt.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(
  //     remoteDataSource: getIt(),
  //     localDataSource: getIt(),
  //   ),
  // );
}

void _setupUseCases() {
  // getIt.registerLazySingleton<LoginUseCase>(
  //   () => LoginUseCase(getIt()),
  // );
}
