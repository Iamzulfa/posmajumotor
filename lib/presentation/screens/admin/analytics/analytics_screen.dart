import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.daily;
  DateTime _selectedDate = DateTime.now();
  int _selectedWeek = 1;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // Track which tabs have been loaded
  final Set<int> _loadedTabs = {0}; // Start with first tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _loadedTabs.add(_tabController.index);
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use basic metrics provider for initial load (lighter)
    final basicMetricsAsync = ref.watch(
      analyticsBasicMetricsProvider(_getAnalyticsFilter()),
    );

    final syncStatus = basicMetricsAsync.when(
      data: (_) => SyncStatus.online,
      loading: () => SyncStatus.syncing,
      error: (_, _) => SyncStatus.offline,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics Lanjutan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: syncStatus == SyncStatus.online
                        ? AppColors.success
                        : AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  syncStatus == SyncStatus.online ? 'Online' : 'Syncing...',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
                const Text(
                  ' • Real-time',
                  style: TextStyle(fontSize: 12, color: AppColors.textGray),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildPeriodSelector(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 0: Transaction Details - uses basic metrics
                  _buildTransactionDetailsTabOptimized(),
                  // Tab 1: Payment Analysis - uses basic metrics
                  _buildPaymentAnalysisTabOptimized(),
                  // Tab 2: Profit Analysis - uses profit provider (heavier)
                  _buildProfitAnalysisTabOptimized(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Optimized Transaction Details Tab
  Widget _buildTransactionDetailsTabOptimized() {
    final basicMetricsAsync = ref.watch(
      analyticsBasicMetricsProvider(_getAnalyticsFilter()),
    );

    return basicMetricsAsync.when(
      data: (data) => _buildTransactionDetailsContent(data),
      loading: () => const LoadingWidget(),
      error: (error, _) => _buildErrorWidget(error),
    );
  }

  Widget _buildTransactionDetailsContent(AnalyticsBasicMetrics data) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(analyticsBasicMetricsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSpecificSelector(),
            const SizedBox(height: AppSpacing.lg),
            _buildTierBreakdownCardFromBasic(data),
            const SizedBox(height: AppSpacing.lg),
            _buildTransactionSummaryCardFromBasic(data),
            const SizedBox(height: AppSpacing.lg),
            _buildTopProductsCardFromBasic(data),
          ],
        ),
      ),
    );
  }

  // Optimized Payment Analysis Tab
  Widget _buildPaymentAnalysisTabOptimized() {
    if (!_loadedTabs.contains(1)) {
      return const Center(
        child: Text(
          'Tap untuk memuat data pembayaran',
          style: TextStyle(color: AppColors.textGray),
        ),
      );
    }

    final basicMetricsAsync = ref.watch(
      analyticsBasicMetricsProvider(_getAnalyticsFilter()),
    );

    return basicMetricsAsync.when(
      data: (data) => _buildPaymentAnalysisContent(data),
      loading: () => const LoadingWidget(),
      error: (error, _) => _buildErrorWidget(error),
    );
  }

  Widget _buildPaymentAnalysisContent(AnalyticsBasicMetrics data) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(analyticsBasicMetricsProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSpecificSelector(),
            const SizedBox(height: AppSpacing.lg),
            _buildPaymentMethodBreakdownFromBasic(data),
            const SizedBox(height: AppSpacing.lg),
            _buildPaymentByTierAnalysisFromBasic(data),
          ],
        ),
      ),
    );
  }

  // Optimized Profit Analysis Tab
  Widget _buildProfitAnalysisTabOptimized() {
    if (!_loadedTabs.contains(2)) {
      return const Center(
        child: Text(
          'Tap untuk memuat data profit',
          style: TextStyle(color: AppColors.textGray),
        ),
      );
    }

    final profitAsync = ref.watch(
      analyticsProfitProvider(_getAnalyticsFilter()),
    );

    return profitAsync.when(
      data: (data) => _buildProfitAnalysisContent(data),
      loading: () => const LoadingWidget(),
      error: (error, _) => _buildErrorWidget(error),
    );
  }

  Widget _buildProfitAnalysisContent(AnalyticsProfitData data) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(analyticsProfitProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSpecificSelector(),
            const SizedBox(height: AppSpacing.lg),
            _buildProfitOverviewCardFromProfit(data),
            const SizedBox(height: AppSpacing.lg),
            _buildHppAnalysisCardFromProfit(data),
            const SizedBox(height: AppSpacing.lg),
            _buildProfitTrendChartFromProfit(data),
            const SizedBox(height: AppSpacing.lg),
            _buildMarginAnalysisByTierFromProfit(data),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: AppSpacing.md),
          Text('$error', style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(analyticsBasicMetricsProvider);
              ref.invalidate(analyticsProfitProvider);
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: ResponsiveUtils.getResponsivePadding(context),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodButton(
              'Harian',
              AnalyticsPeriod.daily,
              Icons.today,
            ),
          ),
          Expanded(
            child: _buildPeriodButton(
              'Mingguan',
              AnalyticsPeriod.weekly,
              Icons.view_week,
            ),
          ),
          Expanded(
            child: _buildPeriodButton(
              'Bulanan',
              AnalyticsPeriod.monthly,
              Icons.calendar_month,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(
    String label,
    AnalyticsPeriod period,
    IconData icon,
  ) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textGray,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.background,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textGray,
        indicatorColor: AppColors.primary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Detail Transaksi'),
          Tab(text: 'Analisis Pembayaran'),
          Tab(text: 'Analisis Profit'),
        ],
      ),
    );
  }

  Widget _buildPeriodSpecificSelector() {
    switch (_selectedPeriod) {
      case AnalyticsPeriod.daily:
        return _buildDateSelector();
      case AnalyticsPeriod.weekly:
        return _buildWeekSelector();
      case AnalyticsPeriod.monthly:
        return _buildMonthSelector();
    }
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _formatDate(_selectedDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          TextButton(onPressed: () => _selectDate(), child: const Text('Ubah')),
        ],
      ),
    );
  }

  Widget _buildWeekSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.view_week, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                '${_getMonthName(_selectedMonth)} $_selectedYear',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(4, (index) {
              final week = index + 1;
              final isSelected = _selectedWeek == week;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedWeek = week),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Minggu $week',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textGray,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<int>(
              value: _selectedMonth,
              isExpanded: true,
              underline: const SizedBox(),
              items: List.generate(12, (index) {
                final month = index + 1;
                return DropdownMenuItem(
                  value: month,
                  child: Text(_getMonthName(month)),
                );
              }),
              onChanged: (month) {
                if (month != null) {
                  setState(() => _selectedMonth = month);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<int>(
            value: _selectedYear,
            underline: const SizedBox(),
            items: List.generate(5, (index) {
              final year = DateTime.now().year - 2 + index;
              return DropdownMenuItem(value: year, child: Text('$year'));
            }),
            onChanged: (year) {
              if (year != null) {
                setState(() => _selectedYear = year);
              }
            },
          ),
        ],
      ),
    );
  }

  // ============================================
  // OPTIMIZED CARD METHODS (using lighter data models)
  // ============================================

  // Tier Breakdown Card from Basic Metrics - WITH PIE CHART
  Widget _buildTierBreakdownCardFromBasic(AnalyticsBasicMetrics data) {
    return _TierBreakdownWithPieChart(data: data);
  }

  // Transaction Summary Card from Basic Metrics
  Widget _buildTransactionSummaryCardFromBasic(AnalyticsBasicMetrics data) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.receipt_long, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Ringkasan Transaksi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Transaksi',
                  '${data.totalTransactions}',
                  Icons.receipt,
                  AppColors.info,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Rata-rata Nilai',
                  _formatCurrency(
                    data.totalTransactions > 0
                        ? data.totalOmset ~/ data.totalTransactions
                        : 0,
                  ),
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Omset',
                  _formatCurrency(data.totalOmset),
                  Icons.attach_money,
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Margin Rata-rata',
                  '${data.averageMargin.toStringAsFixed(1)}%',
                  Icons.percent,
                  data.averageMargin >= 20
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Top Products Card from Basic Metrics
  Widget _buildTopProductsCardFromBasic(AnalyticsBasicMetrics data) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.star, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Produk Terlaris',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (data.topProducts.isNotEmpty)
            ...data.topProducts
                .take(5)
                .map(
                  (product) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.productName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                '${product.quantitySold} terjual',
                                style: const TextStyle(
                                  fontSize: 12,
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
                              _formatCurrency(product.totalRevenue),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              '${product.marginPercent.toStringAsFixed(1)}% margin',
                              style: TextStyle(
                                fontSize: 12,
                                color: product.marginPercent >= 20
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                .toList()
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Tidak ada data produk',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Payment Method Breakdown from Basic Metrics
  Widget _buildPaymentMethodBreakdownFromBasic(AnalyticsBasicMetrics data) {
    final totalAmount = data.paymentBreakdown.values.fold<int>(
      0,
      (sum, p) => sum + p.totalAmount,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.payment, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Analisis Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              Text(
                _formatCurrency(totalAmount),
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (data.paymentBreakdown.isNotEmpty)
            ...data.paymentBreakdown.entries.map((entry) {
              final payment = entry.value;
              final percentage = totalAmount > 0
                  ? (payment.totalAmount / totalAmount) * 100
                  : 0.0;
              final color = _getPaymentColor(entry.key);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          payment.displayName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: AppColors.secondary,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${payment.transactionCount} transaksi • ${_formatCurrency(payment.totalAmount)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              );
            }).toList()
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Tidak ada data pembayaran',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getPaymentColor(String method) {
    switch (method) {
      case 'CASH':
        return AppColors.success;
      case 'TRANSFER':
        return AppColors.info;
      case 'QRIS':
        return AppColors.warning;
      default:
        return AppColors.textGray;
    }
  }

  // Payment by Tier Analysis from Basic Metrics
  // Shows each tier's contribution to total sales
  Widget _buildPaymentByTierAnalysisFromBasic(AnalyticsBasicMetrics data) {
    // Calculate total omset across all tiers
    final totalOmsetAllTiers = data.tierBreakdown.values.fold<int>(
      0,
      (sum, tier) => sum + tier.totalOmset,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kontribusi per Tier',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                _formatCurrency(totalOmsetAllTiers),
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (data.tierBreakdown.isNotEmpty)
            ...data.tierBreakdown.entries.map((entry) {
              final tier = entry.value;
              // Calculate tier's contribution to total sales
              final tierContribution = totalOmsetAllTiers > 0
                  ? (tier.totalOmset / totalOmsetAllTiers) * 100
                  : 0.0;
              final tierColor = _getTierColor(entry.key);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tier header with contribution percentage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tier.displayName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          '${tierContribution.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: tierColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress bar showing tier contribution
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: tierContribution / 100,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tier stats
                    Text(
                      '${tier.transactionCount} transaksi • ${_formatCurrency(tier.totalOmset)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray,
                      ),
                    ),
                    // Payment methods used in this tier
                    if (tier.paymentMethodBreakdown.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: tier.paymentMethodBreakdown.entries.map((
                          paymentEntry,
                        ) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPaymentColor(
                                paymentEntry.key,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getPaymentMethodName(paymentEntry.key),
                              style: TextStyle(
                                fontSize: 10,
                                color: _getPaymentColor(paymentEntry.key),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              );
            }).toList()
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Tidak ada data tier',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'UMUM':
        return AppColors.info;
      case 'BENGKEL':
        return AppColors.warning;
      case 'GROSSIR':
        return AppColors.success;
      default:
        return AppColors.textGray;
    }
  }

  // ============================================
  // PROFIT ANALYSIS CARDS (using AnalyticsProfitData)
  // ============================================

  Widget _buildProfitOverviewCardFromProfit(AnalyticsProfitData data) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.trending_up, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Ringkasan Profit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Profit',
                  _formatCurrency(data.totalProfit),
                  Icons.attach_money,
                  AppColors.success,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Net Profit',
                  _formatCurrency(data.netProfit),
                  Icons.account_balance,
                  data.netProfit >= 0 ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Omset',
                  _formatCurrency(data.totalOmset),
                  Icons.shopping_cart,
                  AppColors.info,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Total HPP',
                  _formatCurrency(data.totalHpp),
                  Icons.inventory,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHppAnalysisCardFromProfit(AnalyticsProfitData data) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.inventory, color: AppColors.warning),
              const SizedBox(width: 8),
              const Text(
                'Analisis HPP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'Rasio HPP terhadap Omset',
                  style: TextStyle(fontSize: 14, color: AppColors.textGray),
                ),
                const SizedBox(height: 8),
                Text(
                  '${data.hppRatio.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: data.hppRatio <= 70
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.hppRatio <= 70
                      ? 'Efisiensi HPP Sangat Baik'
                      : 'Pertimbangkan optimasi HPP',
                  style: TextStyle(
                    fontSize: 12,
                    color: data.hppRatio <= 70
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: (data.hppRatio / 100).clamp(0.0, 1.0),
            backgroundColor: AppColors.secondary,
            valueColor: AlwaysStoppedAnimation<Color>(
              data.hppRatio <= 70 ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitTrendChartFromProfit(AnalyticsProfitData data) {
    // Filter out days with no data for cleaner chart
    final validData = data.dailyData
        .where((d) => d.profit != 0 || d.omset != 0)
        .toList();

    // For daily period with only 1 data point, show summary instead of chart
    if (validData.length <= 1 && _selectedPeriod == AnalyticsPeriod.daily) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tren Profit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48,
                    color: AppColors.textGray.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Profit Hari Ini: ${_formatCurrency(data.totalProfit)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pilih periode Mingguan atau Bulanan\nuntuk melihat grafik tren',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textGray),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Use all daily data for weekly/monthly view
    final chartData = data.dailyData;

    if (chartData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Tidak ada data tren',
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
        ),
      );
    }

    // Calculate max value for Y axis
    final maxProfit = chartData
        .map((d) => d.profit)
        .reduce((a, b) => a > b ? a : b);
    final minProfit = chartData
        .map((d) => d.profit)
        .reduce((a, b) => a < b ? a : b);

    // Add padding to max/min for better visualization
    final yMax = maxProfit > 0 ? (maxProfit * 1.2).toDouble() : 1000000.0;
    final yMin = minProfit < 0 ? (minProfit * 1.2).toDouble() : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tren Profit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                _getPeriodLabel(),
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _calculateYInterval(yMax - yMin),
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border.withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _calculateXInterval(chartData.length),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= chartData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _formatDateLabel(chartData[index].date),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textGray,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: _calculateYInterval(yMax - yMin),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatYAxisLabel(value.toInt()),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textGray,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.border.withOpacity(0.5),
                    ),
                    left: BorderSide(color: AppColors.border.withOpacity(0.5)),
                  ),
                ),
                minY: yMin,
                maxY: yMax,
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index < 0 || index >= chartData.length) {
                          return null;
                        }
                        final dayData = chartData[index];
                        return LineTooltipItem(
                          '${_formatFullDateLabel(dayData.date)}\n${_formatCurrency(dayData.profit)}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.profit.toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.success,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.success,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.success.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Profit Harian',
                style: TextStyle(fontSize: 11, color: AppColors.textGray),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for chart formatting
  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case AnalyticsPeriod.daily:
        return _formatDate(_selectedDate);
      case AnalyticsPeriod.weekly:
        return 'Minggu $_selectedWeek, ${_getMonthName(_selectedMonth)}';
      case AnalyticsPeriod.monthly:
        return '${_getMonthName(_selectedMonth)} $_selectedYear';
    }
  }

  String _formatDateLabel(DateTime date) {
    switch (_selectedPeriod) {
      case AnalyticsPeriod.daily:
        return '${date.hour}:00';
      case AnalyticsPeriod.weekly:
        return _getDayName(date.weekday);
      case AnalyticsPeriod.monthly:
        return '${date.day}';
    }
  }

  String _formatFullDateLabel(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)}';
  }

  String _getDayName(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }

  String _formatYAxisLabel(int value) {
    if (value.abs() >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}M';
    } else if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}jt';
    } else if (value.abs() >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}rb';
    }
    return value.toString();
  }

  double _calculateYInterval(double range) {
    if (range <= 0) return 1000000;
    // Aim for about 4-5 grid lines
    final interval = range / 4;
    // Round to nice numbers
    if (interval >= 10000000) return (interval / 10000000).ceil() * 10000000;
    if (interval >= 1000000) return (interval / 1000000).ceil() * 1000000;
    if (interval >= 100000) return (interval / 100000).ceil() * 100000;
    if (interval >= 10000) return (interval / 10000).ceil() * 10000;
    return (interval / 1000).ceil() * 1000;
  }

  double _calculateXInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    if (dataLength <= 21) return 3;
    return (dataLength / 7).ceil().toDouble();
  }

  Widget _buildMarginAnalysisByTierFromProfit(AnalyticsProfitData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Analisis Margin per Tier',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (data.tierBreakdown.isNotEmpty)
            ...data.tierBreakdown.entries.map((entry) {
              final tier = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tier.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatCurrency(tier.totalProfit),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${tier.marginPercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: tier.marginPercent >= 20
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList()
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Tidak ada data margin',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textGray),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'CASH':
        return 'Tunai';
      case 'TRANSFER':
        return 'Transfer';
      case 'QRIS':
        return 'QRIS';
      default:
        return method;
    }
  }

  // Helper methods
  AnalyticsFilter _getAnalyticsFilter() {
    switch (_selectedPeriod) {
      case AnalyticsPeriod.daily:
        return AnalyticsFilter.daily(_selectedDate);
      case AnalyticsPeriod.weekly:
        return AnalyticsFilter.weekly(
          _selectedYear,
          _selectedMonth,
          _selectedWeek,
        );
      case AnalyticsPeriod.monthly:
        return AnalyticsFilter.monthly(_selectedYear, _selectedMonth);
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  String _formatCurrency(int amount) {
    return CurrencyFormatter.formatCompact(amount);
  }
}

enum AnalyticsPeriod { daily, weekly, monthly }

/// Stateful widget for Tier Breakdown with interactive PieChart
class _TierBreakdownWithPieChart extends StatefulWidget {
  final AnalyticsBasicMetrics data;

  const _TierBreakdownWithPieChart({required this.data});

  @override
  State<_TierBreakdownWithPieChart> createState() =>
      _TierBreakdownWithPieChartState();
}

class _TierBreakdownWithPieChartState
    extends State<_TierBreakdownWithPieChart> {
  String? _selectedTier;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.people, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Breakdown per Tier',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.data.totalTransactions} transaksi',
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (widget.data.tierBreakdown.isNotEmpty) ...[
            _buildPieChart(),
            const SizedBox(height: 16),
            _buildTierList(),
            if (_selectedTier != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildTierDetails(_selectedTier!),
            ],
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Tidak ada data transaksi',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final sections = widget.data.tierBreakdown.entries.map((entry) {
      final tier = entry.value;
      final percentage = widget.data.totalOmset > 0
          ? (tier.totalOmset / widget.data.totalOmset) * 100
          : 0;

      return PieChartSectionData(
        color: _getTierColor(tier.tier),
        value: percentage.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: _selectedTier == tier.tier ? 60.0 : 50.0,
        titleStyle: TextStyle(
          fontSize: _selectedTier == tier.tier ? 12 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (event is FlTapUpEvent &&
                      pieTouchResponse?.touchedSection != null) {
                    final index =
                        pieTouchResponse!.touchedSection!.touchedSectionIndex;
                    if (index >= 0 &&
                        index < widget.data.tierBreakdown.length) {
                      final tierEntry = widget.data.tierBreakdown.entries
                          .elementAt(index);
                      setState(() {
                        _selectedTier = _selectedTier == tierEntry.key
                            ? null
                            : tierEntry.key;
                      });
                    }
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTierList() {
    return Column(
      children: widget.data.tierBreakdown.entries.map((entry) {
        final tier = entry.value;
        final isSelected = _selectedTier == tier.tier;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTier = isSelected ? null : tier.tier;
            });
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? Border.all(color: AppColors.primary) : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getTierColor(tier.tier),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tier.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textDark,
                        ),
                      ),
                      Text(
                        '${tier.transactionCount} transaksi',
                        style: const TextStyle(
                          fontSize: 12,
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
                      _formatCurrency(tier.totalOmset),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${tier.marginPercent.toStringAsFixed(1)}% margin',
                      style: TextStyle(
                        fontSize: 12,
                        color: tier.marginPercent >= 20
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTierDetails(String tierKey) {
    final tier = widget.data.tierBreakdown[tierKey]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail ${tier.displayName}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Total Penjualan',
                  _formatCurrency(tier.totalOmset),
                  Icons.attach_money,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Total HPP',
                  _formatCurrency(tier.totalHpp),
                  Icons.inventory,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Profit',
                  _formatCurrency(tier.totalProfit),
                  Icons.trending_up,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Rata-rata/Transaksi',
                  _formatCurrency(tier.averageTransactionValue),
                  Icons.receipt,
                ),
              ),
            ],
          ),
          if (tier.paymentMethodBreakdown.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Metode Pembayaran:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            ...tier.paymentMethodBreakdown.entries.map((entry) {
              final percentage = tier.totalOmset > 0
                  ? (entry.value / tier.totalOmset) * 100
                  : 0;
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getPaymentMethodName(entry.key),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatCurrency(entry.value),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${percentage.toStringAsFixed(1)}%)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textGray),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'UMUM':
        return AppColors.info;
      case 'BENGKEL':
        return AppColors.warning;
      case 'GROSSIR':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'CASH':
        return 'Tunai';
      case 'TRANSFER':
        return 'Transfer';
      case 'QRIS':
        return 'QRIS';
      default:
        return method;
    }
  }

  String _formatCurrency(int amount) {
    return CurrencyFormatter.formatCompact(amount);
  }
}
