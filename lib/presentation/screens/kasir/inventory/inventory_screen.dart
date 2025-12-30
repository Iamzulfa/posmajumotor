import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async'; // FIX: Add Timer import
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/filter_manager.dart';
import '../../../../data/models/models.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/navigation/hamburger_menu.dart';
import '../../../widgets/filtering/multi_filter_widget.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/inventory_provider.dart';
import '../filtering/advanced_filter_screen.dart';
import 'product_form_modal.dart';
import 'category_form_modal.dart';
import 'brand_form_modal.dart';
import 'category_brand_management_screen.dart';
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
  FilterManager? _filterManager;
  Timer? _debounceTimer; // FIX: Add debounce timer

  @override
  void initState() {
    super.initState();
    _filterManager = FilterManager();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterManager?.dispose();
    _debounceTimer?.cancel(); // FIX: Cancel timer on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch combined enriched products (no nested AsyncValue)
    final enrichedProductsAsync = ref.watch(enrichedProductsProvider);

    // Initialize filter manager with products when available
    enrichedProductsAsync.whenData((products) {
      if (_filterManager != null) {
        _filterManager!.initialize(products);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: HamburgerMenu(
        currentFilterManager: _filterManager,
        onFiltersApplied: (filterManager) {
          setState(() {
            _filterManager = filterManager;
          });
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(enrichedProductsAsync),
            _buildManagementButton(),
            if (_filterManager?.hasActiveFilters == true) _buildActiveFilters(),
            _buildSearchAndFilter(),
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

  Widget _buildActiveFilters() {
    if (_filterManager == null || !_filterManager!.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: ActiveFiltersWidget(
        filterManager: _filterManager!,
        onClearAll: () {
          setState(() {
            _filterManager!.clearAllFilters();
          });
        },
        onRemoveFilter: (String filterId) {
          setState(() {
            _filterManager!.removeFilter(filterId);
          });
        },
      ),
    );
  }

  Widget _buildManagementButton() {
    return Padding(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryBrandManagementScreen(),
                ),
              ),
              icon: Icon(
                Icons.settings,
                size: ResponsiveUtils.getResponsiveIconSize(context) * 0.9,
              ),
              label: Text(
                'Kelola Kategori & Brand',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    phoneSize: 14,
                    tabletSize: 16,
                    desktopSize: 18,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.textDark,
                padding: ResponsiveUtils.getResponsivePaddingCustom(
                  context,
                  phoneValue: 12,
                  tabletValue: 14,
                  desktopValue: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
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

    return Padding(
      padding: filterPadding,
      child: Column(
        children: [
          // Search and Advanced Filter Row
          Row(
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
                    // FIX: Direct search like transaction screen - no debouncing for immediate filtering
                    setState(() => _searchQuery = value.toLowerCase());
                    // Don't use FilterManager for search, handle it directly in build methods
                  },
                  onSubmitted: (value) {
                    // Keep this for consistency but search is already applied
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
              ),
              SizedBox(width: filterSpacing),
              // Advanced Filter Button
              Container(
                decoration: BoxDecoration(
                  color: _filterManager?.hasActiveFilters == true
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context),
                  ),
                  border: Border.all(
                    color: _filterManager?.hasActiveFilters == true
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: IconButton(
                  onPressed: _openAdvancedFilter,
                  icon: Stack(
                    children: [
                      Icon(
                        Icons.tune,
                        color: _filterManager?.hasActiveFilters == true
                            ? AppColors.primary
                            : AppColors.textGray,
                      ),
                      if (_filterManager?.hasActiveFilters == true)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 12,
                              minHeight: 12,
                            ),
                            child: Text(
                              '${_filterManager!.activeFilterCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  tooltip: 'Filter Lanjutan',
                ),
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: 8,
              tabletSpacing: 10,
              desktopSpacing: 12,
            ),
          ),
        ],
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
        // Always initialize FilterManager with products
        if (_filterManager != null) {
          _filterManager!.initialize(products);
        }

        // FIX: Apply search query directly to products first, then use FilterManager for advanced filters
        var searchFiltered = products;
        if (_searchQuery.isNotEmpty) {
          searchFiltered = products
              .where(
                (p) =>
                    p.name.toLowerCase().contains(_searchQuery) ||
                    (p.sku?.toLowerCase().contains(_searchQuery) ?? false) ||
                    (p.category?.name.toLowerCase().contains(_searchQuery) ??
                        false) ||
                    (p.brand?.name.toLowerCase().contains(_searchQuery) ??
                        false),
              )
              .toList();
        }

        // Then apply FilterManager filters (excluding search since we handle it above)
        final displayProducts = _filterManager != null
            ? _filterManager!.applyFiltersToProducts(
                searchFiltered,
                excludeSearch: true,
              )
            : searchFiltered;

        // Build filter summary
        String filterSummary;
        if (_searchQuery.isNotEmpty &&
            _filterManager?.hasActiveFilters == true) {
          filterSummary =
              'Pencarian: "$_searchQuery" + ${_filterManager!.activeFilterCount} filter';
        } else if (_searchQuery.isNotEmpty) {
          filterSummary = 'Pencarian: "$_searchQuery"';
        } else if (_filterManager?.hasActiveFilters == true) {
          filterSummary = _filterManager!.getFilterSummary();
        } else {
          filterSummary = 'Semua Produk';
        }

        return Padding(
          padding: resultPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  filterSummary,
                  style: TextStyle(
                    fontSize: resultFontSize,
                    color: AppColors.textGray,
                  ),
                ),
              ),
              Container(
                padding: ResponsiveUtils.getResponsivePaddingCustom(
                  context,
                  phoneValue: 6,
                  tabletValue: 8,
                  desktopValue: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
                  ),
                ),
                child: Text(
                  '${displayProducts.length} produk',
                  style: TextStyle(
                    fontSize: resultFontSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
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
        // Always initialize FilterManager with products
        if (_filterManager != null) {
          _filterManager!.initialize(products);
        }

        // FIX: Apply search query directly to products first, then use FilterManager for advanced filters
        var searchFiltered = products;
        if (_searchQuery.isNotEmpty) {
          searchFiltered = products
              .where(
                (p) =>
                    p.name.toLowerCase().contains(_searchQuery) ||
                    (p.sku?.toLowerCase().contains(_searchQuery) ?? false) ||
                    (p.category?.name.toLowerCase().contains(_searchQuery) ??
                        false) ||
                    (p.brand?.name.toLowerCase().contains(_searchQuery) ??
                        false),
              )
              .toList();
        }

        // Then apply FilterManager filters (excluding search since we handle it above)
        final displayProducts = _filterManager != null
            ? _filterManager!.applyFiltersToProducts(
                searchFiltered,
                excludeSearch: true,
              )
            : searchFiltered;

        if (displayProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isNotEmpty ||
                          _filterManager?.hasActiveFilters == true
                      ? Icons.search_off
                      : Icons.inventory_2_outlined,
                  size: ResponsiveUtils.getResponsiveIconSize(context) * 3,
                  color: AppColors.textGray,
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: 16,
                    tabletSpacing: 20,
                    desktopSpacing: 24,
                  ),
                ),
                Text(
                  _searchQuery.isNotEmpty ||
                          _filterManager?.hasActiveFilters == true
                      ? 'Tidak ada produk yang sesuai'
                      : 'Tidak ada produk',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontSize: emptyStateFontSize,
                  ),
                ),
                if (_searchQuery.isNotEmpty ||
                    _filterManager?.hasActiveFilters == true) ...[
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 8,
                      tabletSpacing: 10,
                      desktopSpacing: 12,
                    ),
                  ),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Coba kata kunci lain atau hapus filter'
                        : 'Coba ubah filter atau kata kunci pencarian',
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: emptyStateFontSize * 0.9,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(enrichedProductsProvider);
          },
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: listPadding.left),
            itemCount: displayProducts.length,
            cacheExtent: 500,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
            itemBuilder: (context, index) {
              final product = displayProducts[index];
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

  void _openAdvancedFilter() async {
    final result = await Navigator.push<FilterManager>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AdvancedFilterScreen(existingFilterManager: _filterManager),
      ),
    );

    if (result != null) {
      setState(() {
        _filterManager = result;
      });
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
