import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posfelix/core/services/connectivity_service.dart';
import 'package:posfelix/core/services/offline_sync_manager.dart';
import 'package:posfelix/injection_container.dart';

/// Connectivity state
class ConnectivityState {
  final bool isOnline;
  final int queueCount;
  final SyncStatus syncStatus;

  const ConnectivityState({
    this.isOnline = true,
    this.queueCount = 0,
    this.syncStatus = SyncStatus.idle,
  });

  ConnectivityState copyWith({
    bool? isOnline,
    int? queueCount,
    SyncStatus? syncStatus,
  }) {
    return ConnectivityState(
      isOnline: isOnline ?? this.isOnline,
      queueCount: queueCount ?? this.queueCount,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Check if there are pending items to sync
  bool get hasPendingSync => queueCount > 0;

  /// Get status message for UI
  String get statusMessage {
    if (!isOnline) return 'Offline';
    if (syncStatus == SyncStatus.syncing) return 'Syncing...';
    if (hasPendingSync) return '$queueCount pending';
    return 'Online';
  }
}

/// Connectivity notifier
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  final ConnectivityService? _connectivityService;
  final OfflineSyncManager? _syncManager;

  ConnectivityNotifier(this._connectivityService, this._syncManager)
    : super(const ConnectivityState()) {
    _initialize();
  }

  void _initialize() {
    if (_connectivityService == null || _syncManager == null) return;

    // Set initial state
    state = state.copyWith(isOnline: _connectivityService.isOnline);

    // Listen for connectivity changes
    _connectivityService.connectivityStream.listen((isOnline) {
      state = state.copyWith(isOnline: isOnline);
    });

    // Listen for sync status changes
    _syncManager.syncStatusStream.listen((status) {
      state = state.copyWith(syncStatus: status);
    });

    // Update queue count periodically
    _updateQueueCount();
  }

  Future<void> _updateQueueCount() async {
    if (_syncManager == null) return;
    final count = await _syncManager.getQueueCount();
    state = state.copyWith(queueCount: count);
  }

  /// Refresh queue count
  Future<void> refreshQueueCount() async {
    await _updateQueueCount();
  }

  /// Manually trigger sync
  Future<SyncResult> syncNow() async {
    if (_syncManager == null) {
      return SyncResult(
        successCount: 0,
        failedCount: 0,
        failedIds: [],
        error: 'Sync manager not available',
      );
    }

    final result = await _syncManager.processQueue();
    await _updateQueueCount();
    return result;
  }
}

/// Connectivity provider
final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
      ConnectivityService? connectivityService;
      OfflineSyncManager? syncManager;

      try {
        connectivityService = getIt<ConnectivityService>();
        syncManager = getIt<OfflineSyncManager>();
      } catch (e) {
        // Services not registered yet
      }

      return ConnectivityNotifier(connectivityService, syncManager);
    });

/// Stream provider for real-time connectivity updates
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  try {
    final service = getIt<ConnectivityService>();
    return service.connectivityStream;
  } catch (e) {
    return Stream.value(true); // Default to online
  }
});

/// Provider for checking if online
final isOnlineProvider = Provider<bool>((ref) {
  final state = ref.watch(connectivityProvider);
  return state.isOnline;
});

/// Provider for queue count
final queueCountProvider = Provider<int>((ref) {
  final state = ref.watch(connectivityProvider);
  return state.queueCount;
});

/// Provider for sync status
final syncStatusProvider = Provider<SyncStatus>((ref) {
  final state = ref.watch(connectivityProvider);
  return state.syncStatus;
});
