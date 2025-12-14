import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posfelix/domain/repositories/transaction_repository.dart';
import 'package:posfelix/domain/repositories/expense_repository.dart';
import 'package:posfelix/injection_container.dart';
import 'package:posfelix/config/constants/supabase_config.dart';

/// Dashboard data state
class DashboardState {
  // Today's summary
  final int todayOmset;
  final int todayHpp;
  final int todayExpenses;
  final int todayProfit;
  final int todayTransactionCount;
  final int todayAverageTransaction;

  // Tax indicator
  final int monthlyOmset;
  final int taxAmount; // 0.5% of monthly omset

  // Tier breakdown
  final Map<String, TierSummary> tierBreakdown;

  // Loading state
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.todayOmset = 0,
    this.todayHpp = 0,
    this.todayExpenses = 0,
    this.todayProfit = 0,
    this.todayTransactionCount = 0,
    this.todayAverageTransaction = 0,
    this.monthlyOmset = 0,
    this.taxAmount = 0,
    this.tierBreakdown = const {},
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    int? todayOmset,
    int? todayHpp,
    int? todayExpenses,
    int? todayProfit,
    int? todayTransactionCount,
    int? todayAverageTransaction,
    int? monthlyOmset,
    int? taxAmount,
    Map<String, TierSummary>? tierBreakdown,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      todayOmset: todayOmset ?? this.todayOmset,
      todayHpp: todayHpp ?? this.todayHpp,
      todayExpenses: todayExpenses ?? this.todayExpenses,
      todayProfit: todayProfit ?? this.todayProfit,
      todayTransactionCount:
          todayTransactionCount ?? this.todayTransactionCount,
      todayAverageTransaction:
          todayAverageTransaction ?? this.todayAverageTransaction,
      monthlyOmset: monthlyOmset ?? this.monthlyOmset,
      taxAmount: taxAmount ?? this.taxAmount,
      tierBreakdown: tierBreakdown ?? this.tierBreakdown,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Calculate margin percentage
  double get marginPercent {
    if (todayOmset == 0) return 0;
    return (todayProfit / todayOmset) * 100;
  }
}

/// Dashboard notifier
class DashboardNotifier extends StateNotifier<DashboardState> {
  final TransactionRepository? _transactionRepo;
  final ExpenseRepository? _expenseRepo;

  DashboardNotifier(this._transactionRepo, this._expenseRepo)
    : super(const DashboardState());

  Future<void> loadDashboardData() async {
    if (_transactionRepo == null || _expenseRepo == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();

      // Today's date range
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // This month's date range
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // Get today's transaction summary
      final todaySummary = await _transactionRepo.getTransactionSummary(
        startDate: todayStart,
        endDate: todayEnd,
      );

      // Get today's expenses
      final todayExpenses = await _expenseRepo.getTotalExpenses(
        startDate: todayStart,
        endDate: todayEnd,
      );

      // Get monthly omset for tax calculation
      final monthlySummary = await _transactionRepo.getTransactionSummary(
        startDate: monthStart,
        endDate: monthEnd,
      );

      // Get tier breakdown for today
      final tierBreakdown = await _transactionRepo.getTierBreakdown(
        startDate: todayStart,
        endDate: todayEnd,
      );

      // Calculate profit (omset - hpp - expenses)
      final todayProfit =
          todaySummary.totalOmset - todaySummary.totalHpp - todayExpenses;

      // Calculate tax (0.5% of monthly omset)
      final taxAmount = (monthlySummary.totalOmset * 0.005).round();

      state = state.copyWith(
        todayOmset: todaySummary.totalOmset,
        todayHpp: todaySummary.totalHpp,
        todayExpenses: todayExpenses,
        todayProfit: todayProfit,
        todayTransactionCount: todaySummary.totalTransactions,
        todayAverageTransaction: todaySummary.averageTransaction,
        monthlyOmset: monthlySummary.totalOmset,
        taxAmount: taxAmount,
        tierBreakdown: tierBreakdown,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Dashboard provider
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
      final transactionRepo = SupabaseConfig.isConfigured
          ? getIt<TransactionRepository>()
          : null;
      final expenseRepo = SupabaseConfig.isConfigured
          ? getIt<ExpenseRepository>()
          : null;
      return DashboardNotifier(transactionRepo, expenseRepo);
    });
