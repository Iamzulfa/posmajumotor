import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/constants/supabase_config.dart';
import '../../../../data/models/models.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../providers/product_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchController = TextEditingController();

  // Mock data for offline mode
  final List<Map<String, dynamic>> _mockProducts = [
    {
      'name': 'Ban Michelin 90/90 Ring 14',
      'category': 'Ban',
      'brand': 'Michelin',
      'stock': 15,
      'margin': 35,
      'hpp': 300000,
      'price': 450000,
    },
    {
      'name': 'Oli Shell Helix 1L',
      'category': 'Oli',
      'brand': 'Shell',
      'stock': 32,
      'margin': 28,
      'hpp': 65000,
      'price': 85000,
    },
    {
      'name': 'Rantai Motor 415H',
      'category': 'Rantai',
      'brand': 'DID',
      'stock': 5,
      'margin': 40,
      'hpp': 150000,
      'price': 210000,
    },
    {
      'name': 'Gearset Supra X 125',
      'category': 'Gearset',
      'brand': 'Indopart',
      'stock': 8,
      'margin': 25,
      'hpp': 420000,
      'price': 530000,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Load products on init if Supabase is configured
    if (SupabaseConfig.isConfigured) {
      Future.microtask(() {
        ref.read(productListProvider.notifier).loadProducts();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productListProvider);
    final isOnline = SupabaseConfig.isConfigured;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isOnline),
            _buildSearchAndFilter(productState),
            _buildResultCount(productState),
            Expanded(child: _buildProductList(productState, isOnline)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open add product dialog
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader(bool isOnline) {
    return AppHeader(
      title: 'Inventory',
      syncStatus: isOnline ? SyncStatus.online : SyncStatus.offline,
      lastSyncTime: isOnline ? 'Real-time' : 'Offline mode',
    );
  }

  Widget _buildSearchAndFilter(ProductListState state) {
    final categories = ['Semua', ...state.categories.map((c) => c.name)];
    final selectedCategoryName = state.selectedCategoryId != null
        ? state.categories
              .firstWhere(
                (c) => c.id == state.selectedCategoryId,
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
                ref.read(productListProvider.notifier).setSearchQuery(value);
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
                items: categories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  if (value == 'Semua') {
                    ref
                        .read(productListProvider.notifier)
                        .setSelectedCategory(null);
                  } else {
                    final category = state.categories.firstWhere(
                      (c) => c.name == value,
                    );
                    ref
                        .read(productListProvider.notifier)
                        .setSelectedCategory(category.id);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCount(ProductListState state) {
    final count = SupabaseConfig.isConfigured
        ? state.filteredProducts.length
        : _mockProducts.length;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Hasil: $count produk',
          style: const TextStyle(fontSize: 14, color: AppColors.textGray),
        ),
      ),
    );
  }

  Widget _buildProductList(ProductListState state, bool isOnline) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text(state.error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () =>
                  ref.read(productListProvider.notifier).loadProducts(),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // Use real data if online, mock data if offline
    if (isOnline) {
      final products = state.filteredProducts;
      if (products.isEmpty) {
        return const Center(
          child: Text(
            'Tidak ada produk',
            style: TextStyle(color: AppColors.textGray),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: products.length,
        itemBuilder: (context, index) =>
            _buildProductCardFromModel(products[index]),
      );
    } else {
      // Offline mode with mock data
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _mockProducts.length,
        itemBuilder: (context, index) =>
            _buildProductCardFromMap(_mockProducts[index]),
      );
    }
  }

  Widget _buildProductCardFromModel(ProductModel product) {
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
                onPressed: () {
                  // TODO: Open edit dialog
                },
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
                onPressed: () => _confirmDelete(product),
                color: AppColors.error,
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCardFromMap(Map<String, dynamic> product) {
    final marginColor = product['margin'] >= 30
        ? AppColors.success
        : product['margin'] >= 20
        ? AppColors.warning
        : AppColors.error;
    final stockColor = product['stock'] > 5
        ? AppColors.success
        : AppColors.warning;

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
            product['name'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${product['category']} | ${product['brand']}',
            style: const TextStyle(fontSize: 14, color: AppColors.textGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: stockColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Stok: ${product['stock']}',
                style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              ),
              const SizedBox(width: AppSpacing.lg),
              Text(
                'Margin: ${product['margin']}%',
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
            'HPP: Rp ${_formatNumber(product['hpp'])}  |  Jual: Rp ${_formatNumber(product['price'])}',
            style: const TextStyle(fontSize: 14, color: AppColors.textGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
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
                onPressed: () {},
                color: AppColors.error,
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(productListProvider.notifier).deleteProduct(product.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
