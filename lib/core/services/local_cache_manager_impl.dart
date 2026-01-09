import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/core/services/local_cache_manager.dart';
import 'package:posfelix/core/services/hive_adapters.dart';
import 'package:posfelix/core/utils/logger.dart';

/// Implementation of LocalCacheManager using Hive
class LocalCacheManagerImpl implements LocalCacheManager {
  // Cache keys
  static const String _productsCacheKey = 'products';
  static const String _transactionsCacheKey = 'transactions';
  static const String _expensesCacheKey = 'expenses';

  // ============================================
  // PRODUCTS CACHE
  // ============================================

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final box = Hive.box<String>(HiveBoxes.productsCache);
      final metadataBox = Hive.box<CacheMetadata>(HiveBoxes.cacheMetadata);

      // Clear existing cache
      await box.clear();

      // Store each product as JSON string
      for (int i = 0; i < products.length; i++) {
        final jsonString = jsonEncode(products[i].toJson());
        await box.put('product_$i', jsonString);
      }

      // Update metadata
      final metadata = CacheMetadata(
        cacheKey: _productsCacheKey,
        cachedAt: DateTime.now(),
        itemCount: products.length,
      );
      await metadataBox.put(_productsCacheKey, metadata);

      AppLogger.info('Cached ${products.length} products');
    } catch (e) {
      AppLogger.error('Error caching products', e);
      rethrow;
    }
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    try {
      final box = Hive.box<String>(HiveBoxes.productsCache);
      final products = <ProductModel>[];

      for (final key in box.keys) {
        final jsonString = box.get(key);
        if (jsonString != null) {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          products.add(ProductModel.fromJson(json));
        }
      }

      AppLogger.info('Retrieved ${products.length} cached products');
      return products;
    } catch (e) {
      AppLogger.error('Error getting cached products', e);
      return [];
    }
  }

  @override
  Future<void> clearProductsCache() async {
    try {
      final box = Hive.box<String>(HiveBoxes.productsCache);
      final metadataBox = Hive.box<CacheMetadata>(HiveBoxes.cacheMetadata);

      await box.clear();
      await metadataBox.delete(_productsCacheKey);

      AppLogger.info('Products cache cleared');
    } catch (e) {
      AppLogger.error('Error clearing products cache', e);
    }
  }

  // ============================================
  // TRANSACTIONS CACHE
  // ============================================

  @override
  Future<void> cacheTransactions(List<TransactionModel> transactions) async {
    try {
      final box = Hive.box<String>(HiveBoxes.productsCache);
      final metadataBox = Hive.box<CacheMetadata>(HiveBoxes.cacheMetadata);

      // Store transactions as single JSON array
      final jsonList = transactions.map((t) => t.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await box.put(_transactionsCacheKey, jsonString);

      // Update metadata
      final metadata = CacheMetadata(
        cacheKey: _transactionsCacheKey,
        cachedAt: DateTime.now(),
        itemCount: transactions.length,
      );
      await metadataBox.put(_transactionsCacheKey, metadata);

      AppLogger.info('Cached ${transactions.length} transactions');
    } catch (e) {
      AppLogger.error('Error caching transactions', e);
      rethrow;
    }
  }

  @override
  Future<List<TransactionModel>> getCachedTransactions() async {
    try {
      final box = Hive.box<String>(HiveBoxes.productsCache);
      final jsonString = box.get(_transactionsCacheKey);

      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final transactions = jsonList
          .map(
            (json) => TransactionModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      AppLogger.info('Retrieved ${transactions.length} cached transactions');
      return transactions;
    } catch (e) {
      AppLogger.error('Error getting cached transactions', e);
      return [];
    }
  }

  @override
  Future<void> clearTransactionsCache() async {
    try {
      final box = Hive.box<String>(HiveBoxes.productsCache);
      final metadataBox = Hive.box<CacheMetadata>(HiveBoxes.cacheMetadata);

      await box.delete(_transactionsCacheKey);
      await metadataBox.delete(_transactionsCacheKey);

      AppLogger.info('Transactions cache cleared');
    } catch (e) {
      AppLogger.error('Error clearing transactions cache', e);
    }
  }

  // ============================================
  // EXPENSES CACHE
  // ============================================

  @override
  Future<void> cacheExpenses(List<ExpenseModel> expenses) async {
    try {
      final box = Hive.box<String>(HiveBoxes.expensesCache);
      final metadataBox = Hive.box<CacheMetadata>(HiveBoxes.cacheMetadata);

      // Store expenses as single JSON array
      final jsonList = expenses.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await box.put(_expensesCacheKey, jsonString);

      // Update metadata
      final metadata = CacheMetadata(
        cacheKey: _expensesCacheKey,
        cachedAt: DateTime.now(),
        itemCount: expenses.length,
      );
      await metadataBox.put(_expensesCacheKey, metadata);

      AppLogger.info('Cached ${expenses.length} expenses');
    } catch (e) {
      AppLogger.error('Error caching expenses', e);
      rethrow;
    }
  }

  @override
  Future<List<ExpenseModel>> getCachedExpenses() async {
    try {
      final box = Hive.box<String>(HiveBoxes.expensesCache);
      final jsonString = box.get(_expensesCacheKey);

      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final expenses = jsonList
          .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
          .toList();

      AppLogger.info('Retrieved ${expenses.length} cached expenses');
      return expenses;
    } catch (e) {
      AppLogger.error('Error getting cached expenses', e);
      return [];
    }
  }

  @override
  Future<void> clearExpensesCache() async {
    try {
      final box = Hive.box<String>(HiveBoxes.expensesCache);
      final metadataBox = Hive.box<CacheMetadata>(HiveBoxes.cacheMetadata);

      await box.delete(_expensesCacheKey);
      await metadataBox.delete(_expensesCacheKey);

      AppLogger.info('Expenses cache cleared');
    } catch (e) {
      AppLogger.error('Error clearing expenses cache', e);
    }
  }

  // ============================================
  // CACHE METADATA
  // ============================================

  @override
  Future<DateTime?> getLastCacheTime(String cacheKey) async {
    try {
      final metadataBox = Hive.box<CacheMetadata>(HiveBoxes.cacheMetadata);
      final metadata = metadataBox.get(cacheKey);
      return metadata?.cachedAt;
    } catch (e) {
      AppLogger.error('Error getting last cache time', e);
      return null;
    }
  }

  @override
  Future<bool> isCacheValid(String cacheKey, Duration maxAge) async {
    try {
      final metadataBox = Hive.box<CacheMetadata>(HiveBoxes.cacheMetadata);
      final metadata = metadataBox.get(cacheKey);

      if (metadata == null) return false;
      return metadata.isValid(maxAge);
    } catch (e) {
      AppLogger.error('Error checking cache validity', e);
      return false;
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      await clearProductsCache();
      await clearTransactionsCache();
      await clearExpensesCache();

      AppLogger.info('All caches cleared');
    } catch (e) {
      AppLogger.error('Error clearing all caches', e);
    }
  }
}
