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
      // Static credentials for private app
      const staticCredentials = {
        'admin@toko.com': 'admin123',
        'kasir@toko.com': 'kasir123',
      };

      // Verify static credentials
      if (staticCredentials[email] != password) {
        throw Exception('Invalid login credentials');
      }

      // Get user profile from public.users
      final response = await _client.from('users').select().eq('email', email);

      AppLogger.info('Query response: $response');

      if (response.isEmpty) {
        throw Exception('User not found in database');
      }

      if (response.length > 1) {
        throw Exception('Multiple users found with same email');
      }

      final userProfile = response.first;
      AppLogger.info('User signed in: $email');
      return UserModel.fromJson(userProfile);
    } catch (e) {
      AppLogger.error('Auth error during sign in', e);
      throw Exception('Login failed: ${e.toString()}');
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
