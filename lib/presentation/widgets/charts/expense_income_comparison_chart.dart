import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';

/// Expense vs Income Comparison Chart Widget
class ExpenseIncomeComparisonChart extends StatelessWidget {
  final int totalIncome;
  final int totalExpense;
  final String period; // "Hari Ini", "Minggu Ini", "Bulan Ini"

  const ExpenseIncomeComparisonChart({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final profit = totalIncome - totalExpense;
    final maxValue = [
      totalIncome,
      totalExpense,
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            'Perbandingan Pendapatan & Pengeluaran',
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
          SizedBox(height: AppSpacing.xs),
          Text(
            period,
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
          SizedBox(height: AppSpacing.lg),

          // Simple Bar Chart
          _buildSimpleBarChart(context, maxValue),
          SizedBox(height: AppSpacing.lg),

          // Summary Cards - Now in vertical stack
          Column(
            children: [
              _buildSummaryCard(
                context,
                'Pendapatan',
                totalIncome,
                AppColors.success,
              ),
              SizedBox(height: AppSpacing.md),
              _buildSummaryCard(
                context,
                'Pengeluaran',
                totalExpense,
                AppColors.error,
              ),
              SizedBox(height: AppSpacing.md),
              _buildSummaryCard(
                context,
                'Profit',
                profit,
                profit >= 0 ? AppColors.primary : AppColors.error,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // Advanced Metrics & Trends
          _buildAdvancedMetrics(context, profit),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart(BuildContext context, int maxValue) {
    final incomePercent = maxValue > 0 ? (totalIncome / maxValue) : 0.0;
    final expensePercent = maxValue > 0 ? (totalExpense / maxValue) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Income Bar
        Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                'Pendapatan',
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
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: incomePercent,
                  minHeight: 24,
                  backgroundColor: AppColors.secondary,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 80,
              child: Text(
                'Rp ${_formatShortNumber(totalIncome)}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    phoneSize: 12,
                    tabletSize: 13,
                    desktopSize: 14,
                  ),
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),

        // Expense Bar
        Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                'Pengeluaran',
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
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: expensePercent,
                  minHeight: 24,
                  backgroundColor: AppColors.secondary,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 80,
              child: Text(
                'Rp ${_formatShortNumber(totalExpense)}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    phoneSize: 12,
                    tabletSize: 13,
                    desktopSize: 14,
                  ),
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    int amount,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: 16,
        tabletValue: 18,
        desktopValue: 20,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context) * 1.2,
        ),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getIconForLabel(label), color: color, size: 24),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 14,
                      tabletSize: 15,
                      desktopSize: 16,
                    ),
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Rp ${_formatNumber(amount)}',
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
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Pendapatan':
        return Icons.trending_up;
      case 'Pengeluaran':
        return Icons.trending_down;
      case 'Profit':
        return Icons.account_balance_wallet;
      default:
        return Icons.monetization_on;
    }
  }

  Widget _buildAdvancedMetrics(BuildContext context, int profit) {
    final expenseRatio = (totalIncome > 0
        ? (totalExpense / totalIncome * 100).toDouble()
        : 0.0);
    final profitMargin = ((profit / (totalIncome > 0 ? totalIncome : 1)) * 100)
        .toDouble();
    final roi = ((profit / (totalExpense > 0 ? totalExpense : 1)) * 100)
        .toDouble();
    final efficiency = (100 - expenseRatio);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Metrics Grid - Changed to vertical stack
        Column(
          children: [
            _buildMetricCard(
              context,
              'Expense Ratio',
              '${expenseRatio.toStringAsFixed(1)}%',
              _getExpenseRatioColor(expenseRatio),
              Icons.pie_chart,
            ),
            SizedBox(height: AppSpacing.md),
            _buildMetricCard(
              context,
              'Profit Margin',
              '${profitMargin.toStringAsFixed(1)}%',
              _getProfitMarginColor(profitMargin),
              Icons.trending_up,
            ),
            SizedBox(height: AppSpacing.md),
            _buildMetricCard(
              context,
              'ROI',
              '${roi.toStringAsFixed(1)}%',
              _getROIColor(roi),
              Icons.trending_up,
            ),
            SizedBox(height: AppSpacing.md),
            _buildMetricCard(
              context,
              'Efficiency',
              '${efficiency.toStringAsFixed(1)}%',
              _getEfficiencyColor(efficiency),
              Icons.speed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: 16,
        tabletValue: 18,
        desktopValue: 20,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context) * 1.2,
        ),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 13,
                      tabletSize: 14,
                      desktopSize: 15,
                    ),
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 16,
                      tabletSize: 18,
                      desktopSize: 20,
                    ),
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Color helpers for each metric with distinct colors
  Color _getExpenseRatioColor(double ratio) {
    if (ratio <= 20) return const Color(0xFF10B981); // Dark green - excellent
    if (ratio <= 35) return const Color(0xFF3B82F6); // Blue - good
    if (ratio <= 50) return const Color(0xFFF59E0B); // Amber - warning
    return const Color(0xFFEF4444); // Red - critical
  }

  Color _getProfitMarginColor(double margin) {
    if (margin >= 60) return const Color(0xFF059669); // Emerald - excellent
    if (margin >= 40) return const Color(0xFF0891B2); // Cyan - good
    if (margin >= 20) return const Color(0xFF8B5CF6); // Violet - fair
    return const Color(0xFFDC2626); // Dark red - poor
  }

  Color _getROIColor(double roi) {
    if (roi >= 200) return const Color(0xFF7C3AED); // Indigo - excellent
    if (roi >= 100) return const Color(0xFF06B6D4); // Cyan - good
    if (roi >= 50) return const Color(0xFF14B8A6); // Teal - fair
    return const Color(0xFFEA580C); // Orange - poor
  }

  Color _getEfficiencyColor(double efficiency) {
    if (efficiency >= 80) return const Color(0xFF4F46E5); // Indigo - excellent
    if (efficiency >= 65) return const Color(0xFF2563EB); // Blue - good
    if (efficiency >= 50) return const Color(0xFF7C3AED); // Violet - fair
    return const Color(0xFFDC2626); // Red - poor
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
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
}
