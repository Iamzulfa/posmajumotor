# Offline Mode Testing Guide - Updated

**Date**: December 28, 2025  
**Status**: ✅ Ready for Testing  
**Previous Issue**: Hive serialization error (FIXED)

## Quick Start - Test Offline Mode Now

### Prerequisites

- Flutter app running on device/emulator
- WiFi/internet connection available
- Device settings accessible

### Test Scenario 1: Online → Offline (Recommended First Test)

**Step 1: Start App Online**

```
1. Ensure WiFi is ON
2. Launch the app
3. Wait for dashboard to load (should show real data)
4. Check logs for: "✅ Cached real dashboard data"
```

**Step 2: Verify Cache Seeding**

```
Expected logs:
- "🌱 Seeding initial cache data..."
- "📡 Connectivity status: ONLINE"
- "✅ Cached real dashboard data: dashboard_data_..."
- "✅ Cached real profit indicator"
- "✅ Cached real tax indicator"
- "📊 Cache stats: {isOnline: true, cachedItems: 3, ...}"
```

**Step 3: Go Offline**

```
1. Disable WiFi on device
2. Wait 5-10 seconds
3. Check logs for: "📡 OFFLINE MODE ACTIVATED"
```

**Step 4: Verify Offline Display**

```
1. Navigate to Dashboard screen
2. Should display cached data (same as before)
3. Check logs for: "📦 Using cached dashboard data (offline mode)"
4. No error messages should appear
```

**Step 5: Go Back Online**

```
1. Enable WiFi
2. Wait 5-10 seconds
3. Check logs for: "📡 ONLINE MODE ACTIVATED"
4. Data should refresh with latest values
```

### Test Scenario 2: Offline from Start

**Step 1: Disable WiFi**

```
1. Turn OFF WiFi on device
2. Ensure no mobile data connection
```

**Step 2: Launch App**

```
1. Start the app
2. Wait for initialization
3. Check logs for: "📡 Offline detected - seeding with mock data immediately"
```

**Step 3: Verify Mock Data**

```
Expected logs:
- "🌱 Seeding initial cache data..."
- "📡 Connectivity status: OFFLINE"
- "✅ Cached mock dashboard data: dashboard_data_..."
- "✅ Cached mock profit indicator"
- "✅ Cached mock tax indicator"
```

**Step 4: Check Dashboard**

```
1. Dashboard should display mock data:
   - Total Transactions: 15
   - Total Omset: Rp 5,750,000
   - Total Profit: Rp 1,150,000
   - Total Expenses: Rp 500,000
2. No error messages
3. Offline indicator visible (if implemented)
```

### Test Scenario 3: Network Interruption

**Step 1: Start Online**

```
1. WiFi ON
2. App running
3. Dashboard loaded with real data
```

**Step 2: Simulate Network Interruption**

```
1. Disable WiFi
2. Wait 5 seconds
3. Enable WiFi
4. Wait 5 seconds
```

**Step 3: Verify Recovery**

```
1. Dashboard should continue displaying data
2. No crashes or errors
3. Data should update when online
4. Logs show: "📡 OFFLINE MODE ACTIVATED" then "📡 ONLINE MODE ACTIVATED"
```

## Detailed Testing Checklist

### ✅ Cache Seeding Tests

- [ ] **Real Data Caching (Online)**

  - [ ] Dashboard data cached with correct values
  - [ ] Profit indicator cached
  - [ ] Tax indicator cached
  - [ ] Cache keys are correct format

- [ ] **Mock Data Seeding (Offline)**

  - [ ] Mock data seeded when offline detected
  - [ ] Mock data seeded as fallback if Supabase unavailable
  - [ ] Mock data has reasonable test values
  - [ ] All three cache keys populated

- [ ] **Cache Persistence**
  - [ ] Cached data persists after app restart
  - [ ] Cached data available when offline
  - [ ] Cache cleared properly when needed

### ✅ Offline Mode Tests

- [ ] **Offline Detection**

  - [ ] App detects when WiFi disabled
  - [ ] App detects when WiFi enabled
  - [ ] Connectivity status updates correctly
  - [ ] Offline indicator shows/hides

- [ ] **Offline Display**

  - [ ] Dashboard shows cached data when offline
  - [ ] No error messages displayed
  - [ ] UI remains responsive
  - [ ] All screens accessible

- [ ] **Online Recovery**
  - [ ] App reconnects when WiFi enabled
  - [ ] Data updates with latest values
  - [ ] No duplicate data or conflicts
  - [ ] Smooth transition from offline to online

### ✅ Error Handling Tests

- [ ] **Network Errors**

  - [ ] App handles network timeouts gracefully
  - [ ] App handles connection failures gracefully
  - [ ] Error messages are user-friendly
  - [ ] App doesn't crash on network errors

- [ ] **Cache Errors**

  - [ ] App handles missing cache gracefully
  - [ ] App handles corrupted cache gracefully
  - [ ] Fallback to mock data works
  - [ ] No crashes on cache errors

- [ ] **Supabase Unavailable**
  - [ ] App detects Supabase unavailable
  - [ ] Falls back to mock data
  - [ ] No error messages to user
  - [ ] App remains functional

### ✅ Performance Tests

- [ ] **Startup Time**

  - [ ] App starts quickly online
  - [ ] App starts quickly offline
  - [ ] Cache seeding doesn't block UI
  - [ ] Splash screen shows appropriate time

- [ ] **Memory Usage**

  - [ ] No memory leaks when toggling offline/online
  - [ ] Cache doesn't consume excessive memory
  - [ ] App remains responsive with cache

- [ ] **Data Accuracy**
  - [ ] Cached data matches real data
  - [ ] Mock data is reasonable for testing
  - [ ] No data corruption in cache

## Log Monitoring

### Expected Log Patterns

**Successful Online Startup**:

```
🌱 Seeding initial cache data...
📡 Connectivity status: ONLINE
✅ Cached real dashboard data: dashboard_data_2025-12-28T00:00:00.000Z
✅ Cached real profit indicator
✅ Cached real tax indicator
📊 Cache stats: {isOnline: true, cachedItems: 3, pendingSyncItems: 0, cacheSize: 3}
```

**Successful Offline Startup**:

```
🌱 Seeding initial cache data...
📡 Connectivity status: OFFLINE
📡 Offline detected - seeding with mock data immediately
✅ Cached mock dashboard data: dashboard_data_2025-12-28T00:00:00.000Z
✅ Cached mock profit indicator
✅ Cached mock tax indicator
```

**Offline Mode Activated**:

```
📡 OFFLINE MODE ACTIVATED - No internet connection
```

**Online Mode Activated**:

```
📡 ONLINE MODE ACTIVATED - Internet connection restored
🔄 Syncing 0 pending items...
```

**Using Cached Data**:

```
📦 Using cached dashboard data (offline mode)
```

### Error Patterns to Watch For

❌ **Should NOT see these errors**:

```
HiveError: Cannot write, unknown type: DashboardData
ClientException with SocketException: Failed host lookup
Error caching data: HiveError
```

✅ **These are OK**:

```
Error fetching initial dashboard data (followed by cache fallback)
Could not fetch real data from Supabase (followed by mock data seeding)
```

## Debugging Tips

### Check Offline Service Status

```dart
// In debug screen or console
final offlineService = OfflineService();
print('Is Online: ${offlineService.isOnline}');
print('Cache Stats: ${offlineService.getCacheStats()}');
```

### View Cached Data

```dart
final offlineService = OfflineService();
final dashboardCache = offlineService.getCachedData('dashboard_data_2025-12-28T00:00:00.000Z');
print('Cached Dashboard: $dashboardCache');
```

### Clear Cache for Fresh Test

```dart
final offlineService = OfflineService();
await offlineService.clearAllCache();
```

## Common Issues & Solutions

### Issue: "Cannot write, unknown type: DashboardData"

**Status**: ✅ FIXED in this update

**Solution**: Cache seeder now stores Maps instead of objects. No adapter registration needed.

### Issue: App crashes when going offline

**Solution**:

1. Check that OfflineService is initialized in main.dart
2. Verify CacheSeeder.seedInitialCache() is called
3. Check logs for initialization errors

### Issue: Cached data not showing when offline

**Solution**:

1. Verify cache was seeded (check logs for "✅ Cached...")
2. Check cache keys match between seeding and retrieval
3. Verify offline detection is working (check logs for "OFFLINE MODE ACTIVATED")

### Issue: Mock data not seeding

**Solution**:

1. Verify app is offline when starting
2. Check logs for "Offline detected - seeding with mock data"
3. If Supabase is unavailable, mock data should seed as fallback

## Success Criteria

✅ **Offline Mode is Working When**:

1. App starts online and caches real data
2. App detects when WiFi is disabled
3. Cached data displays when offline
4. No error messages shown to user
5. App recovers when WiFi is re-enabled
6. App starts offline and seeds mock data
7. All screens remain accessible offline
8. No crashes or hangs

## Next Steps After Testing

1. **If all tests pass**: Offline mode is production-ready
2. **If issues found**: Check logs and use debugging tips above
3. **For sync functionality**: Implement actual sync logic in repositories
4. **For offline creation**: Add support for creating transactions/expenses offline

## Related Documentation

- `OFFLINE_MODE_IMPLEMENTATION_COMPLETE.md` - Architecture overview
- `OFFLINE_MODE_HIVE_FIX.md` - Hive serialization fix details
- `lib/core/services/offline_service.dart` - Service implementation
- `lib/core/services/cache_seeder.dart` - Cache seeding logic
