import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/models.dart';
import 'product_provider.dart';

/// Combined provider for enriched products (products + categories + brands)
/// This prevents nested AsyncValue handling and cascading rebuilds
final enrichedProductsProvider = StreamProvider<List<ProductModel>>((
  ref,
) async* {
  // Watch all streams
  final productsStream = ref.watch(productsStreamProvider);
  final categoriesStream = ref.watch(categoriesStreamProvider);
  final brandsStream = ref.watch(brandsStreamProvider);

  // Combine when all data is available
  await for (final products in productsStream.when(
    data: (data) => Stream.value(data),
    loading: () => Stream.empty(),
    error: (e, s) => Stream.empty(),
  )) {
    await for (final categories in categoriesStream.when(
      data: (data) => Stream.value(data),
      loading: () => Stream.empty(),
      error: (e, s) => Stream.empty(),
    )) {
      await for (final brands in brandsStream.when(
        data: (data) => Stream.value(data),
        loading: () => Stream.empty(),
        error: (e, s) => Stream.empty(),
      )) {
        yield _enrichProductsWithRelations(products, categories, brands);
      }
    }
  }
});

/// Filtered products by category
final filteredProductsProvider =
    StreamProvider.family<List<ProductModel>, String?>((
      ref,
      categoryId,
    ) async* {
      final enrichedProducts = ref.watch(enrichedProductsProvider);

      await for (final products in enrichedProducts.when(
        data: (data) => Stream.value(data),
        loading: () => Stream.empty(),
        error: (e, s) => Stream.empty(),
      )) {
        if (categoryId == null) {
          yield products;
        } else {
          yield products.where((p) => p.categoryId == categoryId).toList();
        }
      }
    });

/// Searched products
final searchedProductsProvider =
    StreamProvider.family<List<ProductModel>, String>((ref, query) async* {
      final enrichedProducts = ref.watch(enrichedProductsProvider);

      await for (final products in enrichedProducts.when(
        data: (data) => Stream.value(data),
        loading: () => Stream.empty(),
        error: (e, s) => Stream.empty(),
      )) {
        if (query.isEmpty) {
          yield products;
        } else {
          final lowerQuery = query.toLowerCase();
          yield products
              .where(
                (p) =>
                    p.name.toLowerCase().contains(lowerQuery) ||
                    p.sku.toLowerCase().contains(lowerQuery),
              )
              .toList();
        }
      }
    });

/// Combine products with categories and brands data
List<ProductModel> _enrichProductsWithRelations(
  List<ProductModel> products,
  List<CategoryModel> categories,
  List<BrandModel> brands,
) {
  final categoryMap = {for (var c in categories) c.id: c};
  final brandMap = {for (var b in brands) b.id: b};

  return products.map((product) {
    return product.copyWith(
      category: product.categoryId != null
          ? categoryMap[product.categoryId]
          : null,
      brand: product.brandId != null ? brandMap[product.brandId] : null,
    );
  }).toList();
}
