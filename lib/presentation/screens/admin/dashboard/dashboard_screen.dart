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
import '../analytics/analytics_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch real-time stream with daily period
    final dashboardAsync = ref.watch(
      dashboardStreamProvider(DashboardPeriod.fromString('hari')),
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
                        // Lazy load quick stats
                        FutureBuilder(
                          future: Future.delayed(
                            const Duration(milliseconds: 100),
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _buildQuickStats(dashboardState);
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Lazy load analytics button
                        FutureBuilder(
                          future: Future.delayed(
                            const Duration(milliseconds: 200),
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(height: 80);
                            }
                            return _buildAnalyticsButton();
                          },
                        ),
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

  Widget _buildAnalyticsButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to analytics screen
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.analytics,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analytics Lanjutan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap untuk melihat analisis detail transaksi, pembayaran, dan profit',
                    style: TextStyle(fontSize: 12, color: AppColors.textGray),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 16,
            ),
          ],
        ),
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

    // FIX: Calculate HPP from omset and profit if not available
    final calculatedHpp = hpp > 0 ? hpp : (omset - profit - expenses);

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
                Expanded(
                  child: _buildProfitDetail(
                    'HPP',
                    _formatCompact(calculatedHpp),
                  ),
                ),
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
}
