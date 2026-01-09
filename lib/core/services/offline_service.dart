import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

/// Service untuk manage offline mode dan local caching
class OfflineService extends ChangeNotifier {
  static final OfflineService _instance = OfflineService._internal();
  static final Logger _logger = Logger();

  factory OfflineService() {
    return _instance;
  }

  OfflineService._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  late Box<dynamic> _cacheBox;
  late Box<dynamic> _syncQueueBox;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  /// Initialize offline service
  Future<void> initialize() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Open boxes
      _cacheBox = await Hive.openBox('offline_cache');
      _syncQueueBox = await Hive.openBox('sync_queue');

      // Listen to connectivity changes
      _connectivity.onConnectivityChanged.listen((result) {
        final wasOnline = _isOnline;
        _isOnline = result != ConnectivityResult.none;

        if (wasOnline && !_isOnline) {
          _logger.w('📡 OFFLINE MODE ACTIVATED - No internet connection');
        } else if (!wasOnline && _isOnline) {
          _logger.i('📡 ONLINE MODE ACTIVATED - Internet connection restored');
          _syncPendingData();
        }

        notifyListeners();
      });

      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;

      _logger.i(
        '📡 Offline Service initialized - Status: ${_isOnline ? 'ONLINE' : 'OFFLINE'}',
      );
    } catch (e) {
      _logger.e('Error initializing offline service: $e');
    }
  }

  /// Cache data locally
  Future<void> cacheData(String key, dynamic data) async {
    try {
      await _cacheBox.put(key, data);
      _logger.d('💾 Cached: $key');
    } catch (e) {
      _logger.e('Error caching data: $e');
    }
  }

  /// Get cached data
  dynamic getCachedData(String key) {
    try {
      return _cacheBox.get(key);
    } catch (e) {
      _logger.e('Error retrieving cached data: $e');
      return null;
    }
  }

  /// Clear specific cache
  Future<void> clearCache(String key) async {
    try {
      await _cacheBox.delete(key);
      _logger.d('🗑️ Cleared cache: $key');
    } catch (e) {
      _logger.e('Error clearing cache: $e');
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      await _cacheBox.clear();
      _logger.i('🗑️ All cache cleared');
    } catch (e) {
      _logger.e('Error clearing all cache: $e');
    }
  }

  /// Add transaction to sync queue
  Future<void> queueTransaction(String id, Map<String, dynamic> data) async {
    try {
      await _syncQueueBox.put(id, {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'transaction',
      });
      _logger.d('📤 Queued transaction: $id');
    } catch (e) {
      _logger.e('Error queuing transaction: $e');
    }
  }

  /// Add expense to sync queue
  Future<void> queueExpense(String id, Map<String, dynamic> data) async {
    try {
      await _syncQueueBox.put(id, {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'expense',
      });
      _logger.d('📤 Queued expense: $id');
    } catch (e) {
      _logger.e('Error queuing expense: $e');
    }
  }

  /// Get all pending sync items
  List<MapEntry<dynamic, dynamic>> getPendingSyncItems() {
    try {
      return _syncQueueBox.toMap().entries.toList();
    } catch (e) {
      _logger.e('Error getting pending sync items: $e');
      return [];
    }
  }

  /// Remove synced item from queue
  Future<void> removeSyncedItem(String id) async {
    try {
      await _syncQueueBox.delete(id);
      _logger.d('✅ Removed from sync queue: $id');
    } catch (e) {
      _logger.e('Error removing synced item: $e');
    }
  }

  /// Clear sync queue
  Future<void> clearSyncQueue() async {
    try {
      await _syncQueueBox.clear();
      _logger.i('🗑️ Sync queue cleared');
    } catch (e) {
      _logger.e('Error clearing sync queue: $e');
    }
  }

  /// Sync pending data when online
  Future<void> _syncPendingData() async {
    try {
      final pendingItems = getPendingSyncItems();
      if (pendingItems.isEmpty) {
        _logger.i('✅ No pending items to sync');
        return;
      }

      _logger.i('🔄 Syncing ${pendingItems.length} pending items...');

      // Sync logic will be implemented in repositories
      // This is just the notification
      notifyListeners();
    } catch (e) {
      _logger.e('Error syncing pending data: $e');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'isOnline': _isOnline,
      'cachedItems': _cacheBox.length,
      'pendingSyncItems': _syncQueueBox.length,
      'cacheSize': _cacheBox.values.length,
    };
  }

  /// Dispose resources
  @override
  Future<void> dispose() async {
    try {
      await _cacheBox.close();
      await _syncQueueBox.close();
      _logger.i('📡 Offline Service disposed');
      super.dispose();
    } catch (e) {
      _logger.e('Error disposing offline service: $e');
    }
  }
}
