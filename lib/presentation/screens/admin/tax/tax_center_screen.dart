import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../widgets/common/app_header.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../providers/tax_provider.dart';
import '../../../providers/dashboard_provider.dart' show TaxPeriod;
import '../../../../domain/repositories/tax_repository.dart'
    show ProfitLossReport;
import '../../../../core/services/pdf_generator.dart';

class TaxCenterScreen extends ConsumerStatefulWidget {
  const TaxCenterScreen({super.key});

  @override
  ConsumerState<TaxCenterScreen> createState() => _TaxCenterScreenState();
}

class _TaxCenterScreenState extends ConsumerState<TaxCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _expandedTiers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxState = ref.watch(taxCenterProvider);
    final period = TaxPeriod(
      month: taxState.selectedMonth,
      year: taxState.selectedYear,
    );

    // Watch real-time streams
    final taxCalcAsync = ref.watch(taxCalculationStreamProvider(period));
    final profitLossAsync = ref.watch(profitLossReportStreamProvider(period));

    final syncStatus = taxCalcAsync.when(
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
              title: 'Tax Center',
              syncStatus: syncStatus,
              lastSyncTime: syncStatus == SyncStatus.online
                  ? 'Real-time'
                  : 'Syncing...',
            ),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLaporanTab(taxState, taxCalcAsync, profitLossAsync),
                  _buildKalkulatorTab(taxState, taxCalcAsync),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context),
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textGray,
        labelStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            phoneSize: 14,
            tabletSize: 16,
            desktopSize: 18,
          ),
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            phoneSize: 14,
            tabletSize: 16,
            desktopSize: 18,
          ),
          fontWeight: FontWeight.normal,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Laporan'),
          Tab(text: 'Kalkulator Pajak'),
        ],
      ),
    );
  }

  Widget _buildLaporanTab(
    TaxCenterState taxState,
    AsyncValue taxCalcAsync,
    AsyncValue profitLossAsync,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        final period = TaxPeriod(
          month: taxState.selectedMonth,
          year: taxState.selectedYear,
        );
        ref.invalidate(taxCalculationStreamProvider(period));
        ref.invalidate(profitLossReportStreamProvider(period));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthSelector(taxState),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 16,
                tabletSpacing: 20,
                desktopSpacing: 24,
              ),
            ),
            _buildProfitLossCard(taxState, profitLossAsync),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 16,
                tabletSpacing: 20,
                desktopSpacing: 24,
              ),
            ),
            _buildTierBreakdown(taxState, profitLossAsync),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 24,
                tabletSpacing: 30,
                desktopSpacing: 36,
              ),
            ),
            Column(
              children: [
                CustomButton(
                  text: 'Laporan Harian',
                  icon: Icons.calendar_today,
                  onPressed: () => _exportDailyPDF(profitLossAsync),
                ),
                SizedBox(
                  height: ResponsiveUtils.getResponsiveSpacing(
                    context,
                    phoneSpacing: 12,
                    tabletSpacing: 16,
                    desktopSpacing: 20,
                  ),
                ),
                CustomButton(
                  text: 'Laporan Bulanan',
                  icon: Icons.picture_as_pdf,
                  onPressed: () => _exportMonthlyPDF(profitLossAsync),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(TaxCenterState taxState) {
    final months = <String>[];
    final now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      months.add(_getMonthName(date.month, date.year));
    }

    return Container(
      padding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: 16,
        tabletValue: 18,
        desktopValue: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: taxState.periodString,
          isExpanded: true,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 16,
              tabletSize: 18,
              desktopSize: 20,
            ),
            color: AppColors.textDark,
          ),
          items: months
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              final parts = value.split(' ');
              final month = _getMonthNumber(parts[0]);
              final year = int.parse(parts[1]);
              ref
                  .read(taxCenterProvider.notifier)
                  .setSelectedPeriod(month, year);
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfitLossCard(
    TaxCenterState taxState,
    AsyncValue profitLossAsync,
  ) {
    return profitLossAsync.when(
      data: (report) {
        final omset = report.totalOmset;
        final hpp = report.totalHpp;
        final expenses = report.totalExpenses;
        final profit = report.netProfit;
        final margin = omset > 0 ? (profit / omset) * 100 : 0.0;
        return _buildProfitLossCardContent(
          omset,
          hpp,
          expenses,
          profit,
          margin,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildProfitLossCardContent(
    int omset,
    int hpp,
    int expenses,
    int profit,
    double margin,
  ) {
    final cardPadding = ResponsiveUtils.getResponsivePaddingCustom(
      context,
      phoneValue: 10,
      tabletValue: 12,
      desktopValue: 14,
    );
    final titleFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 16,
      tabletSize: 18,
      desktopSize: 20,
    );
    final marginFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: 12,
      tabletSize: 14,
      desktopSize: 15,
    );
    final spacing = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 8,
      tabletSpacing: 10,
      desktopSpacing: 12,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan Laba Rugi',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: spacing),
          _buildReportRow('Total Omset', omset, isPositive: true),
          _buildReportRow('Total HPP', hpp, isNegative: true),
          _buildReportRow('Total Pengeluaran', expenses, isNegative: true),
          Divider(height: spacing * 2),
          _buildReportRow('Profit Bersih', profit, isTotal: true),
          SizedBox(height: spacing),
          Container(
            padding: EdgeInsets.all(
              ResponsiveUtils.getPercentageWidth(context, 2),
            ),
            decoration: BoxDecoration(
              color: profit >= 0
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context) * 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  profit >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: profit >= 0 ? AppColors.success : AppColors.error,
                  size: 16,
                ),
                SizedBox(
                  width: ResponsiveUtils.getPercentageWidth(context, 1.5),
                ),
                Text(
                  'Margin: ${margin.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: marginFontSize,
                    fontWeight: FontWeight.w600,
                    color: profit >= 0 ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(
    String label,
    int amount, {
    bool isPositive = false,
    bool isNegative = false,
    bool isTotal = false,
  }) {
    Color amountColor = AppColors.textDark;
    if (isPositive) amountColor = AppColors.success;
    if (isNegative) amountColor = AppColors.error;
    if (isTotal) {
      amountColor = amount >= 0 ? AppColors.primary : AppColors.error;
    }

    final labelFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: isTotal ? 14 : 12,
      tabletSize: isTotal ? 16 : 14,
      desktopSize: isTotal ? 17 : 15,
    );
    final amountFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: isTotal ? 16 : 12,
      tabletSize: isTotal ? 18 : 14,
      desktopSize: isTotal ? 20 : 15,
    );
    final rowPadding = ResponsiveUtils.getResponsiveSpacing(
      context,
      phoneSpacing: 4,
      tabletSpacing: 6,
      desktopSpacing: 8,
    );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: rowPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textDark : AppColors.textGray,
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}Rp ${_formatNumber(amount.abs())}',
            style: TextStyle(
              fontSize: amountFontSize,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBreakdown(
    TaxCenterState taxState,
    AsyncValue profitLossAsync,
  ) {
    return profitLossAsync.when(
      data: (report) {
        // Cast to ProfitLossReport to ensure correct type
        final profitReport = report as ProfitLossReport;
        final tierData = profitReport.tierBreakdown.entries
            .map(
              (e) => {
                'tier': _getTierDisplayName(e.key),
                'omset': e.value.omset,
                'hpp': e.value.hpp,
                'profit': e.value.profit,
                'margin': e.value.omset > 0
                    ? ((e.value.profit / e.value.omset) * 100)
                    : 0.0,
                'transactions': e.value.transactionCount,
              },
            )
            .toList();
        return _buildTierBreakdownContent(tierData);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildTierBreakdownContent(List<Map<String, dynamic>> tierData) {
    if (tierData.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada data',
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
      );
    }

    return Container(
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
            'Breakdown per Tier',
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
              phoneSpacing: 16,
              tabletSpacing: 20,
              desktopSpacing: 24,
            ),
          ),
          ...tierData.map((tier) => _buildExpandableTierRow(tier)),
        ],
      ),
    );
  }

  Widget _buildExpandableTierRow(Map<String, dynamic> tierData) {
    final tier = tierData['tier'] as String;
    final isExpanded = _expandedTiers.contains(tier);
    final color = _getTierColor(tier);

    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(
          context,
          phoneSpacing: 12,
          tabletSpacing: 16,
          desktopSpacing: 20,
        ),
      ),
      decoration: BoxDecoration(
        color: isExpanded ? color.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context) * 0.7,
        ),
        border: isExpanded
            ? Border.all(color: color.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(
              () => isExpanded
                  ? _expandedTiers.remove(tier)
                  : _expandedTiers.add(tier),
            ),
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.getResponsiveBorderRadius(context) * 0.7,
            ),
            child: Padding(
              padding: ResponsiveUtils.getResponsivePaddingCustom(
                context,
                phoneValue: 12,
                tabletValue: 16,
                desktopValue: 20,
              ),
              child: Row(
                children: [
                  Container(
                    width: ResponsiveUtils.getResponsiveWidth(
                      context,
                      phoneWidth: 8,
                      tabletWidth: 10,
                      desktopWidth: 12,
                    ),
                    height: ResponsiveUtils.getResponsiveHeight(
                      context,
                      phoneHeight: 8,
                      tabletHeight: 10,
                      desktopHeight: 12,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 12,
                      tabletSpacing: 16,
                      desktopSpacing: 20,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              phoneSize: 14,
                              tabletSize: 16,
                              desktopSize: 18,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${tierData['transactions']} transaksi',
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
                    'Rp ${_formatNumber(tierData['omset'])}',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        phoneSize: 14,
                        tabletSize: 16,
                        desktopSize: 18,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 8,
                      tabletSpacing: 10,
                      desktopSpacing: 12,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textGray,
                    size: ResponsiveUtils.getResponsiveIconSize(context),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(
                ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: 24,
                  tabletSpacing: 32,
                  desktopSpacing: 40,
                ),
                0,
                ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: 12,
                  tabletSpacing: 16,
                  desktopSpacing: 20,
                ),
                ResponsiveUtils.getResponsiveSpacing(
                  context,
                  phoneSpacing: 12,
                  tabletSpacing: 16,
                  desktopSpacing: 20,
                ),
              ),
              child: Column(
                children: [
                  _buildTierDetailRow(
                    'Omset',
                    tierData['omset'],
                    AppColors.info,
                  ),
                  _buildTierDetailRow(
                    'HPP',
                    tierData['hpp'],
                    AppColors.error,
                    isNegative: true,
                  ),
                  _buildTierDetailRow(
                    'Profit',
                    tierData['profit'],
                    AppColors.success,
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 8,
                      tabletSpacing: 10,
                      desktopSpacing: 12,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: ResponsiveUtils.getResponsivePaddingCustom(
                          context,
                          phoneValue: 8,
                          tabletValue: 10,
                          desktopValue: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            ResponsiveUtils.getResponsiveBorderRadius(context) *
                                0.3,
                          ),
                        ),
                        child: Text(
                          'Margin: ${(tierData['margin'] as num).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              phoneSize: 12,
                              tabletSize: 14,
                              desktopSize: 16,
                            ),
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTierDetailRow(
    String label,
    int amount,
    Color color, {
    bool isNegative = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveUtils.getResponsiveSpacing(
          context,
          phoneSpacing: 2,
          tabletSpacing: 3,
          desktopSpacing: 4,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                phoneSize: 13,
                tabletSize: 15,
                desktopSize: 17,
              ),
              color: AppColors.textGray,
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}Rp ${_formatNumber(amount)}',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                phoneSize: 13,
                tabletSize: 15,
                desktopSize: 17,
              ),
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKalkulatorTab(TaxCenterState taxState, AsyncValue taxCalcAsync) {
    return taxCalcAsync.when(
      data: (calc) {
        final omset = calc.totalOmset;
        final taxAmount = calc.taxAmount;
        final isPaid = calc.isPaid;
        return _buildKalkulatorContent(taxState, omset, taxAmount, isPaid);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildKalkulatorContent(
    TaxCenterState taxState,
    int omset,
    int taxAmount,
    bool isPaid,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        final period = TaxPeriod(
          month: taxState.selectedMonth,
          year: taxState.selectedYear,
        );
        ref.invalidate(taxCalculationStreamProvider(period));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: ResponsiveUtils.getResponsivePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthSelector(taxState),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 16,
                tabletSpacing: 20,
                desktopSpacing: 24,
              ),
            ),
            Container(
              padding: ResponsiveUtils.getResponsivePaddingCustom(
                context,
                phoneValue: 20,
                tabletValue: 24,
                desktopValue: 28,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.getResponsiveBorderRadius(context),
                ),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    'Kalkulator PPh Final',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        phoneSize: 18,
                        tabletSize: 20,
                        desktopSize: 22,
                      ),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 24,
                      tabletSpacing: 30,
                      desktopSpacing: 36,
                    ),
                  ),
                  _buildCalcRow('Total Omset Bulan Ini', omset),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 12,
                      tabletSpacing: 16,
                      desktopSpacing: 20,
                    ),
                  ),
                  _buildCalcRow('Tarif PPh Final', null, suffix: '0.5%'),
                  Divider(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 24,
                      tabletSpacing: 30,
                      desktopSpacing: 36,
                    ),
                  ),
                  _buildCalcRow('Estimasi Pajak', taxAmount, isTotal: true),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 24,
                      tabletSpacing: 30,
                      desktopSpacing: 36,
                    ),
                  ),
                  Container(
                    padding: ResponsiveUtils.getResponsivePadding(context),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.getResponsiveBorderRadius(context),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPaid ? Icons.check_circle : Icons.info_outline,
                          color: isPaid ? AppColors.success : AppColors.warning,
                          size: ResponsiveUtils.getResponsiveIconSize(context),
                        ),
                        SizedBox(
                          width: ResponsiveUtils.getResponsiveSpacing(
                            context,
                            phoneSpacing: 12,
                            tabletSpacing: 16,
                            desktopSpacing: 20,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Status: ${isPaid ? 'Sudah Dibayar' : 'Belum Dibayar'}',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                phoneSize: 14,
                                tabletSize: 16,
                                desktopSize: 18,
                              ),
                              fontWeight: FontWeight.w500,
                              color: isPaid
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveUtils.getResponsiveSpacing(
                      context,
                      phoneSpacing: 24,
                      tabletSpacing: 30,
                      desktopSpacing: 36,
                    ),
                  ),
                  if (!isPaid)
                    CustomButton(
                      text: 'Tandai Sudah Bayar',
                      icon: Icons.check_circle,
                      onPressed: () => _markAsPaid(),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: ResponsiveUtils.getResponsiveSpacing(
                context,
                phoneSpacing: 24,
                tabletSpacing: 30,
                desktopSpacing: 36,
              ),
            ),
            _buildPaymentHistory(taxState),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistory(TaxCenterState taxState) {
    final history = taxState.paymentHistory.isNotEmpty
        ? taxState.paymentHistory
              .map(
                (p) => {
                  'month': p.periodString,
                  'omset': p.totalOmset,
                  'tax': p.taxAmount,
                  'status': p.isPaid ? 'paid' : 'pending',
                  'paidDate': p.formattedPaidDate,
                },
              )
              .toList()
        : <Map<String, dynamic>>[];

    return Container(
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
            'Riwayat Pembayaran Pajak',
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
              phoneSpacing: 12,
              tabletSpacing: 16,
              desktopSpacing: 20,
            ),
          ),
          ...history.map((payment) => _buildPaymentHistoryItem(payment)),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryItem(Map<String, dynamic> payment) {
    final isPaid = payment['status'] == 'paid';
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.getResponsiveSpacing(
          context,
          phoneSpacing: 12,
          tabletSpacing: 16,
          desktopSpacing: 20,
        ),
      ),
      padding: ResponsiveUtils.getResponsivePadding(context),
      decoration: BoxDecoration(
        color: isPaid
            ? AppColors.success.withValues(alpha: 0.05)
            : AppColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context) * 0.7,
        ),
        border: Border.all(
          color: isPaid
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.warning.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: ResponsiveUtils.getResponsivePaddingCustom(
              context,
              phoneValue: 12,
              tabletValue: 16,
              desktopValue: 20,
            ),
            decoration: BoxDecoration(
              color: isPaid
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.getResponsiveBorderRadius(context) * 0.7,
              ),
            ),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.schedule,
              color: isPaid ? AppColors.success : AppColors.warning,
              size: ResponsiveUtils.getResponsiveIconSize(context),
            ),
          ),
          SizedBox(
            width: ResponsiveUtils.getResponsiveSpacing(
              context,
              phoneSpacing: 16,
              tabletSpacing: 20,
              desktopSpacing: 24,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['month'],
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
                Text(
                  'Omset: Rp ${_formatNumber(payment['omset'])}',
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
                if (isPaid)
                  Text(
                    'Dibayar: ${payment['paidDate']}',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${_formatNumber(payment['tax'])}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    phoneSize: 14,
                    tabletSize: 16,
                    desktopSize: 18,
                  ),
                  fontWeight: FontWeight.bold,
                  color: isPaid ? AppColors.success : AppColors.warning,
                ),
              ),
              Container(
                padding: ResponsiveUtils.getResponsivePaddingCustom(
                  context,
                  phoneValue: 6,
                  tabletValue: 8,
                  desktopValue: 10,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context) * 0.3,
                  ),
                ),
                child: Text(
                  isPaid ? 'Lunas' : 'Pending',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 10,
                      tabletSize: 12,
                      desktopSize: 14,
                    ),
                    fontWeight: FontWeight.w600,
                    color: isPaid ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalcRow(
    String label,
    int? amount, {
    String? suffix,
    bool isTotal = false,
  }) {
    final labelFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: isTotal ? 14 : 12,
      tabletSize: isTotal ? 16 : 14,
      desktopSize: isTotal ? 17 : 15,
    );
    final amountFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      phoneSize: isTotal ? 18 : 12,
      tabletSize: isTotal ? 20 : 14,
      desktopSize: isTotal ? 22 : 15,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.textDark : AppColors.textGray,
          ),
        ),
        Text(
          amount != null ? 'Rp ${_formatNumber(amount)}' : suffix ?? '',
          style: TextStyle(
            fontSize: amountFontSize,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.primary : AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Future<void> _markAsPaid() async {
    await ref.read(taxCenterProvider.notifier).markAsPaid();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pajak ditandai sudah dibayar'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  String _getTierDisplayName(String tier) {
    switch (tier) {
      case 'UMUM':
        return 'Orang Umum';
      case 'BENGKEL':
        return 'Bengkel';
      case 'GROSSIR':
        return 'Grossir';
      default:
        return tier;
    }
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'Orang Umum':
        return AppColors.info;
      case 'Bengkel':
        return AppColors.warning;
      case 'Grossir':
        return AppColors.success;
      default:
        return AppColors.textGray;
    }
  }

  String _getMonthName(int month, int year) {
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
    return '${months[month - 1]} $year';
  }

  int _getMonthNumber(String monthName) {
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
    return months.indexOf(monthName) + 1;
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _exportDailyPDF(AsyncValue profitLossAsync) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating daily report...')),
      );

      await profitLossAsync.when(
        data: (report) async {
          final profitReport = report as ProfitLossReport;
          await PdfGenerator.generateProfitLossReport(
            report: profitReport,
            date: DateTime.now(),
            businessName: 'PosFELIX - Toko Suku Cadang Motor',
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Laporan harian berhasil dibuat'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        loading: () async {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Menunggu data...')));
          }
        },
        error: (error, _) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _exportMonthlyPDF(AsyncValue profitLossAsync) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating monthly report...')),
      );

      await profitLossAsync.when(
        data: (report) async {
          final profitReport = report as ProfitLossReport;
          await PdfGenerator.generateProfitLossReport(
            report: profitReport,
            businessName: 'PosFELIX - Toko Suku Cadang Motor',
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Laporan bulanan berhasil dibuat'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        loading: () async {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Menunggu data...')));
          }
        },
        error: (error, _) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $error'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
