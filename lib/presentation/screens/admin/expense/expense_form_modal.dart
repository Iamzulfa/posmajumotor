import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../data/models/models.dart';
import '../../../../core/utils/logger.dart';
import '../../../providers/expense_provider.dart';

void showExpenseFormModal(BuildContext context, {ExpenseModel? expense}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => ExpenseFormModal(expense: expense),
  );
}

class ExpenseFormModal extends ConsumerStatefulWidget {
  final ExpenseModel? expense;

  const ExpenseFormModal({super.key, this.expense});

  @override
  ConsumerState<ExpenseFormModal> createState() => _ExpenseFormModalState();
}

class _ExpenseFormModalState extends ConsumerState<ExpenseFormModal> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _categoryController;
  String? _selectedCategory;
  bool _isLoading = false;

  late List<String> _categories;

  @override
  void initState() {
    super.initState();

    // Initialize categories list
    _categories = [
      'Gaji Karyawan',
      'Sewa Tempat',
      'Listrik & Air',
      'Transportasi',
      'Perawatan Kendaraan',
      'Supplies',
      'Marketing',
      'Lainnya',
    ];

    _descriptionController = TextEditingController(
      text: widget.expense?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.expense?.category ?? '',
    );

    // Set selected category, ensure it's in the list
    final expenseCategory = widget.expense?.category;
    if (expenseCategory != null && _categories.contains(expenseCategory)) {
      _selectedCategory = expenseCategory;
    } else if (expenseCategory != null) {
      // If category not in list, add it
      _categories.add(expenseCategory);
      _selectedCategory = expenseCategory;
    } else {
      _selectedCategory = _categories.first;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final amount = int.parse(_amountController.text);

      if (widget.expense != null) {
        // Edit existing expense
        final updatedExpense = widget.expense!.copyWith(
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          amount: amount,
          category: _selectedCategory ?? widget.expense!.category,
        );

        await ref
            .read(expenseListProvider.notifier)
            .updateExpense(updatedExpense);

        AppLogger.info('Expense updated: ${updatedExpense.id}');
      } else {
        // Create new expense
        final newExpense = ExpenseModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          amount: amount,
          category: _selectedCategory ?? 'Lainnya',
          expenseDate: DateTime.now(),
        );

        await ref.read(expenseListProvider.notifier).addExpense(newExpense);

        AppLogger.info('Expense created: ${newExpense.id}');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.expense != null
                  ? 'Pengeluaran berhasil diperbarui'
                  : 'Pengeluaran berhasil ditambahkan',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      AppLogger.error('Error saving expense', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _validateForm() {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deskripsi tidak boleh kosong'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }

    if (_amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah tidak boleh kosong'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }

    try {
      int.parse(_amountController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah harus berupa angka'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }

    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori harus dipilih'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final navBarHeight = mediaQuery.padding.bottom;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: keyboardHeight + navBarHeight + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.expense != null
                      ? 'Edit Pengeluaran'
                      : 'Tambah Pengeluaran',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Category Dropdown
            Text(
              'Kategori',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  hint: const Text('Pilih kategori'),
                  items: _categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            Text(
              'Deskripsi',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Masukkan deskripsi pengeluaran',
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),

            // Amount
            Text(
              'Jumlah (Rp)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                hintText: 'Masukkan jumlah pengeluaran',
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: AppColors.textDark),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                    onPressed: _isLoading ? null : _saveExpense,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            widget.expense != null ? 'Perbarui' : 'Simpan',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
