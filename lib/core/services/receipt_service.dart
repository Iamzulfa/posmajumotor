import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../data/models/transaction_model.dart';
import '../utils/receipt_pdf_generator.dart';
import '../utils/logger.dart';

/// Receipt Service for handling PDF generation, saving, and printing
class ReceiptService {
  /// Save receipt as PDF file
  static Future<File?> saveReceiptPdf(TransactionModel transaction) async {
    try {
      // Generate PDF
      final pdf = await ReceiptPdfGenerator.generateReceiptPdf(transaction);

      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'Receipt_${transaction.transactionNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      // Save PDF
      await file.writeAsBytes(await pdf.save());

      AppLogger.info('Receipt saved: ${file.path}');
      return file;
    } catch (e) {
      AppLogger.error('Error saving receipt PDF: $e');
      return null;
    }
  }

  /// Print receipt directly
  static Future<bool> printReceipt(TransactionModel transaction) async {
    try {
      // Generate PDF
      final pdf = await ReceiptPdfGenerator.generateReceiptPdf(transaction);

      // Print
      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: 'Receipt_${transaction.transactionNumber}',
      );

      AppLogger.info('Receipt printed: ${transaction.transactionNumber}');
      return true;
    } catch (e) {
      AppLogger.error('Error printing receipt: $e');
      return false;
    }
  }

  /// Share receipt PDF (opens share dialog)
  static Future<bool> shareReceipt(TransactionModel transaction) async {
    try {
      // Save PDF first
      final file = await saveReceiptPdf(transaction);

      if (file == null) {
        AppLogger.error('Failed to save receipt for sharing');
        return false;
      }

      // Share using native share
      await Printing.sharePdf(
        bytes: await file.readAsBytes(),
        filename: 'Receipt_${transaction.transactionNumber}.pdf',
      );

      AppLogger.info('Receipt shared: ${transaction.transactionNumber}');
      return true;
    } catch (e) {
      AppLogger.error('Error sharing receipt: $e');
      return false;
    }
  }
}
