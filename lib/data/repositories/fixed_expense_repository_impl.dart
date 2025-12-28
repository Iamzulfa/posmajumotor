import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/data/models/fixed_expense_model.dart';
import 'package:posfelix/domain/repositories/fixed_expense_repository.dart';
import 'package:posfelix/core/utils/logger.dart';

class FixedExpenseRepositoryImpl implements FixedExpenseRepository {
  final SupabaseClient _client;

  FixedExpenseRepositoryImpl(this._client);

  @override
  Future<List<FixedExpenseModel>> getFixedExpenses() async {
    try {
      final response = await _client
          .from('fixed_expenses')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return response.map((json) => FixedExpenseModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching fixed expenses', e);
      rethrow;
    }
  }

  @override
  Future<FixedExpenseModel?> getFixedExpenseById(String id) async {
    try {
      final response = await _client
          .from('fixed_expenses')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return FixedExpenseModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching fixed expense by ID', e);
      rethrow;
    }
  }

  @override
  Future<FixedExpenseModel> createFixedExpense(
    FixedExpenseModel expense,
  ) async {
    try {
      final response = await _client
          .from('fixed_expenses')
          .insert(expense.toJson())
          .select()
          .single();

      AppLogger.info('✅ Fixed expense created: ${expense.name}');
      return FixedExpenseModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error creating fixed expense', e);
      rethrow;
    }
  }

  @override
  Future<FixedExpenseModel> updateFixedExpense(
    FixedExpenseModel expense,
  ) async {
    try {
      final response = await _client
          .from('fixed_expenses')
          .update(expense.toJson())
          .eq('id', expense.id)
          .select()
          .single();

      AppLogger.info('✅ Fixed expense updated: ${expense.name}');
      return FixedExpenseModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error updating fixed expense', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteFixedExpense(String id) async {
    try {
      await _client.from('fixed_expenses').delete().eq('id', id);
      AppLogger.info('✅ Fixed expense deleted');
    } catch (e) {
      AppLogger.error('Error deleting fixed expense', e);
      rethrow;
    }
  }

  @override
  Future<int> getTotalFixedExpenses() async {
    try {
      final expenses = await getFixedExpenses();
      return expenses.fold<int>(0, (sum, e) => sum + e.amount);
    } catch (e) {
      AppLogger.error('Error calculating total fixed expenses', e);
      return 0;
    }
  }

  @override
  Stream<List<FixedExpenseModel>> getFixedExpensesStream() {
    // Using polling instead of realtime for consistency
    return Stream.periodic(
      const Duration(seconds: 5),
      (_) => getFixedExpenses(),
    ).asyncExpand((future) => future.asStream());
  }
}
