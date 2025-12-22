import 'package:posfelix/data/models/models.dart';

/// Product Repository Interface
abstract class ProductRepository {
  // ============================================
  // FUTURE METHODS (One-time fetch)
  // ============================================

  /// Get all products with optional filters
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? brandId,
    String? searchQuery,
    bool activeOnly = true,
  });

  /// Get product by ID
  Future<ProductModel?> getProductById(String id);

  /// Get product by barcode
  Future<ProductModel?> getProductByBarcode(String barcode);

  /// Create new product
  Future<ProductModel> createProduct(ProductModel product);

  /// Update existing product
  Future<ProductModel> updateProduct(ProductModel product);

  /// Delete product (soft delete)
  Future<void> deleteProduct(String id);

  /// Update product stock
  Future<void> updateStock({
    required String productId,
    required int quantity,
    required String type, // IN, OUT, ADJUSTMENT
    required String referenceType,
    String? referenceId,
    String? reason,
  });

  /// Get all categories
  Future<List<CategoryModel>> getCategories();

  /// Create new category
  Future<CategoryModel> createCategory(CategoryModel category);

  /// Update existing category
  Future<CategoryModel> updateCategory(CategoryModel category);

  /// Delete category (soft delete)
  Future<void> deleteCategory(String id);

  /// Get all brands
  Future<List<BrandModel>> getBrands();

  /// Create new brand
  Future<BrandModel> createBrand(BrandModel brand);

  /// Update existing brand
  Future<BrandModel> updateBrand(BrandModel brand);

  /// Delete brand (soft delete)
  Future<void> deleteBrand(String id);

  // ============================================
  // STREAM METHODS (Real-time updates)
  // ============================================

  /// Stream all products with real-time updates
  /// Emits new list whenever products table changes
  Stream<List<ProductModel>> getProductsStream({
    String? categoryId,
    String? brandId,
    bool activeOnly = true,
  });

  /// Stream single product with real-time updates
  Stream<ProductModel?> getProductStream(String id);

  /// Stream all categories with real-time updates
  Stream<List<CategoryModel>> getCategoriesStream();

  /// Stream all brands with real-time updates
  Stream<List<BrandModel>> getBrandsStream();
}
