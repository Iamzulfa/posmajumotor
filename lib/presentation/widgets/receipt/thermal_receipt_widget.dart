import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_item_model.dart';

/// Thermal Receipt Widget - 80mm width for thermal printer
/// Designed for 80mm thermal printer (384 pixels at 203 DPI)
class ThermalReceiptWidget extends StatelessWidget {
  final TransactionModel transaction;
  final List<TransactionItemModel> items;
  final String storeName;
  final String? storeAddress;
  final String? storePhone;

  const ThermalReceiptWidget({
    super.key,
    required this.transaction,
    required this.items,
    required this.storeName,
    this.storeAddress,
    this.storePhone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // 80mm ≈ 300px at standard DPI
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 8),
            _buildDivider(),
            const SizedBox(height: 8),

            // Transaction Info
            _buildTransactionInfo(),
            const SizedBox(height: 8),
            _buildDivider(),
            const SizedBox(height: 8),

            // Items
            _buildItems(),
            const SizedBox(height: 8),
            _buildDivider(),
            const SizedBox(height: 8),

            // Totals
            _buildTotals(),
            const SizedBox(height: 8),
            _buildDivider(),
            const SizedBox(height: 8),

            // Payment Info
            _buildPaymentInfo(),
            const SizedBox(height: 12),

            // Footer
            _buildFooter(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          storeName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        if (storeAddress != null) ...[
          const SizedBox(height: 2),
          Text(
            storeAddress!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
          ),
        ],
        if (storePhone != null) ...[
          const SizedBox(height: 2),
          Text(
            storePhone!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: Colors.black);
  }

  Widget _buildTransactionInfo() {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final formattedDate = transaction.createdAt != null
        ? dateFormat.format(transaction.createdAt!)
        : 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('No. Transaksi:', transaction.transactionNumber),
        _buildInfoRow('Tanggal:', formattedDate),
        _buildInfoRow('Tier:', transaction.tier),
        if (transaction.customerName != null &&
            transaction.customerName!.isNotEmpty)
          _buildInfoRow('Pelanggan:', transaction.customerName!),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 10)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                'Item',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                'Qty',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Harga',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'Total',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Items
        ...items.map((item) => _buildItemRow(item)),
      ],
    );
  }

  Widget _buildItemRow(TransactionItemModel item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  item.productName,
                  style: const TextStyle(fontSize: 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${item.quantity}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  _formatCurrency(item.unitPrice),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 9),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  _formatCurrency(item.subtotal),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTotalRow('Subtotal:', transaction.subtotal),
        if (transaction.discountAmount > 0)
          _buildTotalRow('Diskon:', -transaction.discountAmount),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(width: 1),
              bottom: BorderSide(width: 1),
            ),
          ),
          child: _buildTotalRow(
            'TOTAL:',
            transaction.total,
            isBold: true,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(
    String label,
    int amount, {
    bool isBold = false,
    double fontSize = 10,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Metode Bayar:', transaction.paymentMethod),
        _buildInfoRow('Status:', transaction.paymentStatus),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Text(
          'Terima Kasih',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Semoga Puas dengan Layanan Kami',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 9),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    final absAmount = amount.abs();
    if (absAmount >= 1000000) {
      return 'Rp ${(absAmount / 1000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000) {
      return 'Rp ${(absAmount / 1000).toStringAsFixed(0)}K';
    }
    return 'Rp $absAmount';
  }
}
