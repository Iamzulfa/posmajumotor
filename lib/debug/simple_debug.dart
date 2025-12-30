import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/core/utils/logger.dart';

class SimpleDebug {
  static Future<void> checkDatabase() async {
    try {
      final supabase = Supabase.instance.client;

      AppLogger.info('🔍 Checking database connection...');

      // Simple count queries
      final transactionCount = await supabase
          .from('transactions')
          .select('id')
          .count(CountOption.exact);

      final productCount = await supabase
          .from('products')
          .select('id')
          .count(CountOption.exact);

      final expenseCount = await supabase
          .from('expenses')
          .select('id')
          .count(CountOption.exact);

      AppLogger.info('📊 Database Summary:');
      AppLogger.info('   📦 Transactions: ${transactionCount.count}');
      AppLogger.info('   🛍️ Products: ${productCount.count}');
      AppLogger.info('   💰 Expenses: ${expenseCount.count}');

      // Check if we have any data for today
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final todayTransactions = await supabase
          .from('transactions')
          .select('id')
          .gte('created_at', startOfDay.toIso8601String())
          .count(CountOption.exact);

      AppLogger.info('   📅 Today\'s Transactions: ${todayTransactions.count}');

      if (todayTransactions.count == 0) {
        AppLogger.info(
          '⚠️ No transactions found for today. This explains why dashboard is empty.',
        );

        // Check recent transactions
        final recentTransactions = await supabase
            .from('transactions')
            .select('id, created_at')
            .order('created_at', ascending: false)
            .limit(5);

        if (recentTransactions.isNotEmpty) {
          AppLogger.info('📅 Recent transactions:');
          for (final tx in recentTransactions) {
            AppLogger.info('   - ${tx['id']}: ${tx['created_at']}');
          }
        } else {
          AppLogger.info('📭 No transactions found in database at all.');
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ Database check failed', e, stackTrace);
    }
  }
}
