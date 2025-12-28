import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../data/models/expense_model.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/charts/expense_income_comparison_chart.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/dashboard_provider.dart';
import 'expense_form_modal.dart';

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
                  _buildFixedExpenseTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddExpenseDialog(context, ref),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Tambah',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildDailyExpenseTab(BuildContext context, WidgetRef ref) {
    // Watch real-time stream for selected date
    final expensesAsync = ref.watch(
      expensesByDateStreamProvider(_selectedDate),
    );

    return expensesAsync.when(
      data: (expenses) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(expensesByDateStreamProvider(_selectedDate));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildDateSelector(context),
              _buildTotalCard(context, expenses),
              const SizedBox(height: AppSpacing.md),
              _buildExpenseIncomeChart(ref),
              const SizedBox(height: AppSpacing.md),
              _build7DaysHistoryComparison(context, ref),
              const SizedBox(height: AppSpacing.md),
              _buildCategoryBreakdown(context, expenses),
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
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.md),
            Text('$error', style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: () =>
                  ref.invalidate(expensesByDateStreamProvider(_selectedDate)),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedExpenseTab(BuildContext context) {
    final fixedExpenses = [
      {
        'name': 'Gaji Karyawan (10 orang)',
        'amount': 30000000,
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'name': 'Listrik & Air',
        'amount': 8500000,
        'icon': Icons.bolt,
        'color': Colors.orange,
      },
    ];

    final totalFixed = fixedExpenses.fold<int>(
      0,
      (sum, item) => sum + (item['amount'] as int),
    );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Total Fixed Expenses Card
          Container(
            margin: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: AppSpacing.md,
              tabletValue: AppSpacing.lg,
              desktopValue: AppSpacing.xl,
            ).copyWith(top: AppSpacing.md, bottom: 0),
            padding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: AppSpacing.lg,
              tabletValue: AppSpacing.xl,
              desktopValue: 24,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context),
              ),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
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
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.getResponsiveBorderRadius(context),
                    ),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: AppColors.primary,
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
                        'Total Pengeluaran Tetap (Bulanan)',
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
                        'Rp ${_formatNumber(totalFixed)}',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            phoneSize: 24,
                            tabletSize: 28,
                            desktopSize: 32,
                          ),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Fixed Expenses List
          Padding(
            padding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: AppSpacing.md,
              tabletValue: AppSpacing.lg,
              desktopValue: AppSpacing.xl,
            ).copyWith(top: 0, bottom: 0),
            child: Text(
              'Rincian Pengeluaran Tetap',
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
          ),
          const SizedBox(height: AppSpacing.md),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: AppSpacing.md,
              tabletValue: AppSpacing.lg,
              desktopValue: AppSpacing.xl,
            ),
            itemCount: fixedExpenses.length,
            itemBuilder: (context, index) {
              final expense = fixedExpenses[index];
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
                        desktopValue: 16,
                      ),
                      decoration: BoxDecoration(
                        color: (expense['color'] as Color).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context) *
                              0.7,
                        ),
                      ),
                      child: Icon(
                        expense['icon'] as IconData,
                        color: expense['color'] as Color,
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
                            expense['name'] as String,
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
                            'Pengeluaran Tetap Bulanan',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                phoneSize: 12,
                                tabletSize: 14,
                                desktopSize: 16,
                              ),
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${_formatNumber(expense['amount'] as int)}',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          phoneSize: 16,
                          tabletSize: 18,
                          desktopSize: 20,
                        ),
                        fontWeight: FontWeight.w600,
                        color: expense['color'] as Color,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    final isToday =
        _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Container(
      margin: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: AppSpacing.md,
        tabletValue: AppSpacing.lg,
        desktopValue: AppSpacing.xl,
      ).copyWith(top: 0, bottom: 0),
      padding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: AppSpacing.md,
        tabletValue: AppSpacing.lg,
        desktopValue: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: ResponsiveUtils.getResponsivePaddingCustom(
                  context,
                  phoneValue: AppSpacing.md,
                  tabletValue: AppSpacing.lg,
                  desktopValue: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context),
                  ),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                      size: ResponsiveUtils.getResponsiveIconSize(context),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isToday ? 'Hari Ini' : 'Pilih Tanggal',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                phoneSize: 12,
                                tabletSize: 13,
                                desktopSize: 14,
                              ),
                              color: AppColors.textGray,
                            ),
                          ),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                phoneSize: 14,
                                tabletSize: 16,
                                desktopSize: 18,
                              ),
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          // Quick select buttons
          _buildQuickDateButton(
            context,
            'Hari Ini',
            () => setState(() => _selectedDate = DateTime.now()),
            isToday,
          ),
          SizedBox(width: AppSpacing.sm),
          _buildQuickDateButton(
            context,
            'Kemarin',
            () => setState(
              () => _selectedDate = DateTime.now().subtract(
                const Duration(days: 1),
              ),
            ),
            !isToday &&
                _selectedDate.year == DateTime.now().year &&
                _selectedDate.month == DateTime.now().month &&
                _selectedDate.day == DateTime.now().day - 1,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateButton(
    BuildContext context,
    String label,
    VoidCallback onTap,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: ResponsiveUtils.getResponsivePaddingCustom(
          context,
          phoneValue: AppSpacing.sm,
          tabletValue: AppSpacing.md,
          desktopValue: 12,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context),
          ),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 12,
              tabletSize: 13,
              desktopSize: 14,
            ),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textGray,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
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

  Widget _buildExpenseIncomeChart(WidgetRef ref) {
    final dateRange = DashboardPeriod.fromString('hari').getDateRange();
    final comparisonAsync = ref.watch(
      expenseIncomeComparisonProvider(dateRange),
    );

    return comparisonAsync.when(
      data: (data) {
        return Padding(
          padding: ResponsiveUtils.getResponsivePaddingCustom(
            context,
            phoneValue: AppSpacing.md,
            tabletValue: AppSpacing.lg,
            desktopValue: AppSpacing.xl,
          ).copyWith(top: 0, bottom: 0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 500),
            child: ExpenseIncomeComparisonChart(
              totalIncome: data.totalIncome,
              totalExpense: data.totalExpense,
              period: 'Hari Ini',
            ),
          ),
        );
      },
      loading: () => Padding(
        padding: ResponsiveUtils.getResponsivePaddingCustom(
          context,
          phoneValue: AppSpacing.md,
          tabletValue: AppSpacing.lg,
          desktopValue: AppSpacing.xl,
        ).copyWith(top: 0, bottom: 0),
        child: const SizedBox(
          height: 300,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => const SizedBox.shrink(),
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
          desktopSpacing: 20,
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
                  desktopValue: 16,
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
                  size: ResponsiveUtils.getResponsiveIconSize(context) * 1.2,
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
                    SizedBox(
                      height: ResponsiveUtils.getResponsiveSpacing(
                        context,
                        phoneSpacing: 2,
                        tabletSpacing: 4,
                        desktopSpacing: 6,
                      ),
                    ),
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
              desktopSpacing: 20,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
            ),
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
    final isToday =
        _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

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
            isToday
                ? 'Pengeluaran Hari Ini'
                : 'Pengeluaran ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
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
        padding: ResponsiveUtils.getResponsivePaddingCustom(
          context,
          phoneValue: AppSpacing.lg,
          tabletValue: AppSpacing.xl,
          desktopValue: 24,
        ),
        child: Center(
          child: Text(
            'Belum ada pengeluaran hari ini',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                phoneSize: 16,
                tabletSize: 18,
                desktopSize: 20,
              ),
              color: AppColors.textGray,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: AppSpacing.md,
        tabletValue: AppSpacing.lg,
        desktopValue: AppSpacing.xl,
      ),
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
        padding: ResponsiveUtils.getResponsivePaddingCustom(
          context,
          phoneValue: AppSpacing.md,
          tabletValue: AppSpacing.lg,
          desktopValue: 20,
        ).copyWith(left: 0, top: 0, bottom: 0),
        color: AppColors.error,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: ResponsiveUtils.getResponsiveIconSize(context),
        ),
      ),
      confirmDismiss: (direction) => _confirmDelete(context, ref, expense),
      child: Container(
        margin: EdgeInsets.only(
          bottom: ResponsiveUtils.getResponsiveSpacing(
            context,
            phoneSpacing: AppSpacing.sm,
            tabletSpacing: AppSpacing.md,
            desktopSpacing: 16,
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
                desktopValue: 16,
              ),
              decoration: BoxDecoration(
                color: _getCategoryColor(
                  expense.category,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context) * 0.7,
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
                desktopSpacing: 20,
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
                desktopSpacing: 16,
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
              child: Icon(
                Icons.more_vert,
                color: AppColors.textGray,
                size: ResponsiveUtils.getResponsiveIconSize(context),
              ),
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

  Widget _build7DaysHistoryComparison(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(last7DaysExpenseHistoryProvider);

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
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
                'Riwayat 7 Hari Terakhir',
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
              SizedBox(height: AppSpacing.md),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(history.length, (index) {
                    final data = history[index];
                    final isToday = index == history.length - 1;
                    final prevAmount = index > 0
                        ? history[index - 1].amount
                        : data.amount;
                    final trend = prevAmount > 0
                        ? ((data.amount - prevAmount) / prevAmount * 100)
                        : 0.0;

                    return Container(
                      margin: EdgeInsets.only(
                        right: index < history.length - 1 ? AppSpacing.md : 0,
                      ),
                      padding: ResponsiveUtils.getResponsivePaddingCustom(
                        context,
                        phoneValue: AppSpacing.md,
                        tabletValue: AppSpacing.lg,
                        desktopValue: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.secondary,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUtils.getResponsiveBorderRadius(context),
                        ),
                        border: Border.all(
                          color: isToday ? AppColors.primary : AppColors.border,
                          width: isToday ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.formattedDate,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                phoneSize: 12,
                                tabletSize: 13,
                                desktopSize: 14,
                              ),
                              fontWeight: isToday
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.textGray,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            'Rp ${_formatShortNumber(data.amount)}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                phoneSize: 14,
                                tabletSize: 16,
                                desktopSize: 18,
                              ),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (index > 0) ...[
                            SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                Icon(
                                  trend > 0
                                      ? Icons.trending_up
                                      : trend < 0
                                      ? Icons.trending_down
                                      : Icons.trending_flat,
                                  size: 14,
                                  color: trend > 0
                                      ? AppColors.error
                                      : trend < 0
                                      ? AppColors.success
                                      : AppColors.textGray,
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  '${trend.abs().toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveUtils.getResponsiveFontSize(
                                          context,
                                          phoneSize: 11,
                                          tabletSize: 12,
                                          desktopSize: 13,
                                        ),
                                    fontWeight: FontWeight.w600,
                                    color: trend > 0
                                        ? AppColors.error
                                        : trend < 0
                                        ? AppColors.success
                                        : AppColors.textGray,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _formatShortNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
