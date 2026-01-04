import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/models/fixed_expense_model.dart';
import '../../../providers/fixed_expense_provider.dart';
import 'fixed_expense_form_modal.dart';
import 'fixed_expense_detail_screen.dart'; // 🔥 ADD: Import detail screen

class FixedExpenseTab extends ConsumerWidget {
  const FixedExpenseTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixedExpensesAsync = ref.watch(fixedExpensesStreamProvider);

    AppLogger.info('🔧 Building fixed expense tab - TAB ACCESSED!');

    return fixedExpensesAsync.when(
      data: (fixedExpenses) {
        AppLogger.info(
          '🔧 Fixed expenses data received: ${fixedExpenses.length} items',
        );

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                _buildSummaryCard(fixedExpenses),
                const SizedBox(height: AppSpacing.md),

                // Header with Actions
                _buildHeader(context),
                const SizedBox(height: AppSpacing.md),

                // Enhanced Fixed Expenses List with Categories - Now with constrained height
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height *
                      0.4, // Constrain height for scrolling
                  child: _buildFixedExpensesList(context, ref, fixedExpenses),
                ),
              ],
            ),
          ),
        );
      },
      loading: () {
        AppLogger.info('🔧 Fixed expenses loading...');
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.md),
              Text('Memuat pengeluaran tetap...'),
            ],
          ),
        );
      },
      error: (error, _) {
        AppLogger.error('🔧 Fixed expenses error', error);
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Error: $error',
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  AppLogger.info('🔧 Retry button pressed');
                  ref.invalidate(fixedExpensesStreamProvider);
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(List<FixedExpenseModel> fixedExpenses) {
    final totalAmount = fixedExpenses.fold<int>(0, (sum, e) => sum + e.amount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pengeluaran Tetap (Bulanan)',
                    style: TextStyle(fontSize: 14, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatNumber(totalAmount)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Per hari: Rp ${_formatNumber((totalAmount / 30).round())}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Rincian Pengeluaran Tetap',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        // 🔥 ENHANCED: Beautiful gradient "Tambah" button (context-aware)
        SizedBox(
          width: 120,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF45A049)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showAddFixedExpenseDialog(context),
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text(
                'Tambah',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedExpensesList(
    BuildContext context,
    WidgetRef ref,
    List<FixedExpenseModel> fixedExpenses,
  ) {
    AppLogger.info(
      '🔧 Building enhanced fixed expenses list with ${fixedExpenses.length} items',
    );

    if (fixedExpenses.isEmpty) {
      return _buildEmptyState();
    }

    // Group expenses by category
    final groupedExpenses = <String, List<FixedExpenseModel>>{};
    for (final expense in fixedExpenses) {
      final category = expense.category;
      if (!groupedExpenses.containsKey(category)) {
        groupedExpenses[category] = [];
      }
      groupedExpenses[category]!.add(expense);
    }

    return ListView.builder(
      itemCount: groupedExpenses.length,
      itemBuilder: (context, index) {
        final category = groupedExpenses.keys.elementAt(index);
        final categoryExpenses = groupedExpenses[category]!;
        final categoryTotal = categoryExpenses.fold<int>(
          0,
          (sum, e) => sum + e.amount,
        );

        return _buildCategoryExpansionTile(
          context,
          ref,
          category,
          categoryExpenses,
          categoryTotal,
        );
      },
    );
  }

  Widget _buildCategoryExpansionTile(
    BuildContext context,
    WidgetRef ref,
    String category,
    List<FixedExpenseModel> expenses,
    int totalAmount,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(category).withValues(alpha: 0.1),
          child: Icon(
            _getFixedExpenseIcon(category),
            color: _getCategoryColor(category),
            size: 20,
          ),
        ),
        title: Text(
          _getCategoryDisplayName(category),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          '${expenses.length} item${expenses.length > 1 ? 's' : ''} • Rp ${_formatNumber(totalAmount)}/bulan',
          style: const TextStyle(fontSize: 12, color: AppColors.textGray),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rp ${_formatNumber(totalAmount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getCategoryColor(category),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            // 🔥 ADD: View Details Button
            IconButton(
              onPressed: () => _showCategoryDetails(
                context,
                category,
                expenses,
                _getCategoryColor(category),
              ),
              icon: Icon(
                Icons.visibility,
                size: 16,
                color: _getCategoryColor(category),
              ),
              tooltip: 'Lihat Detail',
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          ...expenses.map(
            (expense) =>
                _buildIndividualExpenseItem(context, ref, expense, category),
          ),
          // 🔥 REMOVED: Redundant "Tambah" button inside expansion tile
          // The header already has a "Tambah" button and there's a floating action button
        ],
      ),
    );
  }

  Widget _buildIndividualExpenseItem(
    BuildContext context,
    WidgetRef ref,
    FixedExpenseModel expense,
    String category,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: _getCategoryColor(category),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          expense.name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        subtitle: expense.description?.isNotEmpty == true
            ? Text(
                expense.description!,
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${_formatNumber(expense.amount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Rp ${_formatNumber((expense.amount / 30).round())}/hari',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 16),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditFixedExpenseDialog(context, expense);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(context, ref, expense);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Hapus', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textGray,
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Belum ada pengeluaran tetap',
            style: TextStyle(fontSize: 16, color: AppColors.textGray),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Tambahkan pengeluaran tetap seperti gaji karyawan,\nsewa tempat, listrik, dan lainnya',
            style: TextStyle(fontSize: 14, color: AppColors.textGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getCategoryDisplayName(String category) {
    switch (category.toUpperCase()) {
      case 'GAJI':
        return 'Gaji Karyawan';
      case 'SEWA':
        return 'Sewa Tempat';
      case 'LISTRIK':
        return 'Listrik & Air';
      case 'TRANSPORTASI':
        return 'Transportasi';
      case 'PERAWATAN':
        return 'Perawatan';
      case 'SUPPLIES':
        return 'Supplies';
      case 'MARKETING':
        return 'Marketing';
      case 'LAINNYA':
        return 'Lainnya';
      default:
        return category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'GAJI':
        return Colors.blue;
      case 'SEWA':
        return Colors.orange;
      case 'LISTRIK':
        return Colors.yellow.shade700;
      case 'TRANSPORTASI':
        return Colors.green;
      case 'PERAWATAN':
        return Colors.purple;
      case 'SUPPLIES':
        return Colors.teal;
      case 'MARKETING':
        return Colors.pink;
      case 'LAINNYA':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  IconData _getFixedExpenseIcon(String category) {
    switch (category.toUpperCase()) {
      case 'GAJI':
        return Icons.people;
      case 'SEWA':
        return Icons.home;
      case 'LISTRIK':
        return Icons.bolt;
      case 'AIR':
        return Icons.water_drop;
      case 'INTERNET':
        return Icons.wifi;
      case 'ASURANSI':
        return Icons.security;
      case 'PAJAK':
        return Icons.account_balance;
      case 'MAINTENANCE':
        return Icons.build;
      default:
        return Icons.receipt;
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showAddFixedExpenseDialog(BuildContext context) {
    showFixedExpenseFormModal(context);
  }

  void _showEditFixedExpenseDialog(
    BuildContext context,
    FixedExpenseModel expense,
  ) {
    showFixedExpenseFormModal(context, expense: expense);
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    FixedExpenseModel expense,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengeluaran Tetap'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${expense.name}"?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(fixedExpenseListProvider.notifier)
                    .deleteFixedExpense(expense.id);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${expense.name} berhasil dihapus'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // 🔥 ADD: Navigation to detail screen
  void _showCategoryDetails(
    BuildContext context,
    String category,
    List<FixedExpenseModel> expenses,
    Color categoryColor,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FixedExpenseDetailScreen(
          category: category,
          expenses: expenses,
          categoryColor: categoryColor,
        ),
      ),
    );
  }
}
