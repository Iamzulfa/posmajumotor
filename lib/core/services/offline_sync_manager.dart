import 'package:posfelix/data/models/models.dart';

/// Sync result after processing queue
class SyncResult {
  final int successCount;
  final int failedCount;
  final List<String> failedIds;
  final String? error;

  SyncResult({
    required this.successCount,
    required this.failedCount,
    required this.failedIds,
    this.error,
  });

  bool get hasFailures => failedCount > 0;
  bool get isSuccess => failedCount == 0 && error == null;
}

/// Sync status enum
enum SyncStatus { idle, syncing, success, error }

/// Offline Sync Manager Interface
/// Manages offline transaction queue and synchronization
abstract class OfflineSyncManager {
  // ============================================
  // QUEUE MANAGEMENT
  // ============================================

  /// Add a transaction to the offline queue
  Future<void> addToQueue(TransactionModel transaction);

  /// Get all queued transactions
  Future<List<TransactionModel>> getQueuedTransactions();

  /// Get count of queued transactions
  Future<int> getQueueCount();

  /// Remove a transaction from the queue
  Future<void> removeFromQueue(String localId);

  /// Clear all queued transactions
  Future<void> clearQueue();

  // ============================================
  // SYNC OPERATIONS
  // ============================================

  /// Process the queue and sync to server
  /// Returns SyncResult with success/failure counts
  Future<SyncResult> processQueue();

  /// Get current sync status stream
  Stream<SyncStatus> get syncStatusStream;

  /// Get current sync status
  SyncStatus get currentStatus;

  // ============================================
  // CONNECTIVITY
  // ============================================

  /// Check if device is online
  bool get isOnline;

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream;

  // ============================================
  // LIFECYCLE
  // ============================================

  /// Initialize the sync manager
  Future<void> initialize();

  /// Dispose resources
  void dispose();
}
