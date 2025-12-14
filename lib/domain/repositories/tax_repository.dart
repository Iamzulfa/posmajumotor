import 'package:posfelix/data/models/models.dart';

/// Tax Repository Interface
abstract class TaxRepository {
  /// Get tax payment for specific period
  Future<TaxPaymentModel?> getTaxPayment({
    required int month,
    required int year,
  });

  /// Get all tax payments
  Future<List<TaxPaymentModel>> getTaxPayments({int? year, int? limit});

  /// Calculate tax for period (0.5% of omset)
  Future<TaxCalculation> calculateTax({required int month, required int year});

  /// Mark tax as paid
  Future<TaxPaymentModel> markAsPaid({
    required int month,
    required int year,
    String? paymentProof,
  });

  /// Get profit/loss report for period
  Future<ProfitLossReport> getProfitLossReport({
    required int month,
    required int year,
  });
}

/// Tax calculation result
class TaxCalculation {
  final int month;
  final int year;
  final int totalOmset;
  final int taxAmount; // 0.5% of omset
  final bool isPaid;

  TaxCalculation({
    required this.month,
    required this.year,
    required this.totalOmset,
    required this.taxAmount,
    required this.isPaid,
  });
}

/// Profit/Loss report for tax center
class ProfitLossReport {
  final int month;
  final int year;
  final int totalOmset;
  final int totalHpp;
  final int totalExpenses;
  final int grossProfit; // omset - hpp
  final int netProfit; // omset - hpp - expenses
  final Map<String, TierReportDetail> tierBreakdown;

  ProfitLossReport({
    required this.month,
    required this.year,
    required this.totalOmset,
    required this.totalHpp,
    required this.totalExpenses,
    required this.grossProfit,
    required this.netProfit,
    required this.tierBreakdown,
  });
}

/// Detail per tier for report
class TierReportDetail {
  final String tier;
  final int transactionCount;
  final int omset;
  final int hpp;
  final int profit;

  TierReportDetail({
    required this.tier,
    required this.transactionCount,
    required this.omset,
    required this.hpp,
    required this.profit,
  });
}
