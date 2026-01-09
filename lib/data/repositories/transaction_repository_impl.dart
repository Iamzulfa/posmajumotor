import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/transaction_repository.dart';
import 'package:posfelix/core/utils/logger.dart';
import 'package:posfelix/core/utils/performance_logger.dart';
import 'package:posfelix/core/extensions/stream_extensions.dart';
import 'package:posfelix/core/services/offline_service.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final SupabaseClient _client;
  final OfflineService _offlineService = OfflineService();

  // Stream caching to prevent multiple subscriptions
  Stream<List<TransactionModel>>? _cachedTransactionsStream;
  Stream<List<TransactionModel>>? _cachedTodayTransactionsStream;
  String? _cachedTodayTransactionsDate; // Track which date the cache is for
  Stream<TransactionSummary>? _cachedTransactionSummaryStream;
  Stream<Map<String, TierSummary>>? _cachedTierBreakdownStream;

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
      PerformanceLogger.start('api_call_getTransactions');

      var query = _client.from('transactions').select('''
        *,
        transaction_items(*),
        users(*)
      ''');

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        // Use lt (less than) for exclusive end date to match dashboard behavior
        query = query.lt('created_at', endDate.toIso8601String());
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

      final result = response
          .map((json) => TransactionModel.fromJson(json))
          .toList();

      PerformanceLogger.end('api_call_getTransactions');
      return result;
    } catch (e) {
      AppLogger.error('Error fetching transactions', e);
      rethrow;
    }
  }

  /// Lightweight query untuk Riwayat Transaksi (tanpa items & users)
  Future<List<TransactionModel>> getTransactionsLightweight({
    DateTime? startDate,
    DateTime? endDate,
    String? paymentStatus = 'COMPLETED',
  }) async {
    try {
      PerformanceLogger.start('api_call_getTransactionsLightweight');

      var query = _client.from('transactions').select('''
        id,
        transaction_number,
        tier,
        customer_name,
        total,
        payment_method,
        payment_status,
        created_at
      ''');

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lt('created_at', endDate.toIso8601String());
      }

      if (paymentStatus != null) {
        query = query.eq('payment_status', paymentStatus);
      }

      final response = await query.order('created_at', ascending: false);

      final result = response
          .map((json) => TransactionModel.fromJson(json))
          .toList();

      PerformanceLogger.end('api_call_getTransactionsLightweight');
      return result;
    } catch (e) {
      AppLogger.error('Error fetching lightweight transactions', e);
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
        query = query.lt('created_at', endDate.toIso8601String());
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

      // Try to return cached data if offline
      if (!_offlineService.isOnline) {
        final cached = _offlineService.getCachedData('transaction_summary');
        if (cached != null) {
          AppLogger.info('📦 Using cached transaction summary (offline mode)');
          if (cached is TransactionSummary) {
            return cached;
          } else if (cached is Map) {
            return TransactionSummary(
              totalTransactions:
                  (cached['totalTransactions'] as num?)?.toInt() ?? 0,
              totalOmset: (cached['totalOmset'] as num?)?.toInt() ?? 0,
              totalHpp: (cached['totalHpp'] as num?)?.toInt() ?? 0,
              totalProfit: (cached['totalProfit'] as num?)?.toInt() ?? 0,
              averageTransaction:
                  (cached['averageTransaction'] as num?)?.toInt() ?? 0,
            );
          }
        }

        // Return empty data if offline and no cache
        AppLogger.info(
          '📦 No cached data available, returning empty transaction summary',
        );
        return TransactionSummary(
          totalTransactions: 0,
          totalOmset: 0,
          totalHpp: 0,
          totalProfit: 0,
          averageTransaction: 0,
        );
      }

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
          .select('tier, total, total_hpp, profit')
          .eq('payment_status', 'COMPLETED');

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        // Use lt (less than) for exclusive end date to match dashboard behavior
        query = query.lt('created_at', endDate.toIso8601String());
      }

      final response = await query;

      final Map<String, TierSummary> breakdown = {};

      for (final tier in ['UMUM', 'BENGKEL', 'GROSSIR']) {
        final tierData = response.where((r) => r['tier'] == tier).toList();

        int totalOmset = 0;
        int totalHpp = 0;
        int totalProfit = 0;

        for (final row in tierData) {
          totalOmset += (row['total'] as num).toInt();
          totalHpp += (row['total_hpp'] as num).toInt();
          totalProfit += (row['profit'] as num).toInt();
        }

        breakdown[tier] = TierSummary(
          tier: tier,
          transactionCount: tierData.length,
          totalOmset: totalOmset,
          totalHpp: totalHpp,
          totalProfit: totalProfit,
        );
      }

      return breakdown;
    } catch (e) {
      AppLogger.error('Error getting tier breakdown', e);
      rethrow;
    }
  }

  @override
  Future<List<DailySummary>> getLast7DaysSummary() async {
    try {
      final now = DateTime.now();
      final dailySummaries = <DailySummary>[];

      // Get data for last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startDate = DateTime(date.year, date.month, date.day);
        final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

        // Use inclusive boundaries to include transactions at start of day
        final response = await _client
            .from('transactions')
            .select('total, profit')
            .eq('payment_status', 'COMPLETED')
            .gte(
              'created_at',
              startDate.subtract(const Duration(seconds: 1)).toIso8601String(),
            )
            .lte(
              'created_at',
              endDate.add(const Duration(seconds: 1)).toIso8601String(),
            );

        int totalOmset = 0;
        int totalProfit = 0;

        for (final row in response) {
          totalOmset += (row['total'] as num).toInt();
          totalProfit += (row['profit'] as num).toInt();
        }

        dailySummaries.add(
          DailySummary(
            date: date,
            totalOmset: totalOmset,
            totalProfit: totalProfit,
          ),
        );
      }

      return dailySummaries;
    } catch (e) {
      AppLogger.error('Error getting last 7 days summary', e);
      rethrow;
    }
  }

  // ============================================
  // STREAM METHODS (Real-time updates)
  // ============================================

  @override
  Stream<List<TransactionModel>> getTransactionsStream({
    DateTime? startDate,
    DateTime? endDate,
    String? tier,
    int? limit,
  }) {
    // Only create stream if no filters are applied (base stream)
    if (startDate == null && endDate == null && tier == null && limit == null) {
      if (_cachedTransactionsStream != null) {
        return _cachedTransactionsStream!;
      }

      try {
        // Use polling instead of Realtime to avoid connection issues
        // Emit immediately on first subscription, then poll every 3 seconds
        _cachedTransactionsStream =
            Stream.periodic(
                  const Duration(seconds: 3),
                  (_) => _fetchAllTransactions(),
                )
                .asyncExpand((future) => future.asStream())
                .distinct()
                .handleError((error) {
                  AppLogger.error('Error streaming transactions', error);
                })
                .shareReplay(bufferSize: 1);

        // Trigger initial fetch immediately
        _fetchAllTransactions()
            .then((data) {
              // Data will be emitted through the stream
            })
            .catchError((e) {
              AppLogger.error('Error in initial transaction fetch', e);
            });

        return _cachedTransactionsStream!;
      } catch (e) {
        AppLogger.error('Error setting up transactions stream', e);
        return Stream.value([]);
      }
    }

    // For filtered streams, apply filters on top of base stream
    return getTransactionsStream().map((transactions) {
      var filtered = transactions;

      if (startDate != null) {
        filtered = filtered
            .where(
              (t) =>
                  t.createdAt != null &&
                  (t.createdAt!.isAfter(startDate) ||
                      t.createdAt!.isAtSameMomentAs(startDate)),
            )
            .toList();
      }
      if (endDate != null) {
        filtered = filtered
            .where(
              (t) =>
                  t.createdAt != null &&
                  (t.createdAt!.isBefore(endDate) ||
                      t.createdAt!.isAtSameMomentAs(endDate)),
            )
            .toList();
      }
      if (tier != null) {
        filtered = filtered.where((t) => t.tier == tier).toList();
      }

      if (limit != null && filtered.length > limit) {
        filtered = filtered.take(limit).toList();
      }

      return filtered;
    });
  }

  Future<List<TransactionModel>> _fetchAllTransactions() async {
    try {
      final response = await _client
          .from('transactions')
          .select()
          .order('created_at', ascending: false);

      var transactions = response
          .map((json) => TransactionModel.fromJson(json))
          .toList();

      // Sort by created_at descending
      transactions.sort((a, b) {
        if (a.createdAt == null || b.createdAt == null) return 0;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      return transactions;
    } catch (e) {
      AppLogger.error('Error fetching all transactions', e);
      return [];
    }
  }

  @override
  Stream<List<TransactionModel>> getTodayTransactionsStream() {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Invalidate cache if date has changed
    if (_cachedTodayTransactionsDate != dateStr) {
      _cachedTodayTransactionsStream = null;
      _cachedTodayTransactionsDate = null;
    }

    if (_cachedTodayTransactionsStream != null) {
      return _cachedTodayTransactionsStream!;
    }

    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    _cachedTodayTransactionsDate = dateStr;

    _cachedTodayTransactionsStream = getTransactionsStream(
      startDate: startOfDay,
      endDate: endOfDay,
    ).shareReplay(bufferSize: 1);

    return _cachedTodayTransactionsStream!;
  }

  @override
  Stream<TransactionSummary> getTransactionSummaryStream({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (startDate == null && endDate == null) {
      if (_cachedTransactionSummaryStream != null) {
        return _cachedTransactionSummaryStream!;
      }

      _cachedTransactionSummaryStream = getTransactionsStream()
          .map((transactions) {
            final completed = transactions
                .where((t) => t.paymentStatus == 'COMPLETED')
                .toList();

            int totalOmset = 0;
            int totalHpp = 0;
            int totalProfit = 0;

            for (final t in completed) {
              totalOmset += t.total;
              totalHpp += t.totalHpp;
              totalProfit += t.profit;
            }

            final count = completed.length;
            final average = count > 0 ? totalOmset ~/ count : 0;

            return TransactionSummary(
              totalTransactions: count,
              totalOmset: totalOmset,
              totalHpp: totalHpp,
              totalProfit: totalProfit,
              averageTransaction: average,
            );
          })
          .handleError((error) {
            AppLogger.error('Error streaming transaction summary', error);
          })
          .shareReplay(bufferSize: 1);

      return _cachedTransactionSummaryStream!;
    }

    return getTransactionsStream(startDate: startDate, endDate: endDate)
        .map((transactions) {
          final completed = transactions
              .where((t) => t.paymentStatus == 'COMPLETED')
              .toList();

          int totalOmset = 0;
          int totalHpp = 0;
          int totalProfit = 0;

          for (final t in completed) {
            totalOmset += t.total;
            totalHpp += t.totalHpp;
            totalProfit += t.profit;
          }

          final count = completed.length;
          final average = count > 0 ? totalOmset ~/ count : 0;

          return TransactionSummary(
            totalTransactions: count,
            totalOmset: totalOmset,
            totalHpp: totalHpp,
            totalProfit: totalProfit,
            averageTransaction: average,
          );
        })
        .handleError((error) {
          AppLogger.error('Error streaming transaction summary', error);
        });
  }

  @override
  Stream<Map<String, TierSummary>> getTierBreakdownStream({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (startDate == null && endDate == null) {
      if (_cachedTierBreakdownStream != null) {
        return _cachedTierBreakdownStream!;
      }

      _cachedTierBreakdownStream = getTransactionsStream()
          .map((transactions) {
            final completed = transactions
                .where((t) => t.paymentStatus == 'COMPLETED')
                .toList();

            final Map<String, TierSummary> breakdown = {};

            for (final tier in ['UMUM', 'BENGKEL', 'GROSSIR']) {
              final tierData = completed.where((t) => t.tier == tier).toList();

              int totalOmset = 0;
              int totalHpp = 0;
              int totalProfit = 0;

              for (final t in tierData) {
                totalOmset += t.total;
                totalHpp += t.totalHpp;
                totalProfit += t.profit;
              }

              breakdown[tier] = TierSummary(
                tier: tier,
                transactionCount: tierData.length,
                totalOmset: totalOmset,
                totalHpp: totalHpp,
                totalProfit: totalProfit,
              );
            }

            return breakdown;
          })
          .handleError((error) {
            AppLogger.error('Error streaming tier breakdown', error);
          })
          .shareReplay(bufferSize: 1);

      return _cachedTierBreakdownStream!;
    }

    return getTransactionsStream(startDate: startDate, endDate: endDate)
        .map((transactions) {
          final completed = transactions
              .where((t) => t.paymentStatus == 'COMPLETED')
              .toList();

          final Map<String, TierSummary> breakdown = {};

          for (final tier in ['UMUM', 'BENGKEL', 'GROSSIR']) {
            final tierData = completed.where((t) => t.tier == tier).toList();

            int totalOmset = 0;
            int totalHpp = 0;
            int totalProfit = 0;

            for (final t in tierData) {
              totalOmset += t.total;
              totalHpp += t.totalHpp;
              totalProfit += t.profit;
            }

            breakdown[tier] = TierSummary(
              tier: tier,
              transactionCount: tierData.length,
              totalOmset: totalOmset,
              totalHpp: totalHpp,
              totalProfit: totalProfit,
            );
          }

          return breakdown;
        })
        .handleError((error) {
          AppLogger.error('Error streaming tier breakdown', error);
        });
  }

  @override
  Stream<TransactionModel?> getTransactionStream(String id) {
    try {
      // Use polling instead of Realtime to avoid connection issues
      // Poll every 3 seconds for updates
      return Stream.periodic(
            const Duration(seconds: 3),
            (_) => _fetchTransactionById(id),
          )
          .asyncExpand((future) => future.asStream())
          .distinct()
          .handleError((error) {
            AppLogger.error('Error streaming transaction $id', error);
          })
          .shareReplay(bufferSize: 1);
    } catch (e) {
      AppLogger.error('Error setting up transaction stream', e);
      return Stream.value(null);
    }
  }

  Future<TransactionModel?> _fetchTransactionById(String id) async {
    try {
      final response = await _client
          .from('transactions')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return TransactionModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching transaction by ID', e);
      return null;
    }
  }
}
