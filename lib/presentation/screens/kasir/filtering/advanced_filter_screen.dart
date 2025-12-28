import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/filter_manager.dart';
import '../../../../data/models/models.dart';
import '../../../providers/product_provider.dart';

/// Advanced Filter Screen with Consistent App Design
class AdvancedFilterScreen extends ConsumerStatefulWidget {
  final FilterManager? existingFilterManager;

  const AdvancedFilterScreen({super.key, this.existingFilterManager});

  @override
  ConsumerState<AdvancedFilterScreen> createState() =>
      _AdvancedFilterScreenState();
}

class _AdvancedFilterScreenState extends ConsumerState<AdvancedFilterScreen>
    with TickerProviderStateMixin {
  late FilterManager _filterManager;
  late TabController _tabController;
  final _searchController = TextEditingController();

  // Filter state
  List<String> _selectedBrands = [];
  List<String> _selectedCategories = [];
  String _selectedPriceRange = '';
  String _selectedStockLevel = '';
  String _sortOption = 'name_asc';

  @override
  void initState() {
    super.initState();
    _filterManager = widget.existingFilterManager ?? FilterManager();
    _tabController = TabController(length: 2, vsync: this);
    _initializeFromExistingFilters();
  }

  void _initializeFromExistingFilters() {
    if (widget.existingFilterManager != null) {
      _sortOption = widget.existingFilterManager!.sortOption;

      for (final filter in widget.existingFilterManager!.activeFilters) {
        switch (filter.type) {
          case FilterType.brand:
            _selectedBrands.add(filter.id);
            break;
          case FilterType.category:
            _selectedCategories.add(filter.id);
            break;
          case FilterType.priceRange:
            _selectedPriceRange = filter.id;
            break;
          case FilterType.stock:
            _selectedStockLevel = filter.id;
            break;
          default:
            break;
        }
      }
    }
  }

  void _syncLocalStateWithFilterManager() {
    // Sync local state with current filter manager state
    _selectedBrands.clear();
    _selectedCategories.clear();
    _selectedPriceRange = '';
    _selectedStockLevel = '';

    for (final filter in _filterManager.activeFilters) {
      switch (filter.type) {
        case FilterType.brand:
          _selectedBrands.add(filter.id);
          break;
        case FilterType.category:
          _selectedCategories.add(filter.id);
          break;
        case FilterType.priceRange:
          _selectedPriceRange = filter.id;
          break;
        case FilterType.stock:
          _selectedStockLevel = filter.id;
          break;
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sync local state with filter manager when rebuilding
    _syncLocalStateWithFilterManager();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildFiltersTab(), _buildSortingTab()],
            ),
          ),
          // Dynamic bottom actions - only show when needed
          if (_filterManager.hasActiveFilters || _sortOption != 'name_asc')
            _buildBottomActions(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textDark,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        color: AppColors.textDark,
        tooltip: 'Kembali',
      ),
      title: Text(
        'Filter Lanjutan',
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            phoneSize: 18,
            tabletSize: 20,
            desktopSize: 22,
          ),
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
      actions: [
        if (_filterManager.hasActiveFilters)
          TextButton(
            onPressed: _clearAllFilters,
            child: Text(
              'Reset',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  phoneSize: 14,
                  tabletSize: 16,
                  desktopSize: 18,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: 16,
        tabletValue: 20,
        desktopValue: 24,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context) + 4,
        ),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Container(
        height: ResponsiveUtils.getResponsiveHeight(
          context,
          phoneHeight: 48,
          tabletHeight: 52,
          desktopHeight: 56,
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textGray,
          labelStyle: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 14,
              tabletSize: 16,
              desktopSize: 18,
            ),
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 14,
              tabletSize: 16,
              desktopSize: 18,
            ),
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: 'Filter'),
            Tab(text: 'Sortir'),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersTab() {
    return Container(
      color: AppColors.backgroundLight,
      child: SingleChildScrollView(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 16,
                tabletSpacing: 20,
                desktopSpacing: 24,
              ),
            ),
            _buildMultiRowFilterChips(),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 16,
                tabletSpacing: 20,
                desktopSpacing: 24,
              ),
            ),
            _buildBrandTagGrid(),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 16,
                tabletSpacing: 20,
                desktopSpacing: 24,
              ),
            ),
            _buildCategoryTagGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Cari produk, brand, kategori...',
          hintStyle: TextStyle(color: AppColors.textGray),
          prefixIcon: Icon(Icons.search, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: ResponsiveUtils.getResponsivePadding(context),
        ),
        onChanged: (value) {
          _filterManager.setSearchQuery(value);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildMultiRowFilterChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filter Cepat',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 16,
              tabletSize: 18,
              desktopSize: 20,
            ),
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            phoneSpacing: 8,
            tabletSpacing: 10,
            desktopSpacing: 12,
          ),
        ),
        _buildFilterChipRow([
          _buildFilterChip('Brand', Icons.business, _selectedBrands.isNotEmpty),
          _buildFilterChip(
            'Kategori',
            Icons.category,
            _selectedCategories.isNotEmpty,
          ),
          _buildFilterChip(
            'Harga',
            Icons.attach_money,
            _selectedPriceRange.isNotEmpty,
          ),
        ]),
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            phoneSpacing: 8,
            tabletSpacing: 10,
            desktopSpacing: 12,
          ),
        ),
        _buildFilterChipRow([
          _buildFilterChip(
            'Stok',
            Icons.inventory,
            _selectedStockLevel.isNotEmpty,
          ),
        ]),
      ],
    );
  }

  Widget _buildFilterChipRow(List<Widget> chips) {
    return Row(children: chips.map((chip) => Expanded(child: chip)).toList());
  }

  Widget _buildFilterChip(String label, IconData icon, bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(
          context,
          phoneSpacing: 4,
          tabletSpacing: 6,
          desktopSpacing: 8,
        ),
      ),
      child: GestureDetector(
        onTap: () => _showFilterOptions(label),
        child: Container(
          padding: ResponsiveUtils.getResponsivePaddingCustom(
            context,
            phoneValue: 12,
            tabletValue: 14,
            desktopValue: 16,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.background,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context),
            ),
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primary : AppColors.textGray,
                size: ResponsiveUtils.getResponsiveIconSize(context) * 0.8,
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
                label,
                style: TextStyle(
                  color: isActive ? AppColors.primary : AppColors.textGray,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    phoneSize: 12,
                    tabletSize: 14,
                    desktopSize: 16,
                  ),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandTagGrid() {
    final brandsAsync = ref.watch(brandsStreamProvider);

    return brandsAsync.when(
      data: (brands) => Container(
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
              children: [
                Icon(Icons.business, color: AppColors.primary),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: 8,
                    tabletSpacing: 10,
                    desktopSpacing: 12,
                  ),
                ),
                Text(
                  'Brand Tag',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 16,
                      tabletSize: 18,
                      desktopSize: 20,
                    ),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 12,
                tabletSpacing: 16,
                desktopSpacing: 20,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveHeight(
                context,
                phoneHeight: 120,
                tabletHeight: 140,
                desktopHeight: 160,
              ),
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.4,
                  crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: 8,
                    tabletSpacing: 10,
                    desktopSpacing: 12,
                  ),
                  mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: 8,
                    tabletSpacing: 10,
                    desktopSpacing: 12,
                  ),
                ),
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  final brand = brands[index];
                  final isSelected = _selectedBrands.contains(
                    'brand_${brand.id}',
                  );

                  return GestureDetector(
                    onTap: () =>
                        _toggleBrandSelection('brand_${brand.id}', brand),
                    child: Container(
                      padding: ResponsiveUtils.getResponsivePaddingCustom(
                        context,
                        phoneValue: 8,
                        tabletValue: 10,
                        desktopValue: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.secondary,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context) *
                              0.5,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          brand.name,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              phoneSize: 11,
                              tabletSize: 13,
                              desktopSize: 15,
                            ),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textGray,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Text('Error: $error', style: TextStyle(color: AppColors.textGray)),
    );
  }

  Widget _buildCategoryTagGrid() {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return categoriesAsync.when(
      data: (categories) => Container(
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
              children: [
                Icon(Icons.grid_view, color: AppColors.primary),
                SizedBox(
                  width: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: 8,
                    tabletSpacing: 10,
                    desktopSpacing: 12,
                  ),
                ),
                Text(
                  'Kategori Tag',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 16,
                      tabletSize: 18,
                      desktopSize: 20,
                    ),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 12,
                tabletSpacing: 16,
                desktopSpacing: 20,
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveHeight(
                context,
                phoneHeight: 120,
                tabletHeight: 140,
                desktopHeight: 160,
              ),
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.4,
                  crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: 8,
                    tabletSpacing: 10,
                    desktopSpacing: 12,
                  ),
                  mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: 8,
                    tabletSpacing: 10,
                    desktopSpacing: 12,
                  ),
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategories.contains(
                    'category_${category.id}',
                  );

                  return GestureDetector(
                    onTap: () => _toggleCategorySelection(
                      'category_${category.id}',
                      category,
                    ),
                    child: Container(
                      padding: ResponsiveUtils.getResponsivePaddingCustom(
                        context,
                        phoneValue: 8,
                        tabletValue: 10,
                        desktopValue: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.secondary,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context) *
                              0.5,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category.name,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              phoneSize: 11,
                              tabletSize: 13,
                              desktopSize: 15,
                            ),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textGray,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Text('Error: $error', style: TextStyle(color: AppColors.textGray)),
    );
  }

  Widget _buildSortingTab() {
    final sortOptions = [
      {'id': 'name_asc', 'label': 'Nama A-Z', 'icon': Icons.sort_by_alpha},
      {'id': 'name_desc', 'label': 'Nama Z-A', 'icon': Icons.sort_by_alpha},
      {
        'id': 'price_asc',
        'label': 'Harga Terendah',
        'icon': Icons.trending_down,
      },
      {
        'id': 'price_desc',
        'label': 'Harga Tertinggi',
        'icon': Icons.trending_up,
      },
      {'id': 'stock_desc', 'label': 'Stok Tertinggi', 'icon': Icons.inventory},
      {
        'id': 'stock_asc',
        'label': 'Stok Terendah',
        'icon': Icons.inventory_2_outlined,
      },
      {
        'id': 'margin_desc',
        'label': 'Margin Tertinggi',
        'icon': Icons.trending_up,
      },
      {
        'id': 'margin_asc',
        'label': 'Margin Terendah',
        'icon': Icons.trending_down,
      },
    ];

    return Container(
      color: AppColors.backgroundLight,
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Urutkan Berdasarkan',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                phoneSize: 18,
                tabletSize: 20,
                desktopSize: 22,
              ),
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: 16,
              tabletSpacing: 20,
              desktopSpacing: 24,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sortOptions.length,
              itemBuilder: (context, index) {
                final option = sortOptions[index];
                final isSelected = _sortOption == option['id'];

                return Container(
                  margin: EdgeInsets.only(
                    bottom: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 8,
                      tabletSpacing: 10,
                      desktopSpacing: 12,
                    ),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: ResponsiveUtils.getResponsivePaddingCustom(
                        context,
                        phoneValue: 8,
                        tabletValue: 10,
                        desktopValue: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context) *
                              0.5,
                        ),
                      ),
                      child: Icon(
                        option['icon'] as IconData,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textGray,
                      ),
                    ),
                    title: Text(
                      option['label'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textDark,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 16,
                          tabletSize: 18,
                          desktopSize: 20,
                        ),
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: AppColors.primary)
                        : null,
                    tileColor: isSelected
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _sortOption = option['id'] as String;
                        _filterManager.setSortOption(_sortOption);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final hasActiveFilters = _filterManager.hasActiveFilters;
    final hasCustomSorting = _sortOption != 'name_asc';
    final hasAnyChanges = hasActiveFilters || hasCustomSorting;

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        left: ResponsiveUtils.getResponsiveSpacing(
          context,
          phoneSpacing: hasAnyChanges ? 20 : 16,
          tabletSpacing: hasAnyChanges ? 24 : 20,
          desktopSpacing: hasAnyChanges ? 28 : 24,
        ),
        right: ResponsiveUtils.getResponsiveSpacing(
          context,
          phoneSpacing: hasAnyChanges ? 20 : 16,
          tabletSpacing: hasAnyChanges ? 24 : 20,
          desktopSpacing: hasAnyChanges ? 28 : 24,
        ),
        top: ResponsiveUtils.getResponsiveSpacing(
          context,
          phoneSpacing: hasAnyChanges ? 16 : 12,
          tabletSpacing: hasAnyChanges ? 20 : 16,
          desktopSpacing: hasAnyChanges ? 24 : 20,
        ),
        bottom:
            ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: hasAnyChanges ? 20 : 16,
              tabletSpacing: hasAnyChanges ? 24 : 20,
              desktopSpacing: hasAnyChanges ? 28 : 24,
            ) +
            (bottomInset > 0 ? bottomInset + 4 : 8),
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: hasAnyChanges
                ? AppColors.border
                : AppColors.border.withValues(alpha: 0.5),
            width: hasAnyChanges ? 1.5 : 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textGray.withValues(
              alpha: hasAnyChanges ? 0.15 : 0.08,
            ),
            blurRadius: hasAnyChanges ? 12 : 6,
            offset: Offset(0, hasAnyChanges ? -4 : -2),
            spreadRadius: hasAnyChanges ? 1 : 0,
          ),
        ],
      ),
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasActiveFilters) ...[
              Container(
                width: double.infinity,
                padding: ResponsiveUtils.getResponsivePaddingCustom(
                  context,
                  phoneValue: 12,
                  tabletValue: 14,
                  desktopValue: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context),
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt,
                      color: AppColors.primary,
                      size:
                          ResponsiveUtils.getResponsiveIconSize(context) * 0.7,
                    ),
                    SizedBox(
                      width: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        phoneSpacing: 8,
                        tabletSpacing: 10,
                        desktopSpacing: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _filterManager.getFilterSummary(),
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            phoneSize: 12,
                            tabletSize: 13,
                            desktopSize: 14,
                          ),
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: 12,
                  tabletSpacing: 16,
                  desktopSpacing: 20,
                ),
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textGray,
                      side: BorderSide(color: AppColors.border, width: 1),
                      backgroundColor: AppColors.background,
                      padding: ResponsiveUtils.getResponsivePaddingCustom(
                        context,
                        phoneValue: hasAnyChanges ? 16 : 12,
                        tabletValue: hasAnyChanges ? 18 : 14,
                        desktopValue: hasAnyChanges ? 20 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context),
                        ),
                      ),
                      minimumSize: Size(
                        0,
                        ResponsiveUtils.getResponsiveHeight(
                          context,
                          phoneHeight: hasAnyChanges ? 48 : 44,
                          tabletHeight: hasAnyChanges ? 52 : 48,
                          desktopHeight: hasAnyChanges ? 56 : 52,
                        ),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 14,
                          tabletSize: 16,
                          desktopSize: 18,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                  flex: hasAnyChanges ? 2 : 1,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasAnyChanges
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                      padding: ResponsiveUtils.getResponsivePaddingCustom(
                        context,
                        phoneValue: hasAnyChanges ? 16 : 12,
                        tabletValue: hasAnyChanges ? 18 : 14,
                        desktopValue: hasAnyChanges ? 20 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context),
                        ),
                      ),
                      minimumSize: Size(
                        0,
                        ResponsiveUtils.getResponsiveHeight(
                          context,
                          phoneHeight: hasAnyChanges ? 48 : 44,
                          tabletHeight: hasAnyChanges ? 52 : 48,
                          desktopHeight: hasAnyChanges ? 56 : 52,
                        ),
                      ),
                      elevation: hasAnyChanges ? 3 : 1,
                      shadowColor: AppColors.primary.withValues(
                        alpha: hasAnyChanges ? 0.3 : 0.1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (hasAnyChanges) ...[
                          Icon(
                            Icons.check_circle,
                            size:
                                ResponsiveUtils.getResponsiveIconSize(context) *
                                0.7,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: ResponsiveUtils.getResponsiveSpacing(
                              context,
                              phoneSpacing: 6,
                              tabletSpacing: 8,
                              desktopSpacing: 10,
                            ),
                          ),
                        ],
                        Text(
                          hasAnyChanges ? 'Terapkan Filter' : 'Tutup',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              phoneSize: 14,
                              tabletSize: 16,
                              desktopSize: 18,
                            ),
                            fontWeight: hasAnyChanges
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions(String filterType) {
    switch (filterType.toLowerCase()) {
      case 'harga':
        _showPriceRangeDialog();
        break;
      case 'stok':
        _showStockLevelDialog();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Filter $filterType akan segera hadir'),
            backgroundColor: AppColors.primary,
          ),
        );
    }
  }

  void _showPriceRangeDialog() {
    final priceRanges = [
      {
        'id': 'price_0_50k',
        'label': 'Di bawah 50rb',
        'range': const PriceRange(min: 0, max: 50000),
      },
      {
        'id': 'price_50k_100k',
        'label': '50rb - 100rb',
        'range': const PriceRange(min: 50000, max: 100000),
      },
      {
        'id': 'price_100k_500k',
        'label': '100rb - 500rb',
        'range': const PriceRange(min: 100000, max: 500000),
      },
      {
        'id': 'price_500k_plus',
        'label': 'Di atas 500rb',
        'range': const PriceRange(min: 500000, max: 999999999),
      },
    ];

    // Create temporary state for the dialog
    String tempSelectedPriceRange = _selectedPriceRange;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pilih Range Harga'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: priceRanges.map((priceRange) {
                return RadioListTile<String>(
                  title: Text(priceRange['label'] as String),
                  value: priceRange['id'] as String,
                  groupValue: tempSelectedPriceRange,
                  onChanged: (String? value) {
                    setDialogState(() {
                      tempSelectedPriceRange = value ?? '';
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Remove previous price range filter
                  if (_selectedPriceRange.isNotEmpty) {
                    _filterManager.removeFilter(_selectedPriceRange);
                  }

                  _selectedPriceRange = tempSelectedPriceRange;

                  if (_selectedPriceRange.isNotEmpty) {
                    final selectedRange = priceRanges.firstWhere(
                      (r) => r['id'] == _selectedPriceRange,
                    );
                    _filterManager.addFilter(
                      FilterItem(
                        id: _selectedPriceRange,
                        type: FilterType.priceRange,
                        label: selectedRange['label'] as String,
                        value: selectedRange['range'] as PriceRange,
                      ),
                    );
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Terapkan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStockLevelDialog() {
    final stockLevels = [
      {'id': 'stock_all', 'label': 'Semua Stok', 'level': StockLevel.all},
      {'id': 'stock_inStock', 'label': 'Tersedia', 'level': StockLevel.inStock},
      {
        'id': 'stock_lowStock',
        'label': 'Stok Rendah',
        'level': StockLevel.lowStock,
      },
      {
        'id': 'stock_outOfStock',
        'label': 'Habis',
        'level': StockLevel.outOfStock,
      },
    ];

    // Create temporary state for the dialog
    String tempSelectedStockLevel = _selectedStockLevel;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Pilih Level Stok'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: stockLevels.map((stockLevel) {
                return RadioListTile<String>(
                  title: Text(stockLevel['label'] as String),
                  value: stockLevel['id'] as String,
                  groupValue: tempSelectedStockLevel,
                  onChanged: (String? value) {
                    setDialogState(() {
                      tempSelectedStockLevel = value ?? '';
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Remove previous stock level filter
                  if (_selectedStockLevel.isNotEmpty) {
                    _filterManager.removeFilter(_selectedStockLevel);
                  }

                  _selectedStockLevel = tempSelectedStockLevel;

                  if (_selectedStockLevel.isNotEmpty &&
                      _selectedStockLevel != 'stock_all') {
                    final selectedLevel = stockLevels.firstWhere(
                      (l) => l['id'] == _selectedStockLevel,
                    );
                    _filterManager.addFilter(
                      FilterItem(
                        id: _selectedStockLevel,
                        type: FilterType.stock,
                        label: selectedLevel['label'] as String,
                        value: selectedLevel['level'] as StockLevel,
                      ),
                    );
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Terapkan'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleBrandSelection(String brandId, BrandModel brand) {
    setState(() {
      if (_selectedBrands.contains(brandId)) {
        _selectedBrands.remove(brandId);
        _filterManager.removeFilter(brandId);
      } else {
        _selectedBrands.add(brandId);
        _filterManager.addFilter(
          FilterItem(
            id: brandId,
            type: FilterType.brand,
            label: brand.name,
            value: brand.id,
          ),
        );
      }
    });
  }

  void _toggleCategorySelection(String categoryId, CategoryModel category) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
        _filterManager.removeFilter(categoryId);
      } else {
        _selectedCategories.add(categoryId);
        _filterManager.addFilter(
          FilterItem(
            id: categoryId,
            type: FilterType.category,
            label: category.name,
            value: category.id,
          ),
        );
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedBrands.clear();
      _selectedCategories.clear();
      _selectedPriceRange = '';
      _selectedStockLevel = '';
      _sortOption = 'name_asc';
      _searchController.clear();
      _filterManager.clearAllFilters();
    });
  }

  void _applyFilters() {
    Navigator.pop(context, _filterManager);
  }
}
