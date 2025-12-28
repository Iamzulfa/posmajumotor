import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/services/receipt_service.dart';
import '../../../data/models/transaction_model.dart';
import 'receipt_widget.dart';

class PostTransactionReceiptModal extends StatefulWidget {
  final TransactionModel transaction;
  final VoidCallback onClose;
  final VoidCallback? onPrint;
  final VoidCallback? onShare;

  const PostTransactionReceiptModal({
    super.key,
    required this.transaction,
    required this.onClose,
    this.onPrint,
    this.onShare,
  });

  @override
  State<PostTransactionReceiptModal> createState() =>
      _PostTransactionReceiptModalState();
}

class _PostTransactionReceiptModalState
    extends State<PostTransactionReceiptModal> {
  bool _isPrinting = false;
  bool _isSharing = false;
  bool _isThermalSharing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: ResponsiveUtils.getResponsivePaddingCustom(
        context,
        phoneValue: 16,
        tabletValue: 32,
        desktopValue: 64,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context),
        ),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: ResponsiveUtils.getResponsivePaddingCustom(
                context,
                phoneValue: AppSpacing.md,
                tabletValue: AppSpacing.lg,
                desktopValue: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context),
                  ),
                  topRight: Radius.circular(
                    ResponsiveUtils.getResponsiveBorderRadius(context),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: ResponsiveUtils.getResponsiveIconSize(context),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transaksi Berhasil!',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              phoneSize: 16,
                              tabletSize: 18,
                              desktopSize: 20,
                            ),
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'No. ${widget.transaction.transactionNumber}',
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
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Receipt Content
            Expanded(
              child: SingleChildScrollView(
                padding: ResponsiveUtils.getResponsivePaddingCustom(
                  context,
                  phoneValue: AppSpacing.md,
                  tabletValue: AppSpacing.lg,
                  desktopValue: 16,
                ),
                child: ReceiptWidget(transaction: widget.transaction),
              ),
            ),

            // Action Buttons
            Container(
              padding: ResponsiveUtils.getResponsivePaddingCustom(
                context,
                phoneValue: AppSpacing.md,
                tabletValue: AppSpacing.lg,
                desktopValue: 16,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  // Primary Actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.print,
                          label: 'Cetak',
                          onPressed: _isPrinting ? null : _handlePrint,
                          isPrimary: true,
                          isLoading: _isPrinting,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.share,
                          label: 'Bagikan',
                          onPressed: _isSharing ? null : _handleShare,
                          isPrimary: true,
                          isLoading: _isSharing,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  // Thermal Receipt Actions
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.receipt,
                          label: 'Struk Thermal',
                          onPressed: _handleThermalPrint,
                          isPrimary: true,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildActionButton(
                          context,
                          icon: Icons.share,
                          label: 'Share Thermal',
                          onPressed: _isThermalSharing
                              ? null
                              : _handleThermalShare,
                          isPrimary: true,
                          isLoading: _isThermalSharing,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveUtils.getResponsiveButtonHeight(context),
                    child: ElevatedButton(
                      onPressed: widget.onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.background,
                        foregroundColor: AppColors.textDark,
                        side: BorderSide(color: AppColors.border),
                      ),
                      child: Text(
                        'Tutup',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            phoneSize: 14,
                            tabletSize: 16,
                            desktopSize: 18,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    return SizedBox(
      height: ResponsiveUtils.getResponsiveButtonHeight(context),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary ? Colors.white : AppColors.textDark,
                  ),
                ),
              )
            : Icon(icon),
        label: Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              phoneSize: 14,
              tabletSize: 16,
              desktopSize: 18,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : AppColors.secondary,
          foregroundColor: isPrimary ? Colors.white : AppColors.textDark,
        ),
      ),
    );
  }

  Future<void> _handlePrint() async {
    setState(() => _isPrinting = true);

    try {
      final success = await ReceiptService.printReceipt(widget.transaction);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Struk berhasil dicetak'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mencetak struk'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }

    widget.onPrint?.call();
  }

  Future<void> _handleShare() async {
    setState(() => _isSharing = true);

    try {
      final success = await ReceiptService.shareReceipt(widget.transaction);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Struk siap dibagikan'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal membagikan struk'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }

    widget.onShare?.call();
  }

  Future<void> _handleThermalPrint() async {
    if (!mounted) return;

    // Navigate to thermal receipt screen
    Navigator.pop(context); // Close modal first

    // Import needed at top: import '../../screens/admin/transaction/receipt_screen.dart';
    // This will be handled by the transaction screen
  }

  Future<void> _handleThermalShare() async {
    setState(() => _isThermalSharing = true);

    try {
      final pdfBytes = await _generateThermalPdf();
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/struk_${widget.transaction.transactionNumber}.pdf',
      );
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles([
        XFile(file.path, mimeType: 'application/pdf'),
      ], text: 'Struk Nota - ${widget.transaction.transactionNumber}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isThermalSharing = false);
      }
    }
  }

  Future<Uint8List> _generateThermalPdf() async {
    final pdf = pw.Document();
    final items = widget.transaction.items ?? [];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(5),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header
              pw.Text(
                'TOKO SUKU CADANG',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Transaction Info
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPdfInfoRow(
                    'No. Transaksi:',
                    widget.transaction.transactionNumber,
                  ),
                  _buildPdfInfoRow(
                    'Tanggal:',
                    _formatDate(widget.transaction.createdAt),
                  ),
                  _buildPdfInfoRow('Tier:', widget.transaction.tier),
                  if (widget.transaction.customerName != null)
                    _buildPdfInfoRow(
                      'Pelanggan:',
                      widget.transaction.customerName!,
                    ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Items Table
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          'Item',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          'Qty',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          'Harga',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(2),
                        child: pw.Text(
                          'Total',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Items
                  ...items.map((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            item.productName,
                            style: const pw.TextStyle(fontSize: 9),
                            maxLines: 1,
                            overflow: pw.TextOverflow.clip,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            '${item.quantity}',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            _formatCurrency(item.unitPrice),
                            textAlign: pw.TextAlign.right,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(2),
                          child: pw.Text(
                            _formatCurrency(item.subtotal),
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Totals
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildPdfTotalRow('Subtotal:', widget.transaction.subtotal),
                  if (widget.transaction.discountAmount > 0)
                    _buildPdfTotalRow(
                      'Diskon:',
                      -widget.transaction.discountAmount,
                    ),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(width: 1),
                        bottom: pw.BorderSide(width: 1),
                      ),
                    ),
                    child: _buildPdfTotalRow(
                      'TOTAL:',
                      widget.transaction.total,
                      isBold: true,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Payment Info
              _buildPdfInfoRow(
                'Metode Bayar:',
                widget.transaction.paymentMethod,
              ),
              _buildPdfInfoRow('Status:', widget.transaction.paymentStatus),
              pw.SizedBox(height: 12),

              // Footer
              pw.Text(
                'Terima Kasih',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Semoga Puas dengan Layanan Kami',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                _formatDateTime(DateTime.now()),
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        pw.Expanded(
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfTotalRow(
    String label,
    int amount, {
    bool isBold = false,
    double fontSize = 10,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          _formatCurrency(amount),
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
}

/// Show post-transaction receipt modal
Future<void> showPostTransactionReceiptModal(
  BuildContext context, {
  required TransactionModel transaction,
  VoidCallback? onPrint,
  VoidCallback? onShare,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PostTransactionReceiptModal(
      transaction: transaction,
      onClose: () => Navigator.pop(context),
      onPrint: onPrint,
      onShare: onShare,
    ),
  );
}
