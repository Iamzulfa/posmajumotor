import 'package:posfelix/data/models/models.dart';

/// Dashboard Repository Interface
abstract class DashboardRepository {
  // ============================================
  // FUTURE METHODS (One-time fetch)
  // ============================================

  /// Get dashboard data for today
  Future<DashboardData> getDashboardData();

  /// Get dashboard data for specific date range
  Future<DashboardData> getDashboardDataForRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get profit indicator data
  Future<ProfitIndicator> getProfitIndicator({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get tax indicator data
  Future<TaxIndicator> getTaxIndicator({required int month, required int year});

  // ============================================
  // STREAM METHODS (Real-time updates)
  // ============================================

  /// Stream dashboard data with real-time updates
  Stream<DashboardData> getDashboardDataStream();

  /// Stream dashboard data for date range with real-time updates
  Stream<DashboardData> getDashboardDataStreamForRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Stream profit indicator with real-time updates
  Stream<ProfitIndicator> getProfitIndicatorStream({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Stream tax indicator with real-time updates
  Stream<TaxIndicator> getTaxIndicatorStream({
    required int month,
    required int year,
  });
}

/// Dashboard data model
class DashboardData {
  final int totalTransactions;
  final int totalOmset;
  final int totalProfit;
  final int totalExpenses;
  final int averageTransaction;
  final Map<String, int> tierBreakdown; // UMUM, BENGKEL, GROSSIR
  final Map<String, int> paymentMethodBreakdown;
  final List<TransactionModel>? recentTransactions;

  DashboardData({
    required this.totalTransactions,
    required this.totalOmset,
    required this.totalProfit,
    required this.totalExpenses,
    required this.averageTransaction,
    required this.tierBreakdown,
    required this.paymentMethodBreakdown,
    this.recentTransactions,
  });
}

/// Profit indicator for dashboard
class ProfitIndicator {
  final int grossProfit; // omset - hpp
  final int netProfit; // omset - hpp - expenses
  final double profitMargin; // (profit / omset) * 100
  final int totalOmset;
  final int totalHpp;
  final int totalExpenses;

  ProfitIndicator({
    required this.grossProfit,
    required this.netProfit,
    required this.profitMargin,
    required this.totalOmset,
    required this.totalHpp,
    required this.totalExpenses,
  });
}

/// Tax indicator for dashboard
class TaxIndicator {
  final int month;
  final int year;
  final int totalOmset;
  final int taxAmount; // 0.5% of omset
  final bool isPaid;
  final DateTime? paidAt;

  TaxIndicator({
    required this.month,
    required this.year,
    required this.totalOmset,
    required this.taxAmount,
    required this.isPaid,
    this.paidAt,
  });
}
