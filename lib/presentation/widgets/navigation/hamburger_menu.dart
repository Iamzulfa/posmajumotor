import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/filter_manager.dart';
import '../../screens/kasir/filtering/advanced_filter_screen.dart';
import '../../screens/kasir/inventory/category_brand_management_screen.dart';

class HamburgerMenu extends ConsumerWidget {
  final FilterManager? currentFilterManager;
  final Function(FilterManager)? onFiltersApplied;

  const HamburgerMenu({
    super.key,
    this.currentFilterManager,
    this.onFiltersApplied,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuSection(
                    context,
                    title: 'Filter & Pencarian',
                    icon: Icons.filter_list,
                    children: [
                      _buildMenuItem(
                        context,
                        title: 'Filter Lanjutan',
                        subtitle:
                            'Multi-filter produk dengan kategori, brand, harga',
                        icon: Icons.tune,
                        onTap: () => _openAdvancedFilter(context),
                        badge: currentFilterManager?.hasActiveFilters == true
                            ? '${currentFilterManager!.activeFilterCount}'
                            : null,
                      ),
                      _buildMenuItem(
                        context,
                        title: 'Filter Cepat',
                        subtitle: 'Preset filter yang sering digunakan',
                        icon: Icons.flash_on,
                        onTap: () => _showQuickFilters(context),
                      ),
                    ],
                  ),

                  _buildMenuSection(
                    context,
                    title: 'Manajemen Data',
                    icon: Icons.settings,
                    children: [
                      _buildMenuItem(
                        context,
                        title: 'Kelola Kategori & Brand',
                        subtitle: 'Edit, tambah, hapus kategori dan brand',
                        icon: Icons.category,
                        onTap: () => _openCategoryBrandManagement(context),
                      ),
                      _buildMenuItem(
                        context,
                        title: 'Sortir Manual',
                        subtitle: 'Atur urutan kategori dan brand',
                        icon: Icons.sort,
                        onTap: () => _openManualSorting(context),
                      ),
                    ],
                  ),

                  _buildMenuSection(
                    context,
                    title: 'Tampilan',
                    icon: Icons.view_module,
                    children: [
                      _buildMenuItem(
                        context,
                        title: 'Mode Tampilan',
                        subtitle: 'Grid, list, atau card view',
                        icon: Icons.view_agenda,
                        onTap: () => _showViewModeOptions(context),
                      ),
                      _buildMenuItem(
                        context,
                        title: 'Pengaturan Kolom',
                        subtitle: 'Pilih kolom yang ditampilkan',
                        icon: Icons.view_column,
                        onTap: () => _showColumnSettings(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: 20,
        tabletValue: 24,
        desktopValue: 28,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: ResponsiveUtils.getResponsivePaddingCustom(
                  context,
                  phoneValue: 12,
                  tabletValue: 14,
                  desktopValue: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context),
                  ),
                ),
                child: Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: ResponsiveUtils.getResponsiveIconSize(context) * 1.2,
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
                      'Filter & Manajemen',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 18,
                          tabletSize: 20,
                          desktopSize: 22,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Kelola produk dengan mudah',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 12,
                          tabletSize: 14,
                          desktopSize: 16,
                        ),
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (currentFilterManager?.hasActiveFilters == true) ...[
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 12,
                tabletSpacing: 16,
                desktopSpacing: 20,
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
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_alt,
                    color: Colors.white,
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
                    '${currentFilterManager!.activeFilterCount} filter aktif',
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
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: ResponsiveUtils.getResponsivePaddingCustom(
            context,
            phoneValue: 16,
            tabletValue: 20,
            desktopValue: 24,
          ).copyWith(bottom: 8),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: ResponsiveUtils.getResponsiveIconSize(context) * 0.9,
              ),
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: 8,
                  tabletSpacing: 10,
                  desktopSpacing: 12,
                ),
              ),
              Text(
                title,
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
            ],
          ),
        ),
        ...children,
        SizedBox(
          height: ResponsiveUtils.getResponsiveSpacing(
            context,
            phoneSpacing: 8,
            tabletSpacing: 12,
            desktopSpacing: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    String? badge,
  }) {
    return ListTile(
      leading: Container(
        padding: ResponsiveUtils.getResponsivePaddingCustom(
          context,
          phoneValue: 8,
          tabletValue: 10,
          desktopValue: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context) * 0.7,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: ResponsiveUtils.getResponsiveIconSize(context) * 0.9,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            phoneSize: 16,
            tabletSize: 18,
            desktopSize: 20,
          ),
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: ResponsiveUtils.getResponsivePaddingCustom(
                context,
                phoneValue: 4,
                tabletValue: 6,
                desktopValue: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
                ),
              ),
              child: Text(
                badge,
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
            Icons.arrow_forward_ios,
            color: AppColors.textGray,
            size: ResponsiveUtils.getResponsiveIconSize(context) * 0.7,
          ),
        ],
      ),
      onTap: onTap,
      contentPadding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: 16,
        tabletValue: 20,
        desktopValue: 24,
      ).copyWith(top: 8, bottom: 8),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.textGray,
            size: ResponsiveUtils.getResponsiveIconSize(context) * 0.8,
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
              'Gunakan filter untuk menemukan produk dengan cepat',
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
          ),
        ],
      ),
    );
  }

  void _openAdvancedFilter(BuildContext context) async {
    Navigator.pop(context); // Close drawer first

    final result = await Navigator.push<FilterManager>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AdvancedFilterScreen(existingFilterManager: currentFilterManager),
      ),
    );

    if (result != null && onFiltersApplied != null) {
      onFiltersApplied!(result);
    }
  }

  void _openCategoryBrandManagement(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoryBrandManagementScreen(),
      ),
    );
  }

  void _openManualSorting(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur sortir manual akan segera hadir'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showQuickFilters(BuildContext context) {
    Navigator.pop(context); // Close drawer first

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
      builder: (context) => _buildQuickFiltersModal(context),
    );
  }

  Widget _buildQuickFiltersModal(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.getResponsivePadding(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filter Cepat',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                phoneSize: 18,
                tabletSize: 20,
                desktopSize: 22,
              ),
              fontWeight: FontWeight.bold,
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
          Text(
            'Fitur ini akan segera hadir dengan preset filter yang dapat dikustomisasi',
            textAlign: TextAlign.center,
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
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: 24,
              tabletSpacing: 30,
              desktopSpacing: 36,
            ),
          ),
        ],
      ),
    );
  }

  void _showViewModeOptions(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan tampilan akan segera hadir'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showColumnSettings(BuildContext context) {
    Navigator.pop(context); // Close drawer first
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan kolom akan segera hadir'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
