import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/pill_selector.dart';
import '../../../widgets/common/custom_button.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedTier = 'UMUM';
  String _selectedPayment = 'CASH';
  final List<Map<String, dynamic>> _cart = [];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Ban Michelin 90/90 Ring 14',
      'stock': 15,
      'priceUmum': 450000,
      'priceBengkel': 420000,
      'priceGrossir': 380000,
    },
    {
      'name': 'Oli Shell Helix 1L',
      'stock': 32,
      'priceUmum': 85000,
      'priceBengkel': 78000,
      'priceGrossir': 70000,
    },
    {
      'name': 'Rantai Motor 415H',
      'stock': 5,
      'priceUmum': 210000,
      'priceBengkel': 195000,
      'priceGrossir': 175000,
    },
    {
      'name': 'Gearset Supra X 125',
      'stock': 8,
      'priceUmum': 530000,
      'priceBengkel': 490000,
      'priceGrossir': 450000,
    },
    {
      'name': 'Aki Kering 5A',
      'stock': 12,
      'priceUmum': 380000,
      'priceBengkel': 350000,
      'priceGrossir': 320000,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int _getPrice(Map<String, dynamic> product) {
    switch (_selectedTier) {
      case 'BENGKEL':
        return product['priceBengkel'];
      case 'GROSSIR':
        return product['priceGrossir'];
      default:
        return product['priceUmum'];
    }
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingIndex = _cart.indexWhere(
        (item) => item['name'] == product['name'],
      );
      if (existingIndex >= 0) {
        _cart[existingIndex]['quantity']++;
      } else {
        _cart.add({...product, 'quantity': 1, 'price': _getPrice(product)});
      }
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _cart[index]['quantity'] += delta;
      if (_cart[index]['quantity'] <= 0) _cart.removeAt(index);
    });
  }

  int get _subtotal => _cart.fold(
    0,
    (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Transaksi Penjualan',
              syncStatus: SyncStatus.online,
              lastSyncTime: '2 min ago',
            ),
            // Tier Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: PillSelector<String>(
                label: 'Tier Pembeli',
                items: const ['UMUM', 'BENGKEL', 'GROSSIR'],
                selectedItem: _selectedTier,
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
                onSelected: (item) => setState(() => _selectedTier = item),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Product Section Header
            Padding(
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
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Product List (always visible)
            SizedBox(
              height: 180,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: _products.length,
                itemBuilder: (context, index) =>
                    _buildProductItem(_products[index]),
              ),
            ),
            // Cart Section (if has items)
            if (_cart.isNotEmpty) ...[
              const Divider(height: 1),
              Expanded(child: _buildCartSection()),
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

  Widget _buildProductItem(Map<String, dynamic> product) {
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
                  product['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Stok: ${product['stock']} | Rp ${_formatNumber(_getPrice(product))}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, size: 32),
            color: AppColors.primary,
            onPressed: () => _addToCart(product),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSection() {
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
                  'Keranjang (${_cart.length})',
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
            itemCount: _cart.length,
            itemBuilder: (context, index) =>
                _buildCartItem(_cart[index], index),
          ),
          const SizedBox(height: AppSpacing.md),
          // Summary
          _buildSummary(),
          const SizedBox(height: AppSpacing.md),
          // Payment Method
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: PillSelector<String>(
              label: 'Metode Pembayaran',
              items: const ['CASH', 'TRANSFER', 'QRIS'],
              selectedItem: _selectedPayment,
              itemLabel: (item) => item,
              onSelected: (item) => setState(() => _selectedPayment = item),
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
                    onPressed: () => setState(() => _cart.clear()),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'Selesaikan',
                    icon: Icons.check,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaksi berhasil!')),
                      );
                      setState(() => _cart.clear());
                    },
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

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    final subtotal = (item['price'] as int) * (item['quantity'] as int);
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
                  item['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _cart.removeAt(index)),
                color: AppColors.error,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Text(
            'Rp ${_formatNumber(item['price'])} x ${item['quantity']}',
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
                    () => _updateQuantity(index, -1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Text(
                      '${item['quantity']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    Icons.add,
                    () => _updateQuantity(index, 1),
                  ),
                ],
              ),
              Text(
                'Rp ${_formatNumber(subtotal)}',
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

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 20, color: AppColors.textGray),
      ),
    );
  }

  Widget _buildSummary() {
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
          _buildSummaryRow('Subtotal', _subtotal),
          const SizedBox(height: AppSpacing.xs),
          _buildSummaryRow('Diskon', 0),
          const Divider(height: AppSpacing.md),
          _buildSummaryRow('Total', _subtotal, isTotal: true),
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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
