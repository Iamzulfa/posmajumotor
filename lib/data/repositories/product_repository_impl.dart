import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/product_repository.dart';
import 'package:posfelix/core/utils/logger.dart';

class ProductRepositoryImpl implements ProductRepository {
  final SupabaseClient _client;

  ProductRepositoryImpl(this._client);

  @override
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? brandId,
    String? searchQuery,
    bool activeOnly = true,
  }) async {
    try {
      var query = _client.from('products').select('''
        *,
        categories(*),
        brands(*)
      ''');

      if (activeOnly) {
        query = query.eq('is_active', true);
      }

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (brandId != null) {
        query = query.eq('brand_id', brandId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,sku.ilike.%$searchQuery%');
      }

      final response = await query.order('name');
      return response.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching products', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    try {
      final response = await _client
          .from('products')
          .select('''
        *,
        categories(*),
        brands(*)
      ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ProductModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching product by ID', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final response = await _client
          .from('products')
          .select('''
        *,
        categories(*),
        brands(*)
      ''')
          .eq('barcode', barcode)
          .maybeSingle();

      if (response == null) return null;
      return ProductModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching product by barcode', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final data = {
        'sku': product.sku,
        'barcode': product.barcode,
        'name': product.name,
        'description': product.description,
        'category_id': product.categoryId,
        'brand_id': product.brandId,
        'stock': product.stock,
        'min_stock': product.minStock,
        'hpp': product.hpp,
        'harga_umum': product.hargaUmum,
        'harga_bengkel': product.hargaBengkel,
        'harga_grossir': product.hargaGrossir,
      };

      final response = await _client
          .from('products')
          .insert(data)
          .select()
          .single();

      AppLogger.info('Product created: ${product.name}');
      return ProductModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error creating product', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      final data = {
        'sku': product.sku,
        'barcode': product.barcode,
        'name': product.name,
        'description': product.description,
        'category_id': product.categoryId,
        'brand_id': product.brandId,
        'stock': product.stock,
        'min_stock': product.minStock,
        'hpp': product.hpp,
        'harga_umum': product.hargaUmum,
        'harga_bengkel': product.hargaBengkel,
        'harga_grossir': product.hargaGrossir,
        'is_active': product.isActive,
      };

      final response = await _client
          .from('products')
          .update(data)
          .eq('id', product.id)
          .select()
          .single();

      AppLogger.info('Product updated: ${product.name}');
      return ProductModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error updating product', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      // Soft delete
      await _client.from('products').update({'is_active': false}).eq('id', id);
      AppLogger.info('Product deleted (soft): $id');
    } catch (e) {
      AppLogger.error('Error deleting product', e);
      rethrow;
    }
  }

  @override
  Future<void> updateStock({
    required String productId,
    required int quantity,
    required String type,
    required String referenceType,
    String? referenceId,
    String? reason,
  }) async {
    try {
      // Get current stock
      final product = await getProductById(productId);
      if (product == null) throw Exception('Product not found');

      final stockBefore = product.stock;
      final stockAfter = type == 'IN'
          ? stockBefore + quantity
          : type == 'OUT'
          ? stockBefore - quantity
          : stockBefore + quantity; // ADJUSTMENT can be +/-

      // Update stock
      await _client
          .from('products')
          .update({'stock': stockAfter})
          .eq('id', productId);

      // Create inventory log
      await _client.from('inventory_logs').insert({
        'product_id': productId,
        'type': type,
        'quantity': type == 'OUT' ? -quantity : quantity,
        'stock_before': stockBefore,
        'stock_after': stockAfter,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'reason': reason,
        'created_by': _client.auth.currentUser?.id,
      });

      AppLogger.info('Stock updated: $productId, $type $quantity');
    } catch (e) {
      AppLogger.error('Error updating stock', e);
      rethrow;
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('name');

      return response.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching categories', e);
      rethrow;
    }
  }

  @override
  Future<List<BrandModel>> getBrands() async {
    try {
      final response = await _client
          .from('brands')
          .select()
          .eq('is_active', true)
          .order('name');

      return response.map((json) => BrandModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching brands', e);
      rethrow;
    }
  }
}
