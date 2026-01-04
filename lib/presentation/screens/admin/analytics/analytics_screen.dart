import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../providers/analytics_provider.dart';
import 'widgets/tier_breakdown_card.dart';
import 'widgets/payment_method_breakdown_card.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(
      analyticsDataProvider(_getAnalyticsFilter()),
    );

    final syncStatus = analyticsAsync.when(
      data: (_) => SyncStatus.online,
      loading: () => SyncStatus.syncing,
      error: (_, _) => SyncStatus.offline,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Analytics Lanjutan',
              syncStatus: syncStatus,
              lastSyncTime: syncStatus == SyncStatus.online
                  ? 'Real-time'
                  : 'Syncing...',
            ),
            _buildPeriodSelector(),
            _buildTabBar(),
            Expanded(
              child: analyticsAsync.when(
                data: (data) => TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTransactionDetailsTab(data),
                    _buildPaymentAnalysisTab(data),
                    _buildProfitAnalysisTab(data),
                  ],
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
                      Text(
                        '$error',
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(analyticsDataProvider),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildTransactionDetailsTab(AnalyticsData data) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(analyticsDataProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSpecificSelector(),
            const SizedBox(height: AppSpacing.lg),
            // Lazy load tier breakdown
            FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 100)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildTierBreakdownCard(data);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Lazy load transaction summary
            FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 200)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildTransactionSummaryCard(data);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Lazy load top products
            FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 300)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildTopProductsCard(data);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentAnalysisTab(AnalyticsData data) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(analyticsDataProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSpecificSelector(),
            const SizedBox(height: AppSpacing.lg),
            // Lazy load payment method breakdown
            FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 100)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildPaymentMethodBreakdown(data);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Lazy load payment trend chart
            FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 200)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildPaymentTrendChart(data);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Lazy load payment by tier analysis
            FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 300)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildPaymentByTierAnalysis(data);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfitAnalysisTab(AnalyticsData data) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(analyticsDataProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSpecificSelector(),
            const SizedBox(height: AppSpacing.lg),
            // Lazy load profit overview
            FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 100)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildProfitOverviewCard(data);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Lazy load HPP analysis
            FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 200)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildHppAnalysisCard(data);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Lazy load profit trend chart
            FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 300)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildProfitTrendChart(data);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Lazy load margin analysis by tier
            FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 400)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildMarginAnalysisByTier(data);
              },
            ),
          ],
        ),
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

  // Card implementations
  Widget _buildTierBreakdownCard(AnalyticsData data) {
    return TierBreakdownCard(data: data);
  }

  Widget _buildTransactionSummaryCard(AnalyticsData data) {
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

  Widget _buildTopProductsCard(AnalyticsData data) {
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

  Widget _buildPaymentMethodBreakdown(AnalyticsData data) {
    return PaymentMethodBreakdownCard(data: data);
  }

  Widget _buildPaymentTrendChart(AnalyticsData data) {
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
            'Tren Pembayaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (data.dailyData.isNotEmpty)
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.dailyData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.omset.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Tidak ada data tren',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentByTierAnalysis(AnalyticsData data) {
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
            'Pembayaran per Tier',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...data.tierBreakdown.entries.map((entry) {
            final tier = entry.value;
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
                  Text(
                    tier.displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...tier.paymentMethodBreakdown.entries.map((paymentEntry) {
                    final percentage = tier.totalOmset > 0
                        ? (paymentEntry.value / tier.totalOmset) * 100
                        : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getPaymentMethodName(paymentEntry.key),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGray,
                            ),
                          ),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildProfitOverviewCard(AnalyticsData data) {
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

  Widget _buildHppAnalysisCard(AnalyticsData data) {
    final hppRatio = data.totalOmset > 0
        ? (data.totalHpp / data.totalOmset) * 100
        : 0.0;

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
                Text(
                  'Rasio HPP terhadap Omset',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${hppRatio.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: hppRatio <= 70
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hppRatio <= 70
                      ? 'Efisiensi HPP Sangat Baik'
                      : 'Pertimbangkan optimasi HPP',
                  style: TextStyle(
                    fontSize: 12,
                    color: hppRatio <= 70
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LinearProgressIndicator(
            value: (hppRatio / 100).clamp(0.0, 1.0),
            backgroundColor: AppColors.secondary,
            valueColor: AlwaysStoppedAnimation<Color>(
              hppRatio <= 70 ? AppColors.success : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitTrendChart(AnalyticsData data) {
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
          if (data.dailyData.isNotEmpty)
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.dailyData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.profit.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppColors.success,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            )
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Tidak ada data tren',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMarginAnalysisByTier(AnalyticsData data) {
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
