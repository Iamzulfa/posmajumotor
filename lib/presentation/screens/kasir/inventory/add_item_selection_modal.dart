import 'package:flutter/material.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/responsive_utils.dart';

enum AddItemType { product, category, brand }

void showAddItemSelectionModal(
  BuildContext context, {
  required Function(AddItemType) onItemSelected,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => AddItemSelectionModal(onItemSelected: onItemSelected),
  );
}

class AddItemSelectionModal extends StatelessWidget {
  final Function(AddItemType) onItemSelected;

  const AddItemSelectionModal({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pilih Item yang Ingin Ditambahkan',
                style: TextStyle(
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
          const SizedBox(height: AppSpacing.md),

          // Selection Options
          _buildSelectionItem(
            context,
            icon: Icons.inventory_2,
            title: 'Produk Baru',
            subtitle: 'Tambahkan produk baru ke inventory',
            onTap: () {
              Navigator.pop(context);
              onItemSelected(AddItemType.product);
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          _buildSelectionItem(
            context,
            icon: Icons.category,
            title: 'Kategori Baru',
            subtitle: 'Buat kategori baru untuk produk',
            onTap: () {
              Navigator.pop(context);
              onItemSelected(AddItemType.category);
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          _buildSelectionItem(
            context,
            icon: Icons.branding_watermark,
            title: 'Brand Baru',
            subtitle: 'Tambahkan brand/merek baru',
            onTap: () {
              Navigator.pop(context);
              onItemSelected(AddItemType.brand);
            },
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildSelectionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final itemPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 12,
      tabletValue: 14,
      desktopValue: 16,
    );
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context);
    final titleFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 16,
      tabletSize: 18,
      desktopSize: 20,
    );
    final subtitleFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 12,
      tabletSize: 14,
      desktopSize: 15,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: itemPadding,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: iconSize),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textGray,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
