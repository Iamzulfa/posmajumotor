import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../data/models/models.dart';

/// Optimized product tile with const constructor
/// Uses RepaintBoundary to prevent unnecessary repaints
class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
  });

  final ProductModel product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppSpacing.md),
          leading: _buildLeading(),
          title: _buildTitle(),
          subtitle: _buildSubtitle(),
          trailing: _buildTrailing(context),
        ),
      ),
    );
  }

  Widget _buildLeading() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Center(
        child: Text(
          product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'SKU: ${product.sku}',
          style: const TextStyle(fontSize: 12, color: AppColors.textGray),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          _buildBadge(product.category?.name ?? 'No Category', AppColors.info),
          const SizedBox(width: AppSpacing.sm),
          _buildBadge(
            'Stock: ${product.stock}',
            product.stock > 0 ? AppColors.success : AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(onTap: onEdit, child: const Text('Edit')),
        PopupMenuItem(onTap: onDelete, child: const Text('Delete')),
      ],
      child: const Icon(Icons.more_vert, color: AppColors.textGray),
    );
  }
}
