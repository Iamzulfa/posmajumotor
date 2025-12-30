import 'package:flutter/material.dart';
import '../../../config/theme/app_spacing.dart';

class DailyExpenseMetricsWidget extends StatelessWidget {
  final int totalExpense;
  final int totalIncome;

  const DailyExpenseMetricsWidget({
    super.key,
    required this.totalExpense,
    required this.totalIncome,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate metrics
    final profit = totalIncome - totalExpense;
    final expenseRatio = totalIncome > 0
        ? (totalExpense / totalIncome) * 100
        : 0;
    final profitMargin = totalIncome > 0 ? (profit / totalIncome) * 100 : 0;
    final roi = totalExpense > 0 ? (profit / totalExpense) * 100 : 0;
    final efficiency = totalIncome > 0
        ? ((totalIncome - totalExpense) / totalIncome) * 100
        : 0;

    return Column(
      children: [
        // Pengeluaran Card
        _buildMetricCard(
          title: 'Pengeluaran',
          value: 'Rp ${_formatNumber(totalExpense)}',
          icon: Icons.trending_down,
          color: const Color(0xFFFFE5E5), // Light red background
          iconColor: const Color(0xFFE53E3E), // Red icon
          valueColor: const Color(0xFFE53E3E), // Red text
        ),
        const SizedBox(height: AppSpacing.sm),

        // Profit Card
        _buildMetricCard(
          title: 'Profit',
          value: 'Rp ${profit >= 0 ? '' : '-'}${_formatNumber(profit.abs())}',
          icon: Icons.account_balance_wallet,
          color: profit >= 0
              ? const Color(0xFFE6FFFA)
              : const Color(0xFFFFE5E5), // Light green or red
          iconColor: profit >= 0
              ? const Color(0xFF38A169)
              : const Color(0xFFE53E3E), // Green or red icon
          valueColor: profit >= 0
              ? const Color(0xFF38A169)
              : const Color(0xFFE53E3E), // Green or red text
        ),
        const SizedBox(height: AppSpacing.sm),

        // Expense Ratio Card
        _buildMetricCard(
          title: 'Expense Ratio',
          value: '${expenseRatio.toStringAsFixed(1)}%',
          icon: Icons.pie_chart,
          color: const Color(0xFFFFF5E6), // Light orange background
          iconColor: const Color(0xFFDD6B20), // Orange icon
          valueColor: const Color(0xFFDD6B20), // Orange text
        ),
        const SizedBox(height: AppSpacing.sm),

        // Profit Margin Card
        _buildMetricCard(
          title: 'Profit Margin',
          value:
              '${profitMargin >= 0 ? '' : '-'}${profitMargin.abs().toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: profitMargin >= 0
              ? const Color(0xFFE6FFFA)
              : const Color(0xFFFFE5E5), // Light green or red
          iconColor: profitMargin >= 0
              ? const Color(0xFF38A169)
              : const Color(0xFFE53E3E), // Green or red icon
          valueColor: profitMargin >= 0
              ? const Color(0xFF38A169)
              : const Color(0xFFE53E3E), // Green or red text
        ),
        const SizedBox(height: AppSpacing.sm),

        // ROI Card
        _buildMetricCard(
          title: 'ROI',
          value: '${roi >= 0 ? '' : '-'}${roi.abs().toStringAsFixed(1)}%',
          icon: Icons.show_chart,
          color: const Color(0xFFEBF8FF), // Light blue background
          iconColor: const Color(0xFF3182CE), // Blue icon
          valueColor: roi >= 0
              ? const Color(0xFF38A169)
              : const Color(0xFFE53E3E), // Green or red text
        ),
        const SizedBox(height: AppSpacing.sm),

        // Efficiency Card
        _buildMetricCard(
          title: 'Efficiency',
          value:
              '${efficiency >= 0 ? '' : '-'}${efficiency.abs().toStringAsFixed(1)}%',
          icon: Icons.speed,
          color: efficiency >= 0
              ? const Color(0xFFE6FFFA)
              : const Color(0xFFFFE5E5), // Light green or red
          iconColor: efficiency >= 0
              ? const Color(0xFF38A169)
              : const Color(0xFFE53E3E), // Green or red icon
          valueColor: efficiency >= 0
              ? const Color(0xFF38A169)
              : const Color(0xFFE53E3E), // Green or red text
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 80, maxHeight: 120),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
}
