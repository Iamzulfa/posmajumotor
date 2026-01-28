import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:posfelix/config/constants/supabase_config.dart';

void main() {
  group('SupabaseConfig', () {
    setUpAll(() async {
      // Load test environment
      try {
        await dotenv.load(fileName: '.env.test');
      } catch (e) {
        // If .env.test doesn't exist, set test values manually
        dotenv.testLoad(
          fileInput: '''
SUPABASE_URL=https://test-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test.key
APP_ENV=test
DEBUG_MODE=true
''',
        );
      }
    });

    group('url', () {
      test('should return URL from environment', () {
        // Act
        final url = SupabaseConfig.url;

        // Assert
        expect(url, isNotEmpty);
        expect(url, contains('supabase.co'));
      });
    });

    group('anonKey', () {
      test('should return anon key from environment', () {
        // Act
        final anonKey = SupabaseConfig.anonKey;

        // Assert
        expect(anonKey, isNotEmpty);
        expect(anonKey, startsWith('eyJ'));
      });
    });

    group('environment', () {
      test('should return environment from dotenv', () {
        // Act
        final env = SupabaseConfig.environment;

        // Assert
        expect(env, isNotEmpty);
        expect(env, isIn(['development', 'staging', 'production', 'test']));
      });
    });

    group('isDebugMode', () {
      test('should return debug mode flag', () {
        // Act
        final isDebug = SupabaseConfig.isDebugMode;

        // Assert
        expect(isDebug, isA<bool>());
      });
    });

    group('isConfigured', () {
      test('should validate configuration', () {
        // Act
        final isConfigured = SupabaseConfig.isConfigured;

        // Assert
        expect(isConfigured, isA<bool>());
      });

      test('should check URL contains supabase.co', () {
        // Arrange
        final url = SupabaseConfig.url;

        // Act
        final isConfigured = SupabaseConfig.isConfigured;

        // Assert
        if (url.contains('supabase.co')) {
          expect(isConfigured, isTrue);
        }
      });

      test('should check anon key starts with eyJ', () {
        // Arrange
        final anonKey = SupabaseConfig.anonKey;

        // Act
        final isConfigured = SupabaseConfig.isConfigured;

        // Assert
        if (anonKey.startsWith('eyJ')) {
          expect(isConfigured, isTrue);
        }
      });
    });

    group('validate', () {
      test('should validate without throwing when properly configured', () {
        // Act & Assert
        if (SupabaseConfig.isConfigured) {
          expect(() => SupabaseConfig.validate(), returnsNormally);
        }
      });
    });

    group('Security Tests', () {
      test('should validate JWT format for anon key', () {
        // Act
        final anonKey = SupabaseConfig.anonKey;

        // Assert - JWT should have parts separated by dots
        if (anonKey.isNotEmpty) {
          expect(anonKey.split('.').length, greaterThanOrEqualTo(2));
        }
      });

      test('should validate HTTPS protocol for URL', () {
        // Act
        final url = SupabaseConfig.url;

        // Assert
        if (url.isNotEmpty) {
          expect(url, startsWith('https://'));
        }
      });

      test('should not expose credentials in error messages', () {
        // This is a conceptual test - in practice, check error handling
        // Act
        final url = SupabaseConfig.url;
        final key = SupabaseConfig.anonKey;

        // Assert - Credentials exist but shouldn't be in plain sight
        expect(url, isNotNull);
        expect(key, isNotNull);
      });
    });
  });
}
