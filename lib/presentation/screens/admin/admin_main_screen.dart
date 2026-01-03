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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.ar(context),
            offset: Offset(0, -2.ah(context)),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4.aw(context),
            vertical: 8.ah(context),
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
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isActive = _currentIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(12.ar(context)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4.aw(context),
            vertical: 8.ah(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.textLight,
                size: 24.aw(context),
              ),
              AR.h(context, 4),
              AText(
                label,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textLight,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
