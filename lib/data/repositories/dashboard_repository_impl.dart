import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/domain/repositories/dashboard_repository.dart';
import 'package:posfelix/core/utils/logger.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final SupabaseClient _client;

  DashboardRepositoryImpl(this._client);

  @override
  Future<DashboardData> getDashboardData() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getDashboardDataForRange(startDate: startOfDay, endDate: endOfDay);
  }

  @override
  Future<DashboardData> getDashboardDataForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Get transactions
      final transactionResponse = await _client
          .from('transactions')
          .select('tier, total, total_hpp, profit, payment_method')
          .eq('payment_status', 'COMPLETED')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      // Get expenses
      final startDateStr =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      final expenseResponse = await _client
          .from('expenses')
          .select('amount')
          .gte('expense_date', startDateStr)
          .lte('expense_date', endDateStr);

      // Calculate totals
      int totalOmset = 0;
      int totalProfit = 0;
      int totalExpenses = 0;

      final Map<String, int> tierBreakdown = {
        'UMUM': 0,
        'BENGKEL': 0,
        'GROSSIR': 0,
      };

      final Map<String, int> paymentMethodBreakdown = {};

      // Process transactions
      for (final row in transactionResponse) {
        final omset = (row['total'] as num).toInt();
        final profit = (row['profit'] as num).toInt();
        final tier = row['tier'] as String;
        final paymentMethod = row['payment_method'] as String;

        totalOmset += omset;
        totalProfit += profit;

        tierBreakdown[tier] = (tierBreakdown[tier] ?? 0) + omset;
        paymentMethodBreakdown[paymentMethod] =
            (paymentMethodBreakdown[paymentMethod] ?? 0) + 1;
      }

      // Process expenses
      for (final row in expenseResponse) {
        totalExpenses += (row['amount'] as num).toInt();
      }

      final count = transactionResponse.length;
      final average = count > 0 ? totalOmset ~/ count : 0;

      return DashboardData(
        totalTransactions: count,
        totalOmset: totalOmset,
        totalProfit: totalProfit,
        totalExpenses: totalExpenses,
        averageTransaction: average,
        tierBreakdown: tierBreakdown,
        paymentMethodBreakdown: paymentMethodBreakdown,
      );
    } catch (e) {
      AppLogger.error('Error getting dashboard data', e);
      rethrow;
    }
  }

  @override
  Future<ProfitIndicator> getProfitIndicator({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start = startDate ?? DateTime(DateTime.now().year, 1, 1);
      final end = endDate ?? DateTime.now();

      // Get transactions
      final transactionResponse = await _client
          .from('transactions')
          .select('total, total_hpp, profit')
          .eq('payment_status', 'COMPLETED')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      // Get expenses
      final startDateStr =
          '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
      final endDateStr =
          '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

      final expenseResponse = await _client
          .from('expenses')
          .select('amount')
          .gte('expense_date', startDateStr)
          .lte('expense_date', endDateStr);

      int totalOmset = 0;
      int totalHpp = 0;
      int totalExpenses = 0;

      for (final row in transactionResponse) {
        totalOmset += (row['total'] as num).toInt();
        totalHpp += (row['total_hpp'] as num).toInt();
      }

      for (final row in expenseResponse) {
        totalExpenses += (row['amount'] as num).toInt();
      }

      final grossProfit = totalOmset - totalHpp;
      final netProfit = grossProfit - totalExpenses;
      final profitMargin = totalOmset > 0
          ? (netProfit / totalOmset) * 100
          : 0.0;

      return ProfitIndicator(
        grossProfit: grossProfit,
        netProfit: netProfit,
        profitMargin: profitMargin,
        totalOmset: totalOmset,
        totalHpp: totalHpp,
        totalExpenses: totalExpenses,
      );
    } catch (e) {
      AppLogger.error('Error getting profit indicator', e);
      rethrow;
    }
  }

  @override
  Future<TaxIndicator> getTaxIndicator({
    required int month,
    required int year,
  }) async {
    try {
      // Get start and end of month
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      // Get total omset from transactions
      final transactionResponse = await _client
          .from('transactions')
          .select('total')
          .eq('payment_status', 'COMPLETED')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String());

      int totalOmset = 0;
      for (final row in transactionResponse) {
        totalOmset += (row['total'] as num).toInt();
      }

      // Calculate tax (0.5%)
      final taxAmount = (totalOmset * 0.005).round();

      // Check if already paid
      final taxPaymentResponse = await _client
          .from('tax_payments')
          .select('is_paid, paid_at')
          .eq('period_month', month)
          .eq('period_year', year)
          .maybeSingle();

      final isPaid = taxPaymentResponse?['is_paid'] as bool? ?? false;
      final paidAtStr = taxPaymentResponse?['paid_at'] as String?;
      final paidAt = paidAtStr != null ? DateTime.tryParse(paidAtStr) : null;

      return TaxIndicator(
        month: month,
        year: year,
        totalOmset: totalOmset,
        taxAmount: taxAmount,
        isPaid: isPaid,
        paidAt: paidAt,
      );
    } catch (e) {
      AppLogger.error('Error getting tax indicator', e);
      rethrow;
    }
  }

  // ============================================
  // STREAM METHODS (Real-time updates)
  // ============================================

  @override
  Stream<DashboardData> getDashboardDataStream() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getDashboardDataStreamForRange(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  @override
  Stream<DashboardData> getDashboardDataStreamForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    try {
      // Stream transactions for the date range
      return _client
          .from('transactions')
          .stream(primaryKey: ['id'])
          .asyncMap((data) async {
            // Filter transactions for the date range
            final transactions = data.where((row) {
              final createdAt = DateTime.tryParse(row['created_at'] ?? '');
              if (createdAt == null) return false;
              return createdAt.isAfter(startDate) &&
                  createdAt.isBefore(endDate) &&
                  row['payment_status'] == 'COMPLETED';
            }).toList();

            // Calculate totals
            int totalOmset = 0;
            int totalProfit = 0;

            final Map<String, int> tierBreakdown = {
              'UMUM': 0,
              'BENGKEL': 0,
              'GROSSIR': 0,
            };

            final Map<String, int> paymentMethodBreakdown = {};

            for (final row in transactions) {
              final omset = (row['total'] as num).toInt();
              final profit = (row['profit'] as num).toInt();
              final tier = row['tier'] as String;
              final paymentMethod = row['payment_method'] as String;

              totalOmset += omset;
              totalProfit += profit;

              tierBreakdown[tier] = (tierBreakdown[tier] ?? 0) + omset;
              paymentMethodBreakdown[paymentMethod] =
                  (paymentMethodBreakdown[paymentMethod] ?? 0) + 1;
            }

            // Get expenses (need to fetch separately)
            final startDateStr =
                '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
            final endDateStr =
                '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

            final expenseResponse = await _client
                .from('expenses')
                .select('amount')
                .gte('expense_date', startDateStr)
                .lte('expense_date', endDateStr);

            int totalExpenses = 0;
            for (final row in expenseResponse) {
              totalExpenses += (row['amount'] as num).toInt();
            }

            final count = transactions.length;
            final average = count > 0 ? totalOmset ~/ count : 0;

            return DashboardData(
              totalTransactions: count,
              totalOmset: totalOmset,
              totalProfit: totalProfit,
              totalExpenses: totalExpenses,
              averageTransaction: average,
              tierBreakdown: tierBreakdown,
              paymentMethodBreakdown: paymentMethodBreakdown,
            );
          })
          .handleError((error) {
            AppLogger.error('Error streaming dashboard data', error);
          });
    } catch (e) {
      AppLogger.error('Error setting up dashboard data stream', e);
      rethrow;
    }
  }

  @override
  Stream<ProfitIndicator> getProfitIndicatorStream({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final start = startDate ?? DateTime(DateTime.now().year, 1, 1);
    final end = endDate ?? DateTime.now();

    try {
      return _client
          .from('transactions')
          .stream(primaryKey: ['id'])
          .asyncMap((data) async {
            // Filter transactions for the date range
            final transactions = data.where((row) {
              final createdAt = DateTime.tryParse(row['created_at'] ?? '');
              if (createdAt == null) return false;
              return createdAt.isAfter(start) &&
                  createdAt.isBefore(end) &&
                  row['payment_status'] == 'COMPLETED';
            }).toList();

            int totalOmset = 0;
            int totalHpp = 0;

            for (final row in transactions) {
              totalOmset += (row['total'] as num).toInt();
              totalHpp += (row['total_hpp'] as num).toInt();
            }

            // Get expenses
            final startDateStr =
                '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
            final endDateStr =
                '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

            final expenseResponse = await _client
                .from('expenses')
                .select('amount')
                .gte('expense_date', startDateStr)
                .lte('expense_date', endDateStr);

            int totalExpenses = 0;
            for (final row in expenseResponse) {
              totalExpenses += (row['amount'] as num).toInt();
            }

            final grossProfit = totalOmset - totalHpp;
            final netProfit = grossProfit - totalExpenses;
            final profitMargin = totalOmset > 0
                ? (netProfit / totalOmset) * 100
                : 0.0;

            return ProfitIndicator(
              grossProfit: grossProfit,
              netProfit: netProfit,
              profitMargin: profitMargin,
              totalOmset: totalOmset,
              totalHpp: totalHpp,
              totalExpenses: totalExpenses,
            );
          })
          .handleError((error) {
            AppLogger.error('Error streaming profit indicator', error);
          });
    } catch (e) {
      AppLogger.error('Error setting up profit indicator stream', e);
      rethrow;
    }
  }

  @override
  Stream<TaxIndicator> getTaxIndicatorStream({
    required int month,
    required int year,
  }) {
    // Get start and end of month
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    try {
      return _client
          .from('transactions')
          .stream(primaryKey: ['id'])
          .asyncMap((data) async {
            // Filter transactions for the month
            final transactions = data.where((row) {
              final createdAt = DateTime.tryParse(row['created_at'] ?? '');
              if (createdAt == null) return false;
              return createdAt.isAfter(startDate) &&
                  createdAt.isBefore(endDate) &&
                  row['payment_status'] == 'COMPLETED';
            }).toList();

            int totalOmset = 0;
            for (final row in transactions) {
              totalOmset += (row['total'] as num).toInt();
            }

            // Calculate tax (0.5%)
            final taxAmount = (totalOmset * 0.005).round();

            // Check if already paid
            final taxPaymentResponse = await _client
                .from('tax_payments')
                .select('is_paid, paid_at')
                .eq('period_month', month)
                .eq('period_year', year)
                .maybeSingle();

            final isPaid = taxPaymentResponse?['is_paid'] as bool? ?? false;
            final paidAtStr = taxPaymentResponse?['paid_at'] as String?;
            final paidAt = paidAtStr != null
                ? DateTime.tryParse(paidAtStr)
                : null;

            return TaxIndicator(
              month: month,
              year: year,
              totalOmset: totalOmset,
              taxAmount: taxAmount,
              isPaid: isPaid,
              paidAt: paidAt,
            );
          })
          .handleError((error) {
            AppLogger.error('Error streaming tax indicator', error);
          });
    } catch (e) {
      AppLogger.error('Error setting up tax indicator stream', e);
      rethrow;
    }
  }
}
