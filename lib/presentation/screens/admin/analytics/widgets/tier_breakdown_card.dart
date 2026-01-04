import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_spacing.dart';
import '../../../../providers/analytics_provider.dart';

class TierBreakdownCard extends StatefulWidget {
  final AnalyticsData data;

  const TierBreakdownCard({super.key, required this.data});

  @override
  State<TierBreakdownCard> createState() => _TierBreakdownCardState();
}

class _TierBreakdownCardState extends State<TierBreakdownCard> {
  String? _selectedTier;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensure full width
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
              const Icon(Icons.people, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Breakdown per Tier',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.data.totalTransactions} transaksi',
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (widget.data.tierBreakdown.isNotEmpty) ...[
            // Use Column layout for better mobile experience
            _buildPieChart(),
            const SizedBox(height: 16),
            _buildTierList(),
            if (_selectedTier != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildTierDetails(_selectedTier!),
            ],
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Tidak ada data transaksi',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final sections = widget.data.tierBreakdown.entries.map((entry) {
      final tier = entry.value;
      final percentage = widget.data.totalOmset > 0
          ? (tier.totalOmset / widget.data.totalOmset) * 100
          : 0;

      return PieChartSectionData(
        color: _getTierColor(tier.tier),
        value: percentage.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: _selectedTier == tier.tier ? 60.0 : 50.0,
        titleStyle: TextStyle(
          fontSize: _selectedTier == tier.tier ? 12 : 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      width: double.infinity,
      height: 200, // Fixed height for consistency
      child: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (event is FlTapUpEvent &&
                      pieTouchResponse?.touchedSection != null) {
                    final index =
                        pieTouchResponse!.touchedSection!.touchedSectionIndex;
                    final tierEntry = widget.data.tierBreakdown.entries
                        .elementAt(index);
                    setState(() {
                      _selectedTier = _selectedTier == tierEntry.key
                          ? null
                          : tierEntry.key;
                    });
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTierList() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: widget.data.tierBreakdown.entries.map((entry) {
          final tier = entry.value;
          final isSelected = _selectedTier == tier.tier;

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTier = isSelected ? null : tier.tier;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: AppColors.primary)
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getTierColor(tier.tier),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tier.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textDark,
                            ),
                          ),
                          Text(
                            '${tier.transactionCount} transaksi',
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
                          _formatCurrency(tier.totalOmset),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textDark,
                          ),
                        ),
                        Text(
                          '${tier.marginPercent.toStringAsFixed(1)}% margin',
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
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTierDetails(String tierKey) {
    final tier = widget.data.tierBreakdown[tierKey]!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail ${tier.displayName}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Total Penjualan',
                  _formatCurrency(tier.totalOmset),
                  Icons.attach_money,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Total HPP',
                  _formatCurrency(tier.totalHpp),
                  Icons.inventory,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Profit',
                  _formatCurrency(tier.totalProfit),
                  Icons.trending_up,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Rata-rata/Transaksi',
                  _formatCurrency(tier.averageTransactionValue),
                  Icons.receipt,
                ),
              ),
            ],
          ),
          if (tier.paymentMethodBreakdown.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Metode Pembayaran:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              child: Column(
                children: tier.paymentMethodBreakdown.entries.map((entry) {
                  final percentage = tier.totalOmset > 0
                      ? (entry.value / tier.totalOmset) * 100
                      : 0;
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getPaymentMethodName(entry.key),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              _formatCurrency(entry.value),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${percentage.toStringAsFixed(1)}%)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textGray,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'UMUM':
        return AppColors.info;
      case 'BENGKEL':
        return AppColors.warning;
      case 'GROSSIR':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
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

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return 'Rp $amount';
    }
  }
}
