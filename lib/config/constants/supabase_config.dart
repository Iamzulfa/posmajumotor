/// Supabase Configuration
///
/// IMPORTANT: Jangan commit file ini dengan credentials asli ke Git!
/// Gunakan environment variables untuk production.
class SupabaseConfig {
  SupabaseConfig._();

  /// Supabase Project URL
  /// Ganti dengan URL project kamu dari Supabase Dashboard > Settings > API
  static const String url = 'https://ppmnwbvsvvcytlwmnsoo.supabase.co';

  /// Supabase Anon/Public Key
  /// Ganti dengan anon key dari Supabase Dashboard > Settings > API
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBwbW53YnZzdnZjeXRsd21uc29vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU2NTYzOTYsImV4cCI6MjA4MTIzMjM5Nn0.n2jnfXgCUXXu5LQvusYYWCLBys3m5OCTd9-yr-HDPQY';

  /// Check if Supabase is configured
  /// Returns true if URL and anonKey are not empty/placeholder values
  static bool get isConfigured =>
      url.isNotEmpty &&
      anonKey.isNotEmpty &&
      url.contains('supabase.co') &&
      anonKey.startsWith('eyJ');
}
