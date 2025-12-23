import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../data/models/models.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../providers/product_provider.dart';
import 'category_form_modal.dart';
import 'brand_form_modal.dart';

class CategoryBrandManagementScreen extends ConsumerStatefulWidget {
  const CategoryBrandManagementScreen({super.key});

  @override
  ConsumerState<CategoryBrandManagementScreen> createState() =>
      _CategoryBrandManagementScreenState();
}

class _CategoryBrandManagementScreenState
    extends ConsumerState<CategoryBrandManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final brandsAsync = ref.watch(brandsStreamProvider);

    final syncStatus = categoriesAsync.when(
      data: (_) => brandsAsync.when(
        data: (_) => SyncStatus.online,
        loading: () => SyncStatus.syncing,
        error: (_, _) => SyncStatus.offline,
      ),
      loading: () => SyncStatus.syncing,
      error: (_, _) => SyncStatus.offline,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Kelola Kategori & Brand',
              syncStatus: syncStatus,
              lastSyncTime: syncStatus == SyncStatus.online
                  ? 'Real-time'
                  : 'Syncing...',
              showBackButton: true, // Enable back button
              showLogout: false, // Hide logout for this screen
            ),
            // Modern Tab Bar with Full Coverage Selection
            Container(
              margin: ResponsiveUtils.getResponsivePaddingCustom(
                context,
                phoneValue: 16,
                tabletValue: 20,
                desktopValue: 24,
              ),
              padding: EdgeInsets.all(4), // Padding around tabs
              decoration: BoxDecoration(
                color: AppColors.secondary, // Light background
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
                  // Modern full-coverage indicator
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
                  indicatorSize: TabBarIndicatorSize.tab, // Full tab coverage
                  dividerColor: Colors.transparent, // Remove default divider
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
                    Tab(text: 'Kategori'),
                    Tab(text: 'Brand'),
                  ],
                ),
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCategoriesTab(categoriesAsync),
                  _buildBrandsTab(brandsAsync),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _tabController.index == 0 ? 'Tambah Kategori' : 'Tambah Brand',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 14,
              tabletSize: 16,
              desktopSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesTab(AsyncValue<List<CategoryModel>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: ResponsiveUtils.getResponsiveIconSize(context) * 3,
                  color: AppColors.textGray,
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
                  'Belum ada kategori',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 16,
                      tabletSize: 18,
                      desktopSize: 20,
                    ),
                    color: AppColors.textGray,
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
                Text(
                  'Tap tombol + untuk menambah kategori',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 14,
                      tabletSize: 16,
                      desktopSize: 18,
                    ),
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: ResponsiveUtils.getResponsivePadding(context),
          itemCount: categories.length,
          itemBuilder: (context, index) =>
              _buildCategoryItem(categories[index]),
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: TextStyle(
            color: AppColors.error,
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 14,
              tabletSize: 16,
              desktopSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandsTab(AsyncValue<List<BrandModel>> brandsAsync) {
    return brandsAsync.when(
      data: (brands) {
        if (brands.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.branding_watermark_outlined,
                  size: ResponsiveUtils.getResponsiveIconSize(context) * 3,
                  color: AppColors.textGray,
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
                  'Belum ada brand',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 16,
                      tabletSize: 18,
                      desktopSize: 20,
                    ),
                    color: AppColors.textGray,
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
                Text(
                  'Tap tombol + untuk menambah brand',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 14,
                      tabletSize: 16,
                      desktopSize: 18,
                    ),
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: ResponsiveUtils.getResponsivePadding(context),
          itemCount: brands.length,
          itemBuilder: (context, index) => _buildBrandItem(brands[index]),
        );
      },
      loading: () => const LoadingWidget(),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: TextStyle(
            color: AppColors.error,
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 14,
              tabletSize: 16,
              desktopSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(CategoryModel category) {
    return Container(
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: 8,
              tabletValue: 10,
              desktopValue: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
              ),
            ),
            child: Icon(
              Icons.category,
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
                  category.name,
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
                if (category.description != null &&
                    category.description!.isNotEmpty) ...[
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 4,
                      tabletSpacing: 6,
                      desktopSpacing: 8,
                    ),
                  ),
                  Text(
                    category.description!,
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
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              size: ResponsiveUtils.getResponsiveIconSize(context) * 0.9,
            ),
            onPressed: () => _showEditCategoryDialog(category),
            color: AppColors.primary,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: ResponsiveUtils.getResponsiveIconSize(context) * 0.9,
            ),
            onPressed: () => _showDeleteCategoryDialog(category),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildBrandItem(BrandModel brand) {
    return Container(
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: 8,
              tabletValue: 10,
              desktopValue: 12,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
              ),
            ),
            child: Icon(
              Icons.branding_watermark,
              color: AppColors.success,
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
                  brand.name,
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
                if (brand.description != null &&
                    brand.description!.isNotEmpty) ...[
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 4,
                      tabletSpacing: 6,
                      desktopSpacing: 8,
                    ),
                  ),
                  Text(
                    brand.description!,
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
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              size: ResponsiveUtils.getResponsiveIconSize(context) * 0.9,
            ),
            onPressed: () => _showEditBrandDialog(brand),
            color: AppColors.primary,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: ResponsiveUtils.getResponsiveIconSize(context) * 0.9,
            ),
            onPressed: () => _showDeleteBrandDialog(brand),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    if (_tabController.index == 0) {
      showCategoryFormModal(context);
    } else {
      showBrandFormModal(context);
    }
  }

  void _showEditCategoryDialog(CategoryModel category) {
    showCategoryFormModal(context, category: category);
  }

  void _showEditBrandDialog(BrandModel brand) {
    showBrandFormModal(context, brand: brand);
  }

  void _showDeleteCategoryDialog(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text(
          'Yakin ingin menghapus kategori "${category.name}"?\n\nSemua produk dengan kategori ini akan kehilangan kategorinya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              navigator.pop();
              try {
                await ref
                    .read(productRepositoryProvider)
                    .deleteCategory(category.id);
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Kategori berhasil dihapus'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showDeleteBrandDialog(BrandModel brand) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Brand'),
        content: Text(
          'Yakin ingin menghapus brand "${brand.name}"?\n\nSemua produk dengan brand ini akan kehilangan brandnya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              navigator.pop();
              try {
                await ref.read(productRepositoryProvider).deleteBrand(brand.id);
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Brand berhasil dihapus'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
