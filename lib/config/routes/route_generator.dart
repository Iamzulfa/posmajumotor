import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/kasir/kasir_main_screen.dart';
import '../../presentation/screens/admin/admin_main_screen.dart';
import '../../presentation/pages/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.kasirMain,
        name: 'kasir',
        builder: (context, state) => const KasirMainScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminMain,
        name: 'admin',
        builder: (context, state) => const AdminMainScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri.path}')),
    ),
  );
}
