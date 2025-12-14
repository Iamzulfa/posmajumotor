import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/transaction_repository.dart';
import 'package:posfelix/core/utils/logger.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final SupabaseClient _client;

  TransactionRepositoryImpl(this._client);

  @override
  Future<List<TransactionModel>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? tier,
    String? paymentMethod,
    String? paymentStatus,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client.from('transactions').select('''
        *,
        transaction_items(*),
        users(*)
      ''');

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      if (tier != null) {
        query = query.eq('tier', tier);
      }

      if (paymentMethod != null) {
        query = query.eq('payment_method', paymentMethod);
      }

      if (paymentStatus != null) {
        query = query.eq('payment_status', paymentStatus);
      }

      // Execute with order and limit
      final response = await query
          .order('created_at', ascending: false)
          .limit(limit ?? 100);

      return response.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching transactions', e);
      rethrow;
    }
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final response = await _client
          .from('transactions')
          .select('''
        *,
        transaction_items(*, products(*)),
        users(*)
      ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return TransactionModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching transaction by ID', e);
      rethrow;
    }
  }

  @override
  Future<List<TransactionModel>> getTodayTransactions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getTransactions(startDate: startOfDay, endDate: endOfDay);
  }

  @override
  Future<TransactionModel> createTransaction({
    required String tier,
    required String paymentMethod,
    required List<TransactionItemModel> items,
    String? customerName,
    String? notes,
    int discountAmount = 0,
  }) async {
    try {
      // Calculate totals
      int subtotal = 0;
      int totalHpp = 0;

      for (final item in items) {
        subtotal += item.subtotal;
        totalHpp += item.unitHpp * item.quantity;
      }

      final total = subtotal - discountAmount;
      final profit = total - totalHpp;

      // Create transaction
      final transactionData = {
        'tier': tier,
        'customer_name': customerName,
        'subtotal': subtotal,
        'discount_amount': discountAmount,
        'total': total,
        'total_hpp': totalHpp,
        'profit': profit,
        'payment_method': paymentMethod,
        'payment_status': 'COMPLETED',
        'notes': notes,
        'cashier_id': _client.auth.currentUser?.id,
      };

      final transactionResponse = await _client
          .from('transactions')
          .insert(transactionData)
          .select()
          .single();

      final transactionId = transactionResponse['id'] as String;

      // Create transaction items
      // Note: Stock will be auto-deducted by database trigger
      final itemsData = items
          .map(
            (item) => {
              'transaction_id': transactionId,
              'product_id': item.productId,
              'product_name': item.productName,
              'product_sku': item.productSku,
              'quantity': item.quantity,
              'unit_price': item.unitPrice,
              'unit_hpp': item.unitHpp,
              'subtotal': item.subtotal,
            },
          )
          .toList();

      await _client.from('transaction_items').insert(itemsData);

      AppLogger.info('Transaction created: $transactionId');

      // Return complete transaction
      return (await getTransactionById(transactionId))!;
    } catch (e) {
      AppLogger.error('Error creating transaction', e);
      rethrow;
    }
  }

  @override
  Future<void> refundTransaction(String id) async {
    try {
      // Get transaction with items
      final transaction = await getTransactionById(id);
      if (transaction == null) throw Exception('Transaction not found');

      // Update status to refunded
      await _client
          .from('transactions')
          .update({'payment_status': 'REFUNDED'})
          .eq('id', id);

      // Restore stock for each item
      if (transaction.items != null) {
        for (final item in transaction.items!) {
          // Get current stock
          final productResponse = await _client
              .from('products')
              .select('stock')
              .eq('id', item.productId)
              .single();

          final currentStock = productResponse['stock'] as int;
          final newStock = currentStock + item.quantity;

          // Update stock
          await _client
              .from('products')
              .update({'stock': newStock})
              .eq('id', item.productId);

          // Create inventory log for return
          await _client.from('inventory_logs').insert({
            'product_id': item.productId,
            'type': 'IN',
            'quantity': item.quantity,
            'stock_before': currentStock,
            'stock_after': newStock,
            'reference_type': 'RETURN',
            'reference_id': id,
            'reason': 'Refund transaction ${transaction.transactionNumber}',
            'created_by': _client.auth.currentUser?.id,
          });
        }
      }

      AppLogger.info('Transaction refunded: $id');
    } catch (e) {
      AppLogger.error('Error refunding transaction', e);
      rethrow;
    }
  }

  @override
  Future<TransactionSummary> getTransactionSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('transactions')
          .select('total, total_hpp, profit')
          .eq('payment_status', 'COMPLETED');

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;

      int totalOmset = 0;
      int totalHpp = 0;
      int totalProfit = 0;

      for (final row in response) {
        totalOmset += (row['total'] as num).toInt();
        totalHpp += (row['total_hpp'] as num).toInt();
        totalProfit += (row['profit'] as num).toInt();
      }

      final count = response.length;
      final average = count > 0 ? totalOmset ~/ count : 0;

      return TransactionSummary(
        totalTransactions: count,
        totalOmset: totalOmset,
        totalHpp: totalHpp,
        totalProfit: totalProfit,
        averageTransaction: average,
      );
    } catch (e) {
      AppLogger.error('Error getting transaction summary', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, TierSummary>> getTierBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client
          .from('transactions')
          .select('tier, total, profit')
          .eq('payment_status', 'COMPLETED');

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;

      final Map<String, TierSummary> breakdown = {};

      for (final tier in ['UMUM', 'BENGKEL', 'GROSSIR']) {
        final tierData = response.where((r) => r['tier'] == tier).toList();

        int totalOmset = 0;
        int totalProfit = 0;

        for (final row in tierData) {
          totalOmset += (row['total'] as num).toInt();
          totalProfit += (row['profit'] as num).toInt();
        }

        breakdown[tier] = TierSummary(
          tier: tier,
          transactionCount: tierData.length,
          totalOmset: totalOmset,
          totalProfit: totalProfit,
        );
      }

      return breakdown;
    } catch (e) {
      AppLogger.error('Error getting tier breakdown', e);
      rethrow;
    }
  }
}
