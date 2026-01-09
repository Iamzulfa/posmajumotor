import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/expense_model.dart';
import '../../../providers/transaction_provider.dart';

/// Show transaction detail modal
Future<void> showTransactionDetailModal(
  BuildContext context, {
  required String transactionId,
  VoidCallback? onRefund,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TransactionDetailModal(
      transactionId: transactionId,
      onRefund: onRefund,
    ),
  );
}

/// Show expense detail modal
Future<void> showExpenseDetailModal(
  BuildContext context, {
  required ExpenseModel expense,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ExpenseDetailModal(expense: expense),
  );
}

class TransactionDetailModal extends ConsumerWidget {
  final String transactionId;
  final VoidCallback? onRefund;

  const TransactionDetailModal({
    super.key,
    required this.transactionId,
    this.onRefund,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(
      transactionDetailProvider(transactionId),
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: transactionAsync.when(
        data: (transaction) {
          if (transaction == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Transaksi tidak ditemukan'),
              ),
            );
          }
          return _buildContent(context, transaction);
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Error: $e'),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TransactionModel transaction) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Transaksi',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.transactionNumber,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: transaction.isRefunded
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  transaction.isRefunded ? 'REFUNDED' : 'COMPLETED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: transaction.isRefunded
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Content
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction info
                _buildInfoSection(transaction),
                const SizedBox(height: 20),
                // Items
                _buildItemsSection(transaction),
                const SizedBox(height: 20),
                // Totals
                _buildTotalsSection(transaction),
                const SizedBox(height: 20),
                // Actions
                if (!transaction.isRefunded)
                  _buildActionsSection(context, transaction),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(TransactionModel transaction) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow('Tanggal', transaction.formattedDate),
          _buildInfoRow('Waktu', transaction.formattedTime),
          _buildInfoRow('Tier', _getTierDisplayName(transaction.tier)),
          if (transaction.customerName != null)
            _buildInfoRow('Pelanggan', transaction.customerName!),
          _buildInfoRow(
            'Metode Bayar',
            _getPaymentMethodName(transaction.paymentMethod),
          ),
          if (transaction.cashier != null)
            _buildInfoRow('Kasir', transaction.cashier!.fullName),
          if (transaction.notes != null && transaction.notes!.isNotEmpty)
            _buildInfoRow('Catatan', transaction.notes!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textGray),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(TransactionModel transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Pembelian',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        if (transaction.items != null && transaction.items!.isNotEmpty)
          ...transaction.items!.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (item.productSku != null)
                          Text(
                            'SKU: ${item.productSku}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textGray,
                            ),
                          ),
                        Text(
                          '${item.quantity} x ${CurrencyFormatter.formatFull(item.unitPrice)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatFull(item.subtotal),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Tidak ada detail item',
                style: TextStyle(color: AppColors.textGray),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTotalsSection(TransactionModel transaction) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', transaction.subtotal),
          if (transaction.discountAmount > 0)
            _buildTotalRow(
              'Diskon',
              -transaction.discountAmount,
              isNegative: true,
            ),
          const Divider(),
          _buildTotalRow(
            'Total',
            transaction.total,
            isBold: true,
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    int amount, {
    bool isBold = false,
    bool isLarge = false,
    bool isNegative = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 15 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: AppColors.textDark,
            ),
          ),
          Text(
            '${isNegative ? "-" : ""}${CurrencyFormatter.formatFull(amount.abs())}',
            style: TextStyle(
              fontSize: isLarge ? 16 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isNegative ? AppColors.error : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    TransactionModel transaction,
  ) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            // Print button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement print
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.print, size: 18),
                label: const Text('Cetak'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Refund button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onRefund?.call();
                },
                icon: const Icon(Icons.replay, size: 18),
                label: const Text('Refund'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
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
}

/// Modal for expense detail
class ExpenseDetailModal extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseDetailModal({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_upward, color: AppColors.error),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Pengeluaran',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        expense.categoryDisplayName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Tanggal',
                        _formatDate(expense.expenseDate),
                      ),
                      _buildInfoRow('Kategori', expense.categoryDisplayName),
                      if (expense.description != null)
                        _buildInfoRow('Deskripsi', expense.description!),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pengeluaran',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatFull(expense.amount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textGray),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
