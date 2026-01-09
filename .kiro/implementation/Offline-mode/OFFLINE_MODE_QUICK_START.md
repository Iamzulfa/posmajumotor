# Offline Mode - Quick Start Testing

## 🚀 Fastest Way to Test (5 minutes)

### Step 1: Add Debug Screen to Router

In your `go_router` configuration (usually in `lib/config/router/app_router.dart`):

```dart
GoRoute(
  path: '/debug/offline',
  builder: (context, state) => const OfflineDebugScreen(),
),
```

### Step 2: Run App

```bash
flutter run
```

### Step 3: Navigate to Debug Screen

- Open app
- Go to `/debug/offline` (or add a button to navigate there)
- You should see the debug screen

### Step 4: Test Offline Mode

**Scenario 1: Create Transaction Offline**

1. In debug screen, see current status
2. Disable WiFi/Mobile Data on device
3. Go to transaction screen
4. Create a new transaction
5. Go back to debug screen
6. Should see:
   - 🔴 Offline status
   - Pending count increased
   - Transaction in "Pending Items" list

**Scenario 2: Auto-Sync When Online**

1. Still in debug screen with pending items
2. Enable WiFi/Mobile Data
3. Watch pending items disappear
4. Check Supabase dashboard - transaction should be there

---

## 📱 Alternative: Real Device Testing

### Without Debug Screen

1. **Disable WiFi/Mobile Data**

   - Device: Settings → WiFi → Off
   - Emulator: Extended Controls → Network → Offline

2. **Create Transaction/Expense**

   - Should see "⚠️ Mode Offline" indicator at top
   - Should see pending count badge

3. **Enable WiFi/Mobile Data**
   - Indicator should disappear
   - Data should sync automatically

---

## 🔍 What to Look For

### When Offline:

- ✅ "⚠️ Mode Offline" indicator appears
- ✅ Pending count badge shows number
- ✅ Transaction/expense created successfully
- ✅ Data saved locally

### When Online Again:

- ✅ Offline indicator disappears
- ✅ Pending count goes to 0
- ✅ Data appears in Supabase
- ✅ No errors in console

---

## 🐛 Debug Screen Features

### Status Section

- Shows current connectivity (🟢 Online / 🔴 Offline)
- Shows cache items count
- Shows pending sync items count

### Actions Section

- **Clear Cache** - Remove all cached data
- **Clear Sync Queue** - Remove all pending items
- **View Cache Contents** - See detailed pending items

### Pending Items Section

- Lists all items waiting to sync
- Shows item type (TRANSACTION/EXPENSE)
- Shows when it was queued
- Can delete individual items

---

## 📊 Testing Checklist

- [ ] Debug screen accessible
- [ ] Can see status (Online/Offline)
- [ ] Can create transaction offline
- [ ] Pending count increases
- [ ] Can enable WiFi/Mobile
- [ ] Pending items sync
- [ ] Data appears in Supabase
- [ ] No errors in console

---

## 🎯 Next Steps After Testing

1. **Integrate with Repositories**

   - Update `TransactionRepositoryImpl`
   - Update `ExpenseRepositoryImpl`

2. **Add to Main App**

   - Add `OfflineIndicator` to main screen
   - Initialize `OfflineService` in `main.dart`

3. **Production Ready**
   - Remove debug screen from production build
   - Add proper error handling
   - Add sync progress UI

---

## 💡 Tips

### Quick Toggle WiFi (Emulator)

1. Open Android Studio
2. Emulator window → ... (three dots)
3. Extended controls → Network
4. Change to "Offline" or "WiFi"

### Check Supabase

1. Go to https://supabase.com
2. Login to your project
3. Go to "transactions" or "expenses" table
4. Look for newly synced data

### View Logs

```bash
flutter run -v
# Look for:
# 📡 OFFLINE MODE ACTIVATED
# 📡 ONLINE MODE ACTIVATED
# 💾 Cached: ...
# 📤 Queued: ...
```

---

## ❓ Troubleshooting

### Debug Screen Not Found

- Make sure route is added to router
- Check path is correct: `/debug/offline`
- Restart app

### Offline Indicator Not Showing

- Make sure `OfflineIndicator` is added to main screen
- Check `OfflineService` is initialized in `main.dart`
- Restart app

### Data Not Syncing

- Check internet connection is actually enabled
- Check Supabase is accessible
- Check logs for errors
- Try clearing sync queue and recreating

### Pending Items Not Showing

- Make sure you're actually offline
- Check debug screen shows 🔴 Offline
- Try creating new transaction/expense
- Check logs for queue messages

---

**Status**: ✅ **READY TO TEST**

**Time to First Test**: ~5 minutes

**Recommended**: Start with debug screen, then test with real WiFi toggle
