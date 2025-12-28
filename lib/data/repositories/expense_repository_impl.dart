import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/expense_repository.dart';
import 'package:posfelix/core/utils/logger.dart';
import 'package:posfelix/core/extensions/stream_extensions.dart';
import 'package:posfelix/core/services/offline_service.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final SupabaseClient _client;
  final OfflineService _offlineService = OfflineService();

  // Stream caching to prevent multiple subscriptions
  Stream<List<ExpenseModel>>? _cachedExpensesStream;
  Stream<List<ExpenseModel>>? _cachedTodayExpensesStream;
  String? _cachedTodayExpensesDate; // Track which date the cache is for
  Stream<Map<String, int>>? _cachedExpenseSummaryStream;
  Stream<int>? _cachedTotalExpensesStream;

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

      // Try to return cached data if offline
      if (!_offlineService.isOnline) {
        final cacheKey =
            'expenses_${startDate?.toIso8601String()}_${endDate?.toIso8601String()}_$category';
        final cached = _offlineService.getCachedData(cacheKey);
        if (cached != null) {
          AppLogger.info('📦 Using cached expenses (offline mode)');
          if (cached is List) {
            return cached
                .map(
                  (item) => item is ExpenseModel
                      ? item
                      : ExpenseModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
        }
      }

      return [];
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

      // Try to return cached data if offline
      if (!_offlineService.isOnline) {
        final cached = _offlineService.getCachedData('today_expenses_$dateStr');
        if (cached != null) {
          AppLogger.info('📦 Using cached today expenses (offline mode)');
          if (cached is List) {
            return cached
                .map(
                  (item) => item is ExpenseModel
                      ? item
                      : ExpenseModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
        }
      }

      return [];
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

      // Try to return cached data if offline
      if (!_offlineService.isOnline) {
        final cacheKey =
            'expense_summary_${startDate?.toIso8601String()}_${endDate?.toIso8601String()}';
        final cached = _offlineService.getCachedData(cacheKey);
        if (cached != null) {
          AppLogger.info('📦 Using cached expense summary (offline mode)');
          if (cached is Map) {
            return Map<String, int>.from(cached);
          }
        }
      }

      return {};
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

      // Try to return cached data if offline
      if (!_offlineService.isOnline) {
        final cacheKey =
            'total_expenses_${startDate?.toIso8601String()}_${endDate?.toIso8601String()}';
        final cached = _offlineService.getCachedData(cacheKey);
        if (cached != null) {
          AppLogger.info('📦 Using cached total expenses (offline mode)');
          if (cached is num) {
            return cached.toInt();
          }
        }
      }

      return 0;
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
    // Only create stream if no filters are applied (base stream)
    if (startDate == null &&
        endDate == null &&
        category == null &&
        limit == null) {
      if (_cachedExpensesStream != null) {
        return _cachedExpensesStream!;
      }

      try {
        // Use polling instead of Realtime to avoid connection issues
        // Emit immediately on first subscription, then poll every 3 seconds
        _cachedExpensesStream =
            Stream.periodic(
                  const Duration(seconds: 3),
                  (_) => _fetchAllExpenses(),
                )
                .asyncExpand((future) => future.asStream())
                .distinct()
                .handleError((error) {
                  AppLogger.error('Error streaming expenses', error);
                  return <ExpenseModel>[];
                })
                .shareReplay(bufferSize: 1);

        // Trigger initial fetch immediately
        _fetchAllExpenses()
            .then((data) {
              // Data will be emitted through the stream
            })
            .catchError((e) {
              AppLogger.error('Error in initial expense fetch', e);
            });

        return _cachedExpensesStream!;
      } catch (e) {
        AppLogger.error('Error setting up expenses stream', e);
        return Stream.value([]);
      }
    }

    // For filtered streams, apply filters on top of base stream
    return getExpensesStream().map((expenses) {
      var filtered = expenses;

      if (startDate != null) {
        filtered = filtered
            .where(
              (e) =>
                  e.expenseDate.isAfter(startDate) ||
                  e.expenseDate.isAtSameMomentAs(startDate),
            )
            .toList();
      }
      if (endDate != null) {
        filtered = filtered
            .where(
              (e) =>
                  e.expenseDate.isBefore(endDate) ||
                  e.expenseDate.isAtSameMomentAs(endDate),
            )
            .toList();
      }
      if (category != null) {
        filtered = filtered.where((e) => e.category == category).toList();
      }

      if (limit != null && filtered.length > limit) {
        filtered = filtered.take(limit).toList();
      }

      return filtered;
    });
  }

  Future<List<ExpenseModel>> _fetchAllExpenses() async {
    try {
      final response = await _client
          .from('expenses')
          .select('*, users(*)')
          .order('expense_date', ascending: false);

      final expenses = <ExpenseModel>[];
      for (final json in response) {
        try {
          expenses.add(ExpenseModel.fromJson(json));
        } catch (e) {
          AppLogger.warning('Failed to parse expense: $e');
          continue;
        }
      }

      // Sort by expense_date descending
      expenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

      // Cache for offline use
      await _offlineService.cacheData('all_expenses', expenses);

      return expenses;
    } catch (e) {
      AppLogger.error('Error fetching all expenses', e);

      // Try to return cached data if offline
      if (!_offlineService.isOnline) {
        final cached = _offlineService.getCachedData('all_expenses');
        if (cached != null) {
          AppLogger.info('📦 Using cached all expenses (offline mode)');
          if (cached is List) {
            return cached
                .map(
                  (item) => item is ExpenseModel
                      ? item
                      : ExpenseModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
        }
      }

      return [];
    }
  }

  @override
  Stream<List<ExpenseModel>> getTodayExpensesStream() {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // Invalidate cache if date has changed
    if (_cachedTodayExpensesDate != dateStr) {
      _cachedTodayExpensesStream = null;
      _cachedTodayExpensesDate = null;
    }

    if (_cachedTodayExpensesStream != null) {
      return _cachedTodayExpensesStream!;
    }

    AppLogger.info('📅 Fetching expenses for date: $dateStr');

    try {
      _cachedTodayExpensesDate = dateStr;

      // Use polling instead of Realtime to avoid connection issues
      // Emit immediately on first subscription, then poll every 3 seconds
      _cachedTodayExpensesStream =
          Stream.periodic(
                const Duration(seconds: 3),
                (_) => _fetchTodayExpensesData(dateStr),
              )
              .asyncExpand((future) => future.asStream())
              .distinct()
              .handleError((error) {
                AppLogger.error('Error streaming today expenses', error);
              })
              .shareReplay(bufferSize: 1);

      // Trigger initial fetch immediately
      _fetchTodayExpensesData(dateStr)
          .then((data) {
            // Data will be emitted through the stream
          })
          .catchError((e) {
            AppLogger.error('Error in initial today expense fetch', e);
          });

      return _cachedTodayExpensesStream!;
    } catch (e) {
      AppLogger.error('Error setting up today expenses stream', e);
      return Stream.value([]);
    }
  }

  Future<List<ExpenseModel>> _fetchTodayExpensesData(String dateStr) async {
    try {
      final data = await _client
          .from('expenses')
          .select('*, users(*)')
          .eq('expense_date', dateStr)
          .order('created_at', ascending: false);

      AppLogger.info('📦 Received ${data.length} expense records from fetch');

      // Convert to ExpenseModel with safe parsing
      final expenses = <ExpenseModel>[];
      for (final json in data) {
        try {
          final expense = ExpenseModel.fromJson(json);
          expenses.add(expense);
          AppLogger.info(
            '   ✓ Parsed expense: ${expense.category} - Rp ${expense.amount}',
          );
        } catch (e) {
          AppLogger.warning('Failed to parse expense: $e');
          AppLogger.warning('   JSON: $json');
        }
      }

      AppLogger.info('✅ Found ${expenses.length} expenses for today');

      // Sort by created_at descending
      expenses.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      // Cache for offline use
      await _offlineService.cacheData('today_expenses_$dateStr', expenses);

      return expenses;
    } catch (e) {
      AppLogger.error('Error fetching today expenses data', e);

      // Try to return cached data if offline
      if (!_offlineService.isOnline) {
        final cached = _offlineService.getCachedData('today_expenses_$dateStr');
        if (cached != null) {
          AppLogger.info('📦 Using cached today expenses (offline mode)');
          if (cached is List) {
            return cached
                .map(
                  (item) => item is ExpenseModel
                      ? item
                      : ExpenseModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
        }
      }

      return [];
    }
  }

  @override
  Stream<Map<String, int>> getExpenseSummaryByCategoryStream({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (startDate == null && endDate == null) {
      if (_cachedExpenseSummaryStream != null) {
        return _cachedExpenseSummaryStream!;
      }

      _cachedExpenseSummaryStream = getExpensesStream()
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
          })
          .shareReplay(bufferSize: 1);

      return _cachedExpenseSummaryStream!;
    }

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
    if (startDate == null && endDate == null) {
      if (_cachedTotalExpensesStream != null) {
        return _cachedTotalExpensesStream!;
      }

      _cachedTotalExpensesStream = getExpensesStream()
          .map((expenses) {
            int total = 0;
            for (final expense in expenses) {
              total += expense.amount;
            }
            return total;
          })
          .handleError((error) {
            AppLogger.error('Error streaming total expenses', error);
          })
          .shareReplay(bufferSize: 1);

      return _cachedTotalExpensesStream!;
    }

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
