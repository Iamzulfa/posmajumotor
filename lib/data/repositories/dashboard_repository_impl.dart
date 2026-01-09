import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/domain/repositories/dashboard_repository.dart';
import 'package:posfelix/core/utils/logger.dart';
import 'package:posfelix/core/extensions/stream_extensions.dart';
import 'package:posfelix/core/services/offline_service.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final SupabaseClient _client;
  final OfflineService _offlineService = OfflineService();

  // Stream caching for profit and tax indicators (less frequently updated)
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

    // Don't cache stream - let Riverpod handle caching via provider
    // This allows ref.invalidate() to create a fresh stream
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
      AppLogger.info(
        '🔍 Dashboard stream starting for range: $startDate to $endDate',
      );

      // IMPORTANT: Emit initial data immediately, then poll for updates
      // This prevents waiting for the first polling interval
      return Stream.fromFuture(_fetchInitialDashboardData(startDate, endDate))
          .asyncExpand((initialData) async* {
            // Emit initial data first
            yield initialData;

            // Then poll for updates every 60 seconds
            await for (final _ in Stream.periodic(
              const Duration(seconds: 60),
            )) {
              try {
                final data = await _fetchInitialDashboardData(
                  startDate,
                  endDate,
                );
                yield data;
              } catch (e) {
                AppLogger.error('Error in dashboard polling', e);
              }
            }
          })
          .distinct()
          .handleError(
            (error) {
              AppLogger.error('Error fetching dashboard data', error);
              // Don't rethrow - return empty data instead
            },
            test: (error) => true, // Handle all errors
          );
    } catch (e) {
      AppLogger.error('❌ Error setting up dashboard data stream', e);
      return Stream.value(_emptyDashboardData());
    }
  }

  Future<DashboardData> _fetchInitialDashboardData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final cacheKey = 'dashboard_data_${startDate.toIso8601String()}';

    try {
      // Check if offline first
      if (!_offlineService.isOnline) {
        AppLogger.info('📦 Offline mode - using cached dashboard data');
        final cached = _offlineService.getCachedData(cacheKey);
        if (cached != null && cached is Map) {
          return _mapToDashboardData(cached);
        }
        return _emptyDashboardData();
      }

      // Convert to UTC for database query
      final startUtc = startDate.toUtc();
      final endUtc = endDate.toUtc();

      AppLogger.info(
        '📥 Fetching dashboard data from $startUtc to $endUtc (UTC)',
      );

      // Get transactions with timeout - first try with COMPLETED status
      var transactionResponse = await _client
          .from('transactions')
          .select(
            'tier, total, total_hpp, profit, payment_method, payment_status, created_at',
          )
          .gte('created_at', startUtc.toIso8601String())
          .lt('created_at', endUtc.toIso8601String())
          .timeout(const Duration(seconds: 10));

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

      // Get expenses with timeout
      final startDateStr =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final endDateStr =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      final expenseResponse = await _client
          .from('expenses')
          .select('amount')
          .gte('expense_date', startDateStr)
          .lte('expense_date', endDateStr)
          .timeout(const Duration(seconds: 10));

      AppLogger.info('📦 Received ${expenseResponse.length} expenses');

      // Calculate totals
      int totalOmset = 0;
      int totalHpp = 0; // FIX: Calculate HPP from transactions
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
        final hpp = (row['total_hpp'] as num)
            .toInt(); // FIX: Get HPP from transaction
        final tier = row['tier'] as String;
        final paymentMethod = row['payment_method'] as String;

        totalOmset += omset;
        totalHpp += hpp; // FIX: Add HPP to total
        // FIX: Calculate profit as omset - hpp (before expenses)
        totalProfit += (omset - hpp);

        tierBreakdown[tier] = (tierBreakdown[tier] ?? 0) + omset;
        paymentMethodBreakdown[paymentMethod] =
            (paymentMethodBreakdown[paymentMethod] ?? 0) + 1;
      }

      // Process expenses
      for (final row in expenseResponse) {
        totalExpenses += (row['amount'] as num).toInt();
      }

      // Add fixed expenses as daily amounts (properly calculated)
      try {
        final fixedExpenseResponse = await _client
            .from('fixed_expenses')
            .select('amount')
            .eq('is_active', true);

        int totalFixedExpenses = 0;
        for (final row in fixedExpenseResponse) {
          totalFixedExpenses += (row['amount'] as num).toInt();
        }

        // Calculate daily portion of monthly fixed expenses
        // Get number of days in current month for accurate calculation
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final fixedExpensesDaily = totalFixedExpenses > 0
            ? (totalFixedExpenses / daysInMonth).round()
            : 0;

        totalExpenses += fixedExpensesDaily;

        AppLogger.info(
          '💡 Fixed expenses integrated: Monthly=Rp ${_formatNumber(totalFixedExpenses)}, Daily=Rp ${_formatNumber(fixedExpensesDaily)} ($daysInMonth days in month)',
        );
      } catch (e) {
        AppLogger.error('Error fetching fixed expenses for dashboard', e);
        // Continue without fixed expenses if there's an error
      }

      final count = completedTransactions.length;
      final average = count > 0 ? totalOmset ~/ count : 0;

      // FIX: Final profit calculation = gross profit - expenses
      final netProfit = totalProfit - totalExpenses;

      final dashboardData = DashboardData(
        totalTransactions: count,
        totalOmset: totalOmset,
        totalProfit: netProfit, // FIX: Use net profit (after expenses)
        totalExpenses: totalExpenses,
        averageTransaction: average,
        tierBreakdown: tierBreakdown,
        paymentMethodBreakdown: paymentMethodBreakdown,
      );

      // Cache for offline use (convert to JSON to avoid Hive adapter issues)
      final dashboardJson = {
        'totalTransactions': dashboardData.totalTransactions,
        'totalOmset': dashboardData.totalOmset,
        'totalProfit': dashboardData.totalProfit,
        'totalExpenses': dashboardData.totalExpenses,
        'averageTransaction': dashboardData.averageTransaction,
        'tierBreakdown': dashboardData.tierBreakdown,
        'paymentMethodBreakdown': dashboardData.paymentMethodBreakdown,
      };

      await _offlineService.cacheData(
        'dashboard_data_${startDate.toIso8601String()}',
        dashboardJson,
      );

      AppLogger.info(
        '📥 Initial dashboard data loaded - Transactions: $count, Omset: $totalOmset, HPP: $totalHpp, Expenses: $totalExpenses, Net Profit: $netProfit',
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
      // Poll every 60 seconds for updates (reduced frequency for better performance)
      return Stream.periodic(
            const Duration(seconds: 60),
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
      // Poll every 60 seconds for updates (reduced frequency for better performance)
      final stream =
          Stream.periodic(
                const Duration(seconds: 60),
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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  /// Helper to convert cached Map to DashboardData
  DashboardData _mapToDashboardData(Map cached) {
    return DashboardData(
      totalTransactions: (cached['totalTransactions'] as num?)?.toInt() ?? 0,
      totalOmset: (cached['totalOmset'] as num?)?.toInt() ?? 0,
      totalProfit: (cached['totalProfit'] as num?)?.toInt() ?? 0,
      totalExpenses: (cached['totalExpenses'] as num?)?.toInt() ?? 0,
      averageTransaction: (cached['averageTransaction'] as num?)?.toInt() ?? 0,
      tierBreakdown: Map<String, int>.from(
        cached['tierBreakdown'] as Map? ?? {},
      ),
      paymentMethodBreakdown: Map<String, int>.from(
        cached['paymentMethodBreakdown'] as Map? ?? {},
      ),
    );
  }

  /// Helper to return empty DashboardData
  DashboardData _emptyDashboardData() {
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
