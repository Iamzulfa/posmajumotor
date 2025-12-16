import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../data/models/expense_model.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../providers/expense_provider.dart';

class ExpenseScreen extends ConsumerWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch real-time stream
    final expensesAsync = ref.watch(todayExpensesStreamProvider);

    final syncStatus = expensesAsync.when(
      data: (_) => SyncStatus.online,
      loading: () => SyncStatus.syncing,
      error: (_, __) => SyncStatus.offline,
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
                  _buildTotalCard(expenses),
                  const SizedBox(height: AppSpacing.md),
                  _buildCategoryBreakdown(expenses),
                  const SizedBox(height: AppSpacing.md),
                  _buildSectionTitle(context),
                  _buildExpenseList(context, ref, expenses),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          loading: () => const LoadingWidget(),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text('$error', style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: AppSpacing.md),
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
        label: const Text('Tambah', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildTotalCard(List<ExpenseModel> expenses) {
    final total = expenses.fold(0, (sum, e) => sum + e.amount);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.trending_down,
              color: AppColors.error,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pengeluaran Hari Ini',
                  style: TextStyle(fontSize: 14, color: AppColors.textGray),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Rp ${_formatNumber(total)}',
                  style: const TextStyle(
                    fontSize: 24,
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

  Widget _buildCategoryBreakdown(List<ExpenseModel> expenses) {
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
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Breakdown per Kategori',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...breakdown.entries.map(
            (entry) => _buildCategoryRow(
              entry.key,
              entry.value,
              total > 0 ? entry.value / total : 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String category, int amount, double percentage) {
    final color = _getCategoryColor(category);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(_getCategoryIcon(category), color: color, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCategoryLabel(category),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${_formatNumber(amount)}',
                      style: TextStyle(
                        fontSize: 14,
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.secondary,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Pengeluaran Hari Ini',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('Lihat Riwayat')),
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
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: Text(
            'Belum ada pengeluaran hari ini',
            style: TextStyle(color: AppColors.textGray),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
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
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) => _confirmDelete(context, ref, expense),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _getCategoryColor(
                  expense.category,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: _getCategoryColor(expense.category),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCategoryLabel(expense.category),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    expense.description ?? '-',
                    style: const TextStyle(
                      fontSize: 14,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
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
    String selectedCategory = 'LISTRIK';
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 80,
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Pengeluaran',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Kategori',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: AppSpacing.sm),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items:
                      [
                            'LISTRIK',
                            'GAJI',
                            'PLASTIK',
                            'MAKAN_SIANG',
                            'PEMBELIAN_STOK',
                            'LAINNYA',
                          ]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(_getCategoryLabel(e)),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => setModalState(
                    () => selectedCategory = value ?? 'LISTRIK',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Nominal',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Catatan',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Catatan (opsional)',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                CustomButton(
                  text: 'Simpan',
                  onPressed: () async {
                    final amount =
                        int.tryParse(
                          amountController.text.replaceAll('.', ''),
                        ) ??
                        0;
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nominal harus lebih dari 0'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }

                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);

                    navigator.pop();

                    await ref
                        .read(expenseListProvider.notifier)
                        .createExpense(
                          category: selectedCategory,
                          amount: amount,
                          description: notesController.text.isNotEmpty
                              ? notesController.text
                              : null,
                        );

                    // Invalidate stream to refresh
                    ref.invalidate(todayExpensesStreamProvider);

                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Pengeluaran berhasil ditambahkan'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
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
    switch (category) {
      case 'LISTRIK':
        return 'Listrik';
      case 'GAJI':
        return 'Gaji';
      case 'PLASTIK':
        return 'Plastik';
      case 'MAKAN_SIANG':
        return 'Makan Siang';
      case 'PEMBELIAN_STOK':
        return 'Pembelian Stok';
      default:
        return 'Lainnya';
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
