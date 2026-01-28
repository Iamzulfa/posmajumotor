import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase Configuration
///
/// Credentials are loaded from .env file for security.
/// See .env.example for required variables.
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase Project URL
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase Anon/Public Key
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Current environment
  static String get environment => dotenv.env['APP_ENV'] ?? 'development';

  /// Debug mode flag
  static bool get isDebugMode => dotenv.env['DEBUG_MODE'] == 'true';

  /// Check if Supabase is configured
  /// Returns true if URL and anonKey are properly set
  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      url.contains('supabase.co') &&
      anonKey.startsWith('eyJ');

  /// Validate configuration and throw if invalid
  static void validate() {
    if (!isConfigured) {
      throw Exception(
        'Supabase not configured! Please check your .env file.\n'
        'Required: SUPABASE_URL and SUPABASE_ANON_KEY',
      );
    }
  }
}
