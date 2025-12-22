import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posfelix/data/models/user_model.dart';
import 'package:posfelix/domain/repositories/auth_repository.dart';
import 'package:posfelix/injection_container.dart';
import 'package:posfelix/config/constants/supabase_config.dart';
import 'package:posfelix/core/utils/error_handler.dart';

/// Auth state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.role == 'ADMIN';
  bool get isKasir => user?.role == 'KASIR';
}

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository? _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      final userFriendlyError = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(isLoading: false, error: userFriendlyError);
    }
  }

  Future<bool> signIn(String email, String password) async {
    if (_repository == null) {
      // Supabase not configured - should not be called in demo mode
      state = state.copyWith(
        error: 'Layanan autentikasi tidak tersedia dalam mode demo',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.signIn(email: email, password: password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      final userFriendlyError = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(isLoading: false, error: userFriendlyError);
      return false;
    }
  }

  Future<void> signOut() async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.signOut();
      state = const AuthState();
    } catch (e) {
      final userFriendlyError = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(isLoading: false, error: userFriendlyError);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = SupabaseConfig.isConfigured
      ? getIt<AuthRepository>()
      : null;
  return AuthNotifier(repository);
});
