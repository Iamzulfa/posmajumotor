import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/app_colors.dart';
import '../../../presentation/providers/offline_provider.dart';

class OfflineDebugScreen extends ConsumerWidget {
  const OfflineDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineService = ref.watch(offlineServiceProvider);
    final stats = ref.watch(cacheStatsProvider);
    final pending = offlineService.getPendingSyncItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🐛 Offline Debug'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Section
            _buildSection('Status', [
              _buildRow(
                'Connectivity',
                offlineService.isOnline ? '🟢 Online' : '🔴 Offline',
                offlineService.isOnline ? Colors.green : Colors.red,
              ),
              _buildRow(
                'Cache Items',
                '${stats['cachedItems']}',
                AppColors.primary,
              ),
              _buildRow(
                'Pending Sync',
                '${stats['pendingSyncItems']}',
                AppColors.warning,
              ),
            ]),
            const SizedBox(height: 24),

            // Actions Section
            _buildSection('Actions', [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _clearCache(ref),
                  icon: const Icon(Icons.delete),
                  label: const Text('Clear Cache'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _clearSyncQueue(ref),
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Sync Queue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCacheContents(context, ref),
                  icon: const Icon(Icons.storage),
                  label: const Text('View Cache Contents'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // Pending Items Section
            if (pending.isNotEmpty)
              _buildSection('Pending Items (${pending.length})', [
                ...pending.map((item) {
                  final data = item.value as Map;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.background,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${data['type'].toString().toUpperCase()}: ${item.key}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 16),
                                onPressed: () =>
                                    _removePendingItem(ref, item.key),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Queued: ${data['timestamp']}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ])
            else
              _buildSection('Pending Items', [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.success.withValues(alpha: 0.1),
                  ),
                  child: const Text(
                    '✅ No pending items',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]),
            const SizedBox(height: 24),

            // Info Section
            _buildSection('Info', [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.background,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to Test:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Disable WiFi/Mobile Data\n'
                      '2. Create transaction/expense\n'
                      '3. See items in "Pending Items"\n'
                      '4. Enable WiFi/Mobile Data\n'
                      '5. Items should sync automatically',
                      style: TextStyle(fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Status: ${offlineService.isOnline ? "Online - Check Supabase for synced data" : "Offline - Data will sync when online"}',
                      style: TextStyle(
                        fontSize: 11,
                        color: offlineService.isOnline
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              border: Border.all(color: color),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }

  void _clearCache(WidgetRef ref) async {
    final offlineService = ref.read(offlineServiceProvider);
    await offlineService.clearAllCache();
    ref.invalidate(cacheStatsProvider);
  }

  void _clearSyncQueue(WidgetRef ref) async {
    final offlineService = ref.read(offlineServiceProvider);
    await offlineService.clearSyncQueue();
    ref.invalidate(pendingSyncCountProvider);
  }

  void _removePendingItem(WidgetRef ref, String itemId) async {
    final offlineService = ref.read(offlineServiceProvider);
    await offlineService.removeSyncedItem(itemId);
    ref.invalidate(pendingSyncCountProvider);
  }

  void _showCacheContents(BuildContext context, WidgetRef ref) {
    final offlineService = ref.read(offlineServiceProvider);
    final pending = offlineService.getPendingSyncItems();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache Contents'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pending Items:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (pending.isEmpty)
                const Text('No pending items')
              else
                ...pending.map((item) {
                  final data = item.value as Map;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '• ${data['type']}: ${item.key}\n  ${data['timestamp']}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
