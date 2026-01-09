import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';
import '../../../presentation/providers/offline_provider.dart';

/// Widget untuk menampilkan status offline/online
class OfflineIndicator extends ConsumerWidget {
  final bool showDetails;

  const OfflineIndicator({super.key, this.showDetails = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineService = ref.watch(offlineServiceProvider);
    final pendingCount = ref.watch(pendingSyncCountProvider);

    if (offlineService.isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        border: Border(bottom: BorderSide(color: AppColors.warning, width: 2)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ Mode Offline',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                if (showDetails && pendingCount > 0)
                  Text(
                    '$pendingCount item menunggu sinkronisasi',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textGray,
                    ),
                  ),
              ],
            ),
          ),
          if (pendingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$pendingCount',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget untuk menampilkan sync status di bottom sheet
class SyncStatusBottomSheet extends ConsumerWidget {
  const SyncStatusBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineService = ref.watch(offlineServiceProvider);
    final pendingItems = offlineService.getPendingSyncItems();
    final stats = ref.watch(cacheStatsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                offlineService.isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: offlineService.isOnline
                    ? AppColors.success
                    : AppColors.warning,
              ),
              const SizedBox(width: 12),
              Text(
                offlineService.isOnline ? 'Status: Online' : 'Status: Offline',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow('Cache Items', '${stats['cachedItems']}'),
          _buildStatRow('Pending Sync', '${stats['pendingSyncItems']}'),
          if (pendingItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Pending Items:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 8),
            ...pendingItems.take(5).map((item) {
              final data = item.value as Map;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '• ${data['type']}: ${item.key}',
                  style: const TextStyle(fontSize: 11),
                ),
              );
            }),
            if (pendingItems.length > 5)
              Text(
                '... and ${pendingItems.length - 5} more',
                style: const TextStyle(fontSize: 11, color: AppColors.textGray),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
