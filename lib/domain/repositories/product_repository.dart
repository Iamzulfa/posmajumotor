import 'package:posfelix/data/models/models.dart';

/// Product Repository Interface
abstract class ProductRepository {
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

  /// Get all brands
  Future<List<BrandModel>> getBrands();
}
