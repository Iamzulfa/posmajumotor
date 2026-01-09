# Tax Calculation Notes

## Important: Tax is Per-Month, Not Per-Day

Tax calculation harus berdasarkan **bulan kalender**, bukan per hari. Ini penting untuk compliance dan akurasi laporan.

## How Tax Works

### Tax Calculation

```
Tax = 0.5% × Monthly Omset
```

Contoh:

- Monthly Omset: Rp 100.000.000
- Tax: 0.5% × Rp 100.000.000 = Rp 500.000

### Tax Period

- **Start**: 1st day of month
- **End**: Last day of month
- **Calculation**: Based on all COMPLETED transactions in that month

### Tax Status

- **Unpaid**: Tax calculated but not yet paid
- **Paid**: Tax has been paid (recorded in `tax_payments` table)

## Code Implementation

### 1. Dashboard Repository (`dashboard_repository_impl.dart`)

Tax calculation di repository:

```dart
// Calculate tax (0.5%)
final taxAmount = (totalOmset * 0.005).round();

// Check if already paid
final taxPaymentResponse = await _client
    .from('tax_payments')
    .select('is_paid, paid_at')
    .eq('period_month', month)
    .eq('period_year', year)
    .maybeSingle();
```

**Key Points:**

- Tax dihitung dari `totalOmset` (revenue)
- Tidak termasuk HPP atau expenses
- Disimpan per month-year di `tax_payments` table
- Cache key: `'$month-$year'` untuk prevent duplicate streams

### 2. Dashboard Provider (`dashboard_provider.dart`)

Tax ditampilkan di dashboard:

```dart
// Get monthly omset for tax calculation (ALWAYS from current month)
final currentNow = DateTime.now();
final currentMonthStart = DateTime(currentNow.year, currentNow.month, 1);
final currentMonthEnd = DateTime(currentNow.year, currentNow.month + 1, 0, 23, 59, 59);

final monthlySummary = await transactionRepo.getTransactionSummary(
  startDate: currentMonthStart,
  endDate: currentMonthEnd,
);

// Calculate tax (0.5% of monthly omset)
final taxAmount = (monthlySummary.totalOmset * 0.005).round();
```

**Important:**

- Menggunakan `DateTime.now()` setiap kali stream emit
- Ini memastikan tax selalu dihitung dari bulan SAAT INI
- Ketika berganti bulan, otomatis akan menghitung tax bulan baru

### 3. Tax Indicator Stream

Tax indicator di-cache per month-year:

```dart
final key = '$month-$year';
if (_cachedTaxIndicatorStreams.containsKey(key)) {
  return _cachedTaxIndicatorStreams[key]!;
}
```

**Why Cache?**

- Prevent multiple subscriptions untuk bulan yang sama
- Reduce database queries
- Improve performance

## Database Schema

### tax_payments table

```sql
CREATE TABLE tax_payments (
  id UUID PRIMARY KEY,
  period_month INT,
  period_year INT,
  total_omset INT,
  tax_amount INT,
  is_paid BOOLEAN DEFAULT FALSE,
  paid_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,

  UNIQUE(period_month, period_year)
);
```

## Important Rules

1. **Tax is per month, not per day**

   - ✅ Correct: Calculate tax for entire month
   - ❌ Wrong: Reset tax every day

2. **Tax is based on revenue (omset), not profit**

   - ✅ Correct: 0.5% × total revenue
   - ❌ Wrong: 0.5% × (revenue - expenses)

3. **Tax calculation uses current month**

   - ✅ Correct: Always use `DateTime.now()` to get current month
   - ❌ Wrong: Use hardcoded month from initialization

4. **Tax payment status is persistent**
   - ✅ Correct: Store in database, don't reset
   - ❌ Wrong: Reset when day changes

## Testing Checklist

- [ ] Create transaction on day 1 of month - tax should calculate
- [ ] Create transaction on day 15 of month - tax should accumulate
- [ ] Switch to day 2 - tax should NOT reset
- [ ] Switch to next month (day 1) - tax should reset to 0 (new month)
- [ ] Mark tax as paid - status should persist
- [ ] Refresh app - tax status should remain

## Common Issues & Solutions

### Issue: Tax resets every day

**Cause**: Using `now` variable from initialization instead of `DateTime.now()` in stream
**Solution**: Always call `DateTime.now()` inside stream emit to get current date

### Issue: Tax shows wrong amount

**Cause**: Calculating from wrong date range
**Solution**: Ensure using `DateTime(year, month, 1)` to `DateTime(year, month + 1, 0)`

### Issue: Tax doesn't update when transaction added

**Cause**: Stream not re-emitting when transactions change
**Solution**: Ensure `getDashboardDataStream()` is properly listening to transactions table

### Issue: Tax shows for wrong month

**Cause**: Cache key collision or wrong month/year passed
**Solution**: Verify cache key format: `'$month-$year'` and check month/year values
