import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/auto_responsive_extensions.dart';
import 'dashboard/dashboard_screen.dart';
import '../kasir/inventory/inventory_screen.dart';
import '../kasir/transaction/transaction_screen.dart';
import 'expense/expense_screen.dart';
import 'tax/tax_center_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  void navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    InventoryScreen(),
    TransactionScreen(),
    ExpenseScreen(),
    TaxCenterScreen(),
  ];

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
            blurRadius: isLandscape ? 6 : 8.ar(context),
            offset: Offset(0, isLandscape ? -1 : -2.ah(context)),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          // More flexible height constraints
          constraints: BoxConstraints(
            maxHeight: isLandscape ? 60 : 90, // Increased for portrait
            minHeight: isLandscape ? 50 : 70, // Increased for portrait
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 8 : 4.aw(context),
              vertical: isLandscape
                  ? 4
                  : 6.ah(context), // Reduced vertical padding
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: _buildNavItem(
                    0,
                    Icons.dashboard_outlined,
                    Icons.dashboard,
                    'Dashboard',
                  ),
                ),
                Flexible(
                  child: _buildNavItem(
                    1,
                    Icons.inventory_2_outlined,
                    Icons.inventory_2,
                    'Produk',
                  ),
                ),
                Flexible(
                  child: _buildNavItem(
                    2,
                    Icons.point_of_sale_outlined,
                    Icons.point_of_sale,
                    'Transaksi',
                  ),
                ),
                Flexible(
                  child: _buildNavItem(
                    3,
                    Icons.account_balance_wallet_outlined,
                    Icons.account_balance_wallet,
                    'Keuangan',
                  ),
                ),
                Flexible(
                  child: _buildNavItem(
                    4,
                    Icons.receipt_long_outlined,
                    Icons.receipt_long,
                    'Pajak',
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

    // Responsive icon size with landscape constraints
    double iconSize;
    if (isLandscape) {
      iconSize = screenWidth > 800 ? 20 : 18; // Smaller icons in landscape
    } else {
      iconSize = 24.aw(context);
      // Constrain icon size to prevent it from becoming too large
      if (iconSize > 28) iconSize = 28;
      if (iconSize < 20) iconSize = 20; // Minimum size for readability
    }

    // Responsive font size with landscape constraints
    double fontSize;
    if (isLandscape) {
      fontSize = screenWidth > 800 ? 9 : 8; // Smaller text in landscape
    } else {
      fontSize = 10.asp(context);
      // Constrain font size
      if (fontSize > 12) fontSize = 12;
      if (fontSize < 9) fontSize = 9; // Minimum size for readability
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(isLandscape ? 8 : 12.ar(context)),
        child: Container(
          // More flexible constraints for portrait mode
          constraints: BoxConstraints(
            maxWidth: screenWidth / 5 - 8, // 5 tabs now instead of 6
            minHeight: isLandscape
                ? 40
                : 60, // Increased min height for portrait
            maxHeight: isLandscape
                ? 50
                : 80, // Increased max height for portrait
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isLandscape ? 2 : 4.aw(context),
            vertical: isLandscape
                ? 4
                : 6.ah(context), // Reduced vertical padding
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
                height: isLandscape ? 2 : 3.ah(context),
              ), // Reduced spacing
              Flexible(
                child: AText(
                  label,
                  fontSize: fontSize,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? AppColors.primary : AppColors.textLight,
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
