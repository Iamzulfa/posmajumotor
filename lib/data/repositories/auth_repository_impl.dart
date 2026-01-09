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

      // Try to get user profile from public.users
      try {
        final response = await _client
            .from('users')
            .select()
            .eq('email', email);

        AppLogger.info('Query response: $response');

        if (response.isEmpty) {
          // Create demo user if not exists
          AppLogger.info('User not found, creating demo user for: $email');
          return _createDemoUser(email);
        }

        if (response.length > 1) {
          throw Exception('Multiple users found with same email');
        }

        final userProfile = response.first;
        AppLogger.info('User signed in: $email');

        // Ensure all required fields are present
        final userData = Map<String, dynamic>.from(userProfile);
        userData['id'] =
            userData['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString();
        userData['email'] = userData['email']?.toString() ?? email;
        userData['fullName'] =
            userData['fullName']?.toString() ??
            userData['full_name']?.toString() ??
            'Demo User';
        userData['role'] =
            userData['role']?.toString() ??
            (email.contains('admin') ? 'ADMIN' : 'KASIR');
        userData['isActive'] =
            userData['isActive'] ?? userData['is_active'] ?? true;

        return UserModel.fromJson(userData);
      } catch (dbError) {
        AppLogger.warning('Database error, using demo user: $dbError');
        return _createDemoUser(email);
      }
    } catch (e) {
      AppLogger.error('Auth error during sign in', e);
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  UserModel _createDemoUser(String email) {
    final isAdmin = email.contains('admin');
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      fullName: isAdmin ? 'Admin Demo' : 'Kasir Demo',
      role: isAdmin ? 'ADMIN' : 'KASIR',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
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
