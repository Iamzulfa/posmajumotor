import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/transaction_repository.dart';
import 'package:posfelix/core/services/connectivity_service.dart';
import 'package:posfelix/core/services/offline_sync_manager.dart';
import 'package:posfelix/injection_container.dart';
import 'package:posfelix/config/constants/supabase_config.dart';
import 'package:posfelix/core/utils/logger.dart';
import 'package:posfelix/core/utils/error_handler.dart';
import 'cart_provider.dart';

/// Transaction list state
class TransactionListState {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;

  const TransactionListState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  TransactionListState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return TransactionListState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Transaction list notifier with offline support
class TransactionListNotifier extends StateNotifier<TransactionListState> {
  final TransactionRepository? _repository;
  final ConnectivityService? _connectivityService;
  final OfflineSyncManager? _syncManager;

  TransactionListNotifier(
    this._repository,
    this._connectivityService,
    this._syncManager,
  ) : super(const TransactionListState());

  Future<void> loadTodayTransactions() async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final transactions = await _repository.getTodayTransactions();
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      final userFriendlyError = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(isLoading: false, error: userFriendlyError);
    }
  }

  Future<void> loadTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? tier,
  }) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final transactions = await _repository.getTransactions(
        startDate: startDate,
        endDate: endDate,
        tier: tier,
      );
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create transaction with offline support
  /// If offline, queues the transaction for later sync
  Future<TransactionModel?> createTransaction(CartState cart) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Convert cart items to transaction items
      final items = cart.items
          .map(
            (item) => TransactionItemModel(
              id: '',
              transactionId: '',
              productId: item.product.id,
              productName: item.product.name,
              productSku: item.product.sku,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              unitHpp: item.unitHpp,
              subtotal: item.subtotal,
            ),
          )
          .toList();

      // Check if online
      final isOnline = _connectivityService?.isOnline ?? true;

      if (isOnline && _repository != null) {
        // Online mode - create directly
        final transaction = await _repository.createTransaction(
          tier: cart.tier,
          paymentMethod: cart.paymentMethod,
          items: items,
          notes: cart.notes,
          discountAmount: cart.discountAmount,
        );

        // Reload transactions
        await loadTodayTransactions();
        return transaction;
      } else {
        // Offline mode - queue for later sync
        if (_syncManager != null) {
          // Create a temporary transaction model for queuing
          final tempTransaction = TransactionModel(
            id: '',
            transactionNumber:
                'OFFLINE-${DateTime.now().millisecondsSinceEpoch}',
            tier: cart.tier,
            customerName: null,
            subtotal: cart.subtotal,
            discountAmount: cart.discountAmount,
            total: cart.total,
            totalHpp: cart.totalHpp,
            profit: cart.totalProfit,
            paymentMethod: cart.paymentMethod,
            paymentStatus: 'PENDING',
            notes: cart.notes,
            cashierId: null,
            createdAt: DateTime.now(),
            items: items,
          );

          await _syncManager.addToQueue(tempTransaction);
          AppLogger.info('Transaction queued for offline sync');

          state = state.copyWith(
            isLoading: false,
            error: 'Transaction saved offline. Will sync when online.',
          );
          return tempTransaction;
        } else {
          state = state.copyWith(
            isLoading: false,
            error:
                'Tidak dapat membuat transaksi dalam mode offline. Silakan periksa koneksi internet Anda.',
          );
          return null;
        }
      }
    } catch (e) {
      final userFriendlyError = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(isLoading: false, error: userFriendlyError);
      return null;
    }
  }

  Future<void> refundTransaction(String id) async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.refundTransaction(id);
      await loadTodayTransactions();
    } catch (e) {
      final userFriendlyError = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(isLoading: false, error: userFriendlyError);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Transaction list provider with offline support
final transactionListProvider =
    StateNotifierProvider<TransactionListNotifier, TransactionListState>((ref) {
      TransactionRepository? repository;
      ConnectivityService? connectivityService;
      OfflineSyncManager? syncManager;

      if (SupabaseConfig.isConfigured) {
        repository = getIt<TransactionRepository>();
      }

      try {
        connectivityService = getIt<ConnectivityService>();
        syncManager = getIt<OfflineSyncManager>();
      } catch (e) {
        // Services not registered yet
      }

      return TransactionListNotifier(
        repository,
        connectivityService,
        syncManager,
      );
    });

/// Transaction summary provider (for dashboard)
final transactionSummaryProvider =
    FutureProvider.family<TransactionSummary?, DateRange?>((
      ref,
      dateRange,
    ) async {
      if (!SupabaseConfig.isConfigured) return null;
      final repository = getIt<TransactionRepository>();
      return repository.getTransactionSummary(
        startDate: dateRange?.start,
        endDate: dateRange?.end,
      );
    });

/// Tier breakdown provider (for dashboard)
final tierBreakdownProvider =
    FutureProvider.family<Map<String, TierSummary>?, DateRange?>((
      ref,
      dateRange,
    ) async {
      if (!SupabaseConfig.isConfigured) return null;
      final repository = getIt<TransactionRepository>();
      return repository.getTierBreakdown(
        startDate: dateRange?.start,
        endDate: dateRange?.end,
      );
    });

/// Helper class for date range
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  /// Today
  factory DateRange.today() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  /// This month
  factory DateRange.thisMonth() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );
  }

  /// Last 7 days
  factory DateRange.last7Days() {
    final now = DateTime.now();
    return DateRange(start: now.subtract(const Duration(days: 7)), end: now);
  }
}

// ============================================
// STREAM PROVIDERS (Real-time updates)
// ============================================

/// Real-time today's transactions stream provider
final todayTransactionsStreamProvider = StreamProvider<List<TransactionModel>>((
  ref,
) {
  if (!SupabaseConfig.isConfigured) {
    return Stream.value([]);
  }
  final repository = getIt<TransactionRepository>();
  return repository.getTodayTransactionsStream();
});

/// Real-time transaction summary stream provider
final transactionSummaryStreamProvider =
    StreamProvider.family<TransactionSummary, DateRange?>((ref, dateRange) {
      if (!SupabaseConfig.isConfigured) {
        return Stream.value(
          TransactionSummary(
            totalTransactions: 0,
            totalOmset: 0,
            totalHpp: 0,
            totalProfit: 0,
            averageTransaction: 0,
          ),
        );
      }
      final repository = getIt<TransactionRepository>();
      return repository.getTransactionSummaryStream(
        startDate: dateRange?.start,
        endDate: dateRange?.end,
      );
    });

/// Real-time tier breakdown stream provider
final tierBreakdownStreamProvider =
    StreamProvider.family<Map<String, TierSummary>, DateRange?>((
      ref,
      dateRange,
    ) {
      if (!SupabaseConfig.isConfigured) {
        return Stream.value({});
      }
      final repository = getIt<TransactionRepository>();
      return repository.getTierBreakdownStream(
        startDate: dateRange?.start,
        endDate: dateRange?.end,
      );
    });
