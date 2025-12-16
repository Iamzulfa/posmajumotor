import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:posfelix/domain/repositories/tax_repository.dart';
import 'package:posfelix/core/utils/logger.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// PDF Generator Service untuk laporan keuangan
class PdfGenerator {
  /// Generate PDF untuk profit/loss report
  static Future<void> generateProfitLossReport({
    required ProfitLossReport report,
    required String businessName,
  }) async {
    try {
      // Initialize locale data for Indonesian formatting
      await initializeDateFormatting('id_ID', null);

      final pdf = pw.Document();

      // Format currency
      final currencyFormat = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

      // Format month/year
      final monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final monthName = monthNames[report.month - 1];
      final periodStr = '$monthName ${report.year}';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        businessName,
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Laporan Laba/Rugi',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Periode: $periodStr',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Summary Section
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(5),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RINGKASAN KEUANGAN',
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      _buildSummaryRow(
                        'Total Penjualan (Omset)',
                        currencyFormat.format(report.totalOmset),
                      ),
                      pw.SizedBox(height: 5),
                      _buildSummaryRow(
                        'Total HPP',
                        currencyFormat.format(report.totalHpp),
                      ),
                      pw.SizedBox(height: 5),
                      _buildSummaryRow(
                        'Laba Kotor',
                        currencyFormat.format(report.grossProfit),
                      ),
                      pw.SizedBox(height: 5),
                      _buildSummaryRow(
                        'Total Pengeluaran',
                        currencyFormat.format(report.totalExpenses),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Divider(color: PdfColors.grey400),
                      pw.SizedBox(height: 5),
                      _buildSummaryRow(
                        'LABA BERSIH',
                        currencyFormat.format(report.netProfit),
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Tier Breakdown Section
                pw.Text(
                  'BREAKDOWN PER TIER',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildTierTable(report, currencyFormat),
                pw.SizedBox(height: 20),

                // Footer
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Laporan ini dibuat secara otomatis oleh sistem PosFELIX',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                ),
              ],
            );
          },
        ),
      );

      // Print/Save PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'Laporan_Laba_Rugi_${report.month}_${report.year}.pdf',
      );

      AppLogger.info('PDF generated successfully');
    } catch (e) {
      AppLogger.error('Error generating PDF', e);
      rethrow;
    }
  }

  /// Build summary row
  static pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// Build tier breakdown table
  static pw.Widget _buildTierTable(
    ProfitLossReport report,
    NumberFormat currencyFormat,
  ) {
    final tiers = report.tierBreakdown.entries.toList();

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Tier', isBold: true),
            _buildTableCell(
              'Transaksi',
              isBold: true,
              align: pw.TextAlign.center,
            ),
            _buildTableCell('Omset', isBold: true, align: pw.TextAlign.right),
            _buildTableCell('HPP', isBold: true, align: pw.TextAlign.right),
            _buildTableCell('Laba', isBold: true, align: pw.TextAlign.right),
          ],
        ),
        // Data rows
        ...tiers.map((entry) {
          final tier = entry.value;

          return pw.TableRow(
            children: [
              _buildTableCell(_getTierDisplayName(entry.key)),
              _buildTableCell(
                tier.transactionCount.toString(),
                align: pw.TextAlign.center,
              ),
              _buildTableCell(
                currencyFormat.format(tier.omset),
                align: pw.TextAlign.right,
              ),
              _buildTableCell(
                currencyFormat.format(tier.hpp),
                align: pw.TextAlign.right,
              ),
              _buildTableCell(
                currencyFormat.format(tier.profit),
                align: pw.TextAlign.right,
              ),
            ],
          );
        }),
        // Total row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('TOTAL', isBold: true),
            _buildTableCell(
              tiers
                  .fold<int>(0, (sum, e) => sum + e.value.transactionCount)
                  .toString(),
              isBold: true,
              align: pw.TextAlign.center,
            ),
            _buildTableCell(
              currencyFormat.format(report.totalOmset),
              isBold: true,
              align: pw.TextAlign.right,
            ),
            _buildTableCell(
              currencyFormat.format(report.totalHpp),
              isBold: true,
              align: pw.TextAlign.right,
            ),
            _buildTableCell(
              currencyFormat.format(report.grossProfit),
              isBold: true,
              align: pw.TextAlign.right,
            ),
          ],
        ),
      ],
    );
  }

  /// Build table cell
  static pw.Widget _buildTableCell(
    String text, {
    bool isBold = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Get tier display name
  static String _getTierDisplayName(String tier) {
    switch (tier) {
      case 'UMUM':
        return 'Umum';
      case 'BENGKEL':
        return 'Bengkel';
      case 'GROSSIR':
        return 'Grossir';
      default:
        return tier;
    }
  }
}
