import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/expense_repository.dart';
import 'package:posfelix/injection_container.dart';
import 'package:posfelix/config/constants/supabase_config.dart';
import 'transaction_provider.dart' show DateRange;

/// Expense list state
class ExpenseListState {
  final List<ExpenseModel> expenses;
  final Map<String, int> categoryBreakdown;
  final int totalToday;
  final bool isLoading;
  final String? error;

  const ExpenseListState({
    this.expenses = const [],
    this.categoryBreakdown = const {},
    this.totalToday = 0,
    this.isLoading = false,
    this.error,
  });

  ExpenseListState copyWith({
    List<ExpenseModel>? expenses,
    Map<String, int>? categoryBreakdown,
    int? totalToday,
    bool? isLoading,
    String? error,
  }) {
    return ExpenseListState(
      expenses: expenses ?? this.expenses,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      totalToday: totalToday ?? this.totalToday,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Expense list notifier
class ExpenseListNotifier extends StateNotifier<ExpenseListState> {
  final ExpenseRepository? _repository;

  ExpenseListNotifier(this._repository) : super(const ExpenseListState());

  Future<void> loadTodayExpenses() async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final expenses = await _repository.getTodayExpenses();

      // Calculate category breakdown
      final Map<String, int> breakdown = {};
      int total = 0;
      for (final expense in expenses) {
        breakdown[expense.category] =
            (breakdown[expense.category] ?? 0) + expense.amount;
        total += expense.amount;
      }

      state = state.copyWith(
        expenses: expenses,
        categoryBreakdown: breakdown,
        totalToday: total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final expenses = await _repository.getExpenses(
        startDate: startDate,
        endDate: endDate,
        category: category,
      );

      final breakdown = await _repository.getExpenseSummaryByCategory(
        startDate: startDate,
        endDate: endDate,
      );

      final total = await _repository.getTotalExpenses(
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        expenses: expenses,
        categoryBreakdown: breakdown,
        totalToday: total,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createExpense({
    required String category,
    required int amount,
    String? description,
  }) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createExpense(
        category: category,
        amount: amount,
        description: description,
      );
      await loadTodayExpenses();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createExpense(
        category: expense.category,
        amount: expense.amount,
        description: expense.description,
      );
      await loadTodayExpenses();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Since we don't have an update method in repository, we'll delete and recreate
      await _repository.deleteExpense(expense.id);
      await _repository.createExpense(
        category: expense.category,
        amount: expense.amount,
        description: expense.description,
      );
      await loadTodayExpenses();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteExpense(String id) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteExpense(id);
      await loadTodayExpenses();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Expense list provider
final expenseListProvider =
    StateNotifierProvider<ExpenseListNotifier, ExpenseListState>((ref) {
      final repository = SupabaseConfig.isConfigured
          ? getIt<ExpenseRepository>()
          : null;
      return ExpenseListNotifier(repository);
    });

// ============================================
// STREAM PROVIDERS (Real-time updates)
// ============================================

/// Real-time today's expenses stream provider
final todayExpensesStreamProvider = StreamProvider<List<ExpenseModel>>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return Stream.value([]);
  }
  final repository = getIt<ExpenseRepository>();
  return repository.getTodayExpensesStream();
});

/// Real-time expense summary by category stream provider
final expenseSummaryStreamProvider =
    StreamProvider.family<Map<String, int>, DateRange?>((ref, dateRange) {
      if (!SupabaseConfig.isConfigured) {
        return Stream.value({});
      }
      final repository = getIt<ExpenseRepository>();
      return repository.getExpenseSummaryByCategoryStream(
        startDate: dateRange?.start,
        endDate: dateRange?.end,
      );
    });

/// Real-time total expenses stream provider
final totalExpensesStreamProvider = StreamProvider.family<int, DateRange?>((
  ref,
  dateRange,
) {
  if (!SupabaseConfig.isConfigured) {
    return Stream.value(0);
  }
  final repository = getIt<ExpenseRepository>();
  return repository.getTotalExpensesStream(
    startDate: dateRange?.start,
    endDate: dateRange?.end,
  );
});

// DateRange is imported from transaction_provider.dart via providers.dart
