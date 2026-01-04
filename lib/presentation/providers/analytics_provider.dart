import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/transaction_repository.dart';
import 'package:posfelix/domain/repositories/expense_repository.dart';
import 'package:posfelix/injection_container.dart';
import 'package:posfelix/config/constants/supabase_config.dart';
import 'package:posfelix/core/utils/logger.dart';

/// Analytics data provider with advanced filtering
final analyticsDataProvider =
    FutureProvider.family<AnalyticsData, AnalyticsFilter>((ref, filter) async {
      if (!SupabaseConfig.isConfigured) {
        return AnalyticsData.empty();
      }

      final transactionRepo = getIt<TransactionRepository>();
      final expenseRepo = getIt<ExpenseRepository>();

      try {
        final dateRange = filter.getDateRange();

        // Fetch all required data in parallel
        final results = await Future.wait([
          transactionRepo.getTransactions(
            startDate: dateRange.startDate,
            endDate: dateRange.endDate,
          ),
          transactionRepo.getTierBreakdown(
            startDate: dateRange.startDate,
            endDate: dateRange.endDate,
          ),
          expenseRepo.getExpenses(
            startDate: dateRange.startDate,
            endDate: dateRange.endDate,
          ),
        ]);

        final transactions = results[0] as List<TransactionModel>;
        final tierBreakdown = results[1] as Map<String, TierSummary>;
        final expenses = results[2] as List<ExpenseModel>;

        return AnalyticsData.fromTransactions(
          transactions: transactions,
          tierBreakdown: tierBreakdown,
          expenses: expenses,
          filter: filter,
        );
      } catch (e) {
        AppLogger.error('Error fetching analytics data', e);
        rethrow;
      }
    });

/// Analytics filter for different time periods
class AnalyticsFilter {
  final AnalyticsPeriod period;
  final DateTime? specificDate;
  final int? year;
  final int? month;
  final int? week;

  const AnalyticsFilter._({
    required this.period,
    this.specificDate,
    this.year,
    this.month,
    this.week,
  });

  factory AnalyticsFilter.daily(DateTime date) {
    return AnalyticsFilter._(period: AnalyticsPeriod.daily, specificDate: date);
  }

  factory AnalyticsFilter.weekly(int year, int month, int week) {
    return AnalyticsFilter._(
      period: AnalyticsPeriod.weekly,
      year: year,
      month: month,
      week: week,
    );
  }

  factory AnalyticsFilter.monthly(int year, int month) {
    return AnalyticsFilter._(
      period: AnalyticsPeriod.monthly,
      year: year,
      month: month,
    );
  }

  DateRange getDateRange() {
    switch (period) {
      case AnalyticsPeriod.daily:
        final date = specificDate!;
        return DateRange(
          startDate: DateTime(date.year, date.month, date.day),
          endDate: DateTime(date.year, date.month, date.day, 23, 59, 59),
        );

      case AnalyticsPeriod.weekly:
        final firstDayOfMonth = DateTime(year!, month!, 1);
        final startDate = firstDayOfMonth.add(Duration(days: (week! - 1) * 7));
        final endDate = startDate.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
        );
        return DateRange(startDate: startDate, endDate: endDate);

      case AnalyticsPeriod.monthly:
        final startDate = DateTime(year!, month!, 1);
        final endDate = DateTime(year!, month! + 1, 0, 23, 59, 59);
        return DateRange(startDate: startDate, endDate: endDate);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsFilter &&
        other.period == period &&
        other.specificDate == specificDate &&
        other.year == year &&
        other.month == month &&
        other.week == week;
  }

  @override
  int get hashCode {
    return Object.hash(period, specificDate, year, month, week);
  }
}

class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate});
}

enum AnalyticsPeriod { daily, weekly, monthly }

/// Comprehensive analytics data model
class AnalyticsData {
  // Basic metrics
  final int totalTransactions;
  final int totalOmset;
  final int totalHpp;
  final int totalProfit;
  final int totalExpenses;
  final int netProfit;

  // Tier breakdown
  final Map<String, TierAnalytics> tierBreakdown;

  // Payment method breakdown
  final Map<String, PaymentMethodAnalytics> paymentBreakdown;

  // Product analytics
  final List<ProductAnalytics> topProducts;

  // Time-based analytics
  final List<DailyAnalytics> dailyData;

  // Margin analysis
  final double averageMargin;
  final Map<String, double> marginByTier;

  const AnalyticsData({
    required this.totalTransactions,
    required this.totalOmset,
    required this.totalHpp,
    required this.totalProfit,
    required this.totalExpenses,
    required this.netProfit,
    required this.tierBreakdown,
    required this.paymentBreakdown,
    required this.topProducts,
    required this.dailyData,
    required this.averageMargin,
    required this.marginByTier,
  });

  factory AnalyticsData.empty() {
    return const AnalyticsData(
      totalTransactions: 0,
      totalOmset: 0,
      totalHpp: 0,
      totalProfit: 0,
      totalExpenses: 0,
      netProfit: 0,
      tierBreakdown: {},
      paymentBreakdown: {},
      topProducts: [],
      dailyData: [],
      averageMargin: 0,
      marginByTier: {},
    );
  }

  factory AnalyticsData.fromTransactions({
    required List<TransactionModel> transactions,
    required Map<String, TierSummary> tierBreakdown,
    required List<ExpenseModel> expenses,
    required AnalyticsFilter filter,
  }) {
    // Calculate basic metrics
    final totalTransactions = transactions.length;
    final totalOmset = transactions.fold<int>(0, (sum, t) => sum + t.total);
    final totalHpp = transactions.fold<int>(0, (sum, t) => sum + t.totalHpp);
    final totalProfit = transactions.fold<int>(0, (sum, t) => sum + t.profit);
    final totalExpenses = expenses.fold<int>(0, (sum, e) => sum + e.amount);
    final netProfit = totalProfit - totalExpenses;

    // Calculate tier analytics
    final tierAnalytics = <String, TierAnalytics>{};
    for (final entry in tierBreakdown.entries) {
      final tierTransactions = transactions
          .where((t) => t.tier == entry.key)
          .toList();
      tierAnalytics[entry.key] = TierAnalytics.fromTransactions(
        tier: entry.key,
        transactions: tierTransactions,
        summary: entry.value,
      );
    }

    // Calculate payment method breakdown
    final paymentAnalytics = <String, PaymentMethodAnalytics>{};
    final paymentGroups = <String, List<TransactionModel>>{};

    for (final transaction in transactions) {
      paymentGroups
          .putIfAbsent(transaction.paymentMethod, () => [])
          .add(transaction);
    }

    for (final entry in paymentGroups.entries) {
      paymentAnalytics[entry.key] = PaymentMethodAnalytics.fromTransactions(
        paymentMethod: entry.key,
        transactions: entry.value,
      );
    }

    // Calculate top products
    final productMap = <String, List<TransactionItemModel>>{};
    for (final transaction in transactions) {
      if (transaction.items != null) {
        for (final item in transaction.items!) {
          productMap.putIfAbsent(item.productId, () => []).add(item);
        }
      }
    }

    final topProducts =
        productMap.isEmpty
              ? <ProductAnalytics>[]
              : productMap.entries
                    .map(
                      (entry) => ProductAnalytics.fromItems(
                        productId: entry.key,
                        productName: entry.value.first.productName,
                        items: entry.value,
                      ),
                    )
                    .toList()
          ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    // Calculate daily data (for trends)
    final dailyData = _calculateDailyData(transactions, expenses, filter);

    // Calculate margins
    final averageMargin = totalHpp > 0
        ? ((totalProfit / totalHpp) * 100).toDouble()
        : 0.0;
    final marginByTier = <String, double>{};
    for (final entry in tierAnalytics.entries) {
      marginByTier[entry.key] = entry.value.marginPercent;
    }

    return AnalyticsData(
      totalTransactions: totalTransactions,
      totalOmset: totalOmset,
      totalHpp: totalHpp,
      totalProfit: totalProfit,
      totalExpenses: totalExpenses,
      netProfit: netProfit,
      tierBreakdown: tierAnalytics,
      paymentBreakdown: paymentAnalytics,
      topProducts: topProducts.take(10).toList(),
      dailyData: dailyData,
      averageMargin: averageMargin,
      marginByTier: marginByTier,
    );
  }

  static List<DailyAnalytics> _calculateDailyData(
    List<TransactionModel> transactions,
    List<ExpenseModel> expenses,
    AnalyticsFilter filter,
  ) {
    final dateRange = filter.getDateRange();
    final dailyMap = <String, DailyAnalytics>{};

    // Initialize all days in range
    var currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) ||
        currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final dateKey =
          '${currentDate.year}-${currentDate.month}-${currentDate.day}';
      dailyMap[dateKey] = DailyAnalytics(
        date: currentDate,
        transactions: 0,
        omset: 0,
        hpp: 0,
        profit: 0,
        expenses: 0,
        netProfit: 0,
        paymentBreakdown: {},
      );
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Add transaction data
    for (final transaction in transactions) {
      if (transaction.createdAt != null) {
        final date = transaction.createdAt!;
        final dateKey = '${date.year}-${date.month}-${date.day}';
        final existing = dailyMap[dateKey];
        if (existing != null) {
          dailyMap[dateKey] = existing.copyWith(
            transactions: existing.transactions + 1,
            omset: existing.omset + transaction.total,
            hpp: existing.hpp + transaction.totalHpp,
            profit: existing.profit + transaction.profit,
            paymentBreakdown: {
              ...existing.paymentBreakdown,
              transaction.paymentMethod:
                  (existing.paymentBreakdown[transaction.paymentMethod] ?? 0) +
                  transaction.total,
            },
          );
        }
      }
    }

    // Add expense data
    for (final expense in expenses) {
      final date = expense.expenseDate;
      final dateKey = '${date.year}-${date.month}-${date.day}';
      final existing = dailyMap[dateKey];
      if (existing != null) {
        dailyMap[dateKey] = existing.copyWith(
          expenses: existing.expenses + expense.amount,
          netProfit: existing.profit - (existing.expenses + expense.amount),
        );
      }
    }

    return dailyMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));
  }
}

/// Tier-specific analytics
class TierAnalytics {
  final String tier;
  final int transactionCount;
  final int totalOmset;
  final int totalHpp;
  final int totalProfit;
  final double marginPercent;
  final int averageTransactionValue;
  final Map<String, int> paymentMethodBreakdown;

  const TierAnalytics({
    required this.tier,
    required this.transactionCount,
    required this.totalOmset,
    required this.totalHpp,
    required this.totalProfit,
    required this.marginPercent,
    required this.averageTransactionValue,
    required this.paymentMethodBreakdown,
  });

  factory TierAnalytics.fromTransactions({
    required String tier,
    required List<TransactionModel> transactions,
    required TierSummary summary,
  }) {
    final paymentBreakdown = <String, int>{};
    for (final transaction in transactions) {
      paymentBreakdown[transaction.paymentMethod] =
          (paymentBreakdown[transaction.paymentMethod] ?? 0) +
          transaction.total;
    }

    return TierAnalytics(
      tier: tier,
      transactionCount: summary.transactionCount,
      totalOmset: summary.totalOmset,
      totalHpp: summary.totalHpp,
      totalProfit: summary.totalProfit,
      marginPercent: summary.totalHpp > 0
          ? ((summary.totalProfit / summary.totalHpp) * 100).toDouble()
          : 0.0,
      averageTransactionValue: summary.transactionCount > 0
          ? (summary.totalOmset / summary.transactionCount).round()
          : 0,
      paymentMethodBreakdown: paymentBreakdown,
    );
  }

  String get displayName {
    switch (tier) {
      case 'UMUM':
        return 'Orang Umum';
      case 'BENGKEL':
        return 'Bengkel';
      case 'GROSSIR':
        return 'Grossir';
      default:
        return tier;
    }
  }
}

/// Payment method analytics
class PaymentMethodAnalytics {
  final String paymentMethod;
  final int transactionCount;
  final int totalAmount;
  final double percentage;
  final int averageTransactionValue;

  const PaymentMethodAnalytics({
    required this.paymentMethod,
    required this.transactionCount,
    required this.totalAmount,
    required this.percentage,
    required this.averageTransactionValue,
  });

  factory PaymentMethodAnalytics.fromTransactions({
    required String paymentMethod,
    required List<TransactionModel> transactions,
  }) {
    final totalAmount = transactions.fold<int>(0, (sum, t) => sum + t.total);
    final transactionCount = transactions.length;
    final averageTransactionValue = transactionCount > 0
        ? (totalAmount / transactionCount)
        : 0;

    return PaymentMethodAnalytics(
      paymentMethod: paymentMethod,
      transactionCount: transactionCount,
      totalAmount: totalAmount,
      percentage: 0, // Will be calculated later with total context
      averageTransactionValue: averageTransactionValue.round(),
    );
  }

  String get displayName {
    switch (paymentMethod) {
      case 'CASH':
        return 'Tunai';
      case 'TRANSFER':
        return 'Transfer';
      case 'QRIS':
        return 'QRIS';
      default:
        return paymentMethod;
    }
  }
}

/// Product analytics
class ProductAnalytics {
  final String productId;
  final String productName;
  final int quantitySold;
  final int totalRevenue;
  final int totalProfit;
  final double marginPercent;

  const ProductAnalytics({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalRevenue,
    required this.totalProfit,
    required this.marginPercent,
  });

  factory ProductAnalytics.fromItems({
    required String productId,
    required String productName,
    required List<TransactionItemModel> items,
  }) {
    final quantitySold = items.fold<int>(0, (sum, item) => sum + item.quantity);
    final totalRevenue = items.fold<int>(0, (sum, item) => sum + item.subtotal);
    final totalProfit = items.fold<int>(0, (sum, item) => sum + item.profit);
    final totalHpp = items.fold<int>(
      0,
      (sum, item) => sum + (item.unitHpp * item.quantity),
    );
    final marginPercent = totalHpp > 0
        ? ((totalProfit / totalHpp) * 100).toDouble()
        : 0.0;

    return ProductAnalytics(
      productId: productId,
      productName: productName,
      quantitySold: quantitySold,
      totalRevenue: totalRevenue,
      totalProfit: totalProfit,
      marginPercent: marginPercent,
    );
  }
}

/// Daily analytics data
class DailyAnalytics {
  final DateTime date;
  final int transactions;
  final int omset;
  final int hpp;
  final int profit;
  final int expenses;
  final int netProfit;
  final Map<String, int> paymentBreakdown;

  const DailyAnalytics({
    required this.date,
    required this.transactions,
    required this.omset,
    required this.hpp,
    required this.profit,
    required this.expenses,
    required this.netProfit,
    required this.paymentBreakdown,
  });

  DailyAnalytics copyWith({
    DateTime? date,
    int? transactions,
    int? omset,
    int? hpp,
    int? profit,
    int? expenses,
    int? netProfit,
    Map<String, int>? paymentBreakdown,
  }) {
    return DailyAnalytics(
      date: date ?? this.date,
      transactions: transactions ?? this.transactions,
      omset: omset ?? this.omset,
      hpp: hpp ?? this.hpp,
      profit: profit ?? this.profit,
      expenses: expenses ?? this.expenses,
      netProfit: netProfit ?? (this.profit - (expenses ?? this.expenses)),
      paymentBreakdown: paymentBreakdown ?? this.paymentBreakdown,
    );
  }
}
