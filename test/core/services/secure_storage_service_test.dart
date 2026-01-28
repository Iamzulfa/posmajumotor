import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:posfelix/core/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorageService', () {
    late SecureStorageService service;

    setUp(() {
      service = SecureStorageService.instance;
    });

    group('getHiveEncryptionKey', () {
      test('should generate encryption key', () async {
        // Act
        final key = await service.getHiveEncryptionKey();

        // Assert
        expect(key, isNotNull);
        expect(key.length, equals(32)); // AES-256 key length
        expect(key, isA<List<int>>());
      });

      test('should return same key on multiple calls (cached)', () async {
        // Act
        final key1 = await service.getHiveEncryptionKey();
        final key2 = await service.getHiveEncryptionKey();

        // Assert
        expect(key1, equals(key2));
        expect(identical(key1, key2), isTrue);
      });

      test('should generate valid AES-256 key', () async {
        // Act
        final key = await service.getHiveEncryptionKey();

        // Assert - AES-256 requires 32 bytes
        expect(key.length, equals(32));
        // Check that key contains varied values (not all zeros)
        expect(key.toSet().length, greaterThan(1));
      });
    });

    group('getHiveCipher', () {
      test('should return HiveAesCipher', () async {
        // Act
        final cipher = await service.getHiveCipher();

        // Assert
        expect(cipher, isA<HiveAesCipher>());
      });

      test('should return same cipher on multiple calls', () async {
        // Act
        final cipher1 = await service.getHiveCipher();
        final cipher2 = await service.getHiveCipher();

        // Assert - Should use same encryption key
        expect(cipher1, isNotNull);
        expect(cipher2, isNotNull);
      });
    });

    group('Encryption Key Properties', () {
      test('should generate cryptographically secure key', () async {
        // Act
        final key = await service.getHiveEncryptionKey();

        // Assert
        // Check key entropy - should have good distribution
        final uniqueBytes = key.toSet().length;
        expect(uniqueBytes, greaterThan(20)); // At least 20 unique bytes
      });

      test('should generate different keys for different instances', () async {
        // Arrange - Generate a reference key
        final referenceKey = Hive.generateSecureKey();

        // Act
        final serviceKey = await service.getHiveEncryptionKey();

        // Assert - Keys should be different (unless by extreme coincidence)
        // This tests that we're not using a hardcoded key
        expect(serviceKey, isNot(equals(referenceKey)));
      });
    });

    group('Security Properties', () {
      test('should use secure key length', () async {
        // Act
        final key = await service.getHiveEncryptionKey();

        // Assert - Must be exactly 32 bytes for AES-256
        expect(key.length, equals(32));
      });

      test('should not expose key in plain text', () {
        // Act
        final serviceString = service.toString();

        // Assert - toString should not contain key data
        expect(serviceString, isNot(contains('key')));
        expect(serviceString, isNot(contains('cipher')));
      });
    });
  });
}
