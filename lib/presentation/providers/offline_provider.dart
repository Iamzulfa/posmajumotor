import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/offline_service.dart';

/// Provider untuk offline service
final offlineServiceProvider = Provider<OfflineService>((ref) {
  return OfflineService();
});

/// Provider untuk connectivity status
final connectivityStatusProvider = StreamProvider<bool>((ref) async* {
  final offlineService = ref.watch(offlineServiceProvider);

  // Initial value
  yield offlineService.isOnline;

  // Listen to changes
  offlineService.addListener(() {
    ref.invalidateSelf();
  });
});

/// Provider untuk pending sync items count
final pendingSyncCountProvider = Provider<int>((ref) {
  final offlineService = ref.watch(offlineServiceProvider);
  return offlineService.getPendingSyncItems().length;
});

/// Provider untuk cache statistics
final cacheStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final offlineService = ref.watch(offlineServiceProvider);
  return offlineService.getCacheStats();
});
