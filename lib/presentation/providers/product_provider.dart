import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/product_repository.dart';
import 'package:posfelix/injection_container.dart';
import 'package:posfelix/config/constants/supabase_config.dart';

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

/// Product list notifier
class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductRepository? _repository;

  ProductListNotifier(this._repository) : super(const ProductListState());

  Future<void> loadProducts() async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _repository.getProducts();
      final categories = await _repository.getCategories();
      final brands = await _repository.getBrands();

      state = state.copyWith(
        products: products,
        categories: categories,
        brands: brands,
        isLoading: false,
      );
    } catch (e) {
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
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateProduct(product);
      await loadProducts(); // Reload list
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteProduct(String id) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteProduct(id);
      await loadProducts(); // Reload list
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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

/// Product list provider (StateNotifier for local state management)
final productListProvider =
    StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
      final repository = SupabaseConfig.isConfigured
          ? getIt<ProductRepository>()
          : null;
      return ProductListNotifier(repository);
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
