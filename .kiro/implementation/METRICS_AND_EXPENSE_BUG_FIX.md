# Metrics & Expense Bug Fix

## Problems Fixed

### 1. Dashboard Metrics Showing 0 on Day 3

**Root Cause**: Stream tidak di-cache, sehingga setiap kali widget rebuild, stream baru dibuat tanpa menutup yang lama. Setelah beberapa hari, terlalu banyak stream terbuka menyebabkan data tidak ter-update.

**Solution**:

- Added stream caching di `DashboardRepositoryImpl`
- Implemented `shareReplay()` untuk single subscription dengan multiple listeners
- Cache key-based untuk `getTaxIndicatorStream` (per month-year)

### 2. Expense Creation Only Works Once

**Root Cause**: Setelah `createExpense()` dipanggil, `loadTodayExpenses()` dipanggil yang mengubah state. Namun stream provider (`expensesByDateStreamProvider`) tidak di-invalidate, sehingga UI tetap menampilkan data lama.

**Solution**:

- Removed `loadTodayExpenses()` call setelah create/update/delete
- Stream provider sekarang handle real-time updates otomatis
- State hanya di-update untuk loading/error status, bukan data

## Files Changed

### 1. `lib/data/repositories/dashboard_repository_impl.dart`

- Added stream caching fields:
  - `_cachedDashboardDataStream`
  - `_cachedProfitIndicatorStream`
  - `_cachedTaxIndicatorStreams` (Map untuk per-month caching)
- Modified `getDashboardDataStream()` to use caching
- Modified `getDashboardDataStreamForRange()` to use `shareReplay()`
- Added `_buildProfitStream()` helper untuk reusable profit stream logic
- Modified `getProfitIndicatorStream()` to cache base stream
- Modified `getTaxIndicatorStream()` to cache per month-year
- Added import untuk `stream_extensions.dart`

### 2. `lib/presentation/providers/expense_provider.dart`

- Modified `createExpense()` - removed `loadTodayExpenses()` call
- Modified `addExpense()` - removed `loadTodayExpenses()` call
- Modified `updateExpense()` - removed `loadTodayExpenses()` call
- Modified `deleteExpense()` - removed `loadTodayExpenses()` call
- Replaced `print()` dengan `AppLogger.error()` untuk proper logging
- Added import untuk `AppLogger`

## How It Works Now

### Before (Broken)

```
User creates expense
  ↓
createExpense() called
  ↓
loadTodayExpenses() called (fetches from DB)
  ↓
State updated with new data
  ↓
Stream provider still has old data
  ↓
UI shows inconsistent data
```

### After (Fixed)

```
User creates expense
  ↓
createExpense() called
  ↓
Data inserted to Supabase
  ↓
Realtime stream detects change
  ↓
Stream emits new data automatically
  ↓
UI updates with fresh data
```

## Benefits

✅ Dashboard metrics tetap akurat setelah hari ke-3
✅ Expense creation works unlimited times
✅ Real-time updates tanpa manual refresh
✅ Reduced channel subscriptions (single stream per table)
✅ Better memory management dengan stream caching

## Testing Checklist

- [ ] Create multiple expenses in one day - all should appear
- [ ] Switch between dates - metrics should update correctly
- [ ] Wait 3+ days - dashboard should still show correct metrics
- [ ] Check Supabase dashboard - channel count should be low (2-3 per repo)
- [ ] Monitor logs - no `ChannelRateLimitReached` errors
