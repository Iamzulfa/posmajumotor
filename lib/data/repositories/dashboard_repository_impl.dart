import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/domain/repositories/dashboard_repository.dart';
import 'package:posfelix/core/utils/logger.dart';
import 'package:posfelix/core/extensions/stream_extensions.dart';
import 'package:posfelix/core/services/offline_service.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final SupabaseClient _client;
  final OfflineService _offlineService = OfflineService();

  // Stream caching to prevent multiple subscriptions
  Stream<DashboardData>? _cachedDashboardDataStream;
  String? _cachedDashboardDataStreamDate; // Track which date the cache is for
  Stream<ProfitIndicator>? _cachedProfitIndicatorStream;
  final Map<String, Stream<TaxIndicator>> _cachedTaxIndicatorStreams = {};

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

    // Create a date key to invalidate cache when day changes
    final dateKey = '${startOfDay.year}-${startOfDay.month}-${startOfDay.day}';

    // If cache exists but is for a different day, invalidate it
    if (_cachedDashboardDataStreamDate != dateKey) {
      _cachedDashboardDataStream = null;
      _cachedDashboardDataStreamDate = null;
    }

    if (_cachedDashboardDataStream != null) {
      return _cachedDashboardDataStream!;
    }

    _cachedDashboardDataStreamDate = dateKey;
    _cachedDashboardDataStream = getDashboardDataStreamForRange(
      startDate: startOfDay,
      endDate: endOfDay,
    ).shareReplay(bufferSize: 1);

    return _cachedDashboardDataStream!;
  }

  @override
  Stream<DashboardData> getDashboardDataStreamForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    try {
      AppLogger.info(
        '🔍 Dashboard stream starting for range: $startDate to $endDate',
      );

      // Use polling instead of Realtime to avoid connection issues
      // Poll every 5 seconds for updates
      return Stream.periodic(
        const Duration(seconds: 5),
        (_) => _fetchInitialDashboardData(startDate, endDate),
      ).asyncExpand((future) => future.asStream()).distinct().handleError(
        (error) {
          AppLogger.error('Error fetching dashboard data', error);
          // Don't rethrow - return empty data instead
        },
        test: (error) => true, // Handle all errors
      );
    } catch (e) {
      AppLogger.error('❌ Error setting up dashboard data stream', e);
      return Stream.value(
        DashboardData(
          totalTransactions: 0,
          totalOmset: 0,
          totalProfit: 0,
          totalExpenses: 0,
          averageTransaction: 0,
          tierBreakdown: {'UMUM': 0, 'BENGKEL': 0, 'GROSSIR': 0},
          paymentMethodBreakdown: {},
        ),
      );
    }
  }

  Future<DashboardData> _fetchInitialDashboardData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Convert to UTC for database query
      final startUtc = startDate.toUtc();
      final endUtc = endDate.toUtc();

      AppLogger.info(
        '📥 Fetching dashboard data from $startUtc to $endUtc (UTC)',
      );

      // Get transactions - first try with COMPLETED status
      var transactionResponse = await _client
          .from('transactions')
          .select(
            'tier, total, total_hpp, profit, payment_method, payment_status, created_at',
          )
          .gte('created_at', startUtc.toIso8601String())
          .lt('created_at', endUtc.toIso8601String());

      AppLogger.info(
        '📦 Received ${transactionResponse.length} transactions (all statuses)',
      );

      // Log the statuses we're getting
      final statusCounts = <String, int>{};
      for (final tx in transactionResponse) {
        final status = tx['payment_status'] as String?;
        statusCounts[status ?? 'null'] =
            (statusCounts[status ?? 'null'] ?? 0) + 1;
      }
      AppLogger.info('   Status breakdown: $statusCounts');

      // Filter for COMPLETED only
      final completedTransactions = transactionResponse
          .where((tx) => tx['payment_status'] == 'COMPLETED')
          .toList();

      AppLogger.info(
        '📦 Filtered to ${completedTransactions.length} COMPLETED transactions',
      );

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

      AppLogger.info('📦 Received ${expenseResponse.length} expenses');

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

      // Process transactions (use completed only)
      for (final row in completedTransactions) {
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

      final count = completedTransactions.length;
      final average = count > 0 ? totalOmset ~/ count : 0;

      final dashboardData = DashboardData(
        totalTransactions: count,
        totalOmset: totalOmset,
        totalProfit: totalProfit,
        totalExpenses: totalExpenses,
        averageTransaction: average,
        tierBreakdown: tierBreakdown,
        paymentMethodBreakdown: paymentMethodBreakdown,
      );

      // Cache for offline use
      await _offlineService.cacheData(
        'dashboard_data_${startDate.toIso8601String()}',
        dashboardData,
      );

      AppLogger.info(
        '📥 Initial dashboard data loaded - Transactions: $count, Omset: $totalOmset, Expenses: $totalExpenses',
      );

      return dashboardData;
    } catch (e) {
      AppLogger.error('Error fetching initial dashboard data', e);

      // Try to return cached data if offline
      if (!_offlineService.isOnline) {
        final cached = _offlineService.getCachedData(
          'dashboard_data_${startDate.toIso8601String()}',
        );
        if (cached != null) {
          AppLogger.info('📦 Using cached dashboard data (offline mode)');

          // Handle both DashboardData object and Map (from Hive serialization)
          if (cached is DashboardData) {
            return cached;
          } else if (cached is Map) {
            return DashboardData(
              totalTransactions:
                  (cached['totalTransactions'] as num?)?.toInt() ?? 0,
              totalOmset: (cached['totalOmset'] as num?)?.toInt() ?? 0,
              totalProfit: (cached['totalProfit'] as num?)?.toInt() ?? 0,
              totalExpenses: (cached['totalExpenses'] as num?)?.toInt() ?? 0,
              averageTransaction:
                  (cached['averageTransaction'] as num?)?.toInt() ?? 0,
              tierBreakdown: Map<String, int>.from(
                cached['tierBreakdown'] as Map? ?? {},
              ),
              paymentMethodBreakdown: Map<String, int>.from(
                cached['paymentMethodBreakdown'] as Map? ?? {},
              ),
            );
          }
        }
      }

      return DashboardData(
        totalTransactions: 0,
        totalOmset: 0,
        totalProfit: 0,
        totalExpenses: 0,
        averageTransaction: 0,
        tierBreakdown: {'UMUM': 0, 'BENGKEL': 0, 'GROSSIR': 0},
        paymentMethodBreakdown: {},
      );
    }
  }

  @override
  Stream<ProfitIndicator> getProfitIndicatorStream({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (startDate == null && endDate == null) {
      if (_cachedProfitIndicatorStream != null) {
        return _cachedProfitIndicatorStream!;
      }

      final start = DateTime(DateTime.now().year, 1, 1);
      final end = DateTime.now();

      _cachedProfitIndicatorStream = _buildProfitStream(
        start,
        end,
      ).shareReplay(bufferSize: 1);

      return _cachedProfitIndicatorStream!;
    }

    final start = startDate ?? DateTime(DateTime.now().year, 1, 1);
    final end = endDate ?? DateTime.now();

    return _buildProfitStream(start, end);
  }

  Stream<ProfitIndicator> _buildProfitStream(DateTime start, DateTime end) {
    try {
      // Use polling instead of Realtime to avoid connection issues
      // Poll every 5 seconds for updates
      return Stream.periodic(
            const Duration(seconds: 5),
            (_) => _fetchInitialProfitData(start, end),
          )
          .asyncExpand((future) => future.asStream())
          .distinct()
          .handleError(
            (error) {
              AppLogger.error('Error streaming profit indicator', error);
              // Don't rethrow - return empty data instead
            },
            test: (error) => true, // Handle all errors
          )
          .shareReplay(bufferSize: 1);
    } catch (e) {
      AppLogger.error('Error setting up profit indicator stream', e);
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
  }

  Future<ProfitIndicator> _fetchInitialProfitData(
    DateTime start,
    DateTime end,
  ) async {
    try {
      // Convert to UTC for database query
      final startUtc = start.toUtc();
      final endUtc = end.toUtc();

      // Get transactions
      final transactionResponse = await _client
          .from('transactions')
          .select('total, total_hpp, profit')
          .eq('payment_status', 'COMPLETED')
          .gte('created_at', startUtc.toIso8601String())
          .lt('created_at', endUtc.toIso8601String());

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

      AppLogger.info(
        '📥 Initial profit data loaded - Omset: $totalOmset, Profit: $netProfit',
      );

      return ProfitIndicator(
        grossProfit: grossProfit,
        netProfit: netProfit,
        profitMargin: profitMargin,
        totalOmset: totalOmset,
        totalHpp: totalHpp,
        totalExpenses: totalExpenses,
      );
    } catch (e) {
      AppLogger.error('Error fetching initial profit data', e);
      return ProfitIndicator(
        grossProfit: 0,
        netProfit: 0,
        profitMargin: 0,
        totalOmset: 0,
        totalHpp: 0,
        totalExpenses: 0,
      );
    }
  }

  @override
  Stream<TaxIndicator> getTaxIndicatorStream({
    required int month,
    required int year,
  }) {
    final key = '$month-$year';
    if (_cachedTaxIndicatorStreams.containsKey(key)) {
      return _cachedTaxIndicatorStreams[key]!;
    }

    // Get start and end of month
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    try {
      // Use polling instead of Realtime to avoid connection issues
      // Poll every 5 seconds for updates
      final stream =
          Stream.periodic(
                const Duration(seconds: 5),
                (_) => _fetchInitialTaxData(month, year, startDate, endDate),
              )
              .asyncExpand((future) => future.asStream())
              .distinct()
              .handleError(
                (error) {
                  AppLogger.error('Error streaming tax indicator', error);
                  // Don't rethrow - return empty data instead
                },
                test: (error) => true, // Handle all errors
              )
              .shareReplay(bufferSize: 1);

      _cachedTaxIndicatorStreams[key] = stream;
      return stream;
    } catch (e) {
      AppLogger.error('Error setting up tax indicator stream', e);
      return Stream.value(
        TaxIndicator(
          month: month,
          year: year,
          totalOmset: 0,
          taxAmount: 0,
          isPaid: false,
          paidAt: null,
        ),
      );
    }
  }

  Future<TaxIndicator> _fetchInitialTaxData(
    int month,
    int year,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Convert to UTC for database query
      final startUtc = startDate.toUtc();
      final endUtc = endDate.toUtc();

      // Get total omset from transactions
      final transactionResponse = await _client
          .from('transactions')
          .select('total')
          .eq('payment_status', 'COMPLETED')
          .gte('created_at', startUtc.toIso8601String())
          .lt('created_at', endUtc.toIso8601String());

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

      AppLogger.info(
        '📥 Initial tax data loaded - Month: $month/$year, Omset: $totalOmset, Tax: $taxAmount',
      );

      return TaxIndicator(
        month: month,
        year: year,
        totalOmset: totalOmset,
        taxAmount: taxAmount,
        isPaid: isPaid,
        paidAt: paidAt,
      );
    } catch (e) {
      AppLogger.error('Error fetching initial tax data', e);
      return TaxIndicator(
        month: month,
        year: year,
        totalOmset: 0,
        taxAmount: 0,
        isPaid: false,
        paidAt: null,
      );
    }
  }
}
