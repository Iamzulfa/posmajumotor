# Test Offline Mode - Do This Now! 🚀

## ⏱️ Takes 5 Minutes

### Step 1: Add Debug Route (1 min)

In your router file (e.g., `lib/config/router/app_router.dart`):

```dart
GoRoute(
  path: '/debug/offline',
  builder: (context, state) => const OfflineDebugScreen(),
),
```

Don't forget to import:

```dart
import 'package:posfelix/presentation/screens/debug/offline_debug_screen.dart';
```

### Step 2: Run App (1 min)

```bash
flutter run
```

### Step 3: Navigate to Debug Screen (1 min)

- Open app
- Navigate to `/debug/offline`
- You should see the debug screen with status

### Step 4: Test Offline (2 min)

**Test A: Create Transaction Offline**

1. In debug screen, note current status
2. Disable WiFi/Mobile Data:
   - **Device**: Settings → WiFi → Off
   - **Emulator**: Extended Controls → Network → Offline
3. Go to transaction screen
4. Create a new transaction
5. Go back to debug screen
6. **Expected**:
   - Status shows 🔴 Offline
   - Pending count increased
   - Transaction appears in "Pending Items"

**Test B: Auto-Sync When Online**

1. Still in debug screen with pending items
2. Enable WiFi/Mobile Data:
   - **Device**: Settings → WiFi → On
   - **Emulator**: Extended Controls → Network → WiFi
3. Watch debug screen
4. **Expected**:
   - Status changes to 🟢 Online
   - Pending count goes to 0
   - Pending items disappear

**Test C: Verify in Supabase**

1. Go to https://supabase.com
2. Login to your project
3. Go to "transactions" table
4. **Expected**: Your transaction should be there!

---

## ✅ Success Criteria

- [ ] Debug screen loads
- [ ] Shows 🟢 Online initially
- [ ] Can disable WiFi/Mobile
- [ ] Shows 🔴 Offline
- [ ] Can create transaction
- [ ] Transaction appears in pending items
- [ ] Can enable WiFi/Mobile
- [ ] Shows 🟢 Online again
- [ ] Pending items disappear
- [ ] Transaction appears in Supabase

---

## 🎯 What Each Status Means

### 🟢 Online

- App has internet connection
- Transactions/expenses sync immediately to Supabase
- No pending items

### 🔴 Offline

- No internet connection
- Transactions/expenses saved locally
- Will sync when online
- Shows pending count

### Pending Items

- Transactions/expenses waiting to sync
- Will sync automatically when online
- Can manually delete from debug screen

---

## 🐛 If Something Goes Wrong

### Debug Screen Not Found

```
Error: Could not find route /debug/offline
```

**Fix**: Make sure you added the route to your router

### Offline Indicator Not Showing

```
Can't see "⚠️ Mode Offline" at top
```

**Fix**: Make sure OfflineService is initialized in main.dart

### Data Not Syncing

```
Pending items still there after enabling WiFi
```

**Fix**:

1. Check internet is actually working
2. Check Supabase is accessible
3. Check logs for errors

### Pending Items Not Showing

```
Created transaction but don't see it in pending items
```

**Fix**: Make sure you're actually offline (check debug screen shows 🔴)

---

## 📱 Quick Reference

### Disable WiFi (Device)

1. Settings
2. WiFi
3. Toggle Off

### Disable WiFi (Emulator)

1. Android Studio
2. Emulator window → ... (three dots)
3. Extended controls
4. Network tab
5. Change to "Offline"

### Check Supabase

1. https://supabase.com
2. Login
3. Select project
4. Go to "transactions" table
5. Look for your data

### View Logs

```bash
flutter run -v
# Look for:
# 📡 OFFLINE MODE ACTIVATED
# 📤 Queued transaction
# 📡 ONLINE MODE ACTIVATED
```

---

## 🎉 You're Done!

If all checks pass ✅, offline mode is working!

**Next**:

1. Test with expenses too
2. Test with multiple items
3. Test sync reliability
4. Integrate with main app

---

## 💡 Pro Tips

### Fastest Testing

1. Use emulator (faster WiFi toggle)
2. Use debug screen (instant feedback)
3. Keep Supabase dashboard open

### Best Practices

1. Test with 1 item first
2. Then test with 5 items
3. Then test with 10 items
4. Check Supabase after each test

### Debugging

1. Keep logs visible: `flutter run -v`
2. Keep debug screen open
3. Keep Supabase dashboard open
4. Watch all three while testing

---

**Status**: Ready to test now! 🚀

**Time**: 5 minutes

**Difficulty**: Easy

**Result**: Offline mode working! ✅
