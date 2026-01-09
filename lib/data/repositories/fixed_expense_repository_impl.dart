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
      AppLogger.info('🔧 Fetching fixed expenses from database...');

      final response = await _client
          .from('fixed_expenses')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      AppLogger.info('🔧 Raw response from database: $response');
      AppLogger.info('🔧 Response type: ${response.runtimeType}');
      AppLogger.info('🔧 Got ${response.length} fixed expenses from database');

      if (response.isEmpty) {
        AppLogger.info('🔧 No fixed expenses found in database');
        return [];
      }

      final result = response.map((json) {
        AppLogger.info('🔧 Processing JSON: $json');
        return FixedExpenseModel.fromJson(json);
      }).toList();

      AppLogger.info('🔧 Parsed ${result.length} FixedExpenseModel objects');
      for (final expense in result) {
        AppLogger.info('🔧 - ${expense.name}: Rp ${expense.amount}');
      }

      return result;
    } catch (e) {
      AppLogger.error('Error fetching fixed expenses', e);
      // Return empty list instead of rethrowing to prevent app crashes
      return [];
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
      // Create expense data without id (let database generate UUID)
      final expenseData = expense.toJson();

      AppLogger.info('✅ Creating fixed expense: ${expense.name}');
      AppLogger.info('✅ Expense data: $expenseData');

      final response = await _client
          .from('fixed_expenses')
          .insert(expenseData)
          .select()
          .single();

      AppLogger.info('✅ Fixed expense created successfully: ${expense.name}');
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
    AppLogger.info('🔧 getFixedExpensesStream called');
    try {
      // Use polling with immediate initial fetch (same pattern as daily expenses)
      final stream =
          Stream.periodic(const Duration(seconds: 3), (_) async {
            AppLogger.info('🔧 Polling fixed expenses from database...');
            try {
              final expenses = await getFixedExpenses();
              AppLogger.info('🔧 Polled ${expenses.length} fixed expenses');
              return expenses;
            } catch (e) {
              AppLogger.error('Error in polling fixed expenses', e);
              return <FixedExpenseModel>[];
            }
          }).asyncMap((future) => future).handleError((error) {
            AppLogger.error('Error in fixed expenses polling stream', error);
            return <FixedExpenseModel>[];
          });

      // Trigger immediate initial fetch (this is the key difference!)
      getFixedExpenses()
          .then((data) {
            AppLogger.info(
              '🔧 Initial fixed expenses fetch completed: ${data.length} items',
            );
          })
          .catchError((e) {
            AppLogger.error('Error in initial fixed expenses fetch', e);
          });

      return stream;
    } catch (e) {
      AppLogger.error('Error setting up fixed expenses polling stream', e);
      // Fallback to single fetch if polling setup fails
      return Stream.fromFuture(getFixedExpenses()).handleError((error) {
        AppLogger.error('Error in fallback fixed expenses fetch', error);
        return <FixedExpenseModel>[];
      });
    }
  }
}
