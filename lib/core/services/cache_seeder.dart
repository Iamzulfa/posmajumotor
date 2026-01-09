import 'package:posfelix/core/services/offline_service.dart';
import 'package:posfelix/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service untuk seed initial cache data dari Supabase untuk offline mode
class CacheSeeder {
  static Future<void> seedInitialCache() async {
    try {
      // Use the singleton instance
      final offlineService = OfflineService();

      AppLogger.info('🌱 Seeding initial cache data...');
      AppLogger.info(
        '📡 Connectivity status: ${offlineService.isOnline ? "ONLINE" : "OFFLINE"}',
      );

      // Give connectivity check a moment to complete
      await Future.delayed(const Duration(milliseconds: 500));
      AppLogger.info(
        '📡 Connectivity status (after delay): ${offlineService.isOnline ? "ONLINE" : "OFFLINE"}',
      );

      // Check if we're online first
      if (!offlineService.isOnline) {
        AppLogger.info(
          '📡 Offline detected - seeding with mock data immediately',
        );
        await _seedMockData(offlineService);
        return;
      }

      // Try to fetch real data from Supabase
      try {
        final supabase = Supabase.instance.client;

        // Seed dashboard data for today
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        final cacheKey = 'dashboard_data_${startOfDay.toIso8601String()}';

        // Fetch real transactions with timeout
        final transactionResponse = await supabase
            .from('transactions')
            .select(
              'tier, total, total_hpp, profit, payment_method, payment_status, created_at',
            )
            .gte('created_at', startOfDay.toUtc().toIso8601String())
            .lt('created_at', endOfDay.toUtc().toIso8601String())
            .timeout(const Duration(seconds: 5));

        // Fetch real expenses with timeout
        final startDateStr =
            '${startOfDay.year}-${startOfDay.month.toString().padLeft(2, '0')}-${startOfDay.day.toString().padLeft(2, '0')}';
        final endDateStr =
            '${endOfDay.year}-${endOfDay.month.toString().padLeft(2, '0')}-${endOfDay.day.toString().padLeft(2, '0')}';

        final expenseResponse = await supabase
            .from('expenses')
            .select('amount')
            .gte('expense_date', startDateStr)
            .lte('expense_date', endDateStr)
            .timeout(const Duration(seconds: 5));

        // Calculate totals from real data
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
          if (row['payment_status'] == 'COMPLETED') {
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
        }

        // Process expenses
        for (final row in expenseResponse) {
          totalExpenses += (row['amount'] as num).toInt();
        }

        final count = transactionResponse
            .where((tx) => tx['payment_status'] == 'COMPLETED')
            .length;
        final average = count > 0 ? totalOmset ~/ count : 0;

        // Cache dashboard data as Map (Hive-compatible)
        await offlineService.cacheData(cacheKey, {
          'totalTransactions': count,
          'totalOmset': totalOmset,
          'totalProfit': totalProfit,
          'totalExpenses': totalExpenses,
          'averageTransaction': average,
          'tierBreakdown': tierBreakdown,
          'paymentMethodBreakdown': paymentMethodBreakdown,
        });
        AppLogger.info('✅ Cached real dashboard data: $cacheKey');

        // Seed profit indicator from real data
        final yearStart = DateTime(today.year, 1, 1);
        final yearEnd = DateTime.now();

        final yearTransactionResponse = await supabase
            .from('transactions')
            .select('total, total_hpp, profit')
            .eq('payment_status', 'COMPLETED')
            .gte('created_at', yearStart.toUtc().toIso8601String())
            .lt('created_at', yearEnd.toUtc().toIso8601String())
            .timeout(const Duration(seconds: 5));

        int yearTotalOmset = 0;
        int yearTotalHpp = 0;
        int yearTotalExpenses = 0;

        for (final row in yearTransactionResponse) {
          yearTotalOmset += (row['total'] as num).toInt();
          yearTotalHpp += (row['total_hpp'] as num).toInt();
        }

        // Get year expenses
        final yearStartStr =
            '${yearStart.year}-${yearStart.month.toString().padLeft(2, '0')}-${yearStart.day.toString().padLeft(2, '0')}';
        final yearEndStr =
            '${yearEnd.year}-${yearEnd.month.toString().padLeft(2, '0')}-${yearEnd.day.toString().padLeft(2, '0')}';

        final yearExpenseResponse = await supabase
            .from('expenses')
            .select('amount')
            .gte('expense_date', yearStartStr)
            .lte('expense_date', yearEndStr)
            .timeout(const Duration(seconds: 5));

        for (final row in yearExpenseResponse) {
          yearTotalExpenses += (row['amount'] as num).toInt();
        }

        final grossProfit = yearTotalOmset - yearTotalHpp;
        final netProfit = grossProfit - yearTotalExpenses;
        final profitMargin = yearTotalOmset > 0
            ? (netProfit / yearTotalOmset) * 100
            : 0.0;

        // Cache profit indicator as Map (Hive-compatible)
        await offlineService.cacheData('profit_indicator', {
          'grossProfit': grossProfit,
          'netProfit': netProfit,
          'profitMargin': profitMargin,
          'totalOmset': yearTotalOmset,
          'totalHpp': yearTotalHpp,
          'totalExpenses': yearTotalExpenses,
        });
        AppLogger.info('✅ Cached real profit indicator');

        // Seed tax indicator for current month
        final monthStart = DateTime(today.year, today.month, 1);
        final monthEnd = DateTime(today.year, today.month + 1, 0, 23, 59, 59);

        final monthTransactionResponse = await supabase
            .from('transactions')
            .select('total')
            .eq('payment_status', 'COMPLETED')
            .gte('created_at', monthStart.toUtc().toIso8601String())
            .lt('created_at', monthEnd.toUtc().toIso8601String())
            .timeout(const Duration(seconds: 5));

        int monthTotalOmset = 0;
        for (final row in monthTransactionResponse) {
          monthTotalOmset += (row['total'] as num).toInt();
        }

        final taxAmount = (monthTotalOmset * 0.005).round();

        // Cache tax indicator as Map (Hive-compatible)
        await offlineService
            .cacheData('tax_indicator_${today.month}_${today.year}', {
              'month': today.month,
              'year': today.year,
              'totalOmset': monthTotalOmset,
              'taxAmount': taxAmount,
              'isPaid': false,
              'paidAt': null,
            });
        AppLogger.info('✅ Cached real tax indicator');

        AppLogger.info(
          '🌱 Cache seeding completed successfully with real data!',
        );
        AppLogger.info('📊 Cache stats: ${offlineService.getCacheStats()}');
      } catch (e) {
        AppLogger.warning('Could not fetch real data from Supabase: $e');
        AppLogger.info('🌱 Seeding with mock data as fallback...');

        // Fallback to mock data if Supabase is not available
        await _seedMockData(offlineService);
      }

      // ALWAYS ensure mock data exists as a safety net
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final cacheKey = 'dashboard_data_${startOfDay.toIso8601String()}';
      final existingCache = offlineService.getCachedData(cacheKey);
      if (existingCache == null) {
        AppLogger.info('⚠️ No cache found, seeding mock data as safety net...');
        await _seedMockData(offlineService);
      }
    } catch (e) {
      AppLogger.error('Error seeding cache', e);
      // Try to seed mock data even if there's an error
      try {
        final offlineService = OfflineService();
        await _seedMockData(offlineService);
      } catch (e2) {
        AppLogger.error('Failed to seed mock data', e2);
      }
    }
  }

  static Future<void> _seedMockData(OfflineService offlineService) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final cacheKey = 'dashboard_data_${startOfDay.toIso8601String()}';

    // Create mock dashboard data as Map (Hive-compatible)
    await offlineService.cacheData(cacheKey, {
      'totalTransactions': 15,
      'totalOmset': 5750000,
      'totalProfit': 1150000,
      'totalExpenses': 500000,
      'averageTransaction': 383333,
      'tierBreakdown': {
        'UMUM': 2000000,
        'BENGKEL': 2500000,
        'GROSSIR': 1250000,
      },
      'paymentMethodBreakdown': {'CASH': 8, 'TRANSFER': 5, 'CARD': 2},
    });
    AppLogger.info('✅ Cached mock dashboard data: $cacheKey');

    // Seed mock profit indicator as Map (Hive-compatible)
    await offlineService.cacheData('profit_indicator', {
      'grossProfit': 1425000,
      'netProfit': 925000,
      'profitMargin': 16.09,
      'totalOmset': 5750000,
      'totalHpp': 4025000,
      'totalExpenses': 500000,
    });
    AppLogger.info('✅ Cached mock profit indicator');

    // Seed mock tax indicator as Map (Hive-compatible)
    await offlineService
        .cacheData('tax_indicator_${today.month}_${today.year}', {
          'month': today.month,
          'year': today.year,
          'totalOmset': 5750000,
          'taxAmount': 28750,
          'isPaid': false,
          'paidAt': null,
        });
    AppLogger.info('✅ Cached mock tax indicator');
  }
}
