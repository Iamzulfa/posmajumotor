import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import 'inventory/inventory_screen.dart';
import 'transaction/transaction_screen.dart';

class KasirMainScreen extends StatefulWidget {
  const KasirMainScreen({super.key});

  @override
  State<KasirMainScreen> createState() => _KasirMainScreenState();
}

class _KasirMainScreenState extends State<KasirMainScreen> {
  int _currentIndex = 1; // Default to Transaction

  final List<Widget> _screens = const [InventoryScreen(), TransactionScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: 8,
              tabletSpacing: 10,
              desktopSpacing: 12,
            ),
            offset: Offset(
              0,
              -ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 2,
                tabletSpacing: 3,
                desktopSpacing: 4,
              ),
            ),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding:
              ResponsiveUtils.getResponsivePaddingCustom(
                context,
                phoneValue: AppSpacing.lg,
                tabletValue: AppSpacing.xl,
                desktopValue: 24,
              ).copyWith(
                top: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.sm,
                  tabletSpacing: AppSpacing.md,
                  desktopSpacing: AppSpacing.lg,
                ),
                bottom: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.sm,
                  tabletSpacing: AppSpacing.md,
                  desktopSpacing: AppSpacing.lg,
                ),
              ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                0,
                Icons.inventory_2_outlined,
                Icons.inventory_2,
                'Produk',
              ),
              _buildNavItem(
                1,
                Icons.point_of_sale_outlined,
                Icons.point_of_sale,
                'Transaksi',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: AppSpacing.sm,
              tabletSpacing: AppSpacing.md,
              desktopSpacing: AppSpacing.lg,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.textLight,
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
              SizedBox(
                height: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.xs,
                  tabletSpacing: AppSpacing.sm,
                  desktopSpacing: AppSpacing.md,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    phoneSize: 12,
                    tabletSize: 14,
                    desktopSize: 16,
                  ),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? AppColors.primary : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
