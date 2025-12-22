import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../data/models/models.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/inventory_provider.dart';
import 'product_form_modal.dart';
import 'category_form_modal.dart';
import 'brand_form_modal.dart';
import 'add_item_selection_modal.dart';
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

  @override
  Widget build(BuildContext context) {
    // Watch combined enriched products (no nested AsyncValue)
    final enrichedProductsAsync = ref.watch(enrichedProductsProvider);

    // Watch categories for filter dropdown
    final categoriesAsync = ref.watch(categoriesStreamProvider);

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
        onPressed: () => _showAddItemSelectionModal(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(AsyncValue<List<ProductModel>> productsAsync) {
    final syncStatus = productsAsync.when(
      data: (_) => SyncStatus.online,
      loading: () => SyncStatus.syncing,
      error: (_, _) => SyncStatus.offline,
    );

    final lastSyncText = productsAsync.when(
      data: (_) => 'Real-time',
      loading: () => 'Syncing...',
      error: (_, _) => 'Error',
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
    final filterPadding = ResponsiveUtils.getResponsivePadding(context);
    final filterSpacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 6,
      tabletSpacing: 8,
      desktopSpacing: 10,
    );
    final textFieldPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 10,
      tabletValue: 12,
      desktopValue: 14,
    );

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
          padding: filterPadding,
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
                    contentPadding: textFieldPadding,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context),
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
              ),
              SizedBox(width: filterSpacing),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getPercentageWidth(context, 3),
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context),
                  ),
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
      loading: () => Padding(
        padding: filterPadding,
        child: const LinearProgressIndicator(),
      ),
      error: (error, _) => Padding(
        padding: filterPadding,
        child: Text(
          'Error: $error',
          style: TextStyle(
            color: AppColors.error,
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 12,
              tabletSize: 14,
              desktopSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCount(AsyncValue<List<ProductModel>> productsAsync) {
    final resultPadding = ResponsiveUtils.getResponsivePadding(context);
    final resultFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 13,
      tabletSize: 14,
      desktopSize: 15,
    );

    return productsAsync.when(
      data: (products) {
        final filtered = _filterProducts(products);
        return Padding(
          padding: resultPadding,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hasil: ${filtered.length} produk',
              style: TextStyle(
                fontSize: resultFontSize,
                color: AppColors.textGray,
              ),
            ),
          ),
        );
      },
      loading: () => Padding(
        padding: resultPadding,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Loading...',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: resultFontSize,
            ),
          ),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
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
    final listPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 12,
      tabletValue: 14,
      desktopValue: 16,
    );
    final emptyStateFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 12,
      tabletSize: 14,
      desktopSize: 15,
    );
    final errorSpacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 12,
      tabletSpacing: 14,
      desktopSpacing: 16,
    );

    return productsAsync.when(
      data: (products) {
        final filtered = _filterProducts(products);

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              'Tidak ada produk',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: emptyStateFontSize,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(enrichedProductsProvider);
          },
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: listPadding.left),
            itemCount: filtered.length,
            cacheExtent: 500,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
            itemBuilder: (context, index) {
              final product = filtered[index];
              return RepaintBoundary(
                key: ValueKey(product.id),
                child: _buildProductCard(product),
              );
            },
          ),
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ResponsiveUtils.getResponsiveHeight(
                context,
                phoneHeight: 40,
                tabletHeight: 48,
                desktopHeight: 56,
              ),
              color: AppColors.error,
            ),
            SizedBox(height: errorSpacing),
            Text(
              '$error',
              style: TextStyle(
                color: AppColors.error,
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  phoneSize: 12,
                  tabletSize: 14,
                  desktopSize: 15,
                ),
              ),
            ),
            SizedBox(height: errorSpacing),
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

    final productNameFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 15,
      tabletSize: 16,
      desktopSize: 17,
    );
    final categoryFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 13,
      tabletSize: 13,
      desktopSize: 14,
    );
    final infoFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 13,
      tabletSize: 13,
      desktopSize: 14,
    );
    final cardPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 10,
      tabletValue: 12,
      desktopValue: 14,
    );
    final cardMargin = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 10,
      tabletSpacing: 12,
      desktopSpacing: 14,
    );
    final spacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 6,
      tabletSpacing: 8,
      desktopSpacing: 10,
    );
    final buttonPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 8,
      tabletValue: 10,
      desktopValue: 12,
    );

    return Container(
      margin: EdgeInsets.only(bottom: cardMargin),
      padding: cardPadding,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: TextStyle(
              fontSize: productNameFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: spacing),
          Text(
            '${product.category?.name ?? '-'} | ${product.brand?.name ?? '-'}',
            style: TextStyle(
              fontSize: categoryFontSize,
              color: AppColors.textGray,
            ),
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: stockColor),
              SizedBox(width: spacing * 0.5),
              Text(
                'Stok: ${product.stock}',
                style: TextStyle(
                  fontSize: infoFontSize,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(width: spacing * 2),
              Text(
                'Margin: ${margin.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: infoFontSize,
                  fontWeight: FontWeight.w600,
                  color: marginColor,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing),
          Text(
            'HPP: Rp ${_formatNumber(product.hpp)}  |  Jual: Rp ${_formatNumber(product.hargaUmum)}',
            style: TextStyle(fontSize: infoFontSize, color: AppColors.textGray),
          ),
          SizedBox(height: spacing),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _showEditProductDialog(context, product),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textGray,
                  padding: buttonPadding,
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

  void _showAddItemSelectionModal(BuildContext context) {
    showAddItemSelectionModal(
      context,
      onItemSelected: (AddItemType type) {
        switch (type) {
          case AddItemType.product:
            _showAddProductDialog(context);
            break;
          case AddItemType.category:
            _showAddCategoryDialog(context);
            break;
          case AddItemType.brand:
            _showAddBrandDialog(context);
            break;
        }
      },
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

  void _showAddCategoryDialog(BuildContext context) {
    showCategoryFormModal(context);
  }

  void _showAddBrandDialog(BuildContext context) {
    showBrandFormModal(context);
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
