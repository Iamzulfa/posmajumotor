import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:posfelix/core/utils/logger.dart';

/// Service for managing secure storage and encryption keys
class SecureStorageService {
  static const _hiveKeyName = 'posfelix_hive_encryption_key';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static SecureStorageService? _instance;
  List<int>? _encryptionKey;

  SecureStorageService._();

  static SecureStorageService get instance {
    _instance ??= SecureStorageService._();
    return _instance!;
  }

  /// Get or generate Hive encryption key
  Future<List<int>> getHiveEncryptionKey() async {
    if (_encryptionKey != null) {
      return _encryptionKey!;
    }

    try {
      // Try to read existing key
      final existingKey = await _storage.read(key: _hiveKeyName);

      if (existingKey != null) {
        _encryptionKey = base64Url.decode(existingKey);
        AppLogger.info('🔐 Loaded existing Hive encryption key');
        return _encryptionKey!;
      }

      // Generate new key if not exists
      final newKey = Hive.generateSecureKey();
      await _storage.write(key: _hiveKeyName, value: base64Url.encode(newKey));

      _encryptionKey = newKey;
      AppLogger.info('🔐 Generated new Hive encryption key');
      return _encryptionKey!;
    } catch (e) {
      AppLogger.error('Error getting Hive encryption key', e);
      // Fallback: generate a key but don't persist (less secure but functional)
      _encryptionKey = Hive.generateSecureKey();
      return _encryptionKey!;
    }
  }

  /// Get HiveAesCipher for encrypted boxes
  Future<HiveAesCipher> getHiveCipher() async {
    final key = await getHiveEncryptionKey();
    return HiveAesCipher(key);
  }

  /// Store sensitive data securely
  Future<void> writeSecure(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      AppLogger.error('Error writing to secure storage', e);
      rethrow;
    }
  }

  /// Read sensitive data
  Future<String?> readSecure(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      AppLogger.error('Error reading from secure storage', e);
      return null;
    }
  }

  /// Delete sensitive data
  Future<void> deleteSecure(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      AppLogger.error('Error deleting from secure storage', e);
    }
  }

  /// Clear all secure storage (use with caution!)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      _encryptionKey = null;
      AppLogger.warning('🔐 All secure storage cleared');
    } catch (e) {
      AppLogger.error('Error clearing secure storage', e);
    }
  }
}
