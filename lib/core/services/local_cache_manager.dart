import 'package:posfelix/data/models/models.dart';

/// Local Cache Manager Interface
/// Provides methods for caching and retrieving data locally using Hive
abstract class LocalCacheManager {
  // ============================================
  // PRODUCTS CACHE
  // ============================================

  /// Cache list of products locally
  Future<void> cacheProducts(List<ProductModel> products);

  /// Get cached products
  Future<List<ProductModel>> getCachedProducts();

  /// Clear products cache
  Future<void> clearProductsCache();

  // ============================================
  // TRANSACTIONS CACHE
  // ============================================

  /// Cache list of transactions locally
  Future<void> cacheTransactions(List<TransactionModel> transactions);

  /// Get cached transactions
  Future<List<TransactionModel>> getCachedTransactions();

  /// Clear transactions cache
  Future<void> clearTransactionsCache();

  // ============================================
  // EXPENSES CACHE
  // ============================================

  /// Cache list of expenses locally
  Future<void> cacheExpenses(List<ExpenseModel> expenses);

  /// Get cached expenses
  Future<List<ExpenseModel>> getCachedExpenses();

  /// Clear expenses cache
  Future<void> clearExpensesCache();

  // ============================================
  // CACHE METADATA
  // ============================================

  /// Get last cache time for a specific cache key
  Future<DateTime?> getLastCacheTime(String cacheKey);

  /// Check if cache is still valid based on max age
  Future<bool> isCacheValid(String cacheKey, Duration maxAge);

  /// Clear all caches
  Future<void> clearAllCache();
}
