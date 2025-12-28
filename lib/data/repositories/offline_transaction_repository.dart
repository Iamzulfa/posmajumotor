import 'package:uuid/uuid.dart';
import '../../core/services/offline_service.dart';
import '../models/transaction_model.dart';

/// Repository untuk handle transaction dengan offline support
class OfflineTransactionRepository {
  final OfflineService _offlineService;

  OfflineTransactionRepository(this._offlineService);

  /// Create transaction dengan offline support
  Future<TransactionModel> createTransactionOfflineSupport(
    TransactionModel transaction,
  ) async {
    try {
      // Jika online, langsung create di Supabase
      if (_offlineService.isOnline) {
        // Actual creation akan di-handle oleh main repository
        return transaction;
      }

      // Jika offline, queue untuk sync nanti
      final transactionId = const Uuid().v4();
      final transactionData = {
        'id': transactionId,
        'transaction_number': transaction.transactionNumber,
        'tier': transaction.tier,
        'subtotal': transaction.subtotal,
        'discount_amount': transaction.discountAmount,
        'total': transaction.total,
        'payment_method': transaction.paymentMethod,
        'payment_status': transaction.paymentStatus,
        'created_at': DateTime.now().toIso8601String(),
        'items':
            transaction.items
                ?.map(
                  (item) => {
                    'product_name': item.productName,
                    'quantity': item.quantity,
                    'unit_price': item.unitPrice,
                    'unit_hpp': item.unitHpp,
                    'subtotal': item.subtotal,
                  },
                )
                .toList() ??
            [],
      };

      await _offlineService.queueTransaction(transactionId, transactionData);

      // Cache transaction locally
      await _offlineService.cacheData(
        'transaction_$transactionId',
        transactionData,
      );

      return transaction.copyWith(id: transactionId);
    } catch (e) {
      rethrow;
    }
  }

  /// Get transactions dengan offline fallback
  Future<List<TransactionModel>> getTransactionsWithOfflineFallback(
    List<TransactionModel> onlineTransactions,
  ) async {
    try {
      // Jika online, return online data
      if (_offlineService.isOnline) {
        // Cache untuk offline use
        await _offlineService.cacheData(
          'transactions_list',
          onlineTransactions,
        );
        return onlineTransactions;
      }

      // Jika offline, return cached data
      final cached = _offlineService.getCachedData('transactions_list');
      if (cached != null && cached is List) {
        return cached.cast<TransactionModel>();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Get pending transactions untuk sync
  List<Map<String, dynamic>> getPendingTransactions() {
    final pendingItems = _offlineService.getPendingSyncItems();
    return pendingItems
        .where((item) {
          final data = item.value as Map;
          return data['type'] == 'transaction';
        })
        .map((item) => item.value as Map<String, dynamic>)
        .toList();
  }

  /// Mark transaction as synced
  Future<void> markTransactionSynced(String transactionId) async {
    await _offlineService.removeSyncedItem(transactionId);
  }
}
