import 'package:posfelix/data/models/models.dart';

/// Transaction Repository Interface
abstract class TransactionRepository {
  // ============================================
  // FUTURE METHODS (One-time fetch)
  // ============================================

  /// Get all transactions with optional filters
  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? tier,
    String? paymentMethod,
    String? paymentStatus,
    int? limit,
    int? offset,
  });

  /// Get transaction by ID with items
  Future<TransactionModel?> getTransactionById(String id);

  /// Get transactions for today
  Future<List<TransactionModel>> getTodayTransactions();

  /// Create new transaction with items
  Future<TransactionModel> createTransaction({
    required String tier,
    required String paymentMethod,
    required List<TransactionItemModel> items,
    String? customerName,
    String? notes,
    int discountAmount = 0,
  });

  /// Refund transaction
  Future<void> refundTransaction(String id);

  /// Get transaction summary for dashboard
  Future<TransactionSummary> getTransactionSummary({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get transactions grouped by tier
  Future<Map<String, TierSummary>> getTierBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  });

  // ============================================
  // STREAM METHODS (Real-time updates)
  // ============================================

  /// Stream all transactions with real-time updates
  Stream<List<TransactionModel>> getTransactionsStream({
    DateTime? startDate,
    DateTime? endDate,
    String? tier,
    int? limit,
  });

  /// Stream today's transactions with real-time updates
  Stream<List<TransactionModel>> getTodayTransactionsStream();

  /// Stream transaction summary with real-time updates
  Stream<TransactionSummary> getTransactionSummaryStream({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Stream tier breakdown with real-time updates
  Stream<Map<String, TierSummary>> getTierBreakdownStream({
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Transaction summary for dashboard
class TransactionSummary {
  final int totalTransactions;
  final int totalOmset;
  final int totalHpp;
  final int totalProfit;
  final int averageTransaction;

  TransactionSummary({
    required this.totalTransactions,
    required this.totalOmset,
    required this.totalHpp,
    required this.totalProfit,
    required this.averageTransaction,
  });
}

/// Summary per tier
class TierSummary {
  final String tier;
  final int transactionCount;
  final int totalOmset;
  final int totalProfit;

  TierSummary({
    required this.tier,
    required this.transactionCount,
    required this.totalOmset,
    required this.totalProfit,
  });
}
