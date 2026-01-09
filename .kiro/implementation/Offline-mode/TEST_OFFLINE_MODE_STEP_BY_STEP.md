# Test Offline Mode - Step by Step

## Prerequisites

- Flutter app running
- Device/Emulator with WiFi capability
- Supabase connection working

## Test 1: Verify Cache Seeding (2 minutes)

### Steps

1. **Clean and rebuild**

   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Watch console logs**

   - Look for: `🌱 Seeding initial cache data from Supabase...`
   - Look for: `✅ Cached real dashboard data`
   - Look for: `✅ Cached real profit indicator`
   - Look for: `✅ Cached real tax indicator`
   - Look for: `🌱 Cache seeding completed successfully with real data!`

3. **Expected Result**
   - ✅ All cache seeding logs appear
   - ✅ No errors in console
   - ✅ App loads dashboard normally

### Troubleshooting

- If logs don't appear: Check Supabase connection
- If errors appear: Check Hive initialization in main.dart
- If app crashes: Check OfflineService initialization

---

## Test 2: Verify Offline Detection (3 minutes)

### Steps

1. **Start app with WiFi ON**

   - Dashboard loads normally
   - Check console: `📡 Offline Service initialized - Status: ONLINE`

2. **Disable WiFi**

   - **Android**: Settings → WiFi → Toggle Off
   - **iOS**: Settings → WiFi → Toggle Off
   - **Emulator**: Emulator menu → WiFi → Toggle Off

3. **Watch console logs**

   - Look for: `📡 OFFLINE MODE ACTIVATED - No internet connection`

4. **Check UI**

   - Offline indicator banner should appear at top
   - Shows: "⚠️ Mode Offline" with warning icon

5. **Expected Result**
   - ✅ Offline log appears in console
   - ✅ Offline indicator visible in UI
   - ✅ No errors

### Troubleshooting

- If offline not detected: Restart app
- If indicator not showing: Check OfflineIndicator widget is in app
- If logs don't appear: Check connectivity_plus initialization

---

## Test 3: Verify Cached Data Display (3 minutes)

### Steps

1. **Start with WiFi OFF** (from Test 2)

   - Offline indicator visible
   - Console shows offline mode

2. **Navigate to Dashboard**

   - Dashboard should load
   - Shows cached data (not error)
   - Displays: Total Transactions, Omset, Profit, Expenses

3. **Check values**

   - Should show numbers (not 0 or error)
   - Values from cache seeding

4. **Navigate to Expenses**

   - Expense screen loads
   - Shows cached expenses
   - Can view today's expenses

5. **Navigate to Transactions**

   - Transaction summary loads
   - Shows cached transaction data

6. **Expected Result**
   - ✅ All screens load without errors
   - ✅ Cached data displays correctly
   - ✅ No "Connection Error" messages
   - ✅ Console shows: `📦 Using cached data (offline mode)`

### Troubleshooting

- If screens show error: Check cache seeding completed
- If data shows 0: Check cache keys match
- If error messages appear: Check offline fallback in repositories

---

## Test 4: Verify Offline Indicator (2 minutes)

### Steps

1. **With WiFi OFF** (from Test 3)

   - Look at top of screen
   - Should see orange/yellow banner

2. **Check banner content**

   - Shows: "⚠️ Mode Offline"
   - Shows warning icon
   - May show pending sync count

3. **Tap on banner** (if expandable)

   - Should show more details
   - Shows pending items count

4. **Expected Result**
   - ✅ Banner visible and styled correctly
   - ✅ Shows offline status
   - ✅ Shows pending count if any

### Troubleshooting

- If banner not visible: Check OfflineIndicator in app layout
- If styling wrong: Check AppColors in theme
- If not updating: Check Riverpod provider invalidation

---

## Test 5: Verify Debug Screen (3 minutes)

### Steps

1. **With WiFi OFF** (from Test 4)

   - Navigate to: `OfflineDebugScreen`
   - Or: `Navigator.push(context, MaterialPageRoute(builder: (_) => OfflineDebugScreen()))`

2. **Check Status Section**

   - Connectivity: Should show "🔴 Offline"
   - Cache Items: Should show number > 0
   - Pending Sync: Should show 0 (no pending items yet)

3. **Check Actions Section**

   - "Clear Cache" button visible
   - "Clear Sync Queue" button visible
   - "View Cache Contents" button visible

4. **Check Pending Items Section**

   - Should show "✅ No pending items" (green box)

5. **Check Info Section**

   - Shows testing instructions
   - Shows current status

6. **Expected Result**
   - ✅ All sections visible
   - ✅ Status shows "🔴 Offline"
   - ✅ Cache items > 0
   - ✅ No errors

### Troubleshooting

- If screen not accessible: Add route to debug screen
- If status wrong: Check OfflineService connectivity monitoring
- If cache items 0: Check cache seeding completed

---

## Test 6: Verify Reconnection (2 minutes)

### Steps

1. **With WiFi OFF and Debug Screen open** (from Test 5)

   - Status shows: "🔴 Offline"
   - Offline indicator visible

2. **Enable WiFi**

   - **Android**: Settings → WiFi → Toggle On
   - **iOS**: Settings → WiFi → Toggle On
   - **Emulator**: Emulator menu → WiFi → Toggle On

3. **Watch console logs**

   - Look for: `📡 ONLINE MODE ACTIVATED - Internet connection restored`

4. **Check UI**

   - Offline indicator should disappear
   - Debug screen status changes to: "🟢 Online"

5. **Check Dashboard**

   - Should refresh with latest data
   - May show updated values

6. **Expected Result**
   - ✅ Online log appears in console
   - ✅ Offline indicator disappears
   - ✅ Debug screen shows online status
   - ✅ No errors

### Troubleshooting

- If offline not cleared: Restart app
- If indicator still showing: Check Riverpod invalidation
- If data not updating: Check polling interval

---

## Test 7: Verify Cache Clearing (2 minutes)

### Steps

1. **With WiFi ON** (from Test 6)

   - Open Debug Screen
   - Status shows: "🟢 Online"
   - Cache Items: Shows number > 0

2. **Click "Clear Cache" button**

   - Should show confirmation or toast
   - Cache Items count should drop to 0

3. **Disable WiFi again**

   - Offline indicator appears
   - Navigate to Dashboard

4. **Check Dashboard**

   - Should show empty/0 values (cache cleared)
   - Or show error (no cache available)

5. **Expected Result**
   - ✅ Cache cleared successfully
   - ✅ Cache items count becomes 0
   - ✅ Dashboard shows empty data when offline

### Troubleshooting

- If cache not clearing: Check clearAllCache() in OfflineService
- If count not updating: Check cacheStatsProvider invalidation
- If dashboard still shows data: Check cache key matching

---

## Test 8: Full Offline Workflow (5 minutes)

### Complete Workflow

1. **Start app** (WiFi ON)

   - Cache seeded with real data
   - Dashboard shows live data

2. **Disable WiFi**

   - Offline indicator appears
   - Dashboard shows cached data

3. **Open Debug Screen**

   - Shows offline status
   - Shows cache statistics

4. **Navigate screens**

   - Dashboard: Shows cached data
   - Expenses: Shows cached expenses
   - Transactions: Shows cached summary

5. **Enable WiFi**

   - Offline indicator disappears
   - Status changes to online

6. **Check Dashboard**
   - Should show updated data
   - May have new transactions/expenses

### Expected Result

- ✅ All steps complete without errors
- ✅ Smooth transition between online/offline
- ✅ Data displays correctly in both modes
- ✅ No crashes or exceptions

---

## Test 9: Mock Data Fallback (Optional)

### Steps

1. **Disconnect from Supabase** (simulate unavailable)

   - Stop Supabase server or block connection

2. **Restart app**

   - Watch console logs
   - Look for: `Could not fetch real data from Supabase`
   - Look for: `Seeding with mock data instead...`

3. **Check Dashboard**

   - Should show mock data (not error)
   - Values: Transactions: 15, Omset: 5,750,000, etc.

4. **Expected Result**
   - ✅ Mock data seeded successfully
   - ✅ Dashboard shows mock values
   - ✅ No errors or crashes

### Troubleshooting

- If real data still showing: Check Supabase connection
- If mock data not showing: Check \_seedMockData() in CacheSeeder
- If error appears: Check error handling in cache seeding

---

## Test 10: Performance Check (2 minutes)

### Steps

1. **Monitor startup time**

   - Time from app launch to dashboard visible
   - Should be ~2-3 seconds (including cache seeding)

2. **Monitor memory usage**

   - Check device memory before/after
   - Should be minimal increase

3. **Monitor battery**

   - Run for 5 minutes offline
   - Check battery drain (should be minimal)

4. **Expected Result**
   - ✅ Startup time acceptable
   - ✅ Memory usage reasonable
   - ✅ Battery drain minimal

### Troubleshooting

- If startup slow: Check cache seeding performance
- If memory high: Check Hive box sizes
- If battery drains fast: Check connectivity monitoring frequency

---

## Summary Checklist

- [ ] Test 1: Cache seeding works
- [ ] Test 2: Offline detection works
- [ ] Test 3: Cached data displays
- [ ] Test 4: Offline indicator shows
- [ ] Test 5: Debug screen works
- [ ] Test 6: Reconnection works
- [ ] Test 7: Cache clearing works
- [ ] Test 8: Full workflow works
- [ ] Test 9: Mock data fallback works (optional)
- [ ] Test 10: Performance acceptable

## Success Criteria

✅ All 10 tests pass
✅ No errors in console
✅ No crashes or exceptions
✅ Smooth online/offline transitions
✅ Data displays correctly in both modes
✅ Performance acceptable

## Estimated Total Time: 25-30 minutes

---

**Ready to Test**: Yes ✅
**Last Updated**: December 28, 2025
