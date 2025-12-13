import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  final List<Map<String, dynamic>> _products = [
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

  List<Map<String, dynamic>> get _filteredProducts {
    var filtered = List<Map<String, dynamic>>.from(_products);
    if (_selectedCategory != 'Semua') {
      filtered = filtered
          .where((p) => p['category'] == _selectedCategory)
          .toList();
    }
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p['name'].toString().toLowerCase().contains(query) ||
                p['brand'].toString().toLowerCase().contains(query),
          )
          .toList();
    }
    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilter(),
            _buildResultCount(),
            Expanded(
              child: _filteredProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada produk',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      child: Column(
                        children: [
                          ..._filteredProducts.map(
                            (product) => _buildProductCard(product),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHeader() {
    return const AppHeader(
      title: 'Inventory',
      syncStatus: SyncStatus.online,
      lastSyncTime: '2 min ago',
    );
  }

  Widget _buildSearchAndFilter() {
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
              onChanged: (value) => setState(() {}),
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
                value: _selectedCategory,
                items: ['Semua', 'Ban', 'Oli', 'Rantai', 'Gearset']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategory = value ?? 'Semua'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCount() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Hasil: ${_filteredProducts.length} produk',
          style: const TextStyle(fontSize: 14, color: AppColors.textGray),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
