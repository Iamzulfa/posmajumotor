import 'package:flutter/material.dart';
import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_spacing.dart';
import '../../../../providers/analytics_provider.dart';

class PaymentMethodBreakdownCard extends StatefulWidget {
  final AnalyticsData data;

  const PaymentMethodBreakdownCard({super.key, required this.data});

  @override
  State<PaymentMethodBreakdownCard> createState() =>
      _PaymentMethodBreakdownCardState();
}

class _PaymentMethodBreakdownCardState
    extends State<PaymentMethodBreakdownCard> {
  String? _selectedMethod;

  @override
  Widget build(BuildContext context) {
    // Calculate percentages for payment methods
    final paymentWithPercentages = widget.data.paymentBreakdown.entries.map((
      entry,
    ) {
      final percentage = widget.data.totalOmset > 0
          ? (entry.value.totalAmount / widget.data.totalOmset) * 100
          : 0;
      return MapEntry(
        entry.key,
        PaymentMethodAnalytics(
          paymentMethod: entry.value.paymentMethod,
          transactionCount: entry.value.transactionCount,
          totalAmount: entry.value.totalAmount,
          percentage: percentage.toDouble(),
          averageTransactionValue: entry.value.averageTransactionValue,
        ),
      );
    }).toList();

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
              const Icon(Icons.payment, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Analisis Metode Pembayaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Text(
                _formatCurrency(widget.data.totalOmset),
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (paymentWithPercentages.isNotEmpty) ...[
            // Use Column layout for better mobile experience
            _buildBarChart(paymentWithPercentages),
            const SizedBox(height: 16),
            _buildPaymentList(paymentWithPercentages),
            if (_selectedMethod != null) ...[
              const SizedBox(height: AppSpacing.lg),
              _buildPaymentDetails(_selectedMethod!, paymentWithPercentages),
            ],
          ] else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Tidak ada data pembayaran',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    List<MapEntry<String, PaymentMethodAnalytics>> payments,
  ) {
    if (payments.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada data pembayaran',
          style: TextStyle(color: AppColors.textGray),
        ),
      );
    }

    final maxAmount = payments
        .map((e) => e.value.totalAmount)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      child: Column(
        children: payments.map((entry) {
          final payment = entry.value;
          final isSelected = _selectedMethod == payment.paymentMethod;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMethod = isSelected ? null : payment.paymentMethod;
              });
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        payment.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textDark,
                        ),
                      ),
                      Text(
                        '${payment.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: maxAmount > 0
                          ? payment.totalAmount / maxAmount
                          : 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getPaymentColor(
                                  payment.paymentMethod,
                                ).withValues(alpha: 0.8)
                              : _getPaymentColor(payment.paymentMethod),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            _formatCurrency(payment.totalAmount),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentList(
    List<MapEntry<String, PaymentMethodAnalytics>> payments,
  ) {
    return Container(
      width: double.infinity,
      child: Column(
        children: payments.map((entry) {
          final payment = entry.value;
          final isSelected = _selectedMethod == payment.paymentMethod;

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedMethod = isSelected ? null : payment.paymentMethod;
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
                        color: _getPaymentColor(payment.paymentMethod),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment.displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textDark,
                            ),
                          ),
                          Text(
                            '${payment.transactionCount} transaksi',
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
                          _formatCurrency(payment.totalAmount),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textDark,
                          ),
                        ),
                        Text(
                          '${payment.percentage.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
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

  Widget _buildPaymentDetails(
    String methodKey,
    List<MapEntry<String, PaymentMethodAnalytics>> payments,
  ) {
    final payment = payments.firstWhere((e) => e.key == methodKey).value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getPaymentColor(payment.paymentMethod).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getPaymentColor(payment.paymentMethod).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getPaymentIcon(payment.paymentMethod),
                color: _getPaymentColor(payment.paymentMethod),
              ),
              const SizedBox(width: 8),
              Text(
                'Detail ${payment.displayName}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _getPaymentColor(payment.paymentMethod),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Total Transaksi',
                  '${payment.transactionCount}',
                  Icons.receipt_long,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Total Nilai',
                  _formatCurrency(payment.totalAmount),
                  Icons.attach_money,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Persentase',
                  '${payment.percentage.toStringAsFixed(1)}%',
                  Icons.pie_chart,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Rata-rata/Transaksi',
                  _formatCurrency(payment.averageTransactionValue),
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPaymentInsights(payment),
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
            Icon(icon, size: 16, color: AppColors.textGray),
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

  Widget _buildPaymentInsights(PaymentMethodAnalytics payment) {
    String insight = '';
    Color insightColor = AppColors.info;
    IconData insightIcon = Icons.info;

    switch (payment.paymentMethod) {
      case 'CASH':
        if (payment.percentage > 60) {
          insight =
              'Dominasi pembayaran tunai tinggi. Pertimbangkan promosi cashless.';
          insightColor = AppColors.warning;
          insightIcon = Icons.warning;
        } else {
          insight = 'Pembayaran tunai dalam proporsi yang sehat.';
          insightColor = AppColors.success;
          insightIcon = Icons.check_circle;
        }
        break;
      case 'TRANSFER':
        if (payment.averageTransactionValue >
            widget.data.totalOmset / widget.data.totalTransactions * 1.5) {
          insight = 'Transfer digunakan untuk transaksi bernilai tinggi.';
          insightColor = AppColors.info;
          insightIcon = Icons.trending_up;
        } else {
          insight =
              'Transfer digunakan secara konsisten untuk berbagai nilai transaksi.';
          insightColor = AppColors.success;
          insightIcon = Icons.check_circle;
        }
        break;
      case 'QRIS':
        if (payment.percentage < 20) {
          insight =
              'Adopsi QRIS masih rendah. Pertimbangkan edukasi pelanggan.';
          insightColor = AppColors.warning;
          insightIcon = Icons.trending_down;
        } else {
          insight = 'Adopsi QRIS berkembang baik.';
          insightColor = AppColors.success;
          insightIcon = Icons.trending_up;
        }
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: insightColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: insightColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(insightIcon, color: insightColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              insight,
              style: TextStyle(
                fontSize: 12,
                color: insightColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPaymentColor(String method) {
    switch (method) {
      case 'CASH':
        return AppColors.success;
      case 'TRANSFER':
        return AppColors.info;
      case 'QRIS':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  IconData _getPaymentIcon(String method) {
    switch (method) {
      case 'CASH':
        return Icons.money;
      case 'TRANSFER':
        return Icons.account_balance;
      case 'QRIS':
        return Icons.qr_code;
      default:
        return Icons.payment;
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
