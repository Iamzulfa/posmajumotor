import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/expense_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/expense_provider.dart';
import 'transaction_detail_modal.dart';

/// Enum untuk jenis transaksi yang ditampilkan
enum MutationType { all, sales, expenses }

/// Model untuk item mutasi (gabungan transaksi & pengeluaran)
class MutationItem {
  final String id;
  final DateTime date;
  final String description;
  final String reference;
  final int amount;
  final bool isCredit; // true = masuk (penjualan), false = keluar (pengeluaran)
  final String type;
  final String? paymentMethod;
  final ExpenseModel? expense; // Original expense data for detail modal

  MutationItem({
    required this.id,
    required this.date,
    required this.description,
    required this.reference,
    required this.amount,
    required this.isCredit,
    required this.type,
    this.paymentMethod,
    this.expense,
  });

  factory MutationItem.fromTransaction(TransactionModel tx) {
    return MutationItem(
      id: tx.id,
      date: tx.createdAt ?? DateTime.now(),
      description: tx.customerName ?? 'Penjualan ${tx.tier}',
      reference: tx.transactionNumber,
      amount: tx.total,
      isCredit: true,
      type: 'Penjualan',
      paymentMethod: tx.paymentMethod,
      expense: null,
    );
  }

  factory MutationItem.fromExpense(ExpenseModel exp) {
    return MutationItem(
      id: exp.id,
      date: exp.expenseDate,
      description: exp.description ?? exp.category,
      reference: exp.category,
      amount: exp.amount,
      isCredit: false,
      type: 'Pengeluaran',
      paymentMethod: null,
      expense: exp,
    );
  }
}

class TransactionHistoryTab extends ConsumerStatefulWidget {
  const TransactionHistoryTab({super.key});

  @override
  ConsumerState<TransactionHistoryTab> createState() =>
      _TransactionHistoryTabState();
}

class _TransactionHistoryTabState extends ConsumerState<TransactionHistoryTab> {
  // Filter state
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _endDate = DateTime.now();
  MutationType _selectedType = MutationType.all;
  String _searchQuery = '';
  bool _isFilterExpanded = true;

  // Controllers
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(transactionsForDateRangeProvider);
        ref.invalidate(expensesForDateRangeProvider);
      },
      child: CustomScrollView(
        slivers: [
          // Filter Section
          SliverToBoxAdapter(child: _buildFilterSection()),
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari mutasi...',
                  hintStyle: const TextStyle(color: AppColors.textGray),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textGray,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          // Period info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Periode: ${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGray,
                    ),
                  ),
                  Text(
                    'Inquiry: ${_formatDateTime(DateTime.now())}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Results
          _buildResultsSliver(),
        ],
      ),
    );
  }

  Widget _buildResultsSliver() {
    final transactionsAsync = ref.watch(
      transactionsForDateRangeProvider(
        DateRange(start: _startDate, end: _endDate),
      ),
    );

    final expensesAsync = ref.watch(
      expensesForDateRangeProvider(DateRange(start: _startDate, end: _endDate)),
    );

    return transactionsAsync.when(
      data: (transactions) => expensesAsync.when(
        data: (expenses) => _buildMutationSliver(transactions, expenses),
        loading: () => const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) =>
            SliverFillRemaining(child: Center(child: Text('Error: $e'))),
      ),
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) =>
          SliverFillRemaining(child: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildMutationSliver(
    List<TransactionModel> transactions,
    List<ExpenseModel> expenses,
  ) {
    List<MutationItem> mutations = [];

    if (_selectedType == MutationType.all ||
        _selectedType == MutationType.sales) {
      mutations.addAll(
        transactions
            .where((tx) => tx.paymentStatus == 'COMPLETED')
            .map((tx) => MutationItem.fromTransaction(tx)),
      );
    }

    if (_selectedType == MutationType.all ||
        _selectedType == MutationType.expenses) {
      mutations.addAll(expenses.map((exp) => MutationItem.fromExpense(exp)));
    }

    if (_searchQuery.isNotEmpty) {
      mutations = mutations.where((m) {
        return m.description.toLowerCase().contains(_searchQuery) ||
            m.reference.toLowerCase().contains(_searchQuery) ||
            m.type.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    mutations.sort((a, b) => b.date.compareTo(a.date));

    if (mutations.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.textGray.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tidak ada mutasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textGray,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ubah filter untuk melihat data lain',
                style: TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
        ),
      );
    }

    final totalCredit = mutations
        .where((m) => m.isCredit)
        .fold<int>(0, (sum, m) => sum + m.amount);
    final totalDebit = mutations
        .where((m) => !m.isCredit)
        .fold<int>(0, (sum, m) => sum + m.amount);

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Masuk', totalCredit, AppColors.success),
                Container(width: 1, height: 30, color: AppColors.border),
                _buildSummaryItem('Keluar', totalDebit, AppColors.error),
                Container(width: 1, height: 30, color: AppColors.border),
                _buildSummaryItem(
                  'Selisih',
                  totalCredit - totalDebit,
                  totalCredit >= totalDebit
                      ? AppColors.success
                      : AppColors.error,
                ),
              ],
            ),
          );
        }

        final mutationIndex = index - 1;
        if (mutationIndex >= mutations.length) return null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildMutationItem(mutations[mutationIndex]),
        );
      }, childCount: mutations.length + 1),
    );
  }

  Widget _buildFilterSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with toggle
            InkWell(
              onTap: () {
                setState(() {
                  _isFilterExpanded = !_isFilterExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Mutasi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Icon(
                    _isFilterExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textGray,
                  ),
                ],
              ),
            ),
            if (_isFilterExpanded) ...[
              const SizedBox(height: 16),
              // Jenis Transaksi
              _buildTypeSelector(),
              const SizedBox(height: 16),
              // Periode Mutasi
              _buildDateRangeSelector(),
              const SizedBox(height: 16),
              // Tombol Cari
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Tampilkan Mutasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Catatan
              Text(
                '• Periode mutasi maksimal 7 hari\n• Data tersedia hingga 31 hari ke belakang',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textGray.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Transaksi',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildTypeChip('Semua', MutationType.all),
            const SizedBox(width: 8),
            _buildTypeChip('Penjualan', MutationType.sales),
            const SizedBox(width: 8),
            _buildTypeChip('Pengeluaran', MutationType.expenses),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String label, MutationType type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.secondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textGray,
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Periode Mutasi',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Dari',
                date: _startDate,
                onTap: () => _selectDate(isStart: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateField(
                label: 'Sampai',
                date: _endDate,
                onTap: () => _selectDate(isStart: false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textGray,
                    ),
                  ),
                  Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
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

  Widget _buildSummaryItem(String label, int amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textGray),
        ),
        const SizedBox(height: 2),
        Text(
          CurrencyFormatter.formatCompact(amount.abs()),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMutationItem(MutationItem item) {
    return GestureDetector(
      onTap: () => _onMutationItemTap(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.isCredit
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: item.isCredit ? AppColors.success : AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: item.isCredit
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatDateShort(item.date)} • ${item.reference}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGray,
                    ),
                  ),
                  if (item.paymentMethod != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.paymentMethod!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Amount and chevron
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.formatFull(item.amount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: item.isCredit
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.isCredit ? 'CR' : 'DB',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item.isCredit
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textGray,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onMutationItemTap(MutationItem item) {
    if (item.isCredit) {
      // Transaction - show transaction detail modal
      showTransactionDetailModal(
        context,
        transactionId: item.id,
        onRefund: () => _showRefundConfirmation(item.id),
      );
    } else {
      // Expense - show expense detail modal
      if (item.expense != null) {
        showExpenseDetailModal(context, expense: item.expense!);
      }
    }
  }

  Future<void> _showRefundConfirmation(String transactionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Refund'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin melakukan refund untuk transaksi ini?',
            ),
            SizedBox(height: 12),
            Text(
              'Tindakan ini akan:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 4),
            Text('• Membatalkan transaksi'),
            Text('• Mengembalikan stok barang'),
            Text('• Mengubah status menjadi REFUNDED'),
            SizedBox(height: 12),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Refund'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _processRefund(transactionId);
    }
  }

  Future<void> _processRefund(String transactionId) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Call refund
      await ref.read(refundTransactionProvider(transactionId).future);

      // Close loading
      if (mounted) Navigator.pop(context);

      // Refresh data
      ref.invalidate(transactionsForDateRangeProvider);

      // Show success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil di-refund'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // Close loading
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal melakukan refund: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Helper methods
  Future<void> _selectDate({required bool isStart}) async {
    final now = DateTime.now();
    final minDate = now.subtract(const Duration(days: 31));

    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: minDate,
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Ensure end date is not more than 7 days after start
          final maxEnd = picked.add(const Duration(days: 6));
          if (_endDate.isAfter(maxEnd)) {
            _endDate = maxEnd;
          }
          // Ensure end date is not before start
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          // Ensure range is max 7 days
          final minStart = picked.subtract(const Duration(days: 6));
          if (_startDate.isBefore(minStart)) {
            _showMaxRangeWarning();
            return;
          }
          _endDate = picked;
        }
      });
    }
  }

  void _showMaxRangeWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Periode mutasi maksimal 7 hari'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _applyFilter() {
    // Collapse filter after applying
    setState(() {
      _isFilterExpanded = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
