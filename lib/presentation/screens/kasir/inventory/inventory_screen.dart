import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../data/models/models.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../providers/product_provider.dart';
import 'product_form_modal.dart';
import 'delete_product_dialog.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    // Watch real-time streams
    final productsAsync = ref.watch(productsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final brandsAsync = ref.watch(brandsStreamProvider);

    // Combine all async data
    final enrichedProductsAsync = productsAsync.when(
      data: (products) {
        return categoriesAsync.when(
          data: (categories) {
            return brandsAsync.when(
              data: (brands) {
                return AsyncValue.data(
                  _enrichProductsWithRelations(products, categories, brands),
                );
              },
              loading: () => const AsyncValue<List<ProductModel>>.loading(),
              error: (e, s) => AsyncValue<List<ProductModel>>.error(e, s),
            );
          },
          loading: () => const AsyncValue<List<ProductModel>>.loading(),
          error: (e, s) => AsyncValue<List<ProductModel>>.error(e, s),
        );
      },
      loading: () => const AsyncValue<List<ProductModel>>.loading(),
      error: (e, s) => AsyncValue<List<ProductModel>>.error(e, s),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(enrichedProductsAsync),
            _buildSearchAndFilter(categoriesAsync),
            _buildResultCount(enrichedProductsAsync),
            Expanded(child: _buildProductList(enrichedProductsAsync)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<List<ProductModel>> productsAsync) {
    final syncStatus = productsAsync.when(
      data: (_) => SyncStatus.online,
      loading: () => SyncStatus.syncing,
      error: (_, __) => SyncStatus.offline,
    );

    final lastSyncText = productsAsync.when(
      data: (_) => 'Real-time',
      loading: () => 'Syncing...',
      error: (_, __) => 'Error',
    );

    return AppHeader(
      title: 'Inventory',
      syncStatus: syncStatus,
      lastSyncTime: lastSyncText,
    );
  }

  Widget _buildSearchAndFilter(
    AsyncValue<List<CategoryModel>> categoriesAsync,
  ) {
    return categoriesAsync.when(
      data: (categories) {
        final categoryNames = ['Semua', ...categories.map((c) => c.name)];
        final selectedCategoryName = _selectedCategoryId != null
            ? categories
                  .firstWhere(
                    (c) => c.id == _selectedCategoryId,
                    orElse: () => const CategoryModel(id: '', name: 'Semua'),
                  )
                  .name
            : 'Semua';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari produk...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategoryName,
                    items: categoryNames
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        if (value == 'Semua') {
                          _selectedCategoryId = null;
                        } else {
                          final category = categories.firstWhere(
                            (c) => c.name == value,
                          );
                          _selectedCategoryId = category.id;
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Text(
          'Error: $error',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildResultCount(AsyncValue<List<ProductModel>> productsAsync) {
    return productsAsync.when(
      data: (products) {
        final filtered = _filterProducts(products);
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hasil: ${filtered.length} produk',
              style: const TextStyle(fontSize: 14, color: AppColors.textGray),
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Loading...',
            style: TextStyle(color: AppColors.textGray),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    var result = products;

    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (p) =>
                p.name.toLowerCase().contains(_searchQuery) ||
                (p.sku?.toLowerCase().contains(_searchQuery) ?? false),
          )
          .toList();
    }

    if (_selectedCategoryId != null) {
      result = result
          .where((p) => p.categoryId == _selectedCategoryId)
          .toList();
    }

    return result;
  }

  Widget _buildProductList(AsyncValue<List<ProductModel>> productsAsync) {
    return productsAsync.when(
      data: (products) {
        final filtered = _filterProducts(products);

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada produk',
              style: TextStyle(color: AppColors.textGray),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(productsStreamProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: filtered.length,
            itemBuilder: (context, index) => _buildProductCard(filtered[index]),
          ),
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text('$error', style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () => ref.invalidate(productsStreamProvider),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final margin = product.getMarginPercent('UMUM');
    final marginColor = margin >= 30
        ? AppColors.success
        : margin >= 20
        ? AppColors.warning
        : AppColors.error;
    final stockColor = product.stock > product.minStock
        ? AppColors.success
        : product.stock > 0
        ? AppColors.warning
        : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${product.category?.name ?? '-'} | ${product.brand?.name ?? '-'}',
            style: const TextStyle(fontSize: 14, color: AppColors.textGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: stockColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Stok: ${product.stock}',
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              ),
              const SizedBox(width: AppSpacing.lg),
              Text(
                'Margin: ${margin.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: marginColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'HPP: Rp ${_formatNumber(product.hpp)}  |  Jual: Rp ${_formatNumber(product.hargaUmum)}',
            style: const TextStyle(fontSize: 14, color: AppColors.textGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _showEditProductDialog(context, product),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textGray,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _showDeleteDialog(context, product),
                color: AppColors.error,
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final categoriesAsync = ref.read(categoriesStreamProvider);
    final brandsAsync = ref.read(brandsStreamProvider);

    categoriesAsync.whenData((categories) {
      brandsAsync.whenData((brands) {
        if (mounted) {
          showProductFormModal(context, categories: categories, brands: brands);
        }
      });
    });
  }

  void _showEditProductDialog(BuildContext context, ProductModel product) {
    final categoriesAsync = ref.read(categoriesStreamProvider);
    final brandsAsync = ref.read(brandsStreamProvider);

    categoriesAsync.whenData((categories) {
      brandsAsync.whenData((brands) {
        if (mounted) {
          showProductFormModal(
            context,
            categories: categories,
            brands: brands,
            product: product,
          );
        }
      });
    });
  }

  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDeleteProductDialog(context, product, ref);
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
