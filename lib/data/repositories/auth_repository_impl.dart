import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/data/models/user_model.dart';
import 'package:posfelix/domain/repositories/auth_repository.dart';
import 'package:posfelix/core/utils/logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  bool get isAuthenticated => _client.auth.currentUser != null;

  @override
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      if (event.session?.user == null) return null;
      return await getCurrentUser();
    });
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final authUser = _client.auth.currentUser;
      if (authUser == null) return null;

      final response = await _client
          .from('users')
          .select()
          .eq('id', authUser.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error getting current user', e);
      return null;
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }

      // Get user profile from public.users
      final userProfile = await _client
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .single();

      AppLogger.info('User signed in: $email');
      return UserModel.fromJson(userProfile);
    } on AuthException catch (e) {
      AppLogger.error('Auth error during sign in', e);
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      AppLogger.error('Error during sign in', e);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      AppLogger.info('User signed out');
    } catch (e) {
      AppLogger.error('Error during sign out', e);
      rethrow;
    }
  }
}
