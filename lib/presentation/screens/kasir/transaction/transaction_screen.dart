import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../data/models/models.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/pill_selector.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/transaction_provider.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen> {
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Invalidate products stream when screen is opened to get latest data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(productsStreamProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
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
    // Watch products - use non-stream provider for now (real-time has issues)
    // TODO: Switch back to productsStreamProvider once real-time is fixed
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final brandsAsync = ref.watch(brandsStreamProvider);
    final cartState = ref.watch(cartProvider);
    final transactionState = ref.watch(transactionListProvider);

    // Combine all async data
    final enrichedProductsAsync = productsAsync.when(
      data: (products) {
        return categoriesAsync.when(
          data: (categories) {
            return brandsAsync.when(
              data: (brands) {
                final enriched = _enrichProductsWithRelations(
                  products,
                  categories,
                  brands,
                );
                // Debug: log product count
                if (enriched.isNotEmpty) {
                  debugPrint(
                    'Transaction screen: ${enriched.length} products loaded',
                  );
                }
                return AsyncValue.data(enriched);
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

    final syncStatus = enrichedProductsAsync.when(
      data: (_) => SyncStatus.online,
      loading: () => SyncStatus.syncing,
      error: (_, __) => SyncStatus.offline,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Transaksi Penjualan',
              syncStatus: syncStatus,
              lastSyncTime: syncStatus == SyncStatus.online
                  ? 'Real-time'
                  : 'Syncing...',
            ),
            // Tier Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: PillSelector<String>(
                label: 'Tier Pembeli',
                items: const ['UMUM', 'BENGKEL', 'GROSSIR'],
                selectedItem: cartState.tier,
                itemLabel: (item) {
                  switch (item) {
                    case 'UMUM':
                      return 'Orang Umum';
                    case 'BENGKEL':
                      return 'Bengkel';
                    case 'GROSSIR':
                      return 'Grossir';
                    default:
                      return item;
                  }
                },
                onSelected: (item) =>
                    ref.read(cartProvider.notifier).setTier(item),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Product Section
            _buildProductSection(cartState),
            const SizedBox(height: AppSpacing.sm),
            // Product List
            SizedBox(
              height: 180,
              child: _buildProductList(enrichedProductsAsync, cartState),
            ),
            // Cart Section
            if (cartState.items.isNotEmpty) ...[
              const Divider(height: 1),
              Expanded(child: _buildCartSection(cartState, transactionState)),
            ] else
              const Expanded(
                child: Center(
                  child: Text(
                    'Keranjang kosong\nTambahkan produk untuk memulai transaksi',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textGray),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSection(CartState cartState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Produk Tersedia',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value.toLowerCase());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(
    AsyncValue<List<ProductModel>> productsAsync,
    CartState cartState,
  ) {
    return productsAsync.when(
      data: (products) {
        // Filter by stock > 0 first
        var filtered = products.where((p) => p.stock > 0).toList();

        // Then filter by search query
        if (_searchQuery.isNotEmpty) {
          filtered = filtered
              .where(
                (p) =>
                    p.name.toLowerCase().contains(_searchQuery) ||
                    (p.sku?.toLowerCase().contains(_searchQuery) ?? false),
              )
              .toList();
        }

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada produk',
              style: TextStyle(color: AppColors.textGray),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: filtered.length,
          itemBuilder: (context, index) =>
              _buildProductItemFromModel(filtered[index], cartState.tier),
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildProductItemFromModel(ProductModel product, String tier) {
    final price = product.getPriceByTier(tier);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Stok: ${product.stock} | Rp ${_formatNumber(price)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: product.stock > 0
                        ? AppColors.textGray
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, size: 32),
            color: product.stock > 0 ? AppColors.primary : AppColors.textGray,
            onPressed: product.stock > 0
                ? () => ref.read(cartProvider.notifier).addItem(product)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCartSection(
    CartState cartState,
    TransactionListState transactionState,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cart Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Keranjang (${cartState.items.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          // Cart Items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: cartState.items.length,
            itemBuilder: (context, index) =>
                _buildCartItem(cartState.items[index]),
          ),
          const SizedBox(height: AppSpacing.md),
          // Summary
          _buildSummary(cartState),
          const SizedBox(height: AppSpacing.md),
          // Payment Method
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: PillSelector<String>(
              label: 'Metode Pembayaran',
              items: const ['CASH', 'TRANSFER', 'QRIS'],
              selectedItem: cartState.paymentMethod,
              itemLabel: (item) => item,
              onSelected: (item) =>
                  ref.read(cartProvider.notifier).setPaymentMethod(item),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Notes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan (Opsional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: 'Tambahkan catatan...',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) =>
                      ref.read(cartProvider.notifier).setNotes(value),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Batal',
                    variant: ButtonVariant.secondary,
                    onPressed: () {
                      ref.read(cartProvider.notifier).clearCart();
                      _notesController.clear();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'Selesaikan',
                    icon: Icons.check,
                    isLoading: transactionState.isLoading,
                    onPressed: () => _completeTransaction(cartState),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () =>
                    ref.read(cartProvider.notifier).removeItem(item.product.id),
                color: AppColors.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Text(
            'Rp ${_formatNumber(item.unitPrice)} x ${item.quantity}',
            style: const TextStyle(fontSize: 14, color: AppColors.textGray),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildQuantityButton(
                    Icons.remove,
                    () => ref
                        .read(cartProvider.notifier)
                        .decrementQuantity(item.product.id),
                  ),
                  GestureDetector(
                    onTap: () => _showQuantityDialog(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    Icons.add,
                    item.quantity < item.product.stock
                        ? () => ref
                              .read(cartProvider.notifier)
                              .incrementQuantity(item.product.id)
                        : null,
                  ),
                ],
              ),
              Text(
                'Rp ${_formatNumber(item.subtotal)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback? onPressed) {
    final isEnabled = onPressed != null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isEnabled
                ? AppColors.border
                : AppColors.textGray.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isEnabled
              ? AppColors.textGray
              : AppColors.textGray.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildSummary(CartState cartState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', cartState.subtotal),
          const SizedBox(height: AppSpacing.xs),
          _buildSummaryRow('Diskon', cartState.discountAmount),
          const Divider(height: AppSpacing.md),
          _buildSummaryRow('Total', cartState.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.textDark : AppColors.textGray,
          ),
        ),
        Text(
          'Rp ${_formatNumber(amount)}',
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Future<void> _completeTransaction(CartState cartState) async {
    if (cartState.items.isEmpty) return;

    // Real transaction with Supabase
    final transaction = await ref
        .read(transactionListProvider.notifier)
        .createTransaction(cartState);

    if (transaction != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaksi berhasil! No: ${transaction.transactionNumber}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      ref.read(cartProvider.notifier).clearCart();
      _notesController.clear();
      // Invalidate stream to refresh products (stock updated)
      ref.invalidate(productsStreamProvider);
    } else if (mounted) {
      final error = ref.read(transactionListProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${error ?? 'Unknown error'}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showQuantityDialog(CartItem item) {
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ubah Jumlah - ${item.product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan jumlah',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Stok tersedia: ${item.product.stock}',
              style: const TextStyle(fontSize: 12, color: AppColors.textGray),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final newQuantity = int.tryParse(quantityController.text) ?? 0;
              if (newQuantity > 0 && newQuantity <= item.product.stock) {
                ref
                    .read(cartProvider.notifier)
                    .updateQuantity(item.product.id, newQuantity);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Jumlah harus antara 1 dan ${item.product.stock}',
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
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
