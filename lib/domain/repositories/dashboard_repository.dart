import 'package:hive/hive.dart';
import 'package:posfelix/data/models/models.dart';

part 'dashboard_repository.g.dart';

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
@HiveType(typeId: 20)
class DashboardData {
  @HiveField(0)
  final int totalTransactions;

  @HiveField(1)
  final int totalOmset;

  @HiveField(2)
  final int totalProfit;

  @HiveField(3)
  final int totalExpenses;

  @HiveField(4)
  final int averageTransaction;

  @HiveField(5)
  final Map<String, int> tierBreakdown; // UMUM, BENGKEL, GROSSIR

  @HiveField(6)
  final Map<String, int> paymentMethodBreakdown;

  @HiveField(7)
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
@HiveType(typeId: 21)
class ProfitIndicator {
  @HiveField(0)
  final int grossProfit; // omset - hpp

  @HiveField(1)
  final int netProfit; // omset - hpp - expenses

  @HiveField(2)
  final double profitMargin; // (profit / omset) * 100

  @HiveField(3)
  final int totalOmset;

  @HiveField(4)
  final int totalHpp;

  @HiveField(5)
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
@HiveType(typeId: 22)
class TaxIndicator {
  @HiveField(0)
  final int month;

  @HiveField(1)
  final int year;

  @HiveField(2)
  final int totalOmset;

  @HiveField(3)
  final int taxAmount; // 0.5% of omset

  @HiveField(4)
  final bool isPaid;

  @HiveField(5)
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
