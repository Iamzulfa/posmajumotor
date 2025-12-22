import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/expense_repository.dart';
import 'package:posfelix/core/utils/logger.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final SupabaseClient _client;

  ExpenseRepositoryImpl(this._client);

  // Helper method for safe numeric casting
  int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper method for safe string casting
  String _safeToString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    return value.toString();
  }

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

      AppLogger.info('💾 Creating expense with data: $data');

      final response = await _client
          .from('expenses')
          .insert(data)
          .select()
          .single();

      AppLogger.info('✅ Expense created successfully: $category - $amount');
      AppLogger.info('   Response: $response');

      final createdExpense = ExpenseModel.fromJson(response);
      AppLogger.info(
        '   Parsed expense: ${createdExpense.id} - ${createdExpense.expenseDate}',
      );

      return createdExpense;
    } catch (e) {
      AppLogger.error('❌ Error creating expense', e);
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
        final category = _safeToString(row['category'], 'LAINNYA');
        final amount = _safeToInt(row['amount']);
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
        total += _safeToInt(row['amount']);
      }

      return total;
    } catch (e) {
      AppLogger.error('Error getting total expenses', e);
      rethrow;
    }
  }

  // ============================================
  // STREAM METHODS (Real-time updates)
  // ============================================

  @override
  Stream<List<ExpenseModel>> getExpensesStream({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    int? limit,
  }) {
    try {
      return _client
          .from('expenses')
          .stream(primaryKey: ['id'])
          .map((data) {
            // Convert to ExpenseModel with safe parsing
            final expenses = <ExpenseModel>[];
            for (final json in data) {
              try {
                expenses.add(ExpenseModel.fromJson(json));
              } catch (e) {
                AppLogger.warning('Failed to parse expense: $e');
                // Skip invalid expense data
                continue;
              }
            }

            // Apply filters
            var filteredExpenses = expenses;

            if (startDate != null) {
              filteredExpenses = filteredExpenses
                  .where(
                    (e) =>
                        e.expenseDate.isAfter(startDate) ||
                        e.expenseDate.isAtSameMomentAs(startDate),
                  )
                  .toList();
            }
            if (endDate != null) {
              filteredExpenses = filteredExpenses
                  .where(
                    (e) =>
                        e.expenseDate.isBefore(endDate) ||
                        e.expenseDate.isAtSameMomentAs(endDate),
                  )
                  .toList();
            }
            if (category != null) {
              filteredExpenses = filteredExpenses
                  .where((e) => e.category == category)
                  .toList();
            }

            // Sort by expense_date descending
            filteredExpenses.sort(
              (a, b) => b.expenseDate.compareTo(a.expenseDate),
            );

            // Apply limit
            if (limit != null && filteredExpenses.length > limit) {
              filteredExpenses = filteredExpenses.take(limit).toList();
            }

            return filteredExpenses;
          })
          .handleError((error) {
            AppLogger.error('Error streaming expenses', error);
          });
    } catch (e) {
      AppLogger.error('Error setting up expenses stream', e);
      // Return empty stream instead of throwing
      return Stream.value([]);
    }
  }

  @override
  Stream<List<ExpenseModel>> getTodayExpensesStream() {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    AppLogger.info('📅 Fetching expenses for date: $dateStr');

    try {
      return _client
          .from('expenses')
          .stream(primaryKey: ['id'])
          .map((data) {
            AppLogger.info(
              '📦 Received ${data.length} expense records from stream',
            );

            // Filter for today's expenses only
            final todayExpenses = data.where((json) {
              final expenseDate = json['expense_date'] as String?;
              final matches = expenseDate == dateStr;
              if (!matches && expenseDate != null) {
                AppLogger.info(
                  '   Skipping expense with date: $expenseDate (looking for $dateStr)',
                );
              }
              return matches;
            }).toList();

            AppLogger.info(
              '✅ Found ${todayExpenses.length} expenses for today',
            );

            // Convert to ExpenseModel with safe parsing
            final expenses = <ExpenseModel>[];
            for (final json in todayExpenses) {
              try {
                final expense = ExpenseModel.fromJson(json);
                expenses.add(expense);
                AppLogger.info(
                  '   ✓ Parsed expense: ${expense.category} - Rp ${expense.amount}',
                );
              } catch (e) {
                AppLogger.warning('Failed to parse expense: $e');
                AppLogger.warning('   JSON: $json');
                // Skip invalid expense data
              }
            }

            // Sort by created_at descending
            expenses.sort((a, b) {
              if (a.createdAt == null && b.createdAt == null) return 0;
              if (a.createdAt == null) return 1;
              if (b.createdAt == null) return -1;
              return b.createdAt!.compareTo(a.createdAt!);
            });

            return expenses;
          })
          .handleError((error) {
            AppLogger.error('Error streaming today expenses', error);
          });
    } catch (e) {
      AppLogger.error('Error setting up today expenses stream', e);
      // Return empty stream instead of throwing
      return Stream.value([]);
    }
  }

  @override
  Stream<Map<String, int>> getExpenseSummaryByCategoryStream({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return getExpensesStream(startDate: startDate, endDate: endDate)
        .map((expenses) {
          final Map<String, int> summary = {};

          for (final expense in expenses) {
            summary[expense.category] =
                (summary[expense.category] ?? 0) + expense.amount;
          }

          return summary;
        })
        .handleError((error) {
          AppLogger.error('Error streaming expense summary', error);
        });
  }

  @override
  Stream<int> getTotalExpensesStream({DateTime? startDate, DateTime? endDate}) {
    return getExpensesStream(startDate: startDate, endDate: endDate)
        .map((expenses) {
          int total = 0;
          for (final expense in expenses) {
            total += expense.amount;
          }
          return total;
        })
        .handleError((error) {
          AppLogger.error('Error streaming total expenses', error);
        });
  }
}
