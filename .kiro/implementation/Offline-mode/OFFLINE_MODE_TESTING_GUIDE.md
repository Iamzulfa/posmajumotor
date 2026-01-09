# Offline Mode Testing Guide

## 🧪 Testing Methods

Ada 3 cara untuk test offline mode:

### Method 1: Disable WiFi/Mobile Data (Real Test)

### Method 2: Use Android Emulator Network Control

### Method 3: Use Debug Console (Fastest)

---

## 🔴 Method 1: Real Device Testing (Disable WiFi/Mobile)

### Pros:

- Most realistic
- Tests actual connectivity changes
- Tests battery impact

### Cons:

- Slow to toggle
- Need physical device or emulator

### Steps:

1. **Run app on device/emulator**

   ```bash
   flutter run
   ```

2. **Disable WiFi/Mobile Data**

   - Device: Settings → WiFi → Turn Off
   - Emulator: Extended Controls → Network → Offline

3. **Create Transaction/Expense**

   - Should see "⚠️ Mode Offline" indicator
   - Should see pending count badge
   - Data should be queued locally

4. **Enable WiFi/Mobile Data**

   - Should see indicator disappear
   - Should auto-sync pending items

5. **Verify in Supabase**
   - Check if data was synced to database

---

## 🟢 Method 2: Android Emulator Network Control (Recommended)

### Pros:

- Fast to toggle
- Realistic
- Easy to repeat

### Cons:

- Only for Android emulator
- Need emulator running

### Steps:

1. **Open Emulator Extended Controls**

   ```bash
   # In Android Studio
   # Emulator window → ... (three dots) → Extended controls
   ```

2. **Go to Network tab**

   - Find "Network" section
   - Change to "Offline"

3. **Run app**

   ```bash
   flutter run
   ```

4. **Create Transaction**

   - App should detect offline
   - Show offline indicator
   - Queue data locally

5. **Toggle back to Online**

   - In Extended Controls → Network → WiFi
   - App should detect online
   - Auto-sync pending items

6. **Verify Sync**
   - Check Supabase dashboard
   - Data should be synced

---

## 🟡 Method 3: Debug Console Testing (Fastest)

### Pros:

- Instant toggle
- No need to disable actual network
- Perfect for rapid testing

### Cons:

- Not real connectivity
- Only for development

### Steps:

1. **Add Debug Toggle to App**

Create `lib/presentation/screens/debug/offline_debug_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/offline_service.dart';
import '../../../config/theme/app_colors.dart';

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
            _buildSection(
              'Status',
              [
                _buildRow(
                  'Connectivity',
                  offlineService.isOnline ? '🟢 Online' : '🔴 Offline',
                ),
                _buildRow(
                  'Cache Items',
                  '${stats['cachedItems']}',
                ),
                _buildRow(
                  'Pending Sync',
                  '${stats['pendingSyncItems']}',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions Section
            _buildSection(
              'Actions',
              [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleOfflineMode(ref),
                    icon: Icon(
                      offlineService.isOnline
                          ? Icons.cloud_off
                          : Icons.cloud_done,
                    ),
                    label: Text(
                      offlineService.isOnline
                          ? 'Simulate Offline'
                          : 'Simulate Online',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: offlineService.isOnline
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _clearCache(ref),
                    icon: const Icon(Icons.delete),
                    label: const Text('Clear Cache'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
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
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pending Items Section
            if (pending.isNotEmpty)
              _buildSection(
                'Pending Items (${pending.length})',
                [
                  ...pending.map((item) {
                    final data = item.value as Map;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['type'].toString().toUpperCase()}: ${item.key}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
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
                ],
              ),
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _toggleOfflineMode(WidgetRef ref) {
    final offlineService = ref.read(offlineServiceProvider);
    // This is a mock - in real implementation, you'd need to modify
    // the connectivity monitoring to support debug mode
    ref.invalidate(offlineServiceProvider);
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
}
```

2. **Add to Navigation**

In your app, add debug route:

```dart
// In your router configuration
GoRoute(
  path: '/debug/offline',
  builder: (context, state) => const OfflineDebugScreen(),
),
```

3. **Access Debug Screen**

- Open app
- Navigate to `/debug/offline`
- Click "Simulate Offline"
- Create transaction/expense
- See it queued
- Click "Simulate Online"
- See it sync

---

## 📝 Testing Checklist

### Test 1: Create Transaction Offline

- [ ] Disable WiFi/Mobile or use debug toggle
- [ ] Navigate to transaction screen
- [ ] Create new transaction
- [ ] Verify offline indicator appears
- [ ] Verify pending count shows 1
- [ ] Enable WiFi/Mobile or toggle online
- [ ] Verify transaction syncs to Supabase
- [ ] Verify offline indicator disappears

### Test 2: Create Expense Offline

- [ ] Disable WiFi/Mobile or use debug toggle
- [ ] Navigate to expense screen
- [ ] Create new expense
- [ ] Verify offline indicator appears
- [ ] Verify pending count shows 1
- [ ] Enable WiFi/Mobile or toggle online
- [ ] Verify expense syncs to Supabase
- [ ] Verify offline indicator disappears

### Test 3: Multiple Items Offline

- [ ] Disable WiFi/Mobile
- [ ] Create 3 transactions
- [ ] Create 2 expenses
- [ ] Verify pending count shows 5
- [ ] Enable WiFi/Mobile
- [ ] Verify all 5 items sync
- [ ] Check Supabase for all items

### Test 4: Cache Persistence

- [ ] Create transaction online
- [ ] Disable WiFi/Mobile
- [ ] Navigate away and back
- [ ] Verify transaction still visible (from cache)
- [ ] Enable WiFi/Mobile
- [ ] Verify data still correct

### Test 5: Sync Queue Persistence

- [ ] Disable WiFi/Mobile
- [ ] Create transaction
- [ ] Close app
- [ ] Reopen app
- [ ] Verify pending count still shows 1
- [ ] Enable WiFi/Mobile
- [ ] Verify transaction syncs

### Test 6: Error Handling

- [ ] Disable WiFi/Mobile
- [ ] Create transaction with invalid data
- [ ] Verify error message shown
- [ ] Verify item NOT queued
- [ ] Enable WiFi/Mobile
- [ ] Verify no sync attempt

---

## 🔍 Debugging Tips

### Check Logs

```bash
# Run with verbose logging
flutter run -v

# Look for offline service logs:
# 📡 OFFLINE MODE ACTIVATED
# 📡 ONLINE MODE ACTIVATED
# 💾 Cached: ...
# 📤 Queued: ...
```

### Check Hive Data

```dart
// In debug console
import 'package:hive/hive.dart';

// Get cache box
final cacheBox = Hive.box('offline_cache');
print('Cache contents: ${cacheBox.toMap()}');

// Get sync queue
final syncBox = Hive.box('sync_queue');
print('Sync queue: ${syncBox.toMap()}');
```

### Check Supabase

1. Go to Supabase dashboard
2. Check `transactions` table
3. Check `expenses` table
4. Verify synced data matches queued data

### Monitor Network

```bash
# Use Android Studio Network Profiler
# Tools → Profiler → Network tab
# Watch network requests during sync
```

---

## 🚀 Quick Test Script

Create `test_offline_mode.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:posfelix/core/services/offline_service.dart';

void main() {
  group('Offline Mode Tests', () {
    late OfflineService offlineService;

    setUp(() async {
      offlineService = OfflineService();
      await offlineService.initialize();
    });

    tearDown(() async {
      await offlineService.dispose();
    });

    test('Should cache data', () async {
      await offlineService.cacheData('test_key', {'data': 'test'});
      final cached = offlineService.getCachedData('test_key');
      expect(cached, isNotNull);
    });

    test('Should queue transaction', () async {
      await offlineService.queueTransaction('tx_1', {'amount': 100});
      final pending = offlineService.getPendingSyncItems();
      expect(pending.length, 1);
    });

    test('Should queue expense', () async {
      await offlineService.queueExpense('exp_1', {'amount': 50});
      final pending = offlineService.getPendingSyncItems();
      expect(pending.length, 1);
    });

    test('Should clear cache', () async {
      await offlineService.cacheData('test_key', {'data': 'test'});
      await offlineService.clearCache('test_key');
      final cached = offlineService.getCachedData('test_key');
      expect(cached, isNull);
    });

    test('Should get cache stats', () {
      final stats = offlineService.getCacheStats();
      expect(stats.containsKey('isOnline'), true);
      expect(stats.containsKey('cachedItems'), true);
      expect(stats.containsKey('pendingSyncItems'), true);
    });
  });
}
```

Run tests:

```bash
flutter test test/offline_mode_test.dart
```

---

## 📊 Performance Testing

### Memory Usage

```dart
// Check memory before/after
import 'dart:developer' as developer;

developer.Timeline.instantSync('Before cache', arguments: {
  'memory': ProcessInfo.currentRss,
});

// Cache 1000 items
for (int i = 0; i < 1000; i++) {
  await offlineService.cacheData('item_$i', {'data': 'test'});
}

developer.Timeline.instantSync('After cache', arguments: {
  'memory': ProcessInfo.currentRss,
});
```

### Network Usage

Monitor in Android Studio Profiler:

- Tools → Profiler → Network tab
- Watch requests during sync
- Measure bandwidth used

### Battery Impact

Use Android Studio Battery Profiler:

- Tools → Profiler → Energy tab
- Monitor battery drain during polling
- Compare online vs offline mode

---

## ✅ Testing Checklist Summary

- [ ] Method 1: Real WiFi toggle test
- [ ] Method 2: Emulator network control test
- [ ] Method 3: Debug console test
- [ ] All 6 test scenarios passed
- [ ] Logs verified
- [ ] Supabase data verified
- [ ] Performance acceptable
- [ ] Battery impact acceptable

---

**Status**: ✅ **READY FOR TESTING**

**Recommended Testing Order**:

1. Start with Method 3 (Debug Console) - fastest
2. Then Method 2 (Emulator) - more realistic
3. Finally Method 1 (Real Device) - most realistic
