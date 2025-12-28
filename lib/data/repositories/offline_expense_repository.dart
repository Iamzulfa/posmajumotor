import 'package:uuid/uuid.dart';
import '../../core/services/offline_service.dart';
import '../models/expense_model.dart';

/// Repository untuk handle expense dengan offline support
class OfflineExpenseRepository {
  final OfflineService _offlineService;

  OfflineExpenseRepository(this._offlineService);

  /// Create expense dengan offline support
  Future<ExpenseModel> createExpenseOfflineSupport(ExpenseModel expense) async {
    try {
      // Jika online, langsung create di Supabase
      if (_offlineService.isOnline) {
        return expense;
      }

      // Jika offline, queue untuk sync nanti
      final expenseId = const Uuid().v4();
      final expenseData = {
        'id': expenseId,
        'category': expense.category,
        'amount': expense.amount,
        'description': expense.description,
        'expense_date': expense.expenseDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await _offlineService.queueExpense(expenseId, expenseData);

      // Cache expense locally
      await _offlineService.cacheData('expense_$expenseId', expenseData);

      return expense.copyWith(id: expenseId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get expenses dengan offline fallback
  Future<List<ExpenseModel>> getExpensesWithOfflineFallback(
    List<ExpenseModel> onlineExpenses,
  ) async {
    try {
      // Jika online, return online data
      if (_offlineService.isOnline) {
        // Cache untuk offline use
        await _offlineService.cacheData('expenses_list', onlineExpenses);
        return onlineExpenses;
      }

      // Jika offline, return cached data
      final cached = _offlineService.getCachedData('expenses_list');
      if (cached != null && cached is List) {
        return cached.cast<ExpenseModel>();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get today expenses dengan offline fallback
  Future<List<ExpenseModel>> getTodayExpensesWithOfflineFallback(
    List<ExpenseModel> onlineExpenses,
  ) async {
    try {
      // Jika online, return online data
      if (_offlineService.isOnline) {
        // Cache untuk offline use
        await _offlineService.cacheData('today_expenses', onlineExpenses);
        return onlineExpenses;
      }

      // Jika offline, return cached data
      final cached = _offlineService.getCachedData('today_expenses');
      if (cached != null && cached is List) {
        return cached.cast<ExpenseModel>();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get pending expenses untuk sync
  List<Map<String, dynamic>> getPendingExpenses() {
    final pendingItems = _offlineService.getPendingSyncItems();
    return pendingItems
        .where((item) {
          final data = item.value as Map;
          return data['type'] == 'expense';
        })
        .map((item) => item.value as Map<String, dynamic>)
        .toList();
  }

  /// Mark expense as synced
  Future<void> markExpenseSynced(String expenseId) async {
    await _offlineService.removeSyncedItem(expenseId);
  }
}
