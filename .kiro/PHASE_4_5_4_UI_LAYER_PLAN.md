# 🎨 PHASE 4.5.4: UI LAYER UPDATES - DETAILED PLAN

> **Status:** Ready for Implementation  
> **Date:** December 14, 2025  
> **Objective:** Update 5 screens to use new StreamProviders for real-time data

---

## 📊 CURRENT STATE

### Completed (Phases 4.5.1-4.5.3)

✅ **Phase 4.5.1: Backend Preparation**

- Supabase credentials configured in `lib/config/constants/supabase_config.dart`
- Real-time subscriptions ready

✅ **Phase 4.5.2: Repository Layer**

- Added Stream methods to 5 repositories:
  - `ProductRepository.getProductsStream()`
  - `TransactionRepository.getTransactionsStream()`
  - `ExpenseRepository.getExpensesStream()`
  - `DashboardRepository.getDashboardDataStream()`
  - `TaxRepository.getTaxDataStream()`

✅ **Phase 4.5.3: Provider Layer**

- Created StreamProviders:
  - `productsStreamProvider` (ProductProvider)
  - `categoriesStreamProvider` (ProductProvider)
  - `brandsStreamProvider` (ProductProvider)
  - `todayTransactionsStreamProvider` (TransactionProvider)
  - `transactionSummaryStreamProvider` (TransactionProvider)
  - `tierBreakdownStreamProvider` (TransactionProvider)
  - `todayExpensesStreamProvider` (ExpenseProvider)
  - `expenseSummaryStreamProvider` (ExpenseProvider)
  - `totalExpensesStreamProvider` (ExpenseProvider)
  - `dashboardStreamProvider` (DashboardProvider)
  - `taxCalculationStreamProvider` (TaxProvider)
  - `profitLossReportStreamProvider` (TaxProvider)

---

## 🎯 PHASE 4.5.4: UI LAYER UPDATES

### Overview

Update 5 screens to consume StreamProviders instead of mock data. Each screen will:

1. Replace mock data with real-time streams
2. Use `.when()` pattern for AsyncValue handling
3. Add loading states (skeleton/shimmer)
4. Add error states with retry
5. Add sync status indicator
6. Test real-time updates

---

## 📋 SCREEN-BY-SCREEN BREAKDOWN

### Screen 1: Transaction Screen

**File:** `lib/presentation/screens/kasir/transaction/transaction_screen.dart`

**Current State:**

- Uses mock products from `mockProducts`
- Static product list
- No real-time updates

**Changes Required:**

1. **Replace mock products with stream:**

   ```dart
   // OLD
   final products = mockProducts;

   // NEW
   final productsAsync = ref.watch(productsStreamProvider);
   ```

2. **Update product list builder:**

   ```dart
   productsAsync.when(
     data: (products) => ProductListView(products: products),
     loading: () => ProductListSkeleton(),
     error: (err, stack) => ErrorStateWidget(
       error: err.toString(),
       onRetry: () => ref.refresh(productsStreamProvider),
     ),
   )
   ```

3. **Add sync status indicator:**

   - Show in AppHeader
   - Display: "Syncing...", "Online", "Offline"

4. **Auto-update cart when product price changes:**
   - Listen to product updates
   - Show warning if item in cart has price change
   - Option to update or remove

**Estimated Time:** 1.5-2 hours

---

### Screen 2: Inventory Screen

**File:** `lib/presentation/screens/kasir/inventory/inventory_screen.dart`

**Current State:**

- Uses mock products from `mockProducts`
- Static product list
- No real-time updates

**Changes Required:**

1. **Replace mock products with stream:**

   ```dart
   final productsAsync = ref.watch(productsStreamProvider);
   ```

2. **Update product list builder:**

   ```dart
   productsAsync.when(
     data: (products) => ProductListView(products: products),
     loading: () => ProductListSkeleton(),
     error: (err, stack) => ErrorStateWidget(...),
   )
   ```

3. **Add category filter with stream:**

   ```dart
   final categoriesAsync = ref.watch(categoriesStreamProvider);
   ```

4. **Add sync status indicator**

5. **Auto-update stock display:**
   - Show real-time stock changes
   - Highlight items with stock changes

**Estimated Time:** 1.5-2 hours

---

### Screen 3: Dashboard Screen

**File:** `lib/presentation/screens/admin/dashboard/dashboard_screen.dart`

**Current State:**

- Uses mock dashboard data
- Static charts and indicators
- No real-time updates

**Changes Required:**

1. **Replace mock data with stream:**

   ```dart
   final dashboardAsync = ref.watch(dashboardStreamProvider);
   ```

2. **Update dashboard builder:**

   ```dart
   dashboardAsync.when(
     data: (dashboard) => DashboardContent(data: dashboard),
     loading: () => DashboardSkeleton(),
     error: (err, stack) => ErrorStateWidget(...),
   )
   ```

3. **Add loading skeleton:**

   - Skeleton for profit widget
   - Skeleton for chart
   - Skeleton for tier breakdown

4. **Add sync status indicator**

5. **Auto-update all widgets:**

   - Profit widget updates
   - Chart updates
   - Tier breakdown updates
   - Tax indicator updates

6. **Add pull-to-refresh:**
   ```dart
   RefreshIndicator(
     onRefresh: () => ref.refresh(dashboardStreamProvider).future,
     child: DashboardContent(...),
   )
   ```

**Estimated Time:** 2-2.5 hours

---

### Screen 4: Expense Screen

**File:** `lib/presentation/screens/admin/expense/expense_screen.dart`

**Current State:**

- Uses mock expenses
- Static expense list
- No real-time updates

**Changes Required:**

1. **Replace mock expenses with stream:**

   ```dart
   final expensesAsync = ref.watch(todayExpensesStreamProvider);
   final summaryAsync = ref.watch(expenseSummaryStreamProvider);
   ```

2. **Update expense list builder:**

   ```dart
   expensesAsync.when(
     data: (expenses) => ExpenseListView(expenses: expenses),
     loading: () => ExpenseListSkeleton(),
     error: (err, stack) => ErrorStateWidget(...),
   )
   ```

3. **Update summary builder:**

   ```dart
   summaryAsync.when(
     data: (summary) => ExpenseSummaryWidget(summary: summary),
     loading: () => ExpenseSummarySkeleton(),
     error: (err, stack) => ErrorStateWidget(...),
   )
   ```

4. **Add sync status indicator**

5. **Auto-update totals:**

   - Total expense updates
   - Category breakdown updates
   - Progress bars update

6. **Add pull-to-refresh**

**Estimated Time:** 1.5-2 hours

---

### Screen 5: Tax Center Screen

**File:** `lib/presentation/screens/admin/tax/tax_center_screen.dart`

**Current State:**

- Uses mock tax data
- Static calculations
- No real-time updates

**Changes Required:**

1. **Replace mock data with streams:**

   ```dart
   final taxCalcAsync = ref.watch(taxCalculationStreamProvider);
   final profitLossAsync = ref.watch(profitLossReportStreamProvider);
   ```

2. **Update Laporan tab:**

   ```dart
   profitLossAsync.when(
     data: (report) => ProfitLossReportView(report: report),
     loading: () => ReportSkeleton(),
     error: (err, stack) => ErrorStateWidget(...),
   )
   ```

3. **Update Kalkulator tab:**

   ```dart
   taxCalcAsync.when(
     data: (calc) => TaxCalculatorView(calculation: calc),
     loading: () => CalculatorSkeleton(),
     error: (err, stack) => ErrorStateWidget(...),
   )
   ```

4. **Add sync status indicator**

5. **Auto-update calculations:**

   - Tax amount updates
   - Profit/loss updates
   - Payment status updates

6. **Add pull-to-refresh**

**Estimated Time:** 1.5-2 hours

---

## 🛠️ COMMON PATTERNS TO IMPLEMENT

### Pattern 1: AsyncValue Handling

```dart
// For single stream
final dataAsync = ref.watch(someStreamProvider);

dataAsync.when(
  data: (data) => ContentWidget(data: data),
  loading: () => LoadingWidget(),
  error: (error, stackTrace) => ErrorWidget(
    error: error.toString(),
    onRetry: () => ref.refresh(someStreamProvider),
  ),
)
```

### Pattern 2: Multiple Streams

```dart
// For multiple streams
final data1Async = ref.watch(stream1Provider);
final data2Async = ref.watch(stream2Provider);

// Option 1: Nested when
data1Async.when(
  data: (data1) => data2Async.when(
    data: (data2) => ContentWidget(data1: data1, data2: data2),
    loading: () => LoadingWidget(),
    error: (err, stack) => ErrorWidget(...),
  ),
  loading: () => LoadingWidget(),
  error: (err, stack) => ErrorWidget(...),
)

// Option 2: Use select (more efficient)
final data1 = ref.watch(stream1Provider.select((async) => async.value));
final data2 = ref.watch(stream2Provider.select((async) => async.value));
```

### Pattern 3: Sync Status Indicator

```dart
// Add to AppHeader or top of screen
SyncStatusWidget(
  isOnline: isOnline,
  isSyncing: isSyncing,
  lastSyncTime: lastSyncTime,
)
```

### Pattern 4: Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    await ref.refresh(someStreamProvider).future;
  },
  child: ListView(
    children: [...],
  ),
)
```

### Pattern 5: Error Handling

```dart
ErrorStateWidget(
  icon: Icons.error_outline,
  title: 'Gagal memuat data',
  subtitle: error.toString(),
  buttonText: 'Coba lagi',
  onRetry: () => ref.refresh(someStreamProvider),
)
```

---

## 📦 WIDGETS TO CREATE/UPDATE

### New Widgets Needed

1. **LoadingSkeletons:**

   - `ProductListSkeleton` - Skeleton for product list
   - `DashboardSkeleton` - Skeleton for dashboard
   - `ExpenseListSkeleton` - Skeleton for expense list
   - `ReportSkeleton` - Skeleton for tax report
   - `CalculatorSkeleton` - Skeleton for tax calculator

2. **Status Indicators:**

   - `SyncStatusWidget` - Show sync status (already exists)
   - Update to show in all screens

3. **Error Widgets:**
   - `ErrorStateWidget` - Generic error display (already exists)
   - Update to show retry button

### Existing Widgets to Update

1. `AppHeader` - Add sync status indicator
2. `LoadingWidget` - Use for loading states
3. `ErrorWidget` - Use for error states

---

## 🧪 TESTING CHECKLIST

### For Each Screen

- [ ] Real-time data loads correctly
- [ ] Loading state shows while fetching
- [ ] Error state shows on failure
- [ ] Retry button works
- [ ] Data updates in real-time (2-3 seconds)
- [ ] Sync status indicator updates
- [ ] Pull-to-refresh works
- [ ] No memory leaks
- [ ] No console errors

### Integration Testing

- [ ] Multiple screens open simultaneously
- [ ] Data consistent across screens
- [ ] No duplicate subscriptions
- [ ] Proper cleanup on screen close
- [ ] Works with offline mode

---

## 📝 IMPLEMENTATION ORDER

### Recommended Sequence

1. **Create Loading Skeletons** (30 min)

   - ProductListSkeleton
   - DashboardSkeleton
   - ExpenseListSkeleton
   - ReportSkeleton
   - CalculatorSkeleton

2. **Update Transaction Screen** (1.5-2 hours)

   - Replace mock products
   - Add loading/error states
   - Add sync indicator

3. **Update Inventory Screen** (1.5-2 hours)

   - Replace mock products
   - Add category filter stream
   - Add loading/error states

4. **Update Dashboard Screen** (2-2.5 hours)

   - Replace mock data
   - Add loading skeleton
   - Add pull-to-refresh
   - Add sync indicator

5. **Update Expense Screen** (1.5-2 hours)

   - Replace mock expenses
   - Add loading/error states
   - Add pull-to-refresh

6. **Update Tax Center Screen** (1.5-2 hours)

   - Replace mock data
   - Add loading/error states
   - Add pull-to-refresh

7. **Testing & Validation** (1-2 hours)
   - Test all screens
   - Test real-time updates
   - Test error handling
   - Performance check

---

## ⚠️ POTENTIAL ISSUES & SOLUTIONS

### Issue 1: Multiple Subscriptions

**Problem:** Each screen creates new subscription, causing memory leak  
**Solution:** Use Riverpod's built-in caching, don't create new providers

### Issue 2: Stale Data

**Problem:** Data not updating in real-time  
**Solution:** Verify StreamProvider is properly listening to repository stream

### Issue 3: Performance

**Problem:** App freezes during data updates  
**Solution:** Use `.select()` for granular rebuilds, avoid rebuilding entire screen

### Issue 4: Error Handling

**Problem:** Errors not showing to user  
**Solution:** Implement proper error state in `.when()` pattern

### Issue 5: Offline Mode

**Problem:** App crashes when offline  
**Solution:** Implement fallback to cached data, show offline indicator

---

## 📊 PROGRESS TRACKING

### Completion Checklist

- [ ] Loading skeletons created
- [ ] Transaction Screen updated
- [ ] Inventory Screen updated
- [ ] Dashboard Screen updated
- [ ] Expense Screen updated
- [ ] Tax Center Screen updated
- [ ] All screens tested
- [ ] Real-time updates verified
- [ ] Error handling verified
- [ ] Performance acceptable

---

## 🎯 SUCCESS CRITERIA

### Functional

- [ ] All 5 screens show real-time data
- [ ] Data updates within 2-3 seconds
- [ ] Loading states show during fetch
- [ ] Error states show on failure
- [ ] Retry works correctly

### User Experience

- [ ] Sync status clearly visible
- [ ] No freezing during updates
- [ ] Smooth transitions
- [ ] Clear error messages
- [ ] Intuitive retry mechanism

### Performance

- [ ] Memory usage < 150MB
- [ ] No memory leaks
- [ ] Smooth 60 FPS
- [ ] Battery drain acceptable

---

## 📞 NEXT STEPS

1. Review this plan
2. Approve approach
3. Start implementation with loading skeletons
4. Update screens one by one
5. Test each screen
6. Move to Phase 4.5.5 (Offline Support)

---

_Document Status: READY FOR IMPLEMENTATION_  
_Last Updated: December 14, 2025_
