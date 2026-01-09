# Offline Mode Testing - Quick Start Guide

## What's Ready to Test

✅ **Data Caching** - Real data from Supabase cached on startup
✅ **Offline Detection** - App detects when internet is unavailable
✅ **Cached Data Display** - Dashboard/Expenses show cached data when offline
✅ **Offline Indicator** - UI shows offline status banner
✅ **Debug Screen** - View cache contents and pending items
✅ **Mock Data Fallback** - Mock data if Supabase unavailable

## Quick Test (5 minutes)

### Step 1: Start App

```
flutter run
```

- App initializes OfflineService
- CacheSeeder fetches real data from Supabase
- Cache is populated with today's dashboard, profit, and tax data

### Step 2: Verify Cache Seeded

- Check console logs for: `✅ Cached real dashboard data`
- Or check debug screen for cache items count

### Step 3: Disable Internet

- **Android**: Settings → WiFi → Turn Off
- **iOS**: Settings → WiFi → Turn Off
- **Emulator**: Disable WiFi in emulator settings

### Step 4: Navigate Dashboard

- Dashboard should show cached data (not error)
- Offline indicator banner appears at top
- All metrics display cached values

### Step 5: Check Offline Indicator

- Red banner shows "⚠️ Mode Offline"
- Shows pending sync count (if any)

### Step 6: Open Debug Screen

- Navigate to: `OfflineDebugScreen`
- View cache statistics
- See "🔴 Offline" status
- View cached items

### Step 7: Re-enable Internet

- Turn WiFi back on
- Offline indicator disappears
- Status changes to "🟢 Online"

## Expected Behavior

### Dashboard (Offline)

- Shows cached data from today
- Displays: Total Transactions, Omset, Profit, Expenses
- All values from cache (not real-time)

### Expenses (Offline)

- Shows cached expenses
- Can view today's expenses
- Can view expense history

### Transactions (Offline)

- Shows cached transaction summary
- Displays: Total Omset, Profit, HPP

### Offline Indicator

- Appears when WiFi/Mobile disabled
- Shows "Mode Offline" with warning icon
- Disappears when connection restored

### Debug Screen

- Shows connectivity status
- Shows cache item count
- Shows pending sync count
- Allows clearing cache

## Testing Scenarios

### Scenario 1: View Cached Data

1. Start app (cache seeded)
2. Disable internet
3. Navigate to dashboard
4. ✅ Should show cached data

### Scenario 2: Check Offline Status

1. Disable internet
2. Look for offline indicator banner
3. ✅ Should show "Mode Offline"

### Scenario 3: Debug Cache

1. Disable internet
2. Open debug screen
3. ✅ Should show cache items and offline status

### Scenario 4: Reconnect

1. Disable internet
2. Verify offline indicator shows
3. Enable internet
4. ✅ Indicator should disappear

## Logs to Watch For

### Startup

```
🌱 Seeding initial cache data from Supabase...
✅ Cached real dashboard data: dashboard_data_2025-12-28T00:00:00.000Z
✅ Cached real profit indicator
✅ Cached real tax indicator
🌱 Cache seeding completed successfully with real data!
```

### Going Offline

```
📡 OFFLINE MODE ACTIVATED - No internet connection
```

### Using Cached Data

```
📦 Using cached dashboard data (offline mode)
📦 Using cached today expenses (offline mode)
```

### Going Online

```
📡 ONLINE MODE ACTIVATED - Internet connection restored
🔄 Syncing pending items...
```

## Troubleshooting

### Cache Not Showing

**Problem**: Dashboard shows error when offline
**Solution**:

- Check logs for cache seeding errors
- Verify Supabase connection on startup
- Check Hive boxes initialized in main.dart

### Offline Not Detected

**Problem**: Offline indicator doesn't appear
**Solution**:

- Verify WiFi is actually disabled
- Restart app
- Check connectivity_plus is initialized

### Debug Screen Not Accessible

**Problem**: Can't navigate to debug screen
**Solution**:

- Add route to debug screen in router
- Or access via: `Navigator.push(context, MaterialPageRoute(builder: (_) => OfflineDebugScreen()))`

## What's NOT Yet Implemented

❌ **Sync Logic** - Pending items don't sync yet (queued but not sent)
❌ **Create Offline** - Can't create transactions/expenses while offline yet
❌ **Conflict Resolution** - No handling for data conflicts
❌ **Selective Sync** - Can't choose what to sync

These will be implemented in next phase.

## Files to Check

- `lib/core/services/offline_service.dart` - Core offline logic
- `lib/core/services/cache_seeder.dart` - Cache initialization
- `lib/presentation/screens/debug/offline_debug_screen.dart` - Debug interface
- `lib/main.dart` - Initialization code

## Success Criteria

✅ App starts without errors
✅ Cache is seeded with real data
✅ Offline indicator appears when disconnected
✅ Dashboard shows cached data when offline
✅ Debug screen shows cache statistics
✅ No errors in console logs
✅ Offline indicator disappears when reconnected

---

**Ready to Test**: Yes ✅
**Estimated Test Time**: 5-10 minutes
**Last Updated**: December 28, 2025
