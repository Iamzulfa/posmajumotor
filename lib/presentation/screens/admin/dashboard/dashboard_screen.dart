import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/constants/supabase_config.dart';
import '../../../widgets/common/sync_status_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/auth_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    if (SupabaseConfig.isConfigured) {
      Future.microtask(() {
        ref.read(dashboardProvider.notifier).loadDashboardData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final isOnline = SupabaseConfig.isConfigured;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: dashboardState.isLoading
            ? const LoadingWidget()
            : RefreshIndicator(
                onRefresh: () async {
                  if (isOnline) {
                    await ref
                        .read(dashboardProvider.notifier)
                        .loadDashboardData();
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, isOnline),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfitCard(dashboardState, isOnline),
                            const SizedBox(height: AppSpacing.md),
                            _buildTaxIndicator(dashboardState, isOnline),
                            const SizedBox(height: AppSpacing.md),
                            _buildQuickStats(dashboardState, isOnline),
                            const SizedBox(height: AppSpacing.lg),
                            _buildTrendChart(),
                            const SizedBox(height: AppSpacing.lg),
                            _buildTierBreakdown(dashboardState, isOnline),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isOnline) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatDate(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGray,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  if (isOnline) {
                    await ref.read(authProvider.notifier).signOut();
                  }
                  if (mounted) context.go(AppRoutes.login);
                },
                color: AppColors.textGray,
                tooltip: 'Logout',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SyncStatusWidget(
            status: isOnline ? SyncStatus.online : SyncStatus.offline,
            lastSyncTime: isOnline ? 'Real-time' : 'Offline mode',
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

  Widget _buildProfitCard(DashboardState state, bool isOnline) {
    final profit = isOnline ? state.todayProfit : 2450000;
    final omset = isOnline ? state.todayOmset : 8500000;
    final hpp = isOnline ? state.todayHpp : 5200000;
    final expenses = isOnline ? state.todayExpenses : 850000;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laba Bersih Hari Ini',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Rp ${_formatNumber(profit)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProfitDetail('Penjualan', _formatCompact(omset)),
                Container(width: 1, height: 30, color: Colors.white24),
                _buildProfitDetail('HPP', _formatCompact(hpp)),
                Container(width: 1, height: 30, color: Colors.white24),
                _buildProfitDetail('Pengeluaran', _formatCompact(expenses)),
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

  Widget _buildTaxIndicator(DashboardState state, bool isOnline) {
    final taxAmount = isOnline ? state.taxAmount : 42500;
    final monthlyOmset = isOnline ? state.monthlyOmset : 8500000;
    final targetTax = (monthlyOmset * 0.005).round();
    final progress = targetTax > 0
        ? (taxAmount / targetTax).clamp(0.0, 1.0)
        : 0.0;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tabungan Pajak Bulan Ini',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '0.5%',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
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
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Rp ${_formatNumber(taxAmount)} / Rp ${_formatNumber(targetTax)}',
            style: const TextStyle(fontSize: 12, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(DashboardState state, bool isOnline) {
    final trxCount = isOnline ? state.todayTransactionCount : 24;
    final avgTrx = isOnline ? state.todayAverageTransaction : 354000;
    final expenses = isOnline ? state.todayExpenses : 850000;
    final margin = isOnline ? state.marginPercent : 28.8;

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
            const SizedBox(width: AppSpacing.sm),
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
        const SizedBox(height: AppSpacing.sm),
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
            const SizedBox(width: AppSpacing.sm),
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  label,
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
    );
  }

  Widget _buildTrendChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trend 7 Hari Terakhir',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Omset', AppColors.info),
                  const SizedBox(width: AppSpacing.lg),
                  _buildLegendItem('Profit', AppColors.success),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 180,
                child: CustomPaint(
                  size: const Size(double.infinity, 180),
                  painter: _TrendChartPainter(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                    .map(
                      (d) => Text(
                        d,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textGray,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textGray),
        ),
      ],
    );
  }

  Widget _buildTierBreakdown(DashboardState state, bool isOnline) {
    final tierData = isOnline && state.tierBreakdown.isNotEmpty
        ? state.tierBreakdown
        : null;

    return Column(
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
        _buildTierRow(
          'Orang Umum',
          tierData?['UMUM']?.totalOmset ?? 3200000,
          tierData?['UMUM']?.transactionCount ?? 12,
          0.38,
          AppColors.info,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildTierRow(
          'Bengkel',
          tierData?['BENGKEL']?.totalOmset ?? 2800000,
          tierData?['BENGKEL']?.transactionCount ?? 8,
          0.33,
          AppColors.warning,
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildTierRow(
          'Grossir',
          tierData?['GROSSIR']?.totalOmset ?? 2500000,
          tierData?['GROSSIR']?.transactionCount ?? 4,
          0.29,
          AppColors.success,
        ),
      ],
    );
  }

  Widget _buildTierRow(
    String tier,
    int amount,
    int transactions,
    double percentage,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  tier,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                'Rp ${_formatNumber(amount)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: AppColors.secondary,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '$transactions trx',
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
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
    if (number >= 1000000)
      return 'Rp ${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return 'Rp ${(number / 1000).toStringAsFixed(0)}K';
    return 'Rp $number';
  }
}

class _TrendChartPainter extends CustomPainter {
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

    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final omsetPath = Path();
    final profitPath = Path();
    final omsetPoints = [0.5, 0.65, 0.55, 0.75, 0.6, 0.85, 0.7];
    final profitPoints = [0.25, 0.32, 0.28, 0.38, 0.3, 0.42, 0.35];

    for (int i = 0; i < omsetPoints.length; i++) {
      final x = (size.width / (omsetPoints.length - 1)) * i;
      final omsetY = size.height - (size.height * omsetPoints[i]);
      final profitY = size.height - (size.height * profitPoints[i]);

      if (i == 0) {
        omsetPath.moveTo(x, omsetY);
        profitPath.moveTo(x, profitY);
      } else {
        omsetPath.lineTo(x, omsetY);
        profitPath.lineTo(x, profitY);
      }

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
