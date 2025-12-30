import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posfelix/domain/repositories/transaction_repository.dart';
import 'package:posfelix/domain/repositories/expense_repository.dart';
import 'package:posfelix/domain/repositories/dashboard_repository.dart';
import 'package:posfelix/injection_container.dart';
import 'package:posfelix/config/constants/supabase_config.dart';
import 'package:posfelix/core/utils/logger.dart';
import 'package:posfelix/presentation/providers/transaction_provider.dart'
    show DateRange;

/// Provider untuk 7 hari summary (untuk trend chart)
final last7DaysSummaryProvider = FutureProvider<List<DailySummary>>((
  ref,
) async {
  if (!SupabaseConfig.isConfigured) {
    return [];
  }
  final transactionRepo = getIt<TransactionRepository>();
  return transactionRepo.getLast7DaysSummary();
});

/// Provider untuk last 7 days expense history
final last7DaysExpenseHistoryProvider = FutureProvider<List<DailyExpenseData>>((
  ref,
) async {
  if (!SupabaseConfig.isConfigured) {
    return [];
  }
  final expenseRepo = getIt<ExpenseRepository>();

  try {
    final today = DateTime.now();
    final sevenDaysAgo = today.subtract(const Duration(days: 6));

    final startDate = DateTime(
      sevenDaysAgo.year,
      sevenDaysAgo.month,
      sevenDaysAgo.day,
    ).toUtc();
    final endDate = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).toUtc();

    final expenses = await expenseRepo.getExpenses(
      startDate: startDate,
      endDate: endDate,
    );

    // Group by date
    final Map<String, int> dailyTotals = {};
    for (final expense in expenses) {
      final dateKey = expense.expenseDate.toString().split(' ')[0];
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + expense.amount;
    }

    // Create list for last 7 days
    final result = <DailyExpenseData>[];
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dateKey = date.toString().split(' ')[0];
      final amount = dailyTotals[dateKey] ?? 0;
      result.add(DailyExpenseData(date: date, amount: amount));
    }

    return result;
  } catch (e) {
    AppLogger.error('Error fetching 7 days expense history', e);
    return [];
  }
});

/// Data class for daily expense
class DailyExpenseData {
  final DateTime date;
  final int amount;

  DailyExpenseData({required this.date, required this.amount});

  String get formattedDate {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hari Ini';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Kemarin';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

/// Data class for expense/income comparison with advanced metrics
class ExpenseIncomeData {
  final int totalIncome;
  final int totalExpense;
  final int yesterdayIncome;
  final int yesterdayExpense;

  ExpenseIncomeData({
    required this.totalIncome,
    required this.totalExpense,
    required this.yesterdayIncome,
    required this.yesterdayExpense,
  });

  // Calculate trends
  double get incomeTrend {
    if (yesterdayIncome == 0) return 0;
    return ((totalIncome - yesterdayIncome) / yesterdayIncome) * 100;
  }

  double get expenseTrend {
    if (yesterdayExpense == 0) return 0;
    return ((totalExpense - yesterdayExpense) / yesterdayExpense) * 100;
  }

  int get profit => totalIncome - totalExpense;
  int get yesterdayProfit => yesterdayIncome - yesterdayExpense;

  double get profitTrend {
    if (yesterdayProfit == 0) return 0;
    return ((profit - yesterdayProfit) / yesterdayProfit.abs()) * 100;
  }

  double get expenseRatio {
    if (totalIncome == 0) return 0;
    return (totalExpense / totalIncome) * 100;
  }

  double get yesterdayExpenseRatio {
    if (yesterdayIncome == 0) return 0;
    return (yesterdayExpense / yesterdayIncome) * 100;
  }
}

/// Provider untuk expense/income comparison data with trend analysis
final expenseIncomeComparisonProvider =
    FutureProvider.family<ExpenseIncomeData, DateRange?>((
      ref,
      dateRange,
    ) async {
      if (!SupabaseConfig.isConfigured) {
        return ExpenseIncomeData(
          totalIncome: 0,
          totalExpense: 0,
          yesterdayIncome: 0,
          yesterdayExpense: 0,
        );
      }

      final transactionRepo = getIt<TransactionRepository>();
      final expenseRepo = getIt<ExpenseRepository>();

      try {
        AppLogger.info(
          '📊 Fetching expense/income data for range: ${dateRange?.start} to ${dateRange?.end}',
        );

        // Get today's data
        final summary = await transactionRepo.getTransactionSummary(
          startDate: dateRange?.start,
          endDate: dateRange?.end,
        );

        AppLogger.info('📊 Transaction summary: ${summary.totalOmset}');

        final totalExpenses = await expenseRepo.getTotalExpenses(
          startDate: dateRange?.start,
          endDate: dateRange?.end,
        );

        AppLogger.info('📊 Total expenses: $totalExpenses');

        // Get yesterday's data for comparison
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final yesterdayStart = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
        ).toUtc();
        final yesterdayEnd = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          23,
          59,
          59,
        ).toUtc();

        final yesterdaySummary = await transactionRepo.getTransactionSummary(
          startDate: yesterdayStart,
          endDate: yesterdayEnd,
        );

        final yesterdayExpenses = await expenseRepo.getTotalExpenses(
          startDate: yesterdayStart,
          endDate: yesterdayEnd,
        );

        AppLogger.info(
          '📊 Yesterday - Income: ${yesterdaySummary.totalOmset}, Expenses: $yesterdayExpenses',
        );

        return ExpenseIncomeData(
          totalIncome: summary.totalOmset,
          totalExpense: totalExpenses,
          yesterdayIncome: yesterdaySummary.totalOmset,
          yesterdayExpense: yesterdayExpenses,
        );
      } catch (e) {
        AppLogger.error('Error fetching expense/income data', e);
        return ExpenseIncomeData(
          totalIncome: 0,
          totalExpense: 0,
          yesterdayIncome: 0,
          yesterdayExpense: 0,
        );
      }
    });

/// Dashboard period enum
enum DashboardPeriod {
  hari,
  minggu,
  bulan;

  factory DashboardPeriod.fromString(String value) {
    return DashboardPeriod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DashboardPeriod.hari,
    );
  }

  DateRange getDateRange() {
    final now = DateTime.now();
    switch (this) {
      case DashboardPeriod.hari:
        final start = DateTime(now.year, now.month, now.day).toUtc();
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc();
        return DateRange(start: start, end: end);
      case DashboardPeriod.minggu:
        final start = now.subtract(Duration(days: now.weekday - 1));
        final startDate = DateTime(start.year, start.month, start.day).toUtc();
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59).toUtc();
        return DateRange(start: startDate, end: end);
      case DashboardPeriod.bulan:
        final start = DateTime(now.year, now.month, 1).toUtc();
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59).toUtc();
        return DateRange(start: start, end: end);
    }
  }
}

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

// ============================================
// STREAM PROVIDERS (Real-time updates)
// ============================================

/// Cache for tier breakdown data per period
final _tierBreakdownCache = <DashboardPeriod, Map<String, TierSummary>>{};

/// Real-time dashboard data stream provider with period support
/// Combines transaction summary, expenses, and tier breakdown
/// Tier breakdown is cached per period to avoid unnecessary refreshes
final dashboardStreamProvider =
    StreamProvider.family<DashboardState, DashboardPeriod>((
      ref,
      period,
    ) async* {
      if (!SupabaseConfig.isConfigured) {
        yield const DashboardState();
        return;
      }

      final dashboardRepo = getIt<DashboardRepository>();
      final transactionRepo = getIt<TransactionRepository>();

      final periodRange = period.getDateRange();

      // Load cached tier breakdown for this period if available
      var cachedTierBreakdown = _tierBreakdownCache[period];

      final dashboardStream = dashboardRepo.getDashboardDataStream();

      // Use a timer to debounce rapid emissions
      DashboardData? lastEmittedData;
      DateTime? lastEmitTime;
      const debounceMs = 500; // Wait 500ms before processing next emission

      // Merge streams
      await for (final dashboardData in dashboardStream) {
        final now = DateTime.now();

        // Skip if we just emitted data (debounce)
        if (lastEmitTime != null &&
            now.difference(lastEmitTime).inMilliseconds < debounceMs) {
          continue;
        }

        // Skip if data hasn't changed
        if (lastEmittedData != null &&
            lastEmittedData.totalOmset == dashboardData.totalOmset &&
            lastEmittedData.totalTransactions ==
                dashboardData.totalTransactions &&
            lastEmittedData.totalExpenses == dashboardData.totalExpenses) {
          continue;
        }

        lastEmitTime = now;
        lastEmittedData = dashboardData;

        // Get monthly omset for tax calculation (ALWAYS from current month)
        final currentNow = DateTime.now();
        final currentMonthStart = DateTime(
          currentNow.year,
          currentNow.month,
          1,
        );
        final currentMonthEnd = DateTime(
          currentNow.year,
          currentNow.month + 1,
          0,
          23,
          59,
          59,
        );

        final monthlySummary = await transactionRepo.getTransactionSummary(
          startDate: currentMonthStart,
          endDate: currentMonthEnd,
        );

        // Get tier breakdown for selected period (only if not cached)
        final tierBreakdown =
            cachedTierBreakdown ??
            await transactionRepo.getTierBreakdown(
              startDate: periodRange.start,
              endDate: periodRange.end,
            );

        // Cache the tier breakdown for this period
        _tierBreakdownCache[period] = tierBreakdown;
        cachedTierBreakdown = tierBreakdown;

        // Calculate tax (0.5% of monthly omset) - ALWAYS from current month
        final taxAmount = (monthlySummary.totalOmset * 0.005).round();

        yield DashboardState(
          todayOmset: dashboardData.totalOmset,
          todayHpp:
              dashboardData.totalOmset -
              dashboardData.totalProfit -
              dashboardData.totalExpenses, // FIX: Calculate HPP
          todayExpenses: dashboardData.totalExpenses,
          todayProfit: dashboardData.totalProfit,
          todayTransactionCount: dashboardData.totalTransactions,
          todayAverageTransaction: dashboardData.averageTransaction,
          monthlyOmset: monthlySummary.totalOmset,
          taxAmount: taxAmount,
          tierBreakdown: tierBreakdown,
          isLoading: false,
        );
      }
    });

/// Real-time profit indicator stream provider
final profitIndicatorStreamProvider = StreamProvider<ProfitIndicator>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return Stream.value(
      ProfitIndicator(
        grossProfit: 0,
        netProfit: 0,
        profitMargin: 0,
        totalOmset: 0,
        totalHpp: 0,
        totalExpenses: 0,
      ),
    );
  }
  final repository = getIt<DashboardRepository>();
  return repository.getProfitIndicatorStream();
});

/// Real-time tax indicator stream provider
final taxIndicatorStreamProvider =
    StreamProvider.family<TaxIndicator, TaxPeriod>((ref, period) {
      if (!SupabaseConfig.isConfigured) {
        return Stream.value(
          TaxIndicator(
            month: period.month,
            year: period.year,
            totalOmset: 0,
            taxAmount: 0,
            isPaid: false,
          ),
        );
      }
      final repository = getIt<DashboardRepository>();
      return repository.getTaxIndicatorStream(
        month: period.month,
        year: period.year,
      );
    });

/// Tax period helper class
class TaxPeriod {
  final int month;
  final int year;

  TaxPeriod({required this.month, required this.year});

  factory TaxPeriod.current() {
    final now = DateTime.now();
    return TaxPeriod(month: now.month, year: now.year);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxPeriod &&
          runtimeType == other.runtimeType &&
          month == other.month &&
          year == other.year;

  @override
  int get hashCode => month.hashCode ^ year.hashCode;
}
