import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../data/models/fixed_expense_model.dart';
import '../../../../core/utils/logger.dart';
import '../../../providers/fixed_expense_provider.dart';

void showFixedExpenseFormModal(
  BuildContext context, {
  FixedExpenseModel? expense,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => FixedExpenseFormModal(expense: expense),
  );
}

class FixedExpenseFormModal extends ConsumerStatefulWidget {
  final FixedExpenseModel? expense;

  const FixedExpenseFormModal({super.key, this.expense});

  @override
  ConsumerState<FixedExpenseFormModal> createState() =>
      _FixedExpenseFormModalState();
}

class _FixedExpenseFormModalState extends ConsumerState<FixedExpenseFormModal> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  String? _selectedCategory;
  bool _isLoading = false;

  late List<String> _categories;

  @override
  void initState() {
    super.initState();

    // Initialize categories list for fixed expenses
    _categories = [
      'Gaji Karyawan',
      'Sewa Tempat',
      'Listrik & Air',
      'Internet & Telepon',
      'Asuransi',
      'Pajak',
      'Perawatan & Maintenance',
      'Lainnya',
    ];

    _nameController = TextEditingController(text: widget.expense?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.expense?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );

    // Set selected category
    if (widget.expense != null) {
      final expenseCategory = _mapCategoryFromDb(widget.expense!.category);
      if (_categories.contains(expenseCategory)) {
        _selectedCategory = expenseCategory;
      } else {
        _categories.add(expenseCategory);
        _selectedCategory = expenseCategory;
      }
    } else {
      _selectedCategory = _categories.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _mapCategoryFromDb(String dbCategory) {
    final categoryMapping = {
      'GAJI': 'Gaji Karyawan',
      'SEWA': 'Sewa Tempat',
      'LISTRIK': 'Listrik & Air',
      'INTERNET': 'Internet & Telepon',
      'ASURANSI': 'Asuransi',
      'PAJAK': 'Pajak',
      'MAINTENANCE': 'Perawatan & Maintenance',
      'LAINNYA': 'Lainnya',
    };
    return categoryMapping[dbCategory.toUpperCase()] ?? dbCategory;
  }

  String _mapCategoryToDb(String displayCategory) {
    final categoryMapping = {
      'Gaji Karyawan': 'GAJI',
      'Sewa Tempat': 'SEWA',
      'Listrik & Air': 'LISTRIK',
      'Internet & Telepon': 'INTERNET',
      'Asuransi': 'ASURANSI',
      'Pajak': 'PAJAK',
      'Perawatan & Maintenance': 'MAINTENANCE',
      'Lainnya': 'LAINNYA',
    };
    return categoryMapping[displayCategory] ?? 'LAINNYA';
  }

  Future<void> _saveFixedExpense() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final amount = int.parse(_amountController.text);
      final dbCategory = _mapCategoryToDb(_selectedCategory!);

      AppLogger.info(
        '💰 Saving fixed expense: $_selectedCategory → $dbCategory',
      );

      if (widget.expense != null) {
        // Edit existing fixed expense
        final updatedExpense = widget.expense!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          amount: amount,
          category: dbCategory,
        );

        await ref
            .read(fixedExpenseListProvider.notifier)
            .updateFixedExpense(updatedExpense);

        AppLogger.info('Fixed expense updated: ${updatedExpense.id}');
      } else {
        // Create new fixed expense - generate UUID on client side
        final newExpense = FixedExpenseModel(
          id: '', // Let database generate UUID
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          amount: amount,
          category: dbCategory,
          isActive: true,
          recurrenceType: 'MONTHLY', // Default to monthly for fixed expenses
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await ref
            .read(fixedExpenseListProvider.notifier)
            .createFixedExpense(newExpense);

        AppLogger.info('Fixed expense creation requested');
      }

      // Wait a moment for provider state to update
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if there was an error in the provider
      final providerState = ref.read(fixedExpenseListProvider);
      if (providerState.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${providerState.error}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        // Clear the error after showing it
        ref.read(fixedExpenseListProvider.notifier).clearError();
        return;
      }

      // Force refresh the stream provider to ensure UI updates
      ref.invalidate(fixedExpensesStreamProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.expense != null
                  ? 'Pengeluaran tetap berhasil diperbarui'
                  : 'Pengeluaran tetap berhasil ditambahkan',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      AppLogger.error('Error saving fixed expense', e);
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
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama pengeluaran tidak boleh kosong'),
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
      final amount = int.parse(_amountController.text);
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jumlah harus lebih dari 0'),
            backgroundColor: AppColors.error,
          ),
        );
        return false;
      }
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
                      ? 'Edit Pengeluaran Tetap'
                      : 'Tambah Pengeluaran Tetap',
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

            // Name
            Text(
              'Nama Pengeluaran',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Contoh: Gaji Karyawan, Sewa Kantor',
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

            // Amount
            Text(
              'Jumlah per Bulan (Rp)',
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
                hintText: 'Masukkan jumlah pengeluaran bulanan',
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
            const SizedBox(height: AppSpacing.md),

            // Description
            Text(
              'Deskripsi (Opsional)',
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
                hintText: 'Tambahkan deskripsi atau catatan',
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
                    onPressed: _isLoading ? null : _saveFixedExpense,
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
