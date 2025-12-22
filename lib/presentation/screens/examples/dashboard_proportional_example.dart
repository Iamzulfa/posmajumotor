import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/proportional_extensions.dart';
import '../../../config/constants/proportional_constants.dart';
import '../../widgets/common/proportional_widgets.dart';

/// Example of Dashboard Screen using Proportional Responsive System
/// This shows how to migrate from the old ResponsiveUtils to the new system
class DashboardProportionalExample extends ConsumerStatefulWidget {
  const DashboardProportionalExample({super.key});

  @override
  ConsumerState<DashboardProportionalExample> createState() =>
      _DashboardProportionalExampleState();
}

class _DashboardProportionalExampleState
    extends ConsumerState<DashboardProportionalExample> {
  String _selectedPeriod = 'hari';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),

              // Screen padding using proportional system
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ProportionalConstants.screenPaddingHorizontal.w(
                    context,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfitCard(),
                    PSpacing.large,
                    _buildTaxIndicator(),
                    PSpacing.large,
                    _buildQuickStats(),
                    PSpacing.large,
                    _buildTierBreakdownSection(),
                    PSpacing.large,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return PContainer(
      padding: EdgeInsets.all(ProportionalConstants.screenPaddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PText.heading(
                    'Selamat Pagi, Admin',
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  SizedBox(height: 4.h(context)),
                  PText.medium(
                    _formatDate(DateTime.now()),
                    color: AppColors.textGray,
                  ),
                ],
              ),
              PContainer(
                width: 40,
                height: 40,
                borderRadius: 20,
                color: AppColors.error.withValues(alpha: 0.1),
                child: const PIcon.medium(Icons.logout, color: AppColors.error),
              ),
            ],
          ),
          PSpacing.medium,

          // Sync Status
          PContainer(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w(context),
              vertical: 6.h(context),
            ),
            borderRadius: 16,
            color: AppColors.success.withValues(alpha: 0.1),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PContainer(
                  width: 8,
                  height: 8,
                  borderRadius: 4,
                  color: AppColors.success,
                  child: const SizedBox(), // Add empty child
                ),
                SizedBox(width: 8.w(context)),
                const PText.small(
                  'Real-time',
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitCard() {
    // Mock data
    const profit = 2500000;
    const omset = 8500000;
    const hpp = 4200000;
    const expenses = 1800000;

    return PContainer(
      width: double.infinity,
      padding: EdgeInsets.all(ProportionalConstants.cardPaddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          ProportionalConstants.radiusLarge.r(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PText.large('Laba Bersih Hari Ini', color: Colors.white70),
          SizedBox(height: 8.h(context)),

          PText(
            'Rp ${_formatNumber(profit)}',
            fontSize: 32, // Large display font
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),

          SizedBox(height: 16.h(context)),

          // Breakdown container
          PContainer(
            width: double.infinity,
            padding: EdgeInsets.all(ProportionalConstants.cardPaddingMedium),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(
                ProportionalConstants.radiusMedium.r(context),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildProfitDetail('Penjualan', _formatCompact(omset)),
                ),
                Container(
                  width: 1.w(context),
                  height: 30.h(context),
                  color: Colors.white24,
                ),
                Expanded(child: _buildProfitDetail('HPP', _formatCompact(hpp))),
                Container(
                  width: 1.w(context),
                  height: 30.h(context),
                  color: Colors.white24,
                ),
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
        PText.small(label, color: Colors.white60),
        SizedBox(height: 4.h(context)),
        PText.medium(value, fontWeight: FontWeight.w600, color: Colors.white),
      ],
    );
  }

  Widget _buildTaxIndicator() {
    // Mock data
    const taxAmount = 42500;
    const monthlyOmset = 8500000;
    const targetTax = (monthlyOmset * 0.005);
    final progress = (taxAmount / targetTax).clamp(0.0, 1.0);

    return PContainer(
      padding: EdgeInsets.all(ProportionalConstants.cardPaddingLarge),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          ProportionalConstants.radiusLarge.r(context),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const PText.large(
                'Tabungan Pajak Bulan Ini',
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              PContainer(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w(context),
                  vertical: 4.h(context),
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r(context)),
                ),
                child: const PText.small(
                  '0.5%',
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h(context)),

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r(context)),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.secondary,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.warning,
                    ),
                    minHeight: 8.h(context),
                  ),
                ),
              ),
              SizedBox(width: 12.w(context)),
              PText.medium(
                '${(progress * 100).toInt()}%',
                fontWeight: FontWeight.w600,
                color: AppColors.warning,
              ),
            ],
          ),

          SizedBox(height: 8.h(context)),

          PText.small(
            'Rp ${_formatNumber(taxAmount.toInt())} / Rp ${_formatNumber(targetTax.toInt())}',
            color: AppColors.textGray,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Transaksi',
                '24',
                Icons.receipt_long,
                AppColors.info,
              ),
            ),
            SizedBox(width: 12.w(context)),
            Expanded(
              child: _buildStatCard(
                'Rata-rata',
                'Rp 354K',
                Icons.trending_up,
                AppColors.success,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h(context)),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Pengeluaran',
                'Rp 1.8M',
                Icons.account_balance_wallet,
                AppColors.error,
              ),
            ),
            SizedBox(width: 12.w(context)),
            Expanded(
              child: _buildStatCard(
                'Margin',
                '29.4%',
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
    return PContainer(
      padding: EdgeInsets.all(ProportionalConstants.cardPaddingMedium),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          ProportionalConstants.radiusLarge.r(context),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          PContainer(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                ProportionalConstants.radiusMedium.r(context),
              ),
            ),
            child: PIcon.medium(icon, color: color),
          ),

          SizedBox(width: 12.w(context)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PText.large(
                  value,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                SizedBox(height: 2.h(context)),
                PText.small(label, color: AppColors.textGray),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const PText.large(
              'Breakdown per Tier',
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            PContainer(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(
                  ProportionalConstants.radiusMedium.r(context),
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

        SizedBox(height: 16.h(context)),

        // Mock tier data
        _buildTierRow('Orang Umum', 3200000, 1800000, 12, 45.0, AppColors.info),
        SizedBox(height: 12.h(context)),
        _buildTierRow('Bengkel', 2800000, 1600000, 8, 35.0, AppColors.warning),
        SizedBox(height: 12.h(context)),
        _buildTierRow('Grossir', 2500000, 1400000, 4, 20.0, AppColors.success),
      ],
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;

    return InkWell(
      onTap: () => setState(() => _selectedPeriod = period),
      child: PContainer(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w(context),
          vertical: 8.h(context),
        ),
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
        child: PText.small(
          label,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textGray,
        ),
      ),
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

    return PContainer(
      padding: EdgeInsets.all(ProportionalConstants.cardPaddingLarge),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(
          ProportionalConstants.radiusLarge.r(context),
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              PContainer(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const SizedBox(), // Add empty child
              ),

              SizedBox(width: 12.w(context)),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PText.medium(
                      tier,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                    SizedBox(height: 2.h(context)),
                    PText.small(
                      '$transactions transaksi',
                      color: AppColors.textGray,
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PText.medium(
                    'Rp ${_formatNumber(omset)}',
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  SizedBox(height: 2.h(context)),
                  PText.small(
                    '${percentage.toStringAsFixed(1)}%',
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h(context)),

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

    return Column(
      children: [
        PText.small(label, color: AppColors.textGray),
        SizedBox(height: 4.h(context)),
        PText.small(
          displayValue,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ],
    );
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
