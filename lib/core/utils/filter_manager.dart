import 'package:flutter/material.dart';
import '../../data/models/models.dart';

/// Filter types available in the system
enum FilterType { category, brand, priceRange, stock, margin, custom }

/// Individual filter item
class FilterItem {
  final String id;
  final FilterType type;
  final String label;
  final dynamic value;
  final bool isActive;

  const FilterItem({
    required this.id,
    required this.type,
    required this.label,
    required this.value,
    this.isActive = false,
  });

  FilterItem copyWith({
    String? id,
    FilterType? type,
    String? label,
    dynamic value,
    bool? isActive,
  }) {
    return FilterItem(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}

/// Price range filter
class PriceRange {
  final int min;
  final int max;

  const PriceRange({required this.min, required this.max});

  @override
  String toString() => 'Rp ${_formatNumber(min)} - Rp ${_formatNumber(max)}';

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

/// Stock level filter
enum StockLevel {
  all('Semua Stok'),
  inStock('Tersedia'),
  lowStock('Stok Rendah'),
  outOfStock('Habis');

  const StockLevel(this.label);
  final String label;
}

/// Margin level filter
enum MarginLevel {
  all('Semua Margin'),
  high('Tinggi (>30%)'),
  medium('Sedang (20-30%)'),
  low('Rendah (<20%)');

  const MarginLevel(this.label);
  final String label;
}

/// Filter combination preset
class FilterPreset {
  final String id;
  final String name;
  final String description;
  final List<FilterItem> filters;
  final IconData icon;

  const FilterPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.filters,
    required this.icon,
  });
}

/// Main filter manager class
class FilterManager extends ChangeNotifier {
  List<FilterItem> _activeFilters = [];
  List<ProductModel> _originalProducts = [];
  List<ProductModel> _filteredProducts = [];
  String _searchQuery = '';
  String _sortOption = 'name_asc'; // Add sorting option

  // Getters
  List<FilterItem> get activeFilters => List.unmodifiable(_activeFilters);
  List<ProductModel> get filteredProducts =>
      List.unmodifiable(_filteredProducts);
  String get searchQuery => _searchQuery;
  String get sortOption => _sortOption; // Add getter for sort option
  bool get hasActiveFilters =>
      _activeFilters.isNotEmpty ||
      _searchQuery.isNotEmpty ||
      _sortOption != 'name_asc';
  int get activeFilterCount => _activeFilters.length;

  /// Initialize with products
  void initialize(List<ProductModel> products) {
    _originalProducts = products;
    _applyFilters();
  }

  /// Add filter
  void addFilter(FilterItem filter) {
    // Remove existing filter of same type and value if exists
    _activeFilters.removeWhere((f) => f.id == filter.id);

    // Add new filter
    _activeFilters.add(filter.copyWith(isActive: true));
    _applyFilters();
    notifyListeners();
  }

  /// Remove filter
  void removeFilter(String filterId) {
    _activeFilters.removeWhere((f) => f.id == filterId);
    _applyFilters();
    notifyListeners();
  }

  /// Toggle filter
  void toggleFilter(FilterItem filter) {
    final existingIndex = _activeFilters.indexWhere((f) => f.id == filter.id);

    if (existingIndex >= 0) {
      _activeFilters.removeAt(existingIndex);
    } else {
      _activeFilters.add(filter.copyWith(isActive: true));
    }

    _applyFilters();
    notifyListeners();
  }

  /// Clear all filters
  void clearAllFilters() {
    _activeFilters.clear();
    _searchQuery = '';
    _sortOption = 'name_asc'; // Reset sorting to default
    _applyFilters();
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
    notifyListeners();
  }

  /// Set sorting option
  void setSortOption(String sortOption) {
    _sortOption = sortOption;
    _applyFilters();
    notifyListeners();
  }

  /// Apply preset filters
  void applyPreset(FilterPreset preset) {
    _activeFilters = preset.filters
        .map((f) => f.copyWith(isActive: true))
        .toList();
    _applyFilters();
    notifyListeners();
  }

  /// Apply all active filters
  void _applyFilters() {
    var products = List<ProductModel>.from(_originalProducts);

    // Apply search query first
    if (_searchQuery.isNotEmpty) {
      products = products.where((product) {
        return product.name.toLowerCase().contains(_searchQuery) ||
            (product.sku?.toLowerCase().contains(_searchQuery) ?? false) ||
            (product.category?.name.toLowerCase().contains(_searchQuery) ??
                false) ||
            (product.brand?.name.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    // Apply each active filter
    for (final filter in _activeFilters) {
      products = _applyIndividualFilter(products, filter);
    }

    // Apply sorting
    products = _applySorting(products);

    _filteredProducts = products;
  }

  /// Apply individual filter
  List<ProductModel> _applyIndividualFilter(
    List<ProductModel> products,
    FilterItem filter,
  ) {
    switch (filter.type) {
      case FilterType.category:
        return products.where((p) => p.categoryId == filter.value).toList();

      case FilterType.brand:
        return products.where((p) => p.brandId == filter.value).toList();

      case FilterType.priceRange:
        final range = filter.value as PriceRange;
        return products
            .where((p) => p.hargaUmum >= range.min && p.hargaUmum <= range.max)
            .toList();

      case FilterType.stock:
        final level = filter.value as StockLevel;
        switch (level) {
          case StockLevel.all:
            return products;
          case StockLevel.inStock:
            return products.where((p) => p.stock > p.minStock).toList();
          case StockLevel.lowStock:
            return products
                .where((p) => p.stock > 0 && p.stock <= p.minStock)
                .toList();
          case StockLevel.outOfStock:
            return products.where((p) => p.stock <= 0).toList();
        }

      case FilterType.margin:
        final level = filter.value as MarginLevel;
        return products.where((p) {
          final margin = p.getMarginPercent('UMUM');
          switch (level) {
            case MarginLevel.all:
              return true;
            case MarginLevel.high:
              return margin > 30;
            case MarginLevel.medium:
              return margin >= 20 && margin <= 30;
            case MarginLevel.low:
              return margin < 20;
          }
        }).toList();

      case FilterType.custom:
        // Handle custom filters based on value type
        final customValue = filter.value as String;
        switch (customValue) {
          case 'high_stock':
            // Filter products with stock >= 2x minimum stock (indicating high stock)
            return products.where((p) => p.stock >= (p.minStock * 2)).toList();
          default:
            return products;
        }
    }
  }

  /// Apply sorting to products
  List<ProductModel> _applySorting(List<ProductModel> products) {
    final sortedProducts = List<ProductModel>.from(products);

    switch (_sortOption) {
      case 'name_asc':
        sortedProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'name_desc':
        sortedProducts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'price_asc':
        sortedProducts.sort((a, b) => a.hargaUmum.compareTo(b.hargaUmum));
        break;
      case 'price_desc':
        sortedProducts.sort((a, b) => b.hargaUmum.compareTo(a.hargaUmum));
        break;
      case 'stock_asc':
        sortedProducts.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case 'stock_desc':
        sortedProducts.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      case 'margin_asc':
        sortedProducts.sort(
          (a, b) =>
              a.getMarginPercent('UMUM').compareTo(b.getMarginPercent('UMUM')),
        );
        break;
      case 'margin_desc':
        sortedProducts.sort(
          (a, b) =>
              b.getMarginPercent('UMUM').compareTo(a.getMarginPercent('UMUM')),
        );
        break;
      default:
        // Default to name ascending
        sortedProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return sortedProducts;
  }

  /// Get available filter options
  Map<FilterType, List<FilterItem>> getAvailableFilters(
    List<CategoryModel> categories,
    List<BrandModel> brands,
  ) {
    return {
      FilterType.category: categories
          .map(
            (cat) => FilterItem(
              id: 'category_${cat.id}',
              type: FilterType.category,
              label: cat.name,
              value: cat.id,
            ),
          )
          .toList(),

      FilterType.brand: brands
          .map(
            (brand) => FilterItem(
              id: 'brand_${brand.id}',
              type: FilterType.brand,
              label: brand.name,
              value: brand.id,
            ),
          )
          .toList(),

      FilterType.priceRange: [
        FilterItem(
          id: 'price_0_50k',
          type: FilterType.priceRange,
          label: 'Di bawah 50rb',
          value: const PriceRange(min: 0, max: 50000),
        ),
        FilterItem(
          id: 'price_50k_100k',
          type: FilterType.priceRange,
          label: '50rb - 100rb',
          value: const PriceRange(min: 50000, max: 100000),
        ),
        FilterItem(
          id: 'price_100k_500k',
          type: FilterType.priceRange,
          label: '100rb - 500rb',
          value: const PriceRange(min: 100000, max: 500000),
        ),
        FilterItem(
          id: 'price_500k_plus',
          type: FilterType.priceRange,
          label: 'Di atas 500rb',
          value: const PriceRange(min: 500000, max: 999999999),
        ),
      ],

      FilterType.stock: StockLevel.values
          .map(
            (level) => FilterItem(
              id: 'stock_${level.name}',
              type: FilterType.stock,
              label: level.label,
              value: level,
            ),
          )
          .toList(),

      FilterType.margin: MarginLevel.values
          .map(
            (level) => FilterItem(
              id: 'margin_${level.name}',
              type: FilterType.margin,
              label: level.label,
              value: level,
            ),
          )
          .toList(),
    };
  }

  /// Get predefined filter presets
  List<FilterPreset> getFilterPresets() {
    return [
      FilterPreset(
        id: 'honda_oli',
        name: 'Honda Oli',
        description: 'Honda Genuine + Kategori Oli',
        icon: Icons.local_gas_station,
        filters: [
          // Will be populated with actual IDs when categories/brands are loaded
        ],
      ),
      FilterPreset(
        id: 'high_margin',
        name: 'Margin Tinggi',
        description: 'Produk dengan margin >30%',
        icon: Icons.trending_up,
        filters: [
          FilterItem(
            id: 'margin_high',
            type: FilterType.margin,
            label: 'Margin Tinggi (>30%)',
            value: MarginLevel.high,
          ),
        ],
      ),
      FilterPreset(
        id: 'low_stock',
        name: 'Stok Rendah',
        description: 'Produk yang perlu restock',
        icon: Icons.warning,
        filters: [
          FilterItem(
            id: 'stock_lowStock',
            type: FilterType.stock,
            label: 'Stok Rendah',
            value: StockLevel.lowStock,
          ),
        ],
      ),
      FilterPreset(
        id: 'premium_products',
        name: 'Produk Premium',
        description: 'Harga >500rb + Margin tinggi',
        icon: Icons.star,
        filters: [
          FilterItem(
            id: 'price_500k_plus',
            type: FilterType.priceRange,
            label: 'Di atas 500rb',
            value: const PriceRange(min: 500000, max: 999999999),
          ),
          FilterItem(
            id: 'margin_high',
            type: FilterType.margin,
            label: 'Margin Tinggi (>30%)',
            value: MarginLevel.high,
          ),
        ],
      ),
    ];
  }

  /// Apply filters to specific products (used for external filtering)
  List<ProductModel> applyFiltersToProducts(
    List<ProductModel> products, {
    bool excludeSearch = false,
  }) {
    var filteredProducts = List<ProductModel>.from(products);

    // Apply search query if not excluded
    if (!excludeSearch && _searchQuery.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return product.name.toLowerCase().contains(_searchQuery) ||
            (product.sku?.toLowerCase().contains(_searchQuery) ?? false) ||
            (product.category?.name.toLowerCase().contains(_searchQuery) ??
                false) ||
            (product.brand?.name.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    // Apply each active filter
    for (final filter in _activeFilters) {
      filteredProducts = _applyIndividualFilter(filteredProducts, filter);
    }

    // Apply sorting
    filteredProducts = _applySorting(filteredProducts);

    return filteredProducts;
  }

  /// Get filter summary text
  String getFilterSummary() {
    if (!hasActiveFilters && _sortOption == 'name_asc') return 'Semua Produk';

    final parts = <String>[];

    if (_searchQuery.isNotEmpty) {
      parts.add('Pencarian: "$_searchQuery"');
    }

    if (_activeFilters.isNotEmpty) {
      parts.add('${_activeFilters.length} filter aktif');
    }

    // Add sorting info if not default
    if (_sortOption != 'name_asc') {
      final sortLabel = _getSortLabel(_sortOption);
      parts.add('Urut: $sortLabel');
    }

    return parts.isEmpty ? 'Semua Produk' : parts.join(' • ');
  }

  /// Get sort option label
  String _getSortLabel(String sortOption) {
    switch (sortOption) {
      case 'name_asc':
        return 'Nama A-Z';
      case 'name_desc':
        return 'Nama Z-A';
      case 'price_asc':
        return 'Harga Terendah';
      case 'price_desc':
        return 'Harga Tertinggi';
      case 'stock_asc':
        return 'Stok Terendah';
      case 'stock_desc':
        return 'Stok Tertinggi';
      case 'margin_asc':
        return 'Margin Terendah';
      case 'margin_desc':
        return 'Margin Tertinggi';
      default:
        return 'Default';
    }
  }
}
