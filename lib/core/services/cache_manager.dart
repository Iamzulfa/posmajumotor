import '../utils/logger.dart';

/// Cache manager for request caching and optimization
class CacheManager {
  static final _instance = CacheManager._();

  factory CacheManager() => _instance;

  CacheManager._();

  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTime = {};

  /// Get cached data or fetch if not cached
  Future<T> getCached<T>(
    String key,
    Future<T> Function() fetcher, {
    Duration cacheDuration = const Duration(minutes: 5),
  }) async {
    // Check if cached and not expired
    if (_cache.containsKey(key)) {
      final cacheAge = DateTime.now().difference(_cacheTime[key]!);
      if (cacheAge < cacheDuration) {
        AppLogger.info('📦 Cache hit: $key');
        return _cache[key] as T;
      }
    }

    // Fetch fresh data
    AppLogger.info('🔄 Cache miss: $key - fetching...');
    final result = await fetcher();
    _cache[key] = result;
    _cacheTime[key] = DateTime.now();
    return result;
  }

  /// Invalidate specific cache entry
  void invalidate(String key) {
    _cache.remove(key);
    _cacheTime.remove(key);
    AppLogger.info('🗑️ Cache invalidated: $key');
  }

  /// Invalidate all cache entries
  void invalidateAll() {
    _cache.clear();
    _cacheTime.clear();
    AppLogger.info('🗑️ All cache invalidated');
  }

  /// Check if key is cached
  bool isCached(String key) {
    return _cache.containsKey(key);
  }

  /// Get cache size
  int getCacheSize() {
    return _cache.length;
  }

  /// Get cache info
  Map<String, dynamic> getCacheInfo() {
    return {
      'size': _cache.length,
      'keys': _cache.keys.toList(),
      'ages': _cacheTime.entries.map((e) {
        final age = DateTime.now().difference(e.value);
        return '${e.key}: ${age.inSeconds}s';
      }).toList(),
    };
  }
}

/// Global cache manager instance
final cacheManager = CacheManager();
