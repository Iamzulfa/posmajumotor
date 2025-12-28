# Buffering & Zero Metrics Fix

## Problems Fixed

### 1. Dashboard Metrics Showing 0 (Even with Tax Calculation)

**Root Cause**: Stream hanya menampilkan data real-time dari saat stream dibuat, tidak include data yang sudah ada sebelumnya. Jadi transaksi lama tidak ter-count.

**Solution**:

- Fetch initial data dari database terlebih dahulu
- Kemudian stream real-time updates
- Combine keduanya dengan `asyncExpand()`

### 2. Keuangan Page Buffering Loop

**Root Cause**: `shareReplay()` implementation tidak proper, buffer tidak ter-clear, stream stuck.

**Solution**:

- Perbaiki `shareReplay()` dengan `StreamController.broadcast()`
- Add `isSubscribed` flag untuk prevent duplicate subscriptions
- Use `cancelOnError: false` untuk handle errors gracefully

### 3. Old Transactions Not Showing

**Root Cause**: Stream dimulai dari saat listener subscribe, tidak include historical data.

**Solution**:

- Add `_fetchInitialDashboardData()` helper
- Add `_fetchInitialProfitData()` helper
- Add `_fetchInitialTaxData()` helper
- Emit initial data dulu, baru stream real-time updates

## Files Changed

### 1. `lib/core/extensions/stream_extensions.dart`

- Fixed `shareReplay()` implementation
- Changed to `StreamController.broadcast()` untuk proper broadcasting
- Added `isSubscribed` flag untuk prevent duplicate subscriptions
- Added `cancelOnError: false` untuk graceful error handling

### 2. `lib/data/repositories/dashboard_repository_impl.dart`

- Modified `getDashboardDataStreamForRange()`:

  - Fetch initial data first
  - Then stream real-time updates
  - Use `asyncExpand()` to combine both
  - Add `shareReplay()` untuk caching

- Added `_fetchInitialDashboardData()`:

  - Fetch all transactions & expenses for date range
  - Calculate metrics from historical data
  - Return initial DashboardData

- Modified `_buildProfitStream()`:

  - Fetch initial profit data first
  - Then stream real-time updates
  - Use `asyncExpand()` to combine

- Added `_fetchInitialProfitData()`:

  - Fetch transactions & expenses
  - Calculate profit metrics
  - Return initial ProfitIndicator

- Modified `getTaxIndicatorStream()`:

  - Fetch initial tax data first
  - Then stream real-time updates
  - Use `asyncExpand()` to combine

- Added `_fetchInitialTaxData()`:
  - Fetch transactions for month
  - Calculate tax amount
  - Return initial TaxIndicator

## How It Works Now

### Before (Broken)

```
Stream starts
  ↓
Listener subscribes
  ↓
Stream emits only NEW data from this point
  ↓
Old transactions not included
  ↓
Metrics show 0
```

### After (Fixed)

```
Stream starts
  ↓
Fetch initial data from DB (all historical data)
  ↓
Emit initial data to listener
  ↓
Then stream real-time updates
  ↓
Listener gets complete picture
  ↓
Metrics show correct values
```

## Data Flow

```
getDashboardDataStreamForRange()
  ↓
_fetchInitialDashboardData() [Async]
  ↓
Emit initial DashboardData
  ↓
asyncExpand() to real-time stream
  ↓
Listen to transactions table
  ↓
Filter & calculate on each update
  ↓
Emit updated DashboardData
  ↓
shareReplay() untuk caching
```

## Benefits

✅ Old transactions now included in metrics
✅ No more buffering loops
✅ Dashboard metrics show correct values immediately
✅ Real-time updates still work for new transactions
✅ Single stream subscription (via shareReplay)
✅ Proper error handling

## Testing Checklist

- [ ] Create transaction, check dashboard immediately - should show correct metrics
- [ ] Wait 5 seconds, check again - should still show correct metrics
- [ ] Switch to Keuangan page - should not buffer/loop
- [ ] Create expense - should update immediately
- [ ] Refresh app - old transactions should still show
- [ ] Check logs - should see "Initial dashboard data loaded" message
