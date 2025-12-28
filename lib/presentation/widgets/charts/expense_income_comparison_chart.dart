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

          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Pendapatan',
                  totalIncome,
                  AppColors.success,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Pengeluaran',
                  totalExpense,
                  AppColors.error,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Profit',
                  profit,
                  profit >= 0 ? AppColors.primary : AppColors.error,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

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
      padding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: AppSpacing.md,
        tabletValue: AppSpacing.lg,
        desktopValue: 16,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
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
          SizedBox(height: AppSpacing.xs),
          Text(
            'Rp ${_formatNumber(amount)}',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                phoneSize: 14,
                tabletSize: 16,
                desktopSize: 18,
              ),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
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
        // Metrics Grid
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Expense Ratio',
                '${expenseRatio.toStringAsFixed(1)}%',
                _getExpenseRatioColor(expenseRatio),
                Icons.pie_chart,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMetricCard(
                context,
                'Profit Margin',
                '${profitMargin.toStringAsFixed(1)}%',
                _getProfitMarginColor(profitMargin),
                Icons.trending_up,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),

        // ROI & Efficiency
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'ROI',
                '${roi.toStringAsFixed(1)}%',
                _getROIColor(roi),
                Icons.trending_up,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMetricCard(
                context,
                'Efficiency',
                '${efficiency.toStringAsFixed(1)}%',
                _getEfficiencyColor(efficiency),
                Icons.speed,
              ),
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
      padding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: AppSpacing.md,
        tabletValue: AppSpacing.lg,
        desktopValue: 16,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      phoneSize: 11,
                      tabletSize: 12,
                      desktopSize: 13,
                    ),
                    color: AppColors.textGray,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
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
