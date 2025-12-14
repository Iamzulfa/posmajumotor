import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/expense_repository.dart';
import 'package:posfelix/core/utils/logger.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final SupabaseClient _client;

  ExpenseRepositoryImpl(this._client);

  @override
  Future<List<ExpenseModel>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from('expenses').select('*, users(*)');

      if (startDate != null) {
        query = query.gte(
          'expense_date',
          startDate.toIso8601String().split('T')[0],
        );
      }

      if (endDate != null) {
        query = query.lte(
          'expense_date',
          endDate.toIso8601String().split('T')[0],
        );
      }

      if (category != null) {
        query = query.eq('category', category);
      }

      // Execute with order, limit, range
      final response = await query
          .order('expense_date', ascending: false)
          .limit(limit ?? 100);

      return response.map((json) => ExpenseModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching expenses', e);
      rethrow;
    }
  }

  @override
  Future<ExpenseModel?> getExpenseById(String id) async {
    try {
      final response = await _client
          .from('expenses')
          .select('*, users(*)')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ExpenseModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching expense by ID', e);
      rethrow;
    }
  }

  @override
  Future<List<ExpenseModel>> getTodayExpenses() async {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    try {
      final response = await _client
          .from('expenses')
          .select('*, users(*)')
          .eq('expense_date', dateStr)
          .order('created_at', ascending: false);

      return response.map((json) => ExpenseModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching today expenses', e);
      rethrow;
    }
  }

  @override
  Future<ExpenseModel> createExpense({
    required String category,
    required int amount,
    String? description,
    DateTime? expenseDate,
  }) async {
    try {
      final date = expenseDate ?? DateTime.now();
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final data = {
        'category': category,
        'amount': amount,
        'description': description,
        'expense_date': dateStr,
        'created_by': _client.auth.currentUser?.id,
      };

      final response = await _client
          .from('expenses')
          .insert(data)
          .select()
          .single();

      AppLogger.info('Expense created: $category - $amount');
      return ExpenseModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error creating expense', e);
      rethrow;
    }
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    try {
      final dateStr =
          '${expense.expenseDate.year}-${expense.expenseDate.month.toString().padLeft(2, '0')}-${expense.expenseDate.day.toString().padLeft(2, '0')}';

      final data = {
        'category': expense.category,
        'amount': expense.amount,
        'description': expense.description,
        'expense_date': dateStr,
      };

      final response = await _client
          .from('expenses')
          .update(data)
          .eq('id', expense.id)
          .select()
          .single();

      AppLogger.info('Expense updated: ${expense.id}');
      return ExpenseModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error updating expense', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    try {
      await _client.from('expenses').delete().eq('id', id);
      AppLogger.info('Expense deleted: $id');
    } catch (e) {
      AppLogger.error('Error deleting expense', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getExpenseSummaryByCategory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client.from('expenses').select('category, amount');

      if (startDate != null) {
        query = query.gte(
          'expense_date',
          startDate.toIso8601String().split('T')[0],
        );
      }

      if (endDate != null) {
        query = query.lte(
          'expense_date',
          endDate.toIso8601String().split('T')[0],
        );
      }

      final response = await query;

      final Map<String, int> summary = {};

      for (final row in response) {
        final category = row['category'] as String;
        final amount = (row['amount'] as num).toInt();
        summary[category] = (summary[category] ?? 0) + amount;
      }

      return summary;
    } catch (e) {
      AppLogger.error('Error getting expense summary', e);
      rethrow;
    }
  }

  @override
  Future<int> getTotalExpenses({DateTime? startDate, DateTime? endDate}) async {
    try {
      var query = _client.from('expenses').select('amount');

      if (startDate != null) {
        query = query.gte(
          'expense_date',
          startDate.toIso8601String().split('T')[0],
        );
      }

      if (endDate != null) {
        query = query.lte(
          'expense_date',
          endDate.toIso8601String().split('T')[0],
        );
      }

      final response = await query;

      int total = 0;
      for (final row in response) {
        total += (row['amount'] as num).toInt();
      }

      return total;
    } catch (e) {
      AppLogger.error('Error getting total expenses', e);
      rethrow;
    }
  }
}
