import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:posfelix/data/models/models.dart';
import 'package:posfelix/domain/repositories/transaction_repository.dart';
import 'package:posfelix/core/services/offline_sync_manager.dart';
import 'package:posfelix/core/services/connectivity_service.dart';
import 'package:posfelix/core/services/hive_adapters.dart';
import 'package:posfelix/core/utils/logger.dart';

/// Implementation of OfflineSyncManager
class OfflineSyncManagerImpl implements OfflineSyncManager {
  final ConnectivityService _connectivityService;
  final TransactionRepository? _transactionRepository;

  final _uuid = const Uuid();
  SyncStatus _currentStatus = SyncStatus.idle;
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  StreamSubscription<bool>? _connectivitySubscription;

  OfflineSyncManagerImpl({
    required ConnectivityService connectivityService,
    TransactionRepository? transactionRepository,
  }) : _connectivityService = connectivityService,
       _transactionRepository = transactionRepository;

  @override
  SyncStatus get currentStatus => _currentStatus;

  @override
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

  @override
  bool get isOnline => _connectivityService.isOnline;

  @override
  Stream<bool> get connectivityStream =>
      _connectivityService.connectivityStream;

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  Future<void> initialize() async {
    // Listen for connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen((
      isOnline,
    ) {
      if (isOnline) {
        // Auto-sync when coming back online
        _autoSync();
      }
    });

    AppLogger.info('OfflineSyncManager initialized');
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
    AppLogger.info('OfflineSyncManager disposed');
  }

  // ============================================
  // QUEUE MANAGEMENT
  // ============================================

  @override
  Future<void> addToQueue(TransactionModel transaction) async {
    try {
      final box = Hive.box<QueuedTransaction>(HiveBoxes.transactionsQueue);

      final localId = _uuid.v4();
      final jsonString = jsonEncode(transaction.toJson());

      final queuedTransaction = QueuedTransaction(
        localId: localId,
        transactionJson: jsonString,
        queuedAt: DateTime.now(),
      );

      await box.put(localId, queuedTransaction);

      AppLogger.info('Transaction added to queue: $localId');
    } catch (e) {
      AppLogger.error('Error adding transaction to queue', e);
      rethrow;
    }
  }

  @override
  Future<List<TransactionModel>> getQueuedTransactions() async {
    try {
      final box = Hive.box<QueuedTransaction>(HiveBoxes.transactionsQueue);
      final transactions = <TransactionModel>[];

      // Get all queued transactions sorted by queuedAt
      final queuedList = box.values.toList()
        ..sort((a, b) => a.queuedAt.compareTo(b.queuedAt));

      for (final queued in queuedList) {
        try {
          final json =
              jsonDecode(queued.transactionJson) as Map<String, dynamic>;
          transactions.add(TransactionModel.fromJson(json));
        } catch (e) {
          AppLogger.error(
            'Error parsing queued transaction: ${queued.localId}',
            e,
          );
        }
      }

      return transactions;
    } catch (e) {
      AppLogger.error('Error getting queued transactions', e);
      return [];
    }
  }

  @override
  Future<int> getQueueCount() async {
    try {
      final box = Hive.box<QueuedTransaction>(HiveBoxes.transactionsQueue);
      return box.length;
    } catch (e) {
      AppLogger.error('Error getting queue count', e);
      return 0;
    }
  }

  @override
  Future<void> removeFromQueue(String localId) async {
    try {
      final box = Hive.box<QueuedTransaction>(HiveBoxes.transactionsQueue);
      await box.delete(localId);
      AppLogger.info('Transaction removed from queue: $localId');
    } catch (e) {
      AppLogger.error('Error removing transaction from queue', e);
    }
  }

  @override
  Future<void> clearQueue() async {
    try {
      final box = Hive.box<QueuedTransaction>(HiveBoxes.transactionsQueue);
      await box.clear();
      AppLogger.info('Queue cleared');
    } catch (e) {
      AppLogger.error('Error clearing queue', e);
    }
  }

  // ============================================
  // SYNC OPERATIONS
  // ============================================

  @override
  Future<SyncResult> processQueue() async {
    if (!isOnline) {
      return SyncResult(
        successCount: 0,
        failedCount: 0,
        failedIds: [],
        error: 'Device is offline',
      );
    }

    if (_transactionRepository == null) {
      return SyncResult(
        successCount: 0,
        failedCount: 0,
        failedIds: [],
        error: 'Transaction repository not available',
      );
    }

    _updateStatus(SyncStatus.syncing);

    try {
      final box = Hive.box<QueuedTransaction>(HiveBoxes.transactionsQueue);

      // Get all queued transactions sorted by queuedAt (FIFO)
      final queuedList = box.values.toList()
        ..sort((a, b) => a.queuedAt.compareTo(b.queuedAt));

      int successCount = 0;
      int failedCount = 0;
      final failedIds = <String>[];

      for (final queued in queuedList) {
        try {
          final json =
              jsonDecode(queued.transactionJson) as Map<String, dynamic>;
          final transaction = TransactionModel.fromJson(json);

          // Create transaction items from the model
          final items = transaction.items ?? [];

          // Sync to server
          await _transactionRepository.createTransaction(
            tier: transaction.tier,
            paymentMethod: transaction.paymentMethod,
            items: items,
            customerName: transaction.customerName,
            notes: transaction.notes,
            discountAmount: transaction.discountAmount,
          );

          // Remove from queue on success
          await box.delete(queued.localId);
          successCount++;

          AppLogger.info('Synced transaction: ${queued.localId}');
        } catch (e) {
          // Increment retry count and keep in queue
          queued.incrementRetry(e.toString());
          await queued.save();

          failedCount++;
          failedIds.add(queued.localId);

          AppLogger.error('Failed to sync transaction: ${queued.localId}', e);
        }
      }

      final status = failedCount == 0 ? SyncStatus.success : SyncStatus.error;
      _updateStatus(status);

      AppLogger.info(
        'Sync completed: $successCount success, $failedCount failed',
      );

      return SyncResult(
        successCount: successCount,
        failedCount: failedCount,
        failedIds: failedIds,
      );
    } catch (e) {
      _updateStatus(SyncStatus.error);
      AppLogger.error('Error processing queue', e);

      return SyncResult(
        successCount: 0,
        failedCount: 0,
        failedIds: [],
        error: e.toString(),
      );
    }
  }

  /// Auto-sync when coming back online
  Future<void> _autoSync() async {
    final queueCount = await getQueueCount();
    if (queueCount > 0) {
      AppLogger.info('Auto-syncing $queueCount queued transactions...');
      await processQueue();
    }
  }

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }
}
