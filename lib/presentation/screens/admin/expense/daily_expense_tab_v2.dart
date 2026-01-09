import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/models/expense_model.dart';
import '../../../providers/expense_provider.dart';
import 'expense_form_modal.dart'; // 🔥 ADD: Import for expense form modal

class DailyExpenseTabV2 extends ConsumerWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const DailyExpenseTabV2({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 COPY WORKING PATTERN: Use the same provider pattern as FixedExpenseTab
    final expensesAsync = ref.watch(expensesByDateStreamProvider(selectedDate));

    AppLogger.info('🔧 Building daily expense tab V2 - TAB ACCESSED!');

    return expensesAsync.when(
      data: (expenses) {
        AppLogger.info(
          '🔧 Daily expenses data received: ${expenses.length} items',
        );

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header with Total (Sleek Design)
                _buildDateHeader(context, expenses),
                const SizedBox(height: AppSpacing.md),

                // Header with Actions
                _buildHeader(context, expenses.length),
                const SizedBox(height: AppSpacing.md),

                // Expenses List (COPY WORKING PATTERN) - Now with constrained height
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height *
                      0.4, // Constrain height for scrolling
                  child: _buildExpensesList(context, ref, expenses),
                ),
              ],
            ),
          ),
        );
      },
      loading: () {
        AppLogger.info('🔧 Daily expenses loading...');
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.md),
              Text('Memuat pengeluaran harian...'),
            ],
          ),
        );
      },
      error: (error, _) {
        AppLogger.error('🔧 Daily expenses error', error);
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
                  ref.invalidate(expensesByDateStreamProvider(selectedDate));
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔥 SLEEK DATE HEADER (matching fixed expenses style)
  Widget _buildDateHeader(BuildContext context, List<ExpenseModel> expenses) {
    final totalExpense = expenses.fold<int>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getFormattedDate(selectedDate)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: Rp ${_formatNumber(totalExpense)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
            // Date Change Button
            SizedBox(
              width: 100,
              height: 36,
              child: OutlinedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.edit_calendar, size: 14),
                label: const Text('Ubah', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int expenseCount) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rincian Pengeluaran Harian',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                '$expenseCount item${expenseCount != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
        ),
        // Add Button
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
              onPressed: () => _showAddExpenseDialog(context),
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

  // 🔥 SLEEK LIST PATTERN (matching fixed expenses style)
  Widget _buildExpensesList(
    BuildContext context,
    WidgetRef ref,
    List<ExpenseModel> expenses,
  ) {
    if (expenses.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildExpenseItem(expense, context, ref);
      },
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
            'Belum ada pengeluaran hari ini',
            style: TextStyle(fontSize: 16, color: AppColors.textGray),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Tambahkan pengeluaran harian untuk melihat rincian',
            style: TextStyle(fontSize: 14, color: AppColors.textGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 🔥 SLEEK EXPENSE ITEM (matching fixed expenses style)
  Widget _buildExpenseItem(
    ExpenseModel expense,
    BuildContext context,
    WidgetRef ref,
  ) {
    final time = expense.createdAt != null
        ? '${expense.createdAt!.hour.toString().padLeft(2, '0')}:${expense.createdAt!.minute.toString().padLeft(2, '0')}'
        : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(AppSpacing.md),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getCategoryColor(expense.category).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(expense.category),
              color: _getCategoryColor(expense.category),
              size: 24,
            ),
          ),
          title: Text(
            _getCategoryLabel(expense.category),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (expense.description?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  expense.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGray,
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Waktu: $time',
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
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
                      color: AppColors.textDark,
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
                        Text('Hapus', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods (same as original)
  String _getFormattedDate(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final days = [
      'Minggu',
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
    ];

    final dayName = days[date.weekday % 7];
    final monthName = months[date.month - 1];

    return '$dayName, ${date.day} $monthName ${date.year}';
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

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'GAJI':
        return Icons.people;
      case 'SEWA':
        return Icons.home;
      case 'LISTRIK':
        return Icons.bolt;
      case 'TRANSPORTASI':
        return Icons.directions_car;
      case 'PERAWATAN':
        return Icons.build;
      case 'SUPPLIES':
        return Icons.inventory;
      case 'MARKETING':
        return Icons.campaign;
      case 'LAINNYA':
        return Icons.receipt;
      default:
        return Icons.receipt;
    }
  }

  String _getCategoryLabel(String category) {
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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  void _showAddExpenseDialog(BuildContext context) {
    showExpenseFormModal(context);
  }

  void _showEditExpenseDialog(BuildContext context, ExpenseModel expense) {
    showExpenseFormModal(context, expense: expense);
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    ExpenseModel expense,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengeluaran'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${_getCategoryLabel(expense.category)}" sebesar Rp ${_formatNumber(expense.amount)}?',
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
                    .read(expenseListProvider.notifier)
                    .deleteExpense(expense.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengeluaran berhasil dihapus'),
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
}
