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
    bool activeOnly = false,
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

      AppLogger.info('Creating product with data: $data');

      final response = await _client.from('products').insert(data).select('''
            *,
            categories(*),
            brands(*)
          ''').single();

      AppLogger.info('Product created: ${product.name}, response: $response');

      // Ensure all fields are present in response
      final createdProduct = ProductModel.fromJson(response);
      return createdProduct;
    } catch (e) {
      AppLogger.error('Error creating product', e);
      rethrow;
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    try {
      AppLogger.info(
        'Updating product: id=${product.id}, name=${product.name}',
      );

      if (product.id.isEmpty) {
        throw Exception('Product ID is empty');
      }

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

      AppLogger.info('Update data: $data');

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

  // ============================================
  // STREAM METHODS (Real-time updates)
  // ============================================

  @override
  Stream<List<ProductModel>> getProductsStream({
    String? categoryId,
    String? brandId,
    bool activeOnly = false,
  }) {
    try {
      // Use Supabase real-time stream with select to include relations
      var stream = _client.from('products').stream(primaryKey: ['id']).map((
        data,
      ) {
        AppLogger.info('Stream received ${data.length} products from Supabase');

        var products = data.map((json) {
          // Try to parse with relations if available
          try {
            return ProductModel.fromJson(json);
          } catch (e) {
            AppLogger.error('Error parsing product', e);
            return ProductModel.fromJson(json);
          }
        }).toList();

        AppLogger.info('Parsed ${products.length} products');

        // Apply filters
        if (activeOnly) {
          products = products.where((p) => p.isActive).toList();
          AppLogger.info(
            'After activeOnly filter: ${products.length} products',
          );
        }
        if (categoryId != null) {
          products = products.where((p) => p.categoryId == categoryId).toList();
        }
        if (brandId != null) {
          products = products.where((p) => p.brandId == brandId).toList();
        }

        // Sort by name
        products.sort((a, b) => a.name.compareTo(b.name));
        AppLogger.info('Final stream result: ${products.length} products');
        return products;
      });

      return stream.handleError((error) {
        AppLogger.error('Error streaming products', error);
      });
    } catch (e) {
      AppLogger.error('Error setting up products stream', e);
      rethrow;
    }
  }

  @override
  Stream<ProductModel?> getProductStream(String id) {
    try {
      return _client
          .from('products')
          .stream(primaryKey: ['id'])
          .eq('id', id)
          .map((data) {
            if (data.isEmpty) return null;
            return ProductModel.fromJson(data.first);
          })
          .handleError((error) {
            AppLogger.error('Error streaming product $id', error);
          });
    } catch (e) {
      AppLogger.error('Error setting up product stream', e);
      rethrow;
    }
  }

  @override
  Stream<List<CategoryModel>> getCategoriesStream() {
    try {
      return _client
          .from('categories')
          .stream(primaryKey: ['id'])
          .map((data) {
            var categories = data
                .map((json) => CategoryModel.fromJson(json))
                .toList();
            categories = categories.where((c) => c.isActive).toList();
            categories.sort((a, b) => a.name.compareTo(b.name));
            return categories;
          })
          .handleError((error) {
            AppLogger.error('Error streaming categories', error);
          });
    } catch (e) {
      AppLogger.error('Error setting up categories stream', e);
      rethrow;
    }
  }

  @override
  Stream<List<BrandModel>> getBrandsStream() {
    try {
      return _client
          .from('brands')
          .stream(primaryKey: ['id'])
          .map((data) {
            var brands = data.map((json) => BrandModel.fromJson(json)).toList();
            brands = brands.where((b) => b.isActive).toList();
            brands.sort((a, b) => a.name.compareTo(b.name));
            return brands;
          })
          .handleError((error) {
            AppLogger.error('Error streaming brands', error);
          });
    } catch (e) {
      AppLogger.error('Error setting up brands stream', e);
      rethrow;
    }
  }
}
