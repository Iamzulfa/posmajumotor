# Dashboard Cache Invalidation Fix

## Problem Identified

Dashboard metrics tidak update ketika hari berganti karena cache tidak ter-invalidate.

### Root Cause

`getDashboardDataStream()` di-cache dengan key yang sama setiap hari:

```dart
// BEFORE (WRONG)
if (_cachedDashboardDataStream != null) {
  return _cachedDashboardDataStream!; // Cache tidak pernah di-clear
}

_cachedDashboardDataStream = getDashboardDataStreamForRange(
  startDate: startOfDay,
  endDate: endOfDay,
).shareReplay(bufferSize: 1);
```

**Masalah:**

- Ketika hari berganti (misal dari 1 Januari ke 2 Januari)
- Cache masih ada dari hari kemarin
- Stream lama masih filter untuk 1 Januari
- Metrics tetap menampilkan data 1 Januari

### Solution

Tambahkan date tracking untuk invalidate cache setiap hari:

```dart
// AFTER (CORRECT)
String? _cachedDashboardDataStreamDate; // Track which date the cache is for

Stream<DashboardData> getDashboardDataStream() {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  // Create a date key to invalidate cache when day changes
  final dateKey = '${startOfDay.year}-${startOfDay.month}-${startOfDay.day}';

  // If cache exists but is for a different day, invalidate it
  if (_cachedDashboardDataStreamDate != dateKey) {
    _cachedDashboardDataStream = null;
    _cachedDashboardDataStreamDate = null;
  }

  if (_cachedDashboardDataStream != null) {
    return _cachedDashboardDataStream!;
  }

  _cachedDashboardDataStreamDate = dateKey;
  _cachedDashboardDataStream = getDashboardDataStreamForRange(
    startDate: startOfDay,
    endDate: endOfDay,
  ).shareReplay(bufferSize: 1);

  return _cachedDashboardDataStream!;
}
```

## Files Changed

### `lib/data/repositories/dashboard_repository_impl.dart`

- Added `_cachedDashboardDataStreamDate` field to track cache date
- Modified `getDashboardDataStream()` to check date and invalidate cache when day changes

### `lib/presentation/providers/dashboard_provider.dart`

- Removed unused variables (`monthStart`, `monthEnd`, `todayExpensesStream`)
- Ensured `DateTime.now()` is called inside stream emit loop for accurate date

## How It Works Now

```
Day 1 (Jan 1):
  - getDashboardDataStream() called
  - dateKey = '2024-1-1'
  - Cache created for Jan 1
  - Stream filters transactions for Jan 1

Day 2 (Jan 2):
  - getDashboardDataStream() called
  - dateKey = '2024-1-2'
  - dateKey != _cachedDashboardDataStreamDate ('2024-1-1')
  - Cache invalidated ✓
  - New stream created for Jan 2
  - Stream filters transactions for Jan 2
```

## Testing

- [ ] Create transaction on day 1
- [ ] Check dashboard - should show correct metrics
- [ ] Wait until day 2 (or manually change system date)
- [ ] Check dashboard - should show 0 transactions (new day)
- [ ] Create transaction on day 2
- [ ] Check dashboard - should show new transaction

## Important Notes

1. **Cache is per-day, not per-month**

   - Daily cache invalidates automatically when day changes
   - Monthly data (tax) is calculated separately

2. **Tax calculation is separate**

   - Tax uses `getTaxIndicatorStream()` which is cached per month-year
   - Tax does NOT reset when day changes
   - Tax only resets when month changes

3. **Stream emission**
   - Stream emits when transactions change
   - Cache invalidation ensures correct date range is used
   - `DateTime.now()` is called inside loop for accurate current date
