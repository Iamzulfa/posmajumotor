import 'package:posfelix/data/models/models.dart';

/// Expense Repository Interface
abstract class ExpenseRepository {
  // ============================================
  // FUTURE METHODS (One-time fetch)
  // ============================================

  /// Get all expenses with optional filters
  Future<List<ExpenseModel>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    int? limit,
    int? offset,
  });

  /// Get expense by ID
  Future<ExpenseModel?> getExpenseById(String id);

  /// Get expenses for today
  Future<List<ExpenseModel>> getTodayExpenses();

  /// Create new expense
  Future<ExpenseModel> createExpense({
    required String category,
    required int amount,
    String? description,
    DateTime? expenseDate,
  });

  /// Update existing expense
  Future<ExpenseModel> updateExpense(ExpenseModel expense);

  /// Delete expense
  Future<void> deleteExpense(String id);

  /// Get expense summary by category
  Future<Map<String, int>> getExpenseSummaryByCategory({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get total expenses for period
  Future<int> getTotalExpenses({DateTime? startDate, DateTime? endDate});

  // ============================================
  // STREAM METHODS (Real-time updates)
  // ============================================

  /// Stream all expenses with real-time updates
  Stream<List<ExpenseModel>> getExpensesStream({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    int? limit,
  });

  /// Stream today's expenses with real-time updates
  Stream<List<ExpenseModel>> getTodayExpensesStream();

  /// Stream expense summary by category with real-time updates
  Stream<Map<String, int>> getExpenseSummaryByCategoryStream({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Stream total expenses with real-time updates
  Stream<int> getTotalExpensesStream({DateTime? startDate, DateTime? endDate});
}
