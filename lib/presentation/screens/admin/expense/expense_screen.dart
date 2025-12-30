import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/models/fixed_expense_model.dart';
import '../../../../domain/repositories/fixed_expense_repository.dart';
import '../../../../injection_container.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/expense/daily_expense_metrics_widget.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/fixed_expense_provider.dart';
import '../../../providers/transaction_provider.dart';
import 'expense_form_modal.dart';
import 'fixed_expense_form_modal.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen>
    with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Pengeluaran',
              syncStatus: SyncStatus.online,
              lastSyncTime: 'Real-time',
            ),
            // Tab Bar
            Container(
              color: AppColors.background,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textGray,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Pengeluaran Harian'),
                  Tab(text: 'Pengeluaran Tetap'),
                ],
              ),
            ),
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDailyExpenseTab(context, ref),
                  _buildFixedExpenseTab(context, ref),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 0) {
            // Tab Pengeluaran Harian
            _showAddExpenseDialog(context, ref);
          } else {
            // Tab Pengeluaran Tetap
            _showAddFixedExpenseDialog(context);
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          _tabController.index == 0
              ? 'Tambah Pengeluaran'
              : 'Tambah Pengeluaran Tetap',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDailyExpenseTab(BuildContext context, WidgetRef ref) {
    // Watch real-time stream for selected date
    final expensesAsync = ref.watch(
      expensesByDateStreamProvider(_selectedDate),
    );

    // Watch transaction summary for income data
    final dateRange = DateRange(
      start: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      end: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        23,
        59,
        59,
      ),
    );
    final transactionSummaryAsync = ref.watch(
      transactionSummaryStreamProvider(dateRange),
    );

    return expensesAsync.when(
      data: (expenses) {
        final totalExpense = expenses.fold<int>(
          0,
          (sum, expense) => sum + expense.amount,
        );

        return transactionSummaryAsync.when(
          data: (transactionSummary) {
            final totalIncome = transactionSummary.totalOmset;

            return Column(
              children: [
                // Date Selector
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  color: AppColors.background,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: const Text('Ubah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // Daily Expense Metrics - Wrapped in Expanded
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: DailyExpenseMetricsWidget(
                      totalExpense: totalExpense,
                      totalIncome: totalIncome,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) {
            // If transaction data fails, still show expense metrics with 0 income
            return Column(
              children: [
                // Date Selector
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  color: AppColors.background,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.edit_calendar, size: 16),
                        label: const Text('Ubah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // Metrics with 0 income (fallback) - Wrapped in Expanded
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: DailyExpenseMetricsWidget(
                      totalExpense: totalExpense,
                      totalIncome: 0, // Default to 0 if transaction data fails
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildFixedExpenseTab(BuildContext context, WidgetRef ref) {
    // Use real data from FixedExpenseRepository
    final fixedExpensesAsync = ref.watch(fixedExpensesStreamProvider);

    AppLogger.info('🔧 Building fixed expense tab - TAB ACCESSED!');

    return fixedExpensesAsync.when(
      data: (fixedExpenses) {
        AppLogger.info(
          '🔧 Fixed expenses data received: ${fixedExpenses.length} items',
        );

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Card
              Card(
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
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textGray,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rp ${_formatNumber(fixedExpenses.fold<int>(0, (sum, e) => sum + e.amount))}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Per hari: Rp ${_formatNumber((fixedExpenses.fold<int>(0, (sum, e) => sum + e.amount) / 30).round())}',
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
              ),
              const SizedBox(height: AppSpacing.md),

              // Header with Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rincian Pengeluaran Tetap',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      // Debug button
                      ElevatedButton.icon(
                        onPressed: () async {
                          AppLogger.info(
                            '🔧 DEBUG: Manual data load triggered',
                          );
                          try {
                            final repository = getIt<FixedExpenseRepository>();
                            final data = await repository.getFixedExpenses();
                            AppLogger.info(
                              '🔧 DEBUG: Got ${data.length} fixed expenses',
                            );

                            // If no data exists, create sample data
                            if (data.isEmpty) {
                              AppLogger.info(
                                '🔧 DEBUG: No data found, creating sample data',
                              );
                              final sampleExpense = FixedExpenseModel(
                                id: '',
                                name: 'Gaji Karyawan',
                                description: 'Gaji bulanan karyawan',
                                amount: 5000000,
                                category: 'GAJI',
                                isActive: true,
                                recurrenceType: 'MONTHLY',
                                createdAt: DateTime.now(),
                                updatedAt: DateTime.now(),
                              );

                              await repository.createFixedExpense(
                                sampleExpense,
                              );
                              AppLogger.info('🔧 DEBUG: Sample data created');
                            }

                            // Force refresh providers
                            ref.invalidate(fixedExpensesStreamProvider);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'DEBUG: Found ${data.length} fixed expenses',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            AppLogger.error('🔧 DEBUG: Error loading data', e);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('DEBUG Error: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.bug_report, size: 16),
                        label: const Text('Debug'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Add button
                      ElevatedButton.icon(
                        onPressed: () => _showAddFixedExpenseDialog(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Tambah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Fixed Expenses List
              Expanded(
                child: _buildFixedExpensesList(context, ref, fixedExpenses),
              ),
            ],
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

  Widget _buildFixedExpensesList(
    BuildContext context,
    WidgetRef ref,
    List<FixedExpenseModel> fixedExpenses,
  ) {
    AppLogger.info(
      '🔧 Building fixed expenses list with ${fixedExpenses.length} items',
    );

    if (fixedExpenses.isEmpty) {
      AppLogger.info('🔧 No fixed expenses - showing empty state');
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
              'Tambahkan pengeluaran tetap seperti gaji, sewa, listrik',
              style: TextStyle(fontSize: 14, color: AppColors.textGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    AppLogger.info('🔧 Building ListView with ${fixedExpenses.length} items');
    AppLogger.info(
      '🔧 First expense: ${fixedExpenses.first.name} - ${fixedExpenses.first.amount}',
    );

    return ListView.builder(
      itemCount: fixedExpenses.length,
      itemBuilder: (context, index) {
        final expense = fixedExpenses[index];
        AppLogger.info(
          '🔧 Building item $index: ${expense.name} - Amount: ${expense.amount}',
        );

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                _getFixedExpenseIcon(expense.category),
                color: AppColors.primary,
              ),
            ),
            title: Text(
              expense.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (expense.description?.isNotEmpty == true)
                  Text(expense.description!)
                else
                  const Text('Pengeluaran Tetap Bulanan'),
                const SizedBox(height: 2),
                Text(
                  'Per hari: Rp ${_formatNumber((expense.amount / 30).round())}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${_formatNumber(expense.amount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  '/bulan',
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
              ],
            ),
            onTap: () => _showEditFixedExpenseDialog(context, expense),
          ),
        );
      },
    );
  }

  // Helper methods
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref) {
    showExpenseFormModal(context);
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
}
