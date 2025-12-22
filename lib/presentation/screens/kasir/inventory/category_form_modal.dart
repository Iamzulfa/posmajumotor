import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../data/models/models.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../providers/product_provider.dart';

void showCategoryFormModal(BuildContext context, {CategoryModel? category}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => CategoryFormModal(category: category),
  );
}

class CategoryFormModal extends ConsumerStatefulWidget {
  final CategoryModel? category;

  const CategoryFormModal({super.key, this.category});

  @override
  ConsumerState<CategoryFormModal> createState() => _CategoryFormModalState();
}

class _CategoryFormModalState extends ConsumerState<CategoryFormModal> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final category = widget.category;

    // Debug: Log category data
    if (category != null) {
      AppLogger.info('Initializing category form with: ${category.name}');
    } else {
      AppLogger.info('Initializing form for new category');
    }

    _nameController = TextEditingController(text: category?.name ?? '');
    _descriptionController = TextEditingController(
      text: category?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveCategory() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Nama kategori tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isEdit = widget.category != null;
      final categoryId = widget.category?.id ?? '';

      AppLogger.info(
        'Saving category: isEdit=$isEdit, categoryId=$categoryId, name=${_nameController.text}',
      );

      if (isEdit && categoryId.isEmpty) {
        AppLogger.error('Category ID is empty for edit operation');
        _showError('Category ID tidak valid');
        setState(() => _isLoading = false);
        return;
      }

      final categoryData = CategoryModel(
        id: categoryId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isActive: widget.category?.isActive ?? true,
      );

      AppLogger.info('Category data prepared: ${categoryData.toJson()}');

      if (isEdit) {
        AppLogger.info('Calling updateCategory...');
        await ref.read(productRepositoryProvider).updateCategory(categoryData);
        AppLogger.info('updateCategory completed');
      } else {
        AppLogger.info('Calling createCategory...');
        await ref.read(productRepositoryProvider).createCategory(categoryData);
        AppLogger.info('createCategory completed');
      }

      if (mounted) {
        // Invalidate category providers to refresh all UIs
        ref.invalidate(categoriesStreamProvider);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Kategori berhasil diperbarui'
                  : 'Kategori berhasil ditambahkan',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error saving category', e, stackTrace);
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
    final isEdit = widget.category != null;
    final title = isEdit ? 'Edit Kategori' : 'Tambah Kategori Baru';

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

              // Nama Kategori
              _buildTextField(
                'Nama Kategori *',
                _nameController,
                'Masukkan nama kategori',
              ),
              const SizedBox(height: AppSpacing.md),

              // Deskripsi
              _buildTextField(
                'Deskripsi',
                _descriptionController,
                'Deskripsi kategori (opsional)',
                maxLines: 3,
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
                        onTap: _isLoading ? null : _handleSaveCategory,
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
}
