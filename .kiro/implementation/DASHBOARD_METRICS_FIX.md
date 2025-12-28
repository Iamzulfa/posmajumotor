# Dashboard Metrics Fix - Root Cause Analysis

## Problem

Dashboard metrics were showing 0 for all values (Transaksi: 0, Rata-rata: Rp 0, Pengeluaran: Rp 0) even though:

- Tax calculation was working correctly (showing Rp 27.015.158)
- Transactions existed in the database
- This indicated data was being fetched somewhere, but not for daily metrics

## Root Cause

The `getDashboardDataStreamForRange()` method was using Supabase Realtime stream directly without fetching historical data first.

**Key Issue**: Supabase Realtime streams only emit data **after subscription**, not historical data that existed before the stream started. This meant:

- Stream starts → no data emitted yet
- Only NEW transactions created AFTER stream subscription would appear
- All existing transactions were never shown
- Result: metrics always showed 0 until a new transaction was created

## Solution Implemented

### 1. Fetch Initial Data First

Added proper call to `_fetchInitialDashboardData()` which was previously defined but never used:

```dart
// Fetch all transactions for the date range from database
final transactionResponse = await _client
    .from('transactions')
    .select('...')
    .eq('payment_status', 'COMPLETED')
    .gte('created_at', startDate.toIso8601String())
    .lte('created_at', endDate.toIso8601String());
```

### 2. Use Broadcast Controller for Stream Management

Changed from simple stream chaining to explicit `StreamController.broadcast()`:

```dart
final controller = StreamController<DashboardData>.broadcast();

// Emit initial data first
controller.add(initialData);

// Then subscribe to real-time updates
_client.from('transactions').stream(...).listen((data) {
  controller.add(data);
});
```

### 3. Proper Stream Lifecycle

- **Initial emission**: Historical data is emitted immediately when stream is created
- **Real-time updates**: New transactions are streamed as they arrive
- **Buffering**: `shareReplay(bufferSize: 1)` ensures new subscribers get the latest value

## Files Modified

- `lib/data/repositories/dashboard_repository_impl.dart`
  - Added `import 'dart:async'` for StreamController
  - Rewrote `getDashboardDataStreamForRange()` to emit initial data before real-time updates
  - Fixed `_cachedTaxIndicatorStreams` to be final

## Expected Behavior After Fix

1. Dashboard loads → initial data fetched and displayed immediately
2. New transactions created → stream emits updated data in real-time
3. Metrics show correct values for today's transactions
4. Tax calculation continues to work (per-month, not reset daily)
5. No more buffering loops on Keuangan page

## Testing Checklist

- [ ] Dashboard shows correct metrics on first load
- [ ] Metrics update when new transaction is created
- [ ] Keuangan page no longer buffers in loop
- [ ] Tax calculation shows correct monthly value
- [ ] Switching between days updates metrics correctly
