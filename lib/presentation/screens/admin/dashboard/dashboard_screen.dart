import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../../domain/repositories/transaction_repository.dart'
    show DailySummary;

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedPeriod = 'hari'; // 'hari', 'minggu', 'bulan'

  @override
  Widget build(BuildContext context) {
    // Watch real-time stream with selected period
    final dashboardAsync = ref.watch(
      dashboardStreamProvider(DashboardPeriod.fromString(_selectedPeriod)),
    );

    final syncStatus = dashboardAsync.when(
      data: (_) => SyncStatus.online,
      loading: () => SyncStatus.syncing,
      error: (_, _) => SyncStatus.offline,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: dashboardAsync.when(
          data: (dashboardState) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(dashboardStreamProvider);
              ref.invalidate(last7DaysSummaryProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, ref, syncStatus),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.getResponsivePaddingCustom(
                        context,
                        phoneValue: 12,
                        tabletValue: 14,
                        desktopValue: 16,
                      ).left,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfitCard(dashboardState),
                        const SizedBox(height: AppSpacing.md),
                        _buildTaxIndicator(dashboardState),
                        const SizedBox(height: AppSpacing.md),
                        _buildQuickStats(dashboardState),
                        const SizedBox(height: AppSpacing.lg),
                        // TODO: Fix expense/income comparison chart
                        // _buildExpenseIncomeComparison(ref, _selectedPeriod),
                        // const SizedBox(height: AppSpacing.lg),
                        _buildTrendChart(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildTierBreakdownSection(dashboardState),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
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
                  onPressed: () => ref.invalidate(dashboardStreamProvider),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    SyncStatus syncStatus,
  ) {
    final greetingFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 20,
      tabletSize: 24,
      desktopSize: 28,
    );
    final dateFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 12,
      tabletSize: 14,
      desktopSize: 16,
    );
    final headerPadding = ResponsiveUtils.getResponsivePadding(context);

    return Padding(
      padding: headerPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(
                      fontSize: greetingFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getPercentageHeight(context, 1),
                  ),
                  Text(
                    _formatDate(DateTime.now()),
                    style: TextStyle(
                      fontSize: dateFontSize,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
                color: AppColors.textGray,
                tooltip: 'Logout',
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getPercentageHeight(context, 1)),
          SyncStatusWidget(
            status: syncStatus,
            lastSyncTime: syncStatus == SyncStatus.online
                ? 'Real-time'
                : 'Syncing...',
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi, Admin';
    if (hour < 17) return 'Selamat Siang, Admin';
    return 'Selamat Malam, Admin';
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

  Widget _buildProfitCard(DashboardState state) {
    final profit = state.todayProfit;
    final omset = state.todayOmset;
    final hpp = state.todayHpp;
    final expenses = state.todayExpenses;

    final titleFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 13,
      tabletSize: 15,
      desktopSize: 17,
    );
    final amountFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 28,
      tabletSize: 32,
      desktopSize: 36,
    );
    final cardPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 10,
      tabletValue: 14,
      desktopValue: 18,
    );

    return Container(
      width: double.infinity,
      padding: cardPadding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laba Bersih Hari Ini',
            style: TextStyle(fontSize: titleFontSize, color: Colors.white70),
          ),
          SizedBox(height: ResponsiveUtils.getPercentageHeight(context, 1)),
          Text(
            'Rp ${_formatNumber(profit)}',
            style: TextStyle(
              fontSize: amountFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getPercentageHeight(context, 2)),
          Container(
            width: double.infinity,
            padding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: 8,
              tabletValue: 10,
              desktopValue: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildProfitDetail('Penjualan', _formatCompact(omset)),
                ),
                Container(width: 1, height: 30, color: Colors.white24),
                Expanded(child: _buildProfitDetail('HPP', _formatCompact(hpp))),
                Container(width: 1, height: 30, color: Colors.white24),
                Expanded(
                  child: _buildProfitDetail(
                    'Pengeluaran',
                    _formatCompact(expenses),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTaxIndicator(DashboardState state) {
    final taxAmount = state.taxAmount;
    final monthlyOmset = state.monthlyOmset;
    final targetTax = (monthlyOmset * 0.005).round();
    final progress = targetTax > 0
        ? (taxAmount / targetTax).clamp(0.0, 1.0)
        : 0.0;

    final titleFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 13,
      tabletSize: 15,
      desktopSize: 17,
    );
    final badgeFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 11,
      tabletSize: 12,
      desktopSize: 13,
    );
    final percentFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 13,
      tabletSize: 15,
      desktopSize: 16,
    );
    final containerPadding = ResponsiveUtils.getResponsivePadding(context);
    final progressBarHeight = ResponsiveUtils.getResponsiveHeight(
      context,
      phoneHeight: 6,
      tabletHeight: 8,
      desktopHeight: 10,
    );

    return Container(
      padding: containerPadding,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tabungan Pajak Bulan Ini',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.getPercentageWidth(context, 2),
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '0.5%',
                  style: TextStyle(
                    fontSize: badgeFontSize,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getPercentageHeight(context, 2)),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.secondary,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.warning,
                    ),
                    minHeight: progressBarHeight,
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getPercentageWidth(context, 3)),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: percentFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getPercentageHeight(context, 1)),
          Text(
            'Rp ${_formatNumber(taxAmount)} / Rp ${_formatNumber(targetTax)}',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                phoneSize: 10,
                tabletSize: 12,
                desktopSize: 12,
              ),
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(DashboardState state) {
    final trxCount = state.todayTransactionCount;
    final avgTrx = state.todayAverageTransaction;
    final expenses = state.todayExpenses;
    final margin = state.marginPercent;

    final spacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 8,
      tabletSpacing: 10,
      desktopSpacing: 12,
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Transaksi',
                '$trxCount',
                Icons.receipt_long,
                AppColors.info,
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildStatCard(
                'Rata-rata',
                _formatCompact(avgTrx),
                Icons.trending_up,
                AppColors.success,
              ),
            ),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pengeluaran',
                _formatCompact(expenses),
                Icons.account_balance_wallet,
                AppColors.error,
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: _buildStatCard(
                'Margin',
                '${margin.toStringAsFixed(1)}%',
                Icons.pie_chart,
                AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final valueFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 16,
      tabletSize: 18,
      desktopSize: 20,
    );
    final labelFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 12,
      tabletSize: 13,
      desktopSize: 14,
    );
    final cardPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 10,
      tabletValue: 12,
      desktopValue: 16,
    );
    final iconSize = ResponsiveUtils.getResponsiveIconSize(context);
    final iconContainerPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 6,
      tabletValue: 8,
      desktopValue: 10,
    );

    return Container(
      padding: cardPadding,
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
            padding: iconContainerPadding,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
              ),
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
          SizedBox(width: ResponsiveUtils.getPercentageWidth(context, 2)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(
                  height: ResponsiveUtils.getPercentageHeight(context, 0.5),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    // Watch 7 days summary provider
    final last7DaysAsync = ref.watch(last7DaysSummaryProvider);

    final titleFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 15,
      tabletSize: 17,
      desktopSize: 19,
    );
    final chartHeight = ResponsiveUtils.getResponsiveHeight(
      context,
      phoneHeight: 150,
      tabletHeight: 180,
      desktopHeight: 220,
    );
    final containerPadding = ResponsiveUtils.getResponsivePadding(context);
    final legendSpacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 12,
      tabletSpacing: 16,
      desktopSpacing: 20,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trend 7 Hari Terakhir',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getPercentageHeight(context, 2)),
        Container(
          padding: containerPadding,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context),
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: last7DaysAsync.when(
            data: (dailySummaries) {
              // Calculate max values for scaling
              int maxOmset = 0;
              int maxProfit = 0;
              for (final summary in dailySummaries) {
                if (summary.totalOmset > maxOmset) {
                  maxOmset = summary.totalOmset;
                }
                if (summary.totalProfit > maxProfit) {
                  maxProfit = summary.totalProfit;
                }
              }

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Omset', AppColors.info),
                      SizedBox(width: legendSpacing * 2),
                      _buildLegendItem('Profit', AppColors.success),
                    ],
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getPercentageHeight(context, 2),
                  ),
                  SizedBox(
                    height: chartHeight,
                    child: CustomPaint(
                      size: const Size(double.infinity, 0),
                      painter: _TrendChartPainter(
                        dailySummaries: dailySummaries,
                        maxOmset: maxOmset,
                        maxProfit: maxProfit,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getPercentageHeight(context, 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: dailySummaries
                        .map(
                          (summary) => Text(
                            _formatDateLabel(summary.date),
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                phoneSize: 9,
                                tabletSize: 10,
                                desktopSize: 11,
                              ),
                              color: AppColors.textGray,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
            loading: () => SizedBox(
              height: chartHeight,
              child: const Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SizedBox(
              height: chartHeight,
              child: Center(
                child: Text(
                  'Error loading chart',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    final labelFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 11,
      tabletSize: 12,
      desktopSize: 13,
    );
    final indicatorSize = ResponsiveUtils.getResponsiveHeight(
      context,
      phoneHeight: 10,
      tabletHeight: 12,
      desktopHeight: 14,
    );

    return Row(
      children: [
        Container(
          width: indicatorSize,
          height: indicatorSize,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getPercentageWidth(context, 1.5)),
        Text(
          label,
          style: TextStyle(fontSize: labelFontSize, color: AppColors.textGray),
        ),
      ],
    );
  }

  Widget _buildTierBreakdownSection(DashboardState state) {
    final titleFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 15,
      tabletSize: 17,
      desktopSize: 19,
    );
    final isPhone = ResponsiveUtils.isPhone(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 8,
      tabletSpacing: 12,
      desktopSpacing: 16,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isPhone
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Breakdown per Tier',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getPercentageHeight(context, 1.5),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context),
                      ),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _buildPeriodButton('Hari', 'hari'),
                        Container(width: 1, color: AppColors.border),
                        _buildPeriodButton('Minggu', 'minggu'),
                        Container(width: 1, color: AppColors.border),
                        _buildPeriodButton('Bulan', 'bulan'),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Breakdown per Tier',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context),
                      ),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _buildPeriodButton('Hari', 'hari'),
                        Container(width: 1, color: AppColors.border),
                        _buildPeriodButton('Minggu', 'minggu'),
                        Container(width: 1, color: AppColors.border),
                        _buildPeriodButton('Bulan', 'bulan'),
                      ],
                    ),
                  ),
                ],
              ),
        SizedBox(height: spacing),
        _buildTierBreakdown(state),
      ],
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    final buttonFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 11,
      tabletSize: 12,
      desktopSize: 13,
    );
    final buttonPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 8,
      tabletValue: 12,
      desktopValue: 16,
    );

    return InkWell(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: buttonPadding,
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
        child: Text(
          label,
          style: TextStyle(
            fontSize: buttonFontSize,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.textGray,
          ),
        ),
      ),
    );
  }

  Widget _buildTierBreakdown(DashboardState state) {
    final tierData = state.tierBreakdown;

    // Calculate total omset across all tiers
    int totalOmset = 0;
    for (final tier in tierData.values) {
      totalOmset += tier.totalOmset;
    }

    // Build tier rows only for tiers with transactions
    final tierRows = <Widget>[];
    final tiers = [
      ('UMUM', 'Orang Umum', AppColors.info),
      ('BENGKEL', 'Bengkel', AppColors.warning),
      ('GROSSIR', 'Grossir', AppColors.success),
    ];

    final spacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 8,
      tabletSpacing: 10,
      desktopSpacing: 12,
    );

    for (int i = 0; i < tiers.length; i++) {
      final (tierKey, tierLabel, tierColor) = tiers[i];
      final tierSummary = tierData[tierKey];

      if (tierSummary != null && tierSummary.transactionCount > 0) {
        final percentage = totalOmset > 0
            ? (tierSummary.totalOmset / totalOmset) * 100
            : 0.0;

        tierRows.add(
          _buildTierRow(
            tierLabel,
            tierSummary.totalOmset,
            tierSummary.totalHpp,
            tierSummary.transactionCount,
            percentage,
            tierColor,
          ),
        );

        if (i < tiers.length - 1) {
          tierRows.add(SizedBox(height: spacing));
        }
      }
    }

    return Column(
      children: [
        if (tierRows.isNotEmpty)
          Column(children: tierRows)
        else
          Container(
            padding: ResponsiveUtils.getResponsivePadding(context),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context),
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Text(
                'Belum ada transaksi ${_getPeriodLabel()}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    phoneSize: 12,
                    tabletSize: 14,
                    desktopSize: 14,
                  ),
                  color: AppColors.textGray,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTierRow(
    String tier,
    int omset,
    int hpp,
    int transactions,
    double percentage,
    Color color,
  ) {
    final profit = omset - hpp;
    final marginPercent = omset > 0 ? (profit / omset) * 100 : 0.0;

    final tierNameFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 13,
      tabletSize: 14,
      desktopSize: 15,
    );
    final tierCountFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 11,
      tabletSize: 12,
      desktopSize: 12,
    );
    final tierAmountFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 13,
      tabletSize: 14,
      desktopSize: 15,
    );
    final tierPercentFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 11,
      tabletSize: 12,
      desktopSize: 12,
    );
    final containerPadding = ResponsiveUtils.getResponsivePadding(context);
    final indicatorSize = ResponsiveUtils.getResponsiveHeight(
      context,
      phoneHeight: 7,
      tabletHeight: 8,
      desktopHeight: 10,
    );

    return Container(
      padding: containerPadding,
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
          // Header row
          Row(
            children: [
              Container(
                width: indicatorSize,
                height: indicatorSize,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: ResponsiveUtils.getPercentageWidth(context, 2)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier,
                      style: TextStyle(
                        fontSize: tierNameFontSize,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveUtils.getPercentageHeight(context, 0.5),
                    ),
                    Text(
                      '$transactions transaksi',
                      style: TextStyle(
                        fontSize: tierCountFontSize,
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
                    'Rp ${_formatNumber(omset)}',
                    style: TextStyle(
                      fontSize: tierAmountFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getPercentageHeight(context, 0.5),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: tierPercentFontSize,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getPercentageHeight(context, 2)),
          // Detail breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTierDetail('Omset', omset),
              _buildTierDetail('HPP', hpp),
              _buildTierDetail('Profit', profit),
              _buildTierDetail('Margin', marginPercent, isPercent: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTierDetail(
    String label,
    dynamic value, {
    bool isPercent = false,
  }) {
    final displayValue = isPercent
        ? '${(value as double).toStringAsFixed(1)}%'
        : 'Rp ${_formatNumber(value as int)}';

    final labelFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 10,
      tabletSize: 11,
      desktopSize: 12,
    );
    final valueFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 11,
      tabletSize: 12,
      desktopSize: 13,
    );

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: labelFontSize, color: AppColors.textGray),
        ),
        SizedBox(height: ResponsiveUtils.getPercentageHeight(context, 0.5)),
        Text(
          displayValue,
          style: TextStyle(
            fontSize: valueFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'minggu':
        return 'minggu ini';
      case 'bulan':
        return 'bulan ini';
      default:
        return 'hari ini';
    }
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatCompact(int number) {
    if (number >= 1000000) {
      return 'Rp ${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return 'Rp ${(number / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp $number';
  }

  String _formatDateLabel(DateTime date) {
    // Show day name for today, yesterday, etc. Otherwise show date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hari ini';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Kemarin';
    } else {
      // Show day abbreviation + date
      final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      return '${dayNames[date.weekday - 1]}\n${date.day}';
    }
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<DailySummary> dailySummaries;
  final int maxOmset;
  final int maxProfit;

  _TrendChartPainter({
    required this.dailySummaries,
    required this.maxOmset,
    required this.maxProfit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final omsetPaint = Paint()
      ..color = AppColors.info
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final profitPaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    // Draw grid
    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (dailySummaries.isEmpty) {
      return;
    }

    final omsetPath = Path();
    final profitPath = Path();

    // Use separate scaling for omset and profit to show both clearly
    // Omset uses 60% of height, profit uses 40% of height
    final omsetHeight = size.height * 0.6;
    final profitHeight = size.height * 0.4;

    for (int i = 0; i < dailySummaries.length; i++) {
      final summary = dailySummaries[i];
      final x = (size.width / (dailySummaries.length - 1)) * i;

      // Calculate Y positions with separate scaling
      final omsetNormalized = maxOmset > 0
          ? (summary.totalOmset / maxOmset)
          : 0.0;
      final profitNormalized = maxProfit > 0
          ? (summary.totalProfit / maxProfit)
          : 0.0;

      // Omset line in upper portion
      final omsetY = size.height - (omsetHeight * omsetNormalized);
      // Profit line in lower portion (offset down)
      final profitY = size.height - (profitHeight * profitNormalized);

      if (i == 0) {
        omsetPath.moveTo(x, omsetY);
        profitPath.moveTo(x, profitY);
      } else {
        omsetPath.lineTo(x, omsetY);
        profitPath.lineTo(x, profitY);
      }

      // Draw data points
      canvas.drawCircle(Offset(x, omsetY), 4, Paint()..color = AppColors.info);
      canvas.drawCircle(
        Offset(x, profitY),
        4,
        Paint()..color = AppColors.success,
      );
    }

    canvas.drawPath(omsetPath, omsetPaint);
    canvas.drawPath(profitPath, profitPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
