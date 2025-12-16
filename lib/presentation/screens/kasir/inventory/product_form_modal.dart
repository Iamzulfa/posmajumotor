import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../data/models/models.dart';
import '../../../providers/product_provider.dart';

void showProductFormModal(
  BuildContext context, {
  required List<CategoryModel> categories,
  required List<BrandModel> brands,
  ProductModel? product,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => ProductFormModal(
      categories: categories,
      brands: brands,
      product: product,
    ),
  );
}

class ProductFormModal extends ConsumerStatefulWidget {
  final List<CategoryModel> categories;
  final List<BrandModel> brands;
  final ProductModel? product;

  const ProductFormModal({
    super.key,
    required this.categories,
    required this.brands,
    this.product,
  });

  @override
  ConsumerState<ProductFormModal> createState() => _ProductFormModalState();
}

class _ProductFormModalState extends ConsumerState<ProductFormModal> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _hppController;
  late TextEditingController _hargaUmumController;
  late TextEditingController _hargaBengkelController;
  late TextEditingController _hargaGrossirController;
  late TextEditingController _minStockController;

  String? _selectedCategoryId;
  String? _selectedBrandId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _hppController = TextEditingController(
      text: (product?.hpp ?? 0).toString(),
    );
    _hargaUmumController = TextEditingController(
      text: (product?.hargaUmum ?? 0).toString(),
    );
    _hargaBengkelController = TextEditingController(
      text: (product?.hargaBengkel ?? 0).toString(),
    );
    _hargaGrossirController = TextEditingController(
      text: (product?.hargaGrossir ?? 0).toString(),
    );
    _minStockController = TextEditingController(
      text: (product?.minStock ?? 5).toString(),
    );

    _selectedCategoryId = product?.categoryId;
    _selectedBrandId = product?.brandId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _hppController.dispose();
    _hargaUmumController.dispose();
    _hargaBengkelController.dispose();
    _hargaGrossirController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProduct() async {
    if (_nameController.text.isEmpty) {
      _showError('Nama produk tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isEdit = widget.product != null;

      if (isEdit && widget.product!.id.isEmpty) {
        _showError('Product ID tidak valid');
        setState(() => _isLoading = false);
        return;
      }

      final productData = ProductModel(
        id: isEdit ? widget.product!.id : '',
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        categoryId: _selectedCategoryId,
        brandId: _selectedBrandId,
        hpp: int.tryParse(_hppController.text) ?? 0,
        hargaUmum: int.tryParse(_hargaUmumController.text) ?? 0,
        hargaBengkel: int.tryParse(_hargaBengkelController.text) ?? 0,
        hargaGrossir: int.tryParse(_hargaGrossirController.text) ?? 0,
        minStock: int.tryParse(_minStockController.text) ?? 5,
        stock: widget.product?.stock ?? 0,
        isActive: widget.product?.isActive ?? true,
      );

      if (isEdit) {
        await ref.read(productRepositoryProvider).updateProduct(productData);
      } else {
        await ref.read(productRepositoryProvider).createProduct(productData);
      }

      if (mounted) {
        // Invalidate stream to refresh UI
        ref.invalidate(productsStreamProvider);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Produk berhasil diperbarui'
                  : 'Produk berhasil ditambahkan',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final title = isEdit ? 'Edit Produk' : 'Tambah Produk Baru';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textGray,
                  ),
                ],
              ),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.lg),

              // Nama Produk
              _buildTextField(
                'Nama Produk *',
                _nameController,
                'Masukkan nama produk',
              ),
              const SizedBox(height: AppSpacing.md),

              // Kategori & Brand
              Row(
                children: [
                  Expanded(child: _buildCategoryDropdown()),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildBrandDropdown()),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Deskripsi
              _buildTextField(
                'Deskripsi',
                _descriptionController,
                'Deskripsi produk (opsional)',
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.lg),

              // HPP
              _buildTextField(
                'HPP (Harga Pokok Penjualan)',
                _hppController,
                '0',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),

              // Harga Umum
              _buildTextField(
                'Harga Umum',
                _hargaUmumController,
                '0',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),

              // Harga Bengkel
              _buildTextField(
                'Harga Bengkel',
                _hargaBengkelController,
                '0',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),

              // Harga Grossir
              _buildTextField(
                'Harga Grossir',
                _hargaGrossirController,
                '0',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.md),

              // Min Stock
              _buildTextField(
                'Min Stock',
                _minStockController,
                '5',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Action Buttons
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        onTap: _isLoading ? null : _handleSaveProduct,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  isEdit ? 'Simpan' : 'Tambah',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textGray,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textGray),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textGray,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategoryId,
              isExpanded: true,
              hint: const Text('Tidak ada'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tidak ada')),
                ...widget.categories.map(
                  (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                ),
              ],
              onChanged: _isLoading
                  ? null
                  : (value) => setState(() => _selectedCategoryId = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Brand',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textGray,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedBrandId,
              isExpanded: true,
              hint: const Text('Tidak ada'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Tidak ada')),
                ...widget.brands.map(
                  (b) => DropdownMenuItem(value: b.id, child: Text(b.name)),
                ),
              ],
              onChanged: _isLoading
                  ? null
                  : (value) => setState(() => _selectedBrandId = value),
            ),
          ),
        ),
      ],
    );
  }
}
