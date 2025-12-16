import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/transaction_repository.dart';
import 'package:posfelix/injection_container.dart';
import 'package:posfelix/config/constants/supabase_config.dart';
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

/// Transaction list notifier
class TransactionListNotifier extends StateNotifier<TransactionListState> {
  final TransactionRepository? _repository;

  TransactionListNotifier(this._repository)
    : super(const TransactionListState());

  Future<void> loadTodayTransactions() async {
    if (_repository == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final transactions = await _repository.getTodayTransactions();
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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

  Future<TransactionModel?> createTransaction(CartState cart) async {
    if (_repository == null) return null;

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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Transaction list provider
final transactionListProvider =
    StateNotifierProvider<TransactionListNotifier, TransactionListState>((ref) {
      final repository = SupabaseConfig.isConfigured
          ? getIt<TransactionRepository>()
          : null;
      return TransactionListNotifier(repository);
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
