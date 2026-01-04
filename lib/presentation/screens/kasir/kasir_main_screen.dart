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
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: isLandscape
                ? 6
                : ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: 8,
                    tabletSpacing: 10,
                    desktopSpacing: 12,
                  ),
            offset: Offset(
              0,
              isLandscape
                  ? -1
                  : -ResponsiveUtils.getResponsiveSpacing(
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
        child: Container(
          // More flexible constraints to prevent overflow
          constraints: BoxConstraints(
            maxHeight: isLandscape ? 60 : 90, // Increased for portrait
            minHeight: isLandscape ? 50 : 70, // Increased for portrait
          ),
          child: Padding(
            padding: isLandscape
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                : ResponsiveUtils.getResponsivePaddingCustom(
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
                Flexible(
                  child: _buildNavItem(
                    0,
                    Icons.inventory_2_outlined,
                    Icons.inventory_2,
                    'Produk',
                  ),
                ),
                Flexible(
                  child: _buildNavItem(
                    1,
                    Icons.point_of_sale_outlined,
                    Icons.point_of_sale,
                    'Transaksi',
                  ),
                ),
              ],
            ),
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
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final screenWidth = mediaQuery.size.width;

    // Responsive sizing with landscape constraints
    double iconSize;
    double fontSize;

    if (isLandscape) {
      iconSize = screenWidth > 800 ? 22 : 20;
      fontSize = screenWidth > 800 ? 11 : 10;
    } else {
      iconSize = ResponsiveUtils.getResponsiveIconSize(context);
      fontSize = ResponsiveUtils.getResponsiveFontSize(
        context,
        phoneSize: 12,
        tabletSize: 14,
        desktopSize: 16,
      );
      // Constrain sizes to prevent excessive scaling and ensure readability
      if (iconSize > 30) iconSize = 30;
      if (iconSize < 22) iconSize = 22; // Minimum size for readability
      if (fontSize > 16) fontSize = 16;
      if (fontSize < 11) fontSize = 11; // Minimum size for readability
    }

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(
          isLandscape ? 8 : ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        child: Container(
          constraints: BoxConstraints(
            minHeight: isLandscape ? 40 : 60, // Increased for portrait
            maxHeight: isLandscape ? 50 : 80, // Increased for portrait
          ),
          padding: EdgeInsets.symmetric(
            vertical: isLandscape
                ? 4
                : ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: AppSpacing.sm,
                    tabletSpacing: AppSpacing.md,
                    desktopSpacing: AppSpacing.lg,
                  ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.textLight,
                size: iconSize,
              ),
              SizedBox(
                height: isLandscape
                    ? 2
                    : ResponsiveUtils.getResponsiveSpacing(
                        context,
                        phoneSpacing: AppSpacing.xs,
                        tabletSpacing: AppSpacing.sm,
                        desktopSpacing: AppSpacing.md,
                      ),
              ),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? AppColors.primary : AppColors.textLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
