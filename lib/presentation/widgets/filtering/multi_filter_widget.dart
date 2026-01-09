import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/filter_manager.dart';

/// Filter chip widget for displaying active filters
class FilterChip extends StatelessWidget {
  final FilterItem filter;
  final VoidCallback onRemove;
  final bool showRemoveButton;

  const FilterChip({
    super.key,
    required this.filter,
    required this.onRemove,
    this.showRemoveButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        right: ResponsiveUtils.getResponsiveSpacing(
          context,
          phoneSpacing: 8,
          tabletSpacing: 10,
          desktopSpacing: 12,
        ),
        bottom: ResponsiveUtils.getResponsiveSpacing(
          context,
          phoneSpacing: 4,
          tabletSpacing: 6,
          desktopSpacing: 8,
        ),
      ),
      child: Chip(
        label: Text(
          filter.label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 12,
              tabletSize: 14,
              desktopSize: 16,
            ),
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: _getFilterColor(filter.type),
        deleteIcon: showRemoveButton
            ? Icon(
                Icons.close,
                size: ResponsiveUtils.getResponsiveIconSize(context) * 0.7,
                color: Colors.white,
              )
            : null,
        onDeleted: showRemoveButton ? onRemove : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
          ),
        ),
      ),
    );
  }

  Color _getFilterColor(FilterType type) {
    switch (type) {
      case FilterType.category:
        return AppColors.primary;
      case FilterType.brand:
        return AppColors.success;
      case FilterType.priceRange:
        return AppColors.warning;
      case FilterType.stock:
        return AppColors.info;
      case FilterType.margin:
        return AppColors.error;
      case FilterType.custom:
        return AppColors.textGray;
    }
  }
}

/// Active filters display widget
class ActiveFiltersWidget extends StatelessWidget {
  final FilterManager filterManager;
  final VoidCallback? onClearAll;
  final Function(String)? onRemoveFilter;

  const ActiveFiltersWidget({
    super.key,
    required this.filterManager,
    this.onClearAll,
    this.onRemoveFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (!filterManager.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
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
              Text(
                'Filter Aktif (${filterManager.activeFilterCount})',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    phoneSize: 14,
                    tabletSize: 16,
                    desktopSize: 18,
                  ),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              if (onClearAll != null)
                TextButton(
                  onPressed: onClearAll,
                  child: Text(
                    'Hapus Semua',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        phoneSize: 12,
                        tabletSize: 14,
                        desktopSize: 16,
                      ),
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: 8,
              tabletSpacing: 10,
              desktopSpacing: 12,
            ),
          ),
          Wrap(
            children: filterManager.activeFilters
                .map(
                  (filter) => FilterChip(
                    filter: filter,
                    onRemove: () {
                      if (onRemoveFilter != null) {
                        onRemoveFilter!(filter.id);
                      } else {
                        filterManager.removeFilter(filter.id);
                      }
                    },
                  ),
                )
                .toList(),
          ),
          if (filterManager.searchQuery.isNotEmpty) ...[
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 8,
                tabletSpacing: 10,
                desktopSpacing: 12,
              ),
            ),
            Container(
              padding: ResponsiveUtils.getResponsivePaddingCustom(
                context,
                phoneValue: 8,
                tabletValue: 10,
                desktopValue: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
                ),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search,
                    size: ResponsiveUtils.getResponsiveIconSize(context) * 0.8,
                    color: AppColors.info,
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 4,
                      tabletSpacing: 6,
                      desktopSpacing: 8,
                    ),
                  ),
                  Text(
                    'Pencarian: "${filterManager.searchQuery}"',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        phoneSize: 12,
                        tabletSize: 14,
                        desktopSize: 16,
                      ),
                      color: AppColors.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 4,
                      tabletSpacing: 6,
                      desktopSpacing: 8,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => filterManager.setSearchQuery(''),
                    child: Icon(
                      Icons.close,
                      size:
                          ResponsiveUtils.getResponsiveIconSize(context) * 0.7,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Filter preset card widget
class FilterPresetCard extends StatelessWidget {
  final FilterPreset preset;
  final VoidCallback onTap;
  final bool isSelected;

  const FilterPresetCard({
    super.key,
    required this.preset,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          bottom: ResponsiveUtils.getResponsiveSpacing(
            context,
            phoneSpacing: 8,
            tabletSpacing: 10,
            desktopSpacing: 12,
          ),
        ),
        padding: ResponsiveUtils.getResponsivePadding(context),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context),
          ),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: ResponsiveUtils.getResponsivePaddingCustom(
                context,
                phoneValue: 12,
                tabletValue: 14,
                desktopValue: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context) * 0.7,
                ),
              ),
              child: Icon(
                preset.icon,
                color: AppColors.primary,
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
            ),
            SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 12,
                tabletSpacing: 16,
                desktopSpacing: 20,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.name,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        phoneSize: 16,
                        tabletSize: 18,
                        desktopSize: 20,
                      ),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 2,
                      tabletSpacing: 4,
                      desktopSpacing: 6,
                    ),
                  ),
                  Text(
                    preset.description,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        phoneSize: 12,
                        tabletSize: 14,
                        desktopSize: 16,
                      ),
                      color: AppColors.textGray,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 4,
                      tabletSpacing: 6,
                      desktopSpacing: 8,
                    ),
                  ),
                  Text(
                    '${preset.filters.length} filter',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        phoneSize: 10,
                        tabletSize: 12,
                        desktopSize: 14,
                      ),
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
          ],
        ),
      ),
    );
  }
}

/// Filter section widget for grouping filters by type
class FilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<FilterItem> filters;
  final List<String> selectedFilterIds;
  final Function(FilterItem) onFilterToggle;
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;

  const FilterSection({
    super.key,
    required this.title,
    required this.icon,
    required this.filters,
    required this.selectedFilterIds,
    required this.onFilterToggle,
    this.isExpanded = true,
    this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(
          context,
          phoneSpacing: 12,
          tabletSpacing: 16,
          desktopSpacing: 20,
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Section Header
          InkWell(
            onTap: onToggleExpanded,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context),
              ),
            ),
            child: Container(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.primary,
                    size: ResponsiveUtils.getResponsiveIconSize(context),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 12,
                      tabletSpacing: 16,
                      desktopSpacing: 20,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 16,
                          tabletSize: 18,
                          desktopSize: 20,
                        ),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  if (selectedFilterIds.isNotEmpty)
                    Container(
                      padding: ResponsiveUtils.getResponsivePaddingCustom(
                        context,
                        phoneValue: 4,
                        tabletValue: 6,
                        desktopValue: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context) *
                              0.5,
                        ),
                      ),
                      child: Text(
                        '${selectedFilterIds.length}',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            phoneSize: 10,
                            tabletSize: 12,
                            desktopSize: 14,
                          ),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 8,
                      tabletSpacing: 10,
                      desktopSpacing: 12,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textGray,
                    size: ResponsiveUtils.getResponsiveIconSize(context),
                  ),
                ],
              ),
            ),
          ),
          // Section Content
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Wrap(
                spacing: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: 8,
                  tabletSpacing: 10,
                  desktopSpacing: 12,
                ),
                runSpacing: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: 8,
                  tabletSpacing: 10,
                  desktopSpacing: 12,
                ),
                children: filters.map((filter) {
                  final isSelected = selectedFilterIds.contains(filter.id);
                  return FilterActionChip(
                    filter: filter,
                    isSelected: isSelected,
                    onTap: () => onFilterToggle(filter),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Action chip for filter selection
class FilterActionChip extends StatelessWidget {
  final FilterItem filter;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterActionChip({
    super.key,
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: ResponsiveUtils.getResponsivePaddingCustom(
          context,
          phoneValue: 8,
          tabletValue: 10,
          desktopValue: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
          ),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          filter.label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 12,
              tabletSize: 14,
              desktopSize: 16,
            ),
            color: isSelected ? Colors.white : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
