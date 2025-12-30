import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/core/utils/logger.dart';

class FixedExpenseDebug {
  static Future<void> checkFixedExpenses() async {
    try {
      final supabase = Supabase.instance.client;

      AppLogger.info('🔍 Checking fixed expenses in database...');

      // Check all fixed expenses (including inactive)
      final allExpenses = await supabase
          .from('fixed_expenses')
          .select('*')
          .order('created_at', ascending: false);

      AppLogger.info('📊 Total Fixed Expenses: ${allExpenses.length}');

      if (allExpenses.isNotEmpty) {
        AppLogger.info('📋 All Fixed Expenses:');
        for (final expense in allExpenses) {
          AppLogger.info(
            '   - ${expense['name']}: Rp ${expense['amount']} (Active: ${expense['is_active']})',
          );
          AppLogger.info('     ID: ${expense['id']}');
          AppLogger.info('     Created: ${expense['created_at']}');
        }
      }

      // Check only active fixed expenses (what the UI should show)
      final activeExpenses = await supabase
          .from('fixed_expenses')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      AppLogger.info('📊 Active Fixed Expenses: ${activeExpenses.length}');

      if (activeExpenses.isNotEmpty) {
        AppLogger.info('📋 Active Fixed Expenses:');
        for (final expense in activeExpenses) {
          AppLogger.info('   - ${expense['name']}: Rp ${expense['amount']}');
        }
      } else {
        AppLogger.info(
          '⚠️ No active fixed expenses found. This explains why the UI is empty.',
        );
      }

      // Test realtime subscription
      AppLogger.info('📡 Testing realtime subscription...');
      final channel = supabase.channel('fixed-expenses-debug');

      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'fixed_expenses',
        callback: (payload) {
          AppLogger.info('📡 Realtime event: ${payload.eventType}');
          AppLogger.info('📡 Data: ${payload.newRecord}');
        },
      );

      await channel.subscribe();

      // Wait a bit then unsubscribe
      await Future.delayed(const Duration(seconds: 2));
      await channel.unsubscribe();

      AppLogger.info('✅ Fixed expense debug completed');
    } catch (e, stackTrace) {
      AppLogger.error('❌ Fixed expense debug failed', e, stackTrace);
    }
  }
}
