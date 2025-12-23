import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../data/models/expense_model.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../providers/expense_provider.dart';
import 'expense_form_modal.dart';

class ExpenseScreenResponsive extends ConsumerWidget {
  const ExpenseScreenResponsive({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real-time stream
    final expensesAsync = ref.watch(todayExpensesStreamProvider);

    final syncStatus = expensesAsync.when(
      data: (_) => SyncStatus.online,
      loading: () => SyncStatus.syncing,
      error: (_, _) => SyncStatus.offline,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: expensesAsync.when(
          data: (expenses) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(todayExpensesStreamProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  AppHeader(
                    title: 'Pengeluaran',
                    syncStatus: syncStatus,
                    lastSyncTime: 'Real-time',
                  ),
                  _buildTotalCard(context, expenses),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: AppSpacing.md,
                      tabletSpacing: AppSpacing.lg,
                      desktopSpacing: 20,
                    ),
                  ),
                  _buildCategoryBreakdown(context, expenses),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: AppSpacing.md,
                      tabletSpacing: AppSpacing.lg,
                      desktopSpacing: 20,
                    ),
                  ),
                  _buildSectionTitle(context),
                  _buildExpenseList(context, ref, expenses),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 80,
                      tabletSpacing: 90,
                      desktopSpacing: 100,
                    ),
                  ),
                ],
              ),
            ),
          ),
          loading: () => const LoadingWidget(),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: ResponsiveUtils.getResponsiveIconSize(context) * 2,
                  color: AppColors.error,
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: AppSpacing.md,
                    tabletSpacing: AppSpacing.lg,
                    desktopSpacing: 20,
                  ),
                ),
                Text(
                  '$error',
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
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: AppSpacing.md,
                    tabletSpacing: AppSpacing.lg,
                    desktopSpacing: 20,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => ref.invalidate(todayExpensesStreamProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Tambah',
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

  Widget _buildTotalCard(BuildContext context, List<ExpenseModel> expenses) {
    final total = expenses.fold(0, (sum, e) => sum + e.amount);

    return Container(
      margin: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: AppSpacing.md,
        tabletValue: AppSpacing.lg,
        desktopValue: AppSpacing.xl,
      ).copyWith(top: 0, bottom: 0),
      padding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: AppSpacing.lg,
        tabletValue: AppSpacing.xl,
        desktopValue: 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: AppSpacing.md,
              tabletValue: AppSpacing.lg,
              desktopValue: 18,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context),
              ),
            ),
            child: Icon(
              Icons.trending_down,
              color: AppColors.error,
              size: ResponsiveUtils.getResponsiveIconSize(context),
            ),
          ),
          SizedBox(
            width: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: AppSpacing.md,
              tabletSpacing: AppSpacing.lg,
              desktopSpacing: 20,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Pengeluaran Hari Ini',
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
                    phoneSpacing: AppSpacing.xs,
                    tabletSpacing: AppSpacing.sm,
                    desktopSpacing: AppSpacing.md,
                  ),
                ),
                Text(
                  'Rp ${_formatNumber(total)}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 24,
                      tabletSize: 28,
                      desktopSize: 32,
                    ),
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context,
    List<ExpenseModel> expenses,
  ) {
    // Calculate breakdown from expenses
    final Map<String, int> breakdown = {};
    for (final expense in expenses) {
      breakdown[expense.category] =
          (breakdown[expense.category] ?? 0) + expense.amount;
    }

    final total = breakdown.values.fold(0, (sum, v) => sum + v);

    if (breakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: AppSpacing.md,
        tabletValue: AppSpacing.lg,
        desktopValue: AppSpacing.xl,
      ).copyWith(top: 0, bottom: 0),
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
          Text(
            'Breakdown per Kategori',
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
              phoneSpacing: AppSpacing.md,
              tabletSpacing: AppSpacing.lg,
              desktopSpacing: 20,
            ),
          ),
          ...breakdown.entries.map(
            (entry) => _buildCategoryRow(
              context,
              entry.key,
              entry.value,
              total > 0 ? entry.value / total : 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    String category,
    int amount,
    double percentage,
  ) {
    final color = _getCategoryColor(category);
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(
          context,
          phoneSpacing: AppSpacing.md,
          tabletSpacing: AppSpacing.lg,
          desktopSpacing: 16,
        ),
      ),
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: ResponsiveUtils.getResponsivePaddingCustom(
                  context,
                  phoneValue: AppSpacing.sm,
                  tabletValue: AppSpacing.md,
                  desktopValue: 12,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context),
                  ),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: color,
                  size: ResponsiveUtils.getResponsiveIconSize(context),
                ),
              ),
              SizedBox(
                width: ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: AppSpacing.md,
                  tabletSpacing: AppSpacing.lg,
                  desktopSpacing: 16,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCategoryLabel(category),
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
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${_formatNumber(amount)}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 14,
                          tabletSize: 16,
                          desktopSize: 18,
                        ),
                        fontWeight: FontWeight.w500,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    phoneSize: 18,
                    tabletSize: 20,
                    desktopSize: 22,
                  ),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: AppSpacing.md,
              tabletSpacing: AppSpacing.lg,
              desktopSpacing: 16,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.secondary,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: ResponsiveUtils.getResponsiveHeight(
                context,
                phoneHeight: 8,
                tabletHeight: 10,
                desktopHeight: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: AppSpacing.md,
        tabletValue: AppSpacing.lg,
        desktopValue: AppSpacing.xl,
      ).copyWith(top: 0, bottom: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pengeluaran Hari Ini',
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
          TextButton(
            onPressed: () {},
            child: Text(
              'Lihat Riwayat',
              style: TextStyle(
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
      ),
    );
  }

  Widget _buildExpenseList(
    BuildContext context,
    WidgetRef ref,
    List<ExpenseModel> expenses,
  ) {
    if (expenses.isEmpty) {
      return Padding(
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Center(
          child: Text(
            'Belum ada pengeluaran hari ini',
            style: TextStyle(
              color: AppColors.textGray,
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: ResponsiveUtils.getResponsivePadding(context),
      itemCount: expenses.length,
      itemBuilder: (context, index) =>
          _buildExpenseCard(context, ref, expenses[index]),
    );
  }

  Widget _buildExpenseCard(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
  ) {
    final time = expense.createdAt != null
        ? '${expense.createdAt!.hour.toString().padLeft(2, '0')}:${expense.createdAt!.minute.toString().padLeft(2, '0')}'
        : '-';

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(
          right: ResponsiveUtils.getResponsiveSpacing(
            context,
            phoneSpacing: AppSpacing.md,
            tabletSpacing: AppSpacing.lg,
            desktopSpacing: 20,
          ),
        ),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) => _confirmDelete(context, ref, expense),
      child: Container(
        margin: EdgeInsets.only(
          bottom: ResponsiveUtils.getResponsiveSpacing(
            context,
            phoneSpacing: AppSpacing.sm,
            tabletSpacing: AppSpacing.md,
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
                phoneValue: AppSpacing.sm,
                tabletValue: AppSpacing.md,
                desktopValue: 12,
              ),
              decoration: BoxDecoration(
                color: _getCategoryColor(
                  expense.category,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
                ),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
            ),
            SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: AppSpacing.md,
                tabletSpacing: AppSpacing.lg,
                desktopSpacing: 16,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCategoryLabel(expense.category),
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
                  Text(
                    expense.description ?? '-',
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
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${_formatNumber(expense.amount)}',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 16,
                      tabletSize: 18,
                      desktopSize: 20,
                    ),
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 12,
                      tabletSize: 14,
                      desktopSize: 16,
                    ),
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: AppSpacing.sm,
                tabletSpacing: AppSpacing.md,
                desktopSpacing: 12,
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Edit'),
                  onTap: () => _showEditExpenseDialog(context, ref, expense),
                ),
                PopupMenuItem(
                  child: const Text('Hapus'),
                  onTap: () => _confirmDelete(context, ref, expense),
                ),
              ],
              child: const Icon(Icons.more_vert, color: AppColors.textGray),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengeluaran'),
        content: Text(
          'Yakin ingin menghapus "${_getCategoryLabel(expense.category)}" - Rp ${_formatNumber(expense.amount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (result == true) {
      await ref.read(expenseListProvider.notifier).deleteExpense(expense.id);
    }
    return false; // Don't dismiss, we handle it manually
  }

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref) {
    showExpenseFormModal(context);
  }

  void _showEditExpenseDialog(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
  ) {
    showExpenseFormModal(context, expense: expense);
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'LISTRIK':
        return Icons.bolt;
      case 'GAJI':
        return Icons.people;
      case 'PLASTIK':
        return Icons.shopping_bag;
      case 'MAKAN_SIANG':
        return Icons.restaurant;
      case 'PEMBELIAN_STOK':
        return Icons.inventory;
      default:
        return Icons.receipt;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'LISTRIK':
        return Colors.orange;
      case 'GAJI':
        return Colors.blue;
      case 'PLASTIK':
        return Colors.purple;
      case 'MAKAN_SIANG':
        return Colors.green;
      case 'PEMBELIAN_STOK':
        return Colors.teal;
      default:
        return AppColors.textGray;
    }
  }

  String _getCategoryLabel(String category) {
    // Map database categories back to Indonesian display names
    final categoryMapping = {
      'GAJI': 'Gaji Karyawan',
      'SEWA': 'Sewa Tempat',
      'LISTRIK': 'Listrik & Air',
      'TRANSPORTASI': 'Transportasi',
      'PERAWATAN': 'Perawatan Kendaraan',
      'SUPPLIES': 'Supplies',
      'MARKETING': 'Marketing',
      'LAINNYA': 'Lainnya',
      // Legacy categories (for backward compatibility)
      'PLASTIK': 'Plastik',
      'MAKAN_SIANG': 'Makan Siang',
      'PEMBELIAN_STOK': 'Pembelian Stok',
    };

    return categoryMapping[category.toUpperCase()] ?? category;
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
