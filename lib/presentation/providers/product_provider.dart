import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/product_repository.dart';
import 'package:posfelix/core/services/local_cache_manager.dart';
import 'package:posfelix/core/services/connectivity_service.dart';
import 'package:posfelix/injection_container.dart';
import 'package:posfelix/config/constants/supabase_config.dart';
import 'package:posfelix/core/utils/logger.dart';
import 'package:posfelix/core/utils/error_handler.dart';

/// Product list state
class ProductListState {
  final List<ProductModel> products;
  final List<CategoryModel> categories;
  final List<BrandModel> brands;
  final bool isLoading;
  final String? error;
  final String? searchQuery;
  final String? selectedCategoryId;

  const ProductListState({
    this.products = const [],
    this.categories = const [],
    this.brands = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.selectedCategoryId,
  });

  ProductListState copyWith({
    List<ProductModel>? products,
    List<CategoryModel>? categories,
    List<BrandModel>? brands,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedCategoryId,
  }) {
    return ProductListState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryId: selectedCategoryId,
    );
  }

  /// Get filtered products
  List<ProductModel> get filteredProducts {
    var result = products;

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                (p.sku?.toLowerCase().contains(query) ?? false),
          )
          .toList();
    }

    if (selectedCategoryId != null) {
      result = result.where((p) => p.categoryId == selectedCategoryId).toList();
    }

    return result;
  }
}

/// Product list notifier with offline support
class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductRepository? _repository;
  final LocalCacheManager? _cacheManager;
  final ConnectivityService? _connectivityService;

  ProductListNotifier(
    this._repository,
    this._cacheManager,
    this._connectivityService,
  ) : super(const ProductListState());

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if online and repository available
      final isOnline = _connectivityService?.isOnline ?? true;

      if (isOnline && _repository != null) {
        // Fetch from server
        final products = await _repository.getProducts();
        final categories = await _repository.getCategories();
        final brands = await _repository.getBrands();

        // Cache products for offline use
        if (_cacheManager != null) {
          await _cacheManager.cacheProducts(products);
          AppLogger.info('Products cached for offline use');
        }

        state = state.copyWith(
          products: products,
          categories: categories,
          brands: brands,
          isLoading: false,
        );
      } else {
        // Offline mode - load from cache
        if (_cacheManager != null) {
          final cachedProducts = await _cacheManager.getCachedProducts();
          AppLogger.info('Loaded ${cachedProducts.length} products from cache');

          state = state.copyWith(
            products: cachedProducts,
            isLoading: false,
            error: cachedProducts.isEmpty ? 'No cached data available' : null,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            error: 'Offline mode - no cache available',
          );
        }
      }
    } catch (e) {
      // Try to load from cache on error
      if (_cacheManager != null) {
        try {
          final cachedProducts = await _cacheManager.getCachedProducts();
          if (cachedProducts.isNotEmpty) {
            AppLogger.info(
              'Loaded ${cachedProducts.length} products from cache (fallback)',
            );
            state = state.copyWith(
              products: cachedProducts,
              isLoading: false,
              error: 'Using cached data',
            );
            return;
          }
        } catch (_) {}
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedCategory(String? categoryId) {
    state = state.copyWith(selectedCategoryId: categoryId);
  }

  Future<void> createProduct(ProductModel product) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createProduct(product);
      await loadProducts(); // Reload list
    } catch (e) {
      final userFriendlyError = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(isLoading: false, error: userFriendlyError);
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateProduct(product);
      await loadProducts(); // Reload list
    } catch (e) {
      final userFriendlyError = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(isLoading: false, error: userFriendlyError);
    }
  }

  Future<void> deleteProduct(String id) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteProduct(id);
      await loadProducts(); // Reload list
    } catch (e) {
      final userFriendlyError = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(isLoading: false, error: userFriendlyError);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Product repository provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return getIt<ProductRepository>();
});

/// Product list provider (StateNotifier for local state management with offline support)
final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
      ProductRepository? repository;
      LocalCacheManager? cacheManager;
      ConnectivityService? connectivityService;

      if (SupabaseConfig.isConfigured) {
        repository = getIt<ProductRepository>();
      }

      try {
        cacheManager = getIt<LocalCacheManager>();
        connectivityService = getIt<ConnectivityService>();
      } catch (e) {
        // Services not registered yet
      }

      return ProductListNotifier(repository, cacheManager, connectivityService);
    });

/// Single product provider (for detail/edit)
final productDetailProvider = FutureProvider.family<ProductModel?, String>((
  ref,
  id,
) async {
  if (!SupabaseConfig.isConfigured) return null;
  final repository = getIt<ProductRepository>();
  return repository.getProductById(id);
});

// ============================================
// STREAM PROVIDERS (Real-time updates)
// ============================================

/// Real-time products stream provider
final productsStreamProvider = StreamProvider<List<ProductModel>>((ref) {
  if (!SupabaseConfig.isConfigured) {
    // Return empty stream for offline mode
    return Stream.value([]);
  }
  final repository = getIt<ProductRepository>();
  return repository.getProductsStream();
});

/// Non-stream products provider (for transaction screen as fallback)
final productsProvider = FutureProvider<List<ProductModel>>((ref) async {
  if (!SupabaseConfig.isConfigured) {
    return [];
  }
  final repository = getIt<ProductRepository>();
  return repository.getProducts();
});

/// Real-time categories stream provider
final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return Stream.value([]);
  }
  final repository = getIt<ProductRepository>();
  return repository.getCategoriesStream();
});

/// Real-time brands stream provider
final brandsStreamProvider = StreamProvider<List<BrandModel>>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return Stream.value([]);
  }
  final repository = getIt<ProductRepository>();
  return repository.getBrandsStream();
});

/// Real-time single product stream provider
final productStreamProvider = StreamProvider.family<ProductModel?, String>((
  ref,
  id,
) {
  if (!SupabaseConfig.isConfigured) {
    return Stream.value(null);
  }
  final repository = getIt<ProductRepository>();
  return repository.getProductStream(id);
});
