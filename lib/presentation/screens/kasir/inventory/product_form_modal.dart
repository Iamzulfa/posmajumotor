import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../data/models/models.dart';
import '../../../../core/utils/logger.dart';
import '../../../widgets/common/searchable_dropdown.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/inventory_provider.dart';

void showProductFormModal(
  BuildContext context, {
  required List<CategoryModel> categories,
  required List<BrandModel> brands,
  ProductModel? product,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
      ),
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
  late TextEditingController _stockController;
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

    // Debug: Log product data
    if (product != null) {
      AppLogger.info('Initializing form with product: ${product.name}');
      AppLogger.info(
        'Product prices: hpp=${product.hpp}, hargaUmum=${product.hargaUmum}, hargaBengkel=${product.hargaBengkel}, hargaGrossir=${product.hargaGrossir}',
      );
    } else {
      AppLogger.info('Initializing form for new product');
    }

    _nameController = TextEditingController(text: product?.name ?? '');
    _descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    _stockController = TextEditingController(
      text: (product?.stock ?? 0).toString(),
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
    _stockController.dispose();
    _hppController.dispose();
    _hargaUmumController.dispose();
    _hargaBengkelController.dispose();
    _hargaGrossirController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProduct() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Nama produk tidak boleh kosong');
      return;
    }

    final stock = int.tryParse(_stockController.text) ?? 0;
    final hpp = int.tryParse(_hppController.text) ?? 0;
    final hargaUmum = int.tryParse(_hargaUmumController.text) ?? 0;

    if (stock <= 0) {
      _showError('Stok harus lebih dari 0');
      return;
    }

    if (hpp <= 0) {
      _showError('HPP harus lebih dari 0');
      return;
    }

    if (hargaUmum <= 0) {
      _showError('Harga Umum harus lebih dari 0');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isEdit = widget.product != null;
      final productId = widget.product?.id ?? '';

      AppLogger.info(
        'Saving product: isEdit=$isEdit, productId=$productId, name=${_nameController.text}',
      );

      if (isEdit && productId.isEmpty) {
        AppLogger.error('Product ID is empty for edit operation');
        _showError('Product ID tidak valid');
        setState(() => _isLoading = false);
        return;
      }

      // Generate SKU for new products
      final sku = isEdit
          ? widget.product!.sku
          : 'SKU-${DateTime.now().millisecondsSinceEpoch}';

      final productData = ProductModel(
        id: productId,
        sku: sku,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        categoryId: _selectedCategoryId,
        brandId: _selectedBrandId,
        stock: int.tryParse(_stockController.text) ?? 0,
        hpp: int.tryParse(_hppController.text) ?? 0,
        hargaUmum: int.tryParse(_hargaUmumController.text) ?? 0,
        hargaBengkel: int.tryParse(_hargaBengkelController.text) ?? 0,
        hargaGrossir: int.tryParse(_hargaGrossirController.text) ?? 0,
        minStock: int.tryParse(_minStockController.text) ?? 5,
        isActive: widget.product?.isActive ?? true,
      );

      AppLogger.info('Product data prepared: ${productData.toJson()}');

      if (isEdit) {
        AppLogger.info('Calling updateProduct...');
        await ref.read(productRepositoryProvider).updateProduct(productData);
        AppLogger.info('updateProduct completed');
      } else {
        AppLogger.info('Calling createProduct...');
        await ref.read(productRepositoryProvider).createProduct(productData);
        AppLogger.info('createProduct completed');
      }

      if (mounted) {
        // Force refresh all product-related providers
        ref.invalidate(productsStreamProvider);
        ref.invalidate(productsProvider);
        ref.invalidate(enrichedProductsProvider);
        ref.invalidate(categoriesStreamProvider);
        ref.invalidate(brandsStreamProvider);
        ref.invalidate(productListProvider);

        // Wait a moment for providers to refresh
        await Future.delayed(const Duration(milliseconds: 100));

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
    } catch (e, stackTrace) {
      AppLogger.error('Error saving product', e, stackTrace);
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
          padding: ResponsiveUtils.getResponsivePadding(context),
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
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        phoneSize: 18,
                        tabletSize: 20,
                        desktopSize: 22,
                      ),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: ResponsiveUtils.getResponsiveIconSize(context),
                    ),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textGray,
                  ),
                ],
              ),
              const Divider(color: AppColors.border),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.lg,
                  tabletSpacing: AppSpacing.xl,
                  desktopSpacing: 24,
                ),
              ),

              // Nama Produk
              _buildTextField(
                'Nama Produk *',
                _nameController,
                'Masukkan nama produk',
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.md,
                  tabletSpacing: AppSpacing.lg,
                  desktopSpacing: 20,
                ),
              ),

              // Kategori & Brand - Now with searchable dropdowns
              ResponsiveUtils.isPhone(context)
                  ? Column(
                      children: [
                        SearchableDropdown<CategoryModel>(
                          label: 'Kategori',
                          hint: 'Pilih kategori',
                          items: widget.categories,
                          selectedItem: widget.categories
                              .where((c) => c.id == _selectedCategoryId)
                              .firstOrNull,
                          itemLabel: (category) => category.name,
                          itemValue: (category) => category.id,
                          onChanged: (category) {
                            setState(() => _selectedCategoryId = category?.id);
                          },
                          enabled: !_isLoading,
                          maxDisplayItems: 15,
                        ),
                        SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            phoneSpacing: AppSpacing.md,
                            tabletSpacing: AppSpacing.lg,
                            desktopSpacing: 16,
                          ),
                        ),
                        SearchableDropdown<BrandModel>(
                          label: 'Brand',
                          hint: 'Pilih brand',
                          items: widget.brands,
                          selectedItem: widget.brands
                              .where((b) => b.id == _selectedBrandId)
                              .firstOrNull,
                          itemLabel: (brand) => brand.name,
                          itemValue: (brand) => brand.id,
                          onChanged: (brand) {
                            setState(() => _selectedBrandId = brand?.id);
                          },
                          enabled: !_isLoading,
                          maxDisplayItems: 15,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: SearchableDropdown<CategoryModel>(
                            label: 'Kategori',
                            hint: 'Pilih kategori',
                            items: widget.categories,
                            selectedItem: widget.categories
                                .where((c) => c.id == _selectedCategoryId)
                                .firstOrNull,
                            itemLabel: (category) => category.name,
                            itemValue: (category) => category.id,
                            onChanged: (category) {
                              setState(
                                () => _selectedCategoryId = category?.id,
                              );
                            },
                            enabled: !_isLoading,
                            maxDisplayItems: 15,
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            phoneSpacing: AppSpacing.md,
                            tabletSpacing: AppSpacing.lg,
                            desktopSpacing: 20,
                          ),
                        ),
                        Expanded(
                          child: SearchableDropdown<BrandModel>(
                            label: 'Brand',
                            hint: 'Pilih brand',
                            items: widget.brands,
                            selectedItem: widget.brands
                                .where((b) => b.id == _selectedBrandId)
                                .firstOrNull,
                            itemLabel: (brand) => brand.name,
                            itemValue: (brand) => brand.id,
                            onChanged: (brand) {
                              setState(() => _selectedBrandId = brand?.id);
                            },
                            enabled: !_isLoading,
                            maxDisplayItems: 15,
                          ),
                        ),
                      ],
                    ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.md,
                  tabletSpacing: AppSpacing.lg,
                  desktopSpacing: 20,
                ),
              ),

              // Deskripsi
              _buildTextField(
                'Deskripsi',
                _descriptionController,
                'Deskripsi produk (opsional)',
                maxLines: 3,
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.lg,
                  tabletSpacing: AppSpacing.xl,
                  desktopSpacing: 24,
                ),
              ),

              // Stok
              _buildTextField(
                'Stok *',
                _stockController,
                '0',
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.md,
                  tabletSpacing: AppSpacing.lg,
                  desktopSpacing: 16,
                ),
              ),

              // HPP
              _buildTextField(
                'HPP (Harga Pokok Penjualan) *',
                _hppController,
                '0',
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.md,
                  tabletSpacing: AppSpacing.lg,
                  desktopSpacing: 16,
                ),
              ),

              // Harga Umum
              _buildTextField(
                'Harga Umum *',
                _hargaUmumController,
                '0',
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.md,
                  tabletSpacing: AppSpacing.lg,
                  desktopSpacing: 16,
                ),
              ),

              // Harga Bengkel & Grossir - Responsive layout
              ResponsiveUtils.isPhone(context)
                  ? Column(
                      children: [
                        _buildTextField(
                          'Harga Bengkel',
                          _hargaBengkelController,
                          '0',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            phoneSpacing: AppSpacing.md,
                            tabletSpacing: AppSpacing.lg,
                            desktopSpacing: 16,
                          ),
                        ),
                        _buildTextField(
                          'Harga Grossir',
                          _hargaGrossirController,
                          '0',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Harga Bengkel',
                            _hargaBengkelController,
                            '0',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            phoneSpacing: AppSpacing.md,
                            tabletSpacing: AppSpacing.lg,
                            desktopSpacing: 20,
                          ),
                        ),
                        Expanded(
                          child: _buildTextField(
                            'Harga Grossir',
                            _hargaGrossirController,
                            '0',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.md,
                  tabletSpacing: AppSpacing.lg,
                  desktopSpacing: 16,
                ),
              ),

              // Min Stock
              _buildTextField(
                'Min Stock',
                _minStockController,
                '5',
                keyboardType: TextInputType.number,
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.lg,
                  tabletSpacing: AppSpacing.xl,
                  desktopSpacing: 24,
                ),
              ),

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
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            phoneSize: 14,
                            tabletSize: 16,
                            desktopSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        phoneSpacing: AppSpacing.md,
                        tabletSpacing: AppSpacing.lg,
                        desktopSpacing: 20,
                      ),
                    ),
                    Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context) *
                            0.5,
                      ),
                      child: InkWell(
                        onTap: _isLoading ? null : _handleSaveProduct,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context) *
                              0.5,
                        ),
                        child: Padding(
                          padding:
                              ResponsiveUtils.getResponsivePaddingCustom(
                                context,
                                phoneValue: AppSpacing.lg,
                                tabletValue: AppSpacing.xl,
                                desktopValue: 20,
                              ).copyWith(
                                top: ResponsiveUtils.getResponsiveSpacing(
                                  context,
                                  phoneSpacing: AppSpacing.md,
                                  tabletSpacing: AppSpacing.lg,
                                  desktopSpacing: 16,
                                ),
                                bottom: ResponsiveUtils.getResponsiveSpacing(
                                  context,
                                  phoneSpacing: AppSpacing.md,
                                  tabletSpacing: AppSpacing.lg,
                                  desktopSpacing: 16,
                                ),
                              ),
                          child: _isLoading
                              ? SizedBox(
                                  width:
                                      ResponsiveUtils.getResponsiveIconSize(
                                        context,
                                      ) *
                                      0.7,
                                  height:
                                      ResponsiveUtils.getResponsiveIconSize(
                                        context,
                                      ) *
                                      0.7,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  isEdit ? 'Simpan' : 'Tambah',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        ResponsiveUtils.getResponsiveFontSize(
                                          context,
                                          phoneSize: 14,
                                          tabletSize: 16,
                                          desktopSize: 18,
                                        ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.md,
                  tabletSpacing: AppSpacing.lg,
                  desktopSpacing: 20,
                ),
              ),
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
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 12,
              tabletSize: 14,
              desktopSize: 16,
            ),
            fontWeight: FontWeight.w500,
            color: AppColors.textGray,
          ),
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            phoneSpacing: AppSpacing.xs,
            tabletSpacing: AppSpacing.sm,
            desktopSpacing: 8,
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: !_isLoading,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 14,
              tabletSize: 16,
              desktopSize: 18,
            ),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.textGray,
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                phoneSize: 14,
                tabletSize: 16,
                desktopSize: 18,
              ),
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding:
                ResponsiveUtils.getResponsivePaddingCustom(
                  context,
                  phoneValue: AppSpacing.md,
                  tabletValue: AppSpacing.lg,
                  desktopValue: 16,
                ).copyWith(
                  top: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: AppSpacing.sm,
                    tabletSpacing: AppSpacing.md,
                    desktopSpacing: 12,
                  ),
                  bottom: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: AppSpacing.sm,
                    tabletSpacing: AppSpacing.md,
                    desktopSpacing: 12,
                  ),
                ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context),
              ),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context),
              ),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context),
              ),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
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
