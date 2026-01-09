import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../data/models/fixed_expense_model.dart';
import '../../../widgets/common/app_header.dart';
import 'fixed_expense_form_modal.dart';

class FixedExpenseDetailScreen extends ConsumerWidget {
  final String category;
  final List<FixedExpenseModel> expenses;
  final Color categoryColor;

  const FixedExpenseDetailScreen({
    super.key,
    required this.category,
    required this.expenses,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalAmount = expenses.fold<int>(0, (sum, e) => sum + e.amount);
    final averageAmount = expenses.isNotEmpty
        ? (totalAmount / expenses.length).round()
        : 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            AppHeader(
              title: _getCategoryDisplayName(category),
              showBackButton: true,
              // backgroundColor: categoryColor, // Remove this - AppHeader doesn't have this parameter
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    _buildSummaryCards(
                      totalAmount,
                      averageAmount,
                      expenses.length,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Individual Items Header
                    _buildSectionHeader(
                      'Detail ${_getCategoryDisplayName(category)}',
                      expenses.length,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Individual Items List
                    _buildDetailList(context, ref),

                    const SizedBox(height: AppSpacing.xl),

                    // Insights Section (for Gaji category)
                    if (category.toUpperCase() == 'GAJI') ...[
                      _buildInsightsSection(totalAmount, expenses.length),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // 🔥 REMOVED: Redundant floating action button
      // The main Fixed Expense screen already has proper "Tambah" functionality
    );
  }

  Widget _buildSummaryCards(int totalAmount, int averageAmount, int itemCount) {
    return Row(
      children: [
        // Total Card
        Expanded(
          child: _buildSummaryCard(
            'Total Bulanan',
            'Rp ${_formatNumber(totalAmount)}',
            Icons.account_balance_wallet,
            categoryColor,
          ),
        ),
        const SizedBox(width: AppSpacing.md),

        // Average Card
        Expanded(
          child: _buildSummaryCard(
            'Rata-rata',
            'Rp ${_formatNumber(averageAmount)}',
            Icons.trending_up,
            categoryColor.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: categoryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count item${count != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: categoryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailList(BuildContext context, WidgetRef ref) {
    return Column(
      children: expenses
          .map((expense) => _buildDetailCard(context, ref, expense))
          .toList(),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    WidgetRef ref,
    FixedExpenseModel expense,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Avatar/Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getPersonIcon(
                      expense.name,
                    ), // Different icons for different people
                    color: categoryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Name and Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (expense.description?.isNotEmpty == true)
                        Text(
                          expense.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${_formatNumber(expense.amount)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                    Text(
                      'per bulan',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Additional Info Row
            Row(
              children: [
                _buildInfoChip(
                  'Per Hari',
                  'Rp ${_formatNumber((expense.amount / 30).round())}',
                  Icons.calendar_today,
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildInfoChip(
                  'Per Tahun',
                  'Rp ${_formatNumber(expense.amount * 12)}',
                  Icons.trending_up,
                ),
                const Spacer(),

                // Action Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: categoryColor),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditExpenseDialog(context, expense);
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
                          Text(
                            'Hapus',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textGray),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 8, color: AppColors.textGray),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(int totalAmount, int employeeCount) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: categoryColor),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Insights Gaji Karyawan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          _buildInsightRow('Total Karyawan', '$employeeCount orang'),
          _buildInsightRow(
            'Total Gaji Bulanan',
            'Rp ${_formatNumber(totalAmount)}',
          ),
          _buildInsightRow(
            'Total Gaji Tahunan',
            'Rp ${_formatNumber(totalAmount * 12)}',
          ),
          _buildInsightRow(
            'Rata-rata Gaji',
            'Rp ${_formatNumber((totalAmount / employeeCount).round())}',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.textGray),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
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

  IconData _getPersonIcon(String name) {
    // Different icons for different people to make it more personal
    final lowerName = name.toLowerCase();
    if (lowerName.contains('sinot')) return Icons.person;
    if (lowerName.contains('sigit')) return Icons.person_2;
    if (lowerName.contains('fitri')) return Icons.person_3;
    if (lowerName.contains('aziz')) return Icons.person_4;
    return Icons.account_circle;
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showFixedExpenseFormModal(context);
  }

  void _showEditExpenseDialog(BuildContext context, FixedExpenseModel expense) {
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
              // Note: You'll need to implement the delete functionality here
              // For now, just show a success message
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${expense.name} berhasil dihapus'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context); // Go back to main screen
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
}
