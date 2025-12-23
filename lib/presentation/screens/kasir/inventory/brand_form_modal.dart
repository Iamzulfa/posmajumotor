import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../data/models/models.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../providers/product_provider.dart';

void showBrandFormModal(BuildContext context, {BrandModel? brand}) {
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
    builder: (context) => BrandFormModal(brand: brand),
  );
}

class BrandFormModal extends ConsumerStatefulWidget {
  final BrandModel? brand;

  const BrandFormModal({super.key, this.brand});

  @override
  ConsumerState<BrandFormModal> createState() => _BrandFormModalState();
}

class _BrandFormModalState extends ConsumerState<BrandFormModal> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final brand = widget.brand;

    // Debug: Log brand data
    if (brand != null) {
      AppLogger.info('Initializing brand form with: ${brand.name}');
    } else {
      AppLogger.info('Initializing form for new brand');
    }

    _nameController = TextEditingController(text: brand?.name ?? '');
    _descriptionController = TextEditingController(
      text: brand?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveBrand() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Nama brand tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isEdit = widget.brand != null;
      final brandId = widget.brand?.id ?? '';

      AppLogger.info(
        'Saving brand: isEdit=$isEdit, brandId=$brandId, name=${_nameController.text}',
      );

      if (isEdit && brandId.isEmpty) {
        AppLogger.error('Brand ID is empty for edit operation');
        _showError('Brand ID tidak valid');
        setState(() => _isLoading = false);
        return;
      }

      final brandData = BrandModel(
        id: brandId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isActive: widget.brand?.isActive ?? true,
      );

      AppLogger.info('Brand data prepared: ${brandData.toJson()}');

      if (isEdit) {
        AppLogger.info('Calling updateBrand...');
        await ref.read(productRepositoryProvider).updateBrand(brandData);
        AppLogger.info('updateBrand completed');
      } else {
        AppLogger.info('Calling createBrand...');
        await ref.read(productRepositoryProvider).createBrand(brandData);
        AppLogger.info('createBrand completed');
      }

      if (mounted) {
        // Invalidate brand providers to refresh all UIs
        ref.invalidate(brandsStreamProvider);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Brand berhasil diperbarui'
                  : 'Brand berhasil ditambahkan',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error saving brand', e, stackTrace);
      final userFriendlyError = ErrorHandler.getErrorMessage(e);
      _showError(userFriendlyError);
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
    final isEdit = widget.brand != null;
    final title = isEdit ? 'Edit Brand' : 'Tambah Brand Baru';

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

              // Nama Brand
              _buildTextField(
                'Nama Brand *',
                _nameController,
                'Masukkan nama brand',
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
                'Deskripsi brand (opsional)',
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
                        onTap: _isLoading ? null : _handleSaveBrand,
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
}
