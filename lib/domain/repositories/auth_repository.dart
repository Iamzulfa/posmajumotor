import 'package:posfelix/data/models/user_model.dart';

/// Authentication Repository Interface
abstract class AuthRepository {
  /// Get current authenticated user
  Future<UserModel?> getCurrentUser();

  /// Sign in with email and password
  Future<UserModel> signIn({required String email, required String password});

  /// Sign out current user
  Future<void> signOut();

  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Stream of auth state changes
  Stream<UserModel?> get authStateChanges;
}
