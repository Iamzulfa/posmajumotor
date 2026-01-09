import 'package:flutter/material.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_spacing.dart';
import '../../../../providers/analytics_provider.dart';

class ProfitAnalysisCard extends StatefulWidget {
  final AnalyticsData data;

  const ProfitAnalysisCard({super.key, required this.data});

  @override
  State<ProfitAnalysisCard> createState() => _ProfitAnalysisCardState();
}

class _ProfitAnalysisCardState extends State<ProfitAnalysisCard> {
  bool _showNetProfit = true;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const Icon(Icons.analytics, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Analisis Profit & HPP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              ToggleButtons(
                isSelected: [!_showNetProfit, _showNetProfit],
                onPressed: (index) {
                  setState(() {
                    _showNetProfit = index == 1;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: AppColors.primary,
                color: AppColors.textGray,
                constraints: const BoxConstraints(minHeight: 32, minWidth: 60),
                children: const [
                  Text('Gross', style: TextStyle(fontSize: 12)),
                  Text('Net', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildProfitOverview(),
          const SizedBox(height: AppSpacing.lg),
          _buildProfitBreakdown(),
          const SizedBox(height: AppSpacing.lg),
          _buildHppAnalysis(),
        ],
      ),
    );
  }

  Widget _buildProfitOverview() {
    final grossProfit = widget.data.totalProfit;
    final netProfit = widget.data.netProfit;
    final displayProfit = _showNetProfit ? netProfit : grossProfit;
    final profitColor = displayProfit >= 0
        ? AppColors.success
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [profitColor.withOpacity(0.1), profitColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: profitColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _showNetProfit ? 'Laba Bersih' : 'Laba Kotor',
                    style: TextStyle(
                      fontSize: 14,
                      color: profitColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(displayProfit),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: profitColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: profitColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  displayProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: profitColor,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Margin',
                  '${widget.data.averageMargin.toStringAsFixed(1)}%',
                  Icons.percent,
                  widget.data.averageMargin >= 20
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(
                child: _buildMetricItem(
                  'Total Omset',
                  _formatCurrency(widget.data.totalOmset),
                  Icons.attach_money,
                  AppColors.info,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.border),
              Expanded(
                child: _buildMetricItem(
                  'Total HPP',
                  _formatCurrency(widget.data.totalHpp),
                  Icons.inventory,
                  AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfitBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Breakdown Profit per Tier',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.data.tierBreakdown.entries.map((entry) {
          final tier = entry.value;
          final profitPercentage = widget.data.totalProfit > 0
              ? (tier.totalProfit / widget.data.totalProfit) * 100
              : 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tier.displayName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatCurrency(tier.totalProfit),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${profitPercentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: widget.data.totalProfit > 0
                      ? (tier.totalProfit / widget.data.totalProfit)
                      : 0.0,
                  backgroundColor: AppColors.secondary,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getTierColor(tier.tier),
                  ),
                  minHeight: 6,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildHppAnalysis() {
    final hppRatio = widget.data.totalOmset > 0
        ? ((widget.data.totalHpp / widget.data.totalOmset) * 100).toDouble()
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Analisis HPP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rasio HPP terhadap Omset',
                      style: TextStyle(fontSize: 12, color: AppColors.textGray),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hppRatio.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: hppRatio <= 70
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Efisiensi HPP',
                      style: TextStyle(fontSize: 12, color: AppColors.textGray),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getHppEfficiencyText(hppRatio),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getHppEfficiencyColor(hppRatio),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: hppRatio / 100,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getHppEfficiencyColor(hppRatio),
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            _getHppRecommendation(hppRatio),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textGray,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textGray),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
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

  String _getHppEfficiencyText(double ratio) {
    if (ratio <= 50) return 'Sangat Baik';
    if (ratio <= 65) return 'Baik';
    if (ratio <= 75) return 'Cukup';
    return 'Perlu Perbaikan';
  }

  Color _getHppEfficiencyColor(double ratio) {
    if (ratio <= 50) return AppColors.success;
    if (ratio <= 65) return AppColors.info;
    if (ratio <= 75) return AppColors.warning;
    return AppColors.error;
  }

  String _getHppRecommendation(double ratio) {
    if (ratio <= 50) {
      return 'HPP sangat efisien. Pertahankan strategi procurement saat ini.';
    } else if (ratio <= 65) {
      return 'HPP dalam kondisi baik. Monitor terus untuk optimasi lebih lanjut.';
    } else if (ratio <= 75) {
      return 'HPP cukup tinggi. Pertimbangkan negosiasi dengan supplier.';
    } else {
      return 'HPP terlalu tinggi. Evaluasi ulang strategi procurement dan pricing.';
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
