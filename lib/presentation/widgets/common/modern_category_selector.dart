import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/models.dart';

class ModernCategorySelector extends StatefulWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final Function(CategoryModel?) onChanged;
  final bool enabled;
  final String label;

  const ModernCategorySelector({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onChanged,
    this.enabled = true,
    this.label = 'Kategori',
  });

  @override
  State<ModernCategorySelector> createState() => _ModernCategorySelectorState();
}

class _ModernCategorySelectorState extends State<ModernCategorySelector> {
  late TextEditingController _searchController;
  late List<CategoryModel> _filteredCategories;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCategories = widget.categories;
  }

  @override
  void didUpdateWidget(ModernCategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      _filteredCategories = widget.categories;
      _filterCategories(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = widget.categories;
      } else {
        _filteredCategories = widget.categories
            .where(
              (cat) => cat.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = widget.categories
        .where((c) => c.id == widget.selectedCategoryId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
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

        // Selected Category Display
        if (selectedCategory != null)
          GestureDetector(
            onTap: widget.enabled ? () => _showCategoryModal(context) : null,
            child: Container(
              padding: ResponsiveUtils.getResponsivePaddingCustom(
                context,
                phoneValue: AppSpacing.md,
                tabletValue: AppSpacing.lg,
                desktopValue: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      selectedCategory.name,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 14,
                          tabletSize: 16,
                          desktopSize: 18,
                        ),
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: AppSpacing.sm,
                      tabletSpacing: AppSpacing.md,
                      desktopSpacing: 12,
                    ),
                  ),
                  Row(
                    children: [
                      if (widget.enabled)
                        GestureDetector(
                          onTap: () => widget.onChanged(null),
                          child: Icon(
                            Icons.close,
                            size:
                                ResponsiveUtils.getResponsiveIconSize(context) *
                                0.8,
                            color: AppColors.textGray,
                          ),
                        ),
                      SizedBox(
                        width: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          phoneSpacing: AppSpacing.xs,
                          tabletSpacing: AppSpacing.sm,
                          desktopSpacing: 8,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: ResponsiveUtils.getResponsiveIconSize(context),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        else
          GestureDetector(
            onTap: widget.enabled ? () => _showCategoryModal(context) : null,
            child: Container(
              padding: ResponsiveUtils.getResponsivePaddingCustom(
                context,
                phoneValue: AppSpacing.md,
                tabletValue: AppSpacing.lg,
                desktopValue: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih kategori',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        phoneSize: 14,
                        tabletSize: 16,
                        desktopSize: 18,
                      ),
                      color: AppColors.textGray,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: ResponsiveUtils.getResponsiveIconSize(context),
                    color: AppColors.textGray,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showCategoryModal(BuildContext context) {
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
      builder: (context) => _CategorySelectionModal(
        categories: widget.categories,
        selectedCategoryId: widget.selectedCategoryId,
        onSelected: (category) {
          widget.onChanged(category);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _CategorySelectionModal extends StatefulWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final Function(CategoryModel) onSelected;

  const _CategorySelectionModal({
    required this.categories,
    this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  State<_CategorySelectionModal> createState() =>
      _CategorySelectionModalState();
}

class _CategorySelectionModalState extends State<_CategorySelectionModal> {
  late TextEditingController _searchController;
  late List<CategoryModel> _filteredCategories;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCategories = widget.categories;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = widget.categories;
      } else {
        _filteredCategories = widget.categories
            .where(
              (cat) => cat.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih Kategori',
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
          ),
          const Divider(color: AppColors.border),

          // Search Bar
          Padding(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCategories,
              decoration: InputDecoration(
                hintText: 'Cari kategori...',
                hintStyle: TextStyle(
                  color: AppColors.textGray,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    phoneSize: 14,
                    tabletSize: 16,
                    desktopSize: 18,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textGray,
                  size: ResponsiveUtils.getResponsiveIconSize(context) * 0.9,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: ResponsiveUtils.getResponsivePaddingCustom(
                  context,
                  phoneValue: AppSpacing.md,
                  tabletValue: AppSpacing.lg,
                  desktopValue: 16,
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
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // Category Grid
          Expanded(
            child: _filteredCategories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size:
                              ResponsiveUtils.getResponsiveIconSize(context) *
                              2,
                          color: AppColors.textGray,
                        ),
                        SizedBox(
                          height: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            phoneSpacing: AppSpacing.md,
                            tabletSpacing: AppSpacing.lg,
                            desktopSpacing: 16,
                          ),
                        ),
                        Text(
                          'Kategori tidak ditemukan',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              phoneSize: 14,
                              tabletSize: 16,
                              desktopSize: 18,
                            ),
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: ResponsiveUtils.getResponsivePadding(context),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtils.isPhone(context) ? 2 : 3,
                      crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        phoneSpacing: AppSpacing.md,
                        tabletSpacing: AppSpacing.lg,
                        desktopSpacing: 16,
                      ),
                      mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        phoneSpacing: AppSpacing.md,
                        tabletSpacing: AppSpacing.lg,
                        desktopSpacing: 16,
                      ),
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = _filteredCategories[index];
                      final isSelected =
                          category.id == widget.selectedCategoryId;

                      return _CategoryCard(
                        category: category,
                        isSelected: isSelected,
                        onTap: () => widget.onSelected(category),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context),
            ),
            child: Padding(
              padding: ResponsiveUtils.getResponsivePaddingCustom(
                context,
                phoneValue: AppSpacing.md,
                tabletValue: AppSpacing.lg,
                desktopValue: 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(
                        context,
                        phoneSpacing: AppSpacing.md,
                        tabletSpacing: AppSpacing.lg,
                        desktopSpacing: 12,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context) *
                            0.5,
                      ),
                    ),
                    child: Icon(
                      Icons.category,
                      size:
                          ResponsiveUtils.getResponsiveIconSize(context) * 1.2,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: AppSpacing.sm,
                      tabletSpacing: AppSpacing.md,
                      desktopSpacing: 12,
                    ),
                  ),
                  // Category Name
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        phoneSize: 12,
                        tabletSize: 14,
                        desktopSize: 16,
                      ),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textDark,
                    ),
                  ),
                  if (isSelected)
                    Padding(
                      padding: EdgeInsets.only(
                        top: ResponsiveUtils.getResponsiveSpacing(
                          context,
                          phoneSpacing: AppSpacing.xs,
                          tabletSpacing: AppSpacing.sm,
                          desktopSpacing: 8,
                        ),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size:
                            ResponsiveUtils.getResponsiveIconSize(context) *
                            0.7,
                        color: AppColors.primary,
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
}
