import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
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
      error: (_, __) => SyncStatus.offline,
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
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textGray,
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
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthSelector(taxState),
            const SizedBox(height: AppSpacing.md),
            _buildProfitLossCard(taxState, profitLossAsync),
            const SizedBox(height: AppSpacing.md),
            _buildTierBreakdown(taxState, profitLossAsync),
            const SizedBox(height: AppSpacing.lg),
            CustomButton(
              text: 'Export PDF',
              icon: Icons.picture_as_pdf,
              onPressed: () => _exportPDF(profitLossAsync),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: taxState.periodString,
          isExpanded: true,
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan Laba Rugi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildReportRow('Total Omset', omset, isPositive: true),
          _buildReportRow('Total HPP', hpp, isNegative: true),
          _buildReportRow('Total Pengeluaran', expenses, isNegative: true),
          const Divider(height: AppSpacing.lg),
          _buildReportRow('Profit Bersih', profit, isTotal: true),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: profit >= 0
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  profit >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: profit >= 0 ? AppColors.success : AppColors.error,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Margin: ${margin.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.textDark : AppColors.textGray,
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}Rp ${_formatNumber(amount.abs())}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
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
      return const Center(child: Text('Tidak ada data'));
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Breakdown per Tier',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isExpanded ? color.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${tierData['transactions']} transaksi',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rp ${_formatNumber(tierData['omset'])}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textGray,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.sm,
                AppSpacing.sm,
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
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Margin: ${(tierData['margin'] as num).toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textGray),
          ),
          Text(
            '${isNegative ? '-' : ''}Rp ${_formatNumber(amount)}',
            style: TextStyle(
              fontSize: 13,
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
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthSelector(taxState),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Text(
                    'Kalkulator PPh Final',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildCalcRow('Total Omset Bulan Ini', omset),
                  const SizedBox(height: AppSpacing.sm),
                  _buildCalcRow('Tarif PPh Final', null, suffix: '0.5%'),
                  const Divider(height: AppSpacing.lg),
                  _buildCalcRow('Estimasi Pajak', taxAmount, isTotal: true),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPaid ? Icons.check_circle : Icons.info_outline,
                          color: isPaid ? AppColors.success : AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Status: ${isPaid ? 'Sudah Dibayar' : 'Belum Dibayar'}',
                            style: TextStyle(
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
                  const SizedBox(height: AppSpacing.lg),
                  if (!isPaid)
                    CustomButton(
                      text: 'Tandai Sudah Bayar',
                      icon: Icons.check_circle,
                      onPressed: () => _markAsPaid(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Pembayaran Pajak',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...history.map((payment) => _buildPaymentHistoryItem(payment)),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryItem(Map<String, dynamic> payment) {
    final isPaid = payment['status'] == 'paid';
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isPaid
            ? AppColors.success.withValues(alpha: 0.05)
            : AppColors.warning.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: isPaid
              ? AppColors.success.withValues(alpha: 0.2)
              : AppColors.warning.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isPaid
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.schedule,
              color: isPaid ? AppColors.success : AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['month'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Omset: Rp ${_formatNumber(payment['omset'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
                if (isPaid)
                  Text(
                    'Dibayar: ${payment['paidDate']}',
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
                'Rp ${_formatNumber(payment['tax'])}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isPaid ? AppColors.success : AppColors.warning,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isPaid ? 'Lunas' : 'Pending',
                  style: TextStyle(
                    fontSize: 10,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.textDark : AppColors.textGray,
          ),
        ),
        Text(
          amount != null ? 'Rp ${_formatNumber(amount)}' : suffix ?? '',
          style: TextStyle(
            fontSize: isTotal ? 20 : 14,
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

  Future<void> _exportPDF(AsyncValue profitLossAsync) async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Generating PDF...')));

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
                content: Text('PDF berhasil dibuat'),
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
