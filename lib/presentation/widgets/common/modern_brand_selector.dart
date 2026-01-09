import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/models.dart';

class ModernBrandSelector extends StatefulWidget {
  final List<BrandModel> brands;
  final String? selectedBrandId;
  final Function(BrandModel?) onChanged;
  final bool enabled;
  final String label;

  const ModernBrandSelector({
    super.key,
    required this.brands,
    this.selectedBrandId,
    required this.onChanged,
    this.enabled = true,
    this.label = 'Brand',
  });

  @override
  State<ModernBrandSelector> createState() => _ModernBrandSelectorState();
}

class _ModernBrandSelectorState extends State<ModernBrandSelector> {
  late TextEditingController _searchController;
  late List<BrandModel> _filteredBrands;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredBrands = widget.brands;
  }

  @override
  void didUpdateWidget(ModernBrandSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brands != widget.brands) {
      _filteredBrands = widget.brands;
      _filterBrands(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBrands(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBrands = widget.brands;
      } else {
        _filteredBrands = widget.brands
            .where(
              (brand) => brand.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedBrand = widget.brands
        .where((b) => b.id == widget.selectedBrandId)
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

        // Selected Brand Display
        if (selectedBrand != null)
          GestureDetector(
            onTap: widget.enabled ? () => _showBrandModal(context) : null,
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
                      selectedBrand.name,
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
            onTap: widget.enabled ? () => _showBrandModal(context) : null,
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
                    'Pilih brand',
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

  void _showBrandModal(BuildContext context) {
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
      builder: (context) => _BrandSelectionModal(
        brands: widget.brands,
        selectedBrandId: widget.selectedBrandId,
        onSelected: (brand) {
          widget.onChanged(brand);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _BrandSelectionModal extends StatefulWidget {
  final List<BrandModel> brands;
  final String? selectedBrandId;
  final Function(BrandModel) onSelected;

  const _BrandSelectionModal({
    required this.brands,
    this.selectedBrandId,
    required this.onSelected,
  });

  @override
  State<_BrandSelectionModal> createState() => _BrandSelectionModalState();
}

class _BrandSelectionModalState extends State<_BrandSelectionModal> {
  late TextEditingController _searchController;
  late List<BrandModel> _filteredBrands;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredBrands = widget.brands;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBrands(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBrands = widget.brands;
      } else {
        _filteredBrands = widget.brands
            .where(
              (brand) => brand.name.toLowerCase().contains(query.toLowerCase()),
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
                  'Pilih Brand',
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
              onChanged: _filterBrands,
              decoration: InputDecoration(
                hintText: 'Cari brand...',
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

          // Brand Grid
          Expanded(
            child: _filteredBrands.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
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
                          'Brand tidak ditemukan',
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
                    itemCount: _filteredBrands.length,
                    itemBuilder: (context, index) {
                      final brand = _filteredBrands[index];
                      final isSelected = brand.id == widget.selectedBrandId;

                      return _BrandCard(
                        brand: brand,
                        isSelected: isSelected,
                        onTap: () => widget.onSelected(brand),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final BrandModel brand;
  final bool isSelected;
  final VoidCallback onTap;

  const _BrandCard({
    required this.brand,
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
                      Icons.local_offer,
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
                  // Brand Name
                  Text(
                    brand.name,
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
