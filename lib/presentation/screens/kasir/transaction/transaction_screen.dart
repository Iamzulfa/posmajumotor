import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/haptic_feedback_utils.dart';
import '../../../../data/models/models.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/pill_selector.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/post_transaction_receipt_modal.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/transaction_provider.dart';

class TransactionScreen extends ConsumerStatefulWidget {
  const TransactionScreen({super.key});

  @override
  ConsumerState<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends ConsumerState<TransactionScreen>
    with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();
  String _searchQuery = '';

  // Cart toggle animation
  late AnimationController _cartAnimationController;
  late Animation<double> _cartSlideAnimation;
  bool _isCartVisible = false;

  @override
  void initState() {
    super.initState();

    // Initialize cart animation
    _cartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cartSlideAnimation =
        Tween<double>(
          begin: 1.0, // Hidden (off-screen)
          end: 0.0, // Visible (on-screen)
        ).animate(
          CurvedAnimation(
            parent: _cartAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    // Invalidate products stream when screen is opened to get latest data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(productsStreamProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    _cartAnimationController.dispose();
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
    // Watch products - use stream provider for real-time updates
    final productsAsync = ref.watch(productsStreamProvider);
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
      error: (_, _) => SyncStatus.offline,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Main content
          SafeArea(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
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
                // Product List - Now takes full remaining space
                Expanded(
                  child: _buildProductList(enrichedProductsAsync, cartState),
                ),
                // Bottom padding for floating cart button
                SizedBox(height: cartState.items.isNotEmpty ? 80 : 20),
              ],
            ),
          ),

          // Floating Cart Button (when cart has items)
          if (cartState.items.isNotEmpty) _buildFloatingCartButton(cartState),

          // Background overlay when cart is visible
          if (cartState.items.isNotEmpty && _isCartVisible)
            _buildBackgroundOverlay(),

          // Sliding Cart Panel
          if (cartState.items.isNotEmpty)
            _buildSlidingCartPanel(cartState, transactionState),
        ],
      ),
    );
  }

  Widget _buildProductSection(CartState cartState) {
    final titleFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 14,
      tabletSize: 16,
      desktopSize: 18,
    );
    final sectionPadding = ResponsiveUtils.getResponsivePadding(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 8,
      tabletSpacing: 10,
      desktopSpacing: 12,
    );

    return Padding(
      padding: sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produk Tersedia',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: spacing),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.background,
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
        ],
      ),
    );
  }

  Widget _buildProductList(
    AsyncValue<List<ProductModel>> productsAsync,
    CartState cartState,
  ) {
    final listPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 12,
      tabletValue: 14,
      desktopValue: 16,
    );

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
          return Center(
            child: Text(
              'Tidak ada produk',
              style: TextStyle(
                color: AppColors.textGray,
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  phoneSize: 12,
                  tabletSize: 14,
                  desktopSize: 15,
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: listPadding.left),
          itemCount: filtered.length,
          itemBuilder: (context, index) =>
              _buildProductItemFromModel(filtered[index], cartState.tier),
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, _) => Center(
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

  Widget _buildProductItemFromModel(ProductModel product, String tier) {
    final price = product.getPriceByTier(tier);
    final productNameFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 14,
      tabletSize: 16,
      desktopSize: 17,
    );
    final productInfoFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 12,
      tabletSize: 13,
      desktopSize: 14,
    );
    final itemPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 10,
      tabletValue: 12,
      desktopValue: 14,
    );
    final itemMargin = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 6,
      tabletSpacing: 8,
      desktopSpacing: 10,
    );
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context);

    return Container(
      margin: EdgeInsets.only(bottom: itemMargin),
      padding: itemPadding,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
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
                  style: TextStyle(
                    fontSize: productNameFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getPercentageHeight(context, 0.5),
                ),
                Text(
                  'Stok: ${product.stock} | Rp ${_formatNumber(price)}',
                  style: TextStyle(
                    fontSize: productInfoFontSize,
                    color: product.stock > 0
                        ? AppColors.textGray
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle, size: iconSize),
            color: product.stock > 0 ? AppColors.primary : AppColors.textGray,
            onPressed: product.stock > 0
                ? () {
                    HapticFeedbackUtils.lightTap();
                    ref.read(cartProvider.notifier).addItem(product);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // New methods for toggleable cart
  Widget _buildFloatingCartButton(CartState cartState) {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Container(
        height: 64, // Slightly taller for better touch target
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: _toggleCart,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 22,
                        ),
                        if (cartState.items.isNotEmpty)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${cartState.items.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${cartState.items.length} item dalam keranjang',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Rp ${_formatNumber(cartState.total)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isCartVisible ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlidingCartPanel(
    CartState cartState,
    TransactionListState transactionState,
  ) {
    return AnimatedBuilder(
      animation: _cartSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            MediaQuery.of(context).size.height * _cartSlideAnimation.value,
          ),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height, // Full screen height
            decoration: const BoxDecoration(
              color: AppColors.background,
              // No border radius for full screen professional look
            ),
            child: Column(
              children: [
                // Status bar space
                Container(
                  height: MediaQuery.of(context).padding.top,
                  color: AppColors.background,
                ),
                // Cart header with close button - more prominent and professional
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      bottom: BorderSide(color: AppColors.border, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.shopping_cart,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keranjang Belanja',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              '${cartState.items.length} item • Rp ${_formatNumber(cartState.total)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.textGray.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: _toggleCart,
                          icon: const Icon(Icons.close),
                          color: AppColors.textGray,
                          iconSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                // Cart content - takes remaining space
                Expanded(child: _buildCartSection(cartState, transactionState)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleCart() {
    setState(() {
      _isCartVisible = !_isCartVisible;
    });

    if (_isCartVisible) {
      _cartAnimationController.forward();
    } else {
      _cartAnimationController.reverse();
    }
  }

  Widget _buildBackgroundOverlay() {
    return AnimatedBuilder(
      animation: _cartSlideAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - _cartSlideAnimation.value, // Fade in as cart slides up
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withValues(
              alpha: 0.6,
            ), // Slightly darker for better contrast
            child: GestureDetector(
              onTap: _toggleCart, // Close cart when tapping background
              child: Container(),
            ),
          ),
        );
      },
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
            padding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: 12,
              tabletValue: 14,
              desktopValue: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan (Opsional)',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 12,
                      tabletSize: 14,
                      desktopSize: 15,
                    ),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGray,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: 6,
                    tabletSpacing: 8,
                    desktopSpacing: 10,
                  ),
                ),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    hintText: 'Tambahkan catatan...',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context),
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) =>
                      ref.read(cartProvider.notifier).setNotes(value),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: 12,
              tabletSpacing: 14,
              desktopSpacing: 16,
            ),
          ),
          // Action Buttons
          Padding(
            padding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: 12,
              tabletValue: 14,
              desktopValue: 16,
            ),
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
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: 10,
                    tabletSpacing: 12,
                    desktopSpacing: 14,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'Selesaikan',
                    icon: Icons.check,
                    isLoading: transactionState.isLoading,
                    onPressed: () {
                      HapticFeedbackUtils.mediumTap();
                      _completeTransaction(cartState);
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: 12,
              tabletSpacing: 14,
              desktopSpacing: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final productNameFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 14,
      tabletSize: 16,
      desktopSize: 17,
    );
    final priceInfoFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 12,
      tabletSize: 13,
      desktopSize: 14,
    );
    final subtotalFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 14,
      tabletSize: 16,
      desktopSize: 17,
    );
    final itemPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 10,
      tabletValue: 12,
      desktopValue: 14,
    );
    final itemMargin = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 6,
      tabletSpacing: 8,
      desktopSpacing: 10,
    );
    final spacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 8,
      tabletSpacing: 10,
      desktopSpacing: 12,
    );

    return Container(
      margin: EdgeInsets.only(bottom: itemMargin),
      padding: itemPadding,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.product.name,
                  style: TextStyle(
                    fontSize: productNameFontSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  HapticFeedbackUtils.lightTap();
                  ref.read(cartProvider.notifier).removeItem(item.product.id);
                },
                color: AppColors.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Text(
            'Rp ${_formatNumber(item.unitPrice)} x ${item.quantity}',
            style: TextStyle(
              fontSize: priceInfoFontSize,
              color: AppColors.textGray,
            ),
          ),
          SizedBox(height: spacing),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUtils.getPercentageWidth(
                          context,
                          3,
                        ),
                        vertical: ResponsiveUtils.getPercentageHeight(
                          context,
                          1,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            phoneSize: 14,
                            tabletSize: 16,
                            desktopSize: 17,
                          ),
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
                style: TextStyle(
                  fontSize: subtotalFontSize,
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
      onTap: () {
        if (isEnabled) {
          HapticFeedbackUtils.selectionClick();
          onPressed.call();
        }
      },
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
    final summaryPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 10,
      tabletValue: 12,
      desktopValue: 14,
    );
    final summaryMargin = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 12,
      tabletValue: 14,
      desktopValue: 16,
    );
    final spacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 6,
      tabletSpacing: 8,
      desktopSpacing: 10,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: summaryMargin.left),
      padding: summaryPadding,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', cartState.subtotal),
          SizedBox(height: spacing),
          _buildSummaryRow('Diskon', cartState.discountAmount),
          Divider(height: spacing * 2),
          _buildSummaryRow('Total', cartState.total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int amount, {bool isTotal = false}) {
    final labelFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: isTotal ? 14 : 12,
      tabletSize: isTotal ? 16 : 14,
      desktopSize: isTotal ? 17 : 15,
    );
    final amountFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: isTotal ? 16 : 12,
      tabletSize: isTotal ? 18 : 14,
      desktopSize: isTotal ? 20 : 15,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.textDark : AppColors.textGray,
          ),
        ),
        Text(
          'Rp ${_formatNumber(amount)}',
          style: TextStyle(
            fontSize: amountFontSize,
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
      // Success haptic feedback
      HapticFeedbackUtils.success();

      // Clear cart
      ref.read(cartProvider.notifier).clearCart();
      _notesController.clear();
      _toggleCart(); // Close cart panel

      // Invalidate stream to refresh products (stock updated)
      ref.invalidate(productsStreamProvider);

      // Show receipt modal
      await showPostTransactionReceiptModal(context, transaction: transaction);
    } else if (mounted) {
      // Error haptic feedback
      HapticFeedbackUtils.error();

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
    final dialogTitleFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 14,
      tabletSize: 16,
      desktopSize: 17,
    );
    final dialogContentFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 12,
      tabletSize: 13,
      desktopSize: 14,
    );
    final dialogSpacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 10,
      tabletSpacing: 12,
      desktopSpacing: 14,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Ubah Jumlah - ${item.product.name}',
          style: TextStyle(fontSize: dialogTitleFontSize),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan jumlah',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context),
                  ),
                ),
              ),
              autofocus: true,
            ),
            SizedBox(height: dialogSpacing),
            Text(
              'Stok tersedia: ${item.product.stock}',
              style: TextStyle(
                fontSize: dialogContentFontSize,
                color: AppColors.textGray,
              ),
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
