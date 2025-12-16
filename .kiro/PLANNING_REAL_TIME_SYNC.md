# 📋 PLANNING: Real-Time Synchronization Implementation

> **Status:** Planning Phase (No Execution Yet)  
> **Date:** December 14, 2025  
> **Scope:** Phase 4.5 - Real-time Data Synchronization

---

## 🎯 OBJECTIVE

Transform PosFELIX dari aplikasi dengan **static mock data** menjadi aplikasi dengan **real-time dynamic data** yang tersinkronisasi dengan Supabase backend. Semua data akan live-update tanpa perlu manual refresh.

---

## 📊 CURRENT STATE vs TARGET STATE

### Current State (Static)

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  Screens dengan Mock Data (Hardcoded)   │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         PROVIDERS (Riverpod)            │
│  State Management dengan Mock Data      │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│      REPOSITORIES (Implementations)     │
│  Supabase Integration Ready (Unused)    │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         SUPABASE BACKEND                │
│  Database Ready (Not Connected)         │
└─────────────────────────────────────────┘
```

### Target State (Real-time)

```
┌─────────────────────────────────────────┐
│         PRESENTATION LAYER              │
│  Screens dengan Real-time Data          │
│  Auto-update saat ada perubahan         │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│    PROVIDERS (Riverpod + Listeners)     │
│  State Management dengan Real-time      │
│  Subscriptions ke Supabase              │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│      REPOSITORIES (Implementations)     │
│  Supabase Integration Active            │
│  Real-time Subscriptions                │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│         SUPABASE BACKEND                │
│  PostgreSQL Database Connected          │
│  Real-time Subscriptions Active         │
└─────────────────────────────────────────┘
```

---

## 🔄 REAL-TIME SYNCHRONIZATION ARCHITECTURE

### Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER APP                              │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              PRESENTATION LAYER                      │  │
│  │  ┌─────────────────────────────────────────────────┐ │  │
│  │  │  Screens (Transaction, Dashboard, Expense)     │ │  │
│  │  │  - Auto-update UI saat data berubah            │ │  │
│  │  │  - Show loading/error states                   │ │  │
│  │  └─────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ↑                                   │
│                    (Watch Provider)                          │
│                          ↓                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         STATE MANAGEMENT (Riverpod)                 │  │
│  │  ┌─────────────────────────────────────────────────┐ │  │
│  │  │  Providers:                                     │ │  │
│  │  │  - productListProvider (StreamProvider)         │ │  │
│  │  │  - transactionListProvider (StreamProvider)     │ │  │
│  │  │  - expenseListProvider (StreamProvider)         │ │  │
│  │  │  - dashboardProvider (StreamProvider)           │ │  │
│  │  │  - taxCenterProvider (StreamProvider)           │ │  │
│  │  │                                                 │ │  │
│  │  │  Features:                                      │ │  │
│  │  │  - Auto-refresh setiap 5 detik                 │ │  │
│  │  │  - Listen to Supabase real-time events         │ │  │
│  │  │  - Cache data locally                          │ │  │
│  │  │  - Handle errors & retry                       │ │  │
│  │  └─────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ↑                                   │
│                  (Call Repository)                           │
│                          ↓                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         REPOSITORIES (Data Access)                  │  │
│  │  ┌─────────────────────────────────────────────────┐ │  │
│  │  │  Methods:                                       │ │  │
│  │  │  - getProductsStream() → Stream<List<Product>> │ │  │
│  │  │  - getTransactionsStream() → Stream<...>       │ │  │
│  │  │  - getExpensesStream() → Stream<...>           │ │  │
│  │  │  - getDashboardDataStream() → Stream<...>      │ │  │
│  │  │  - getTaxDataStream() → Stream<...>            │ │  │
│  │  │                                                 │ │  │
│  │  │  Features:                                      │ │  │
│  │  │  - Supabase REST API calls                      │ │  │
│  │  │  - Real-time subscriptions                      │ │  │
│  │  │  - Error handling & retry logic                │ │  │
│  │  │  - Data transformation                         │ │  │
│  │  └─────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ↑                                   │
│              (HTTP + WebSocket)                              │
│                          ↓                                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│              SUPABASE BACKEND                               │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  PostgreSQL Database                               │  │
│  │  - products table                                  │  │
│  │  - transactions table                              │  │
│  │  - transaction_items table                         │  │
│  │  - expenses table                                  │  │
│  │  - inventory_logs table                            │  │
│  │  - tax_payments table                              │  │
│  └──────────────────────────────────────────────────────┘  │
│                          ↑                                   │
│              (REST API + Real-time)                          │
│                          ↓                                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Real-time Subscriptions (WebSocket)               │  │
│  │  - Listen to INSERT events                         │  │
│  │  - Listen to UPDATE events                         │  │
│  │  - Listen to DELETE events                         │  │
│  │  - Broadcast to all connected clients              │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 TECHNICAL REQUIREMENTS

### 1. **Supabase Real-time Subscriptions**

**What:** Supabase provides WebSocket-based real-time subscriptions untuk listen ke database changes.

**How it works:**

```dart
// Subscribe to products table changes
final subscription = supabase
    .from('products')
    .on(SupabaseEventTypes.all, (payload) {
      // Handle INSERT, UPDATE, DELETE events
      print('Product changed: ${payload.eventType}');
    })
    .subscribe();
```

**Scope:**

- Subscribe ke 6 tables: products, transactions, transaction_items, expenses, inventory_logs, tax_payments
- Handle 3 event types: INSERT, UPDATE, DELETE
- Auto-reconnect saat connection lost
- Cleanup subscriptions saat screen dispose

### 2. **Riverpod StreamProvider**

**What:** Riverpod's StreamProvider untuk manage async data streams dari Supabase.

**How it works:**

```dart
final productListProvider = StreamProvider<List<ProductModel>>((ref) async* {
  // Subscribe to products stream
  final subscription = supabase
      .from('products')
      .stream(primaryKey: ['id'])
      .map((data) => data.map(ProductModel.fromJson).toList());

  yield* subscription;
});
```

**Scope:**

- Convert 5 existing StateNotifierProviders ke StreamProviders
- Handle loading, error, dan data states
- Auto-refresh setiap 5 detik (polling fallback)
- Cache data locally dengan Hive

### 3. **Error Handling & Retry Logic**

**What:** Robust error handling untuk network failures, timeouts, dan data conflicts.

**Scope:**

- Retry logic dengan exponential backoff (1s, 2s, 4s, 8s)
- Graceful degradation ke offline mode
- User-friendly error messages
- Logging untuk debugging

### 4. **Offline Support dengan Hive**

**What:** Local caching dengan Hive untuk offline functionality.

**Scope:**

- Cache products, transactions, expenses locally
- Sync queue untuk offline transactions
- Conflict resolution saat sync
- Clear cache saat logout

### 5. **Performance Optimization**

**What:** Optimize untuk mengurangi bandwidth dan latency.

**Scope:**

- Selective field queries (tidak fetch semua columns)
- Pagination untuk large datasets
- Debouncing untuk frequent updates
- Connection pooling

---

## 📋 IMPLEMENTATION SCOPE

### Phase 4.5: Real-time Synchronization

#### 4.5.1 Backend Preparation

- [ ] Verify Supabase credentials configured
- [ ] Test Supabase connection
- [ ] Verify database schema & RLS policies
- [ ] Test real-time subscriptions manually

#### 4.5.2 Repository Layer Updates

- [ ] Add Stream methods ke 5 repositories:
  - `ProductRepository.getProductsStream()`
  - `TransactionRepository.getTransactionsStream()`
  - `ExpenseRepository.getExpensesStream()`
  - `DashboardRepository.getDashboardDataStream()`
  - `TaxRepository.getTaxDataStream()`
- [ ] Implement Supabase real-time subscriptions
- [ ] Add error handling & retry logic
- [ ] Add data transformation & mapping

#### 4.5.3 Provider Layer Updates

- [ ] Convert productListProvider → StreamProvider
- [ ] Convert transactionListProvider → StreamProvider
- [ ] Convert expenseListProvider → StreamProvider
- [ ] Convert dashboardProvider → StreamProvider
- [ ] Convert taxCenterProvider → StreamProvider
- [ ] Add auto-refresh logic (5 detik polling)
- [ ] Add error state handling
- [ ] Add loading state handling

#### 4.5.4 UI Layer Updates

- [ ] Update Transaction Screen:
  - Replace mock products dengan real-time stream
  - Auto-update cart saat product price berubah
  - Show sync status indicator
- [ ] Update Inventory Screen:
  - Replace mock products dengan real-time stream
  - Auto-update stock saat ada transaksi
  - Show sync status indicator
- [ ] Update Dashboard Screen:
  - Replace mock data dengan real-time stream
  - Auto-update profit/tax indicator
  - Show sync status indicator
- [ ] Update Expense Screen:
  - Replace mock expenses dengan real-time stream
  - Auto-update total & breakdown
  - Show sync status indicator
- [ ] Update Tax Center Screen:
  - Replace mock data dengan real-time stream
  - Auto-update calculations
  - Show sync status indicator

#### 4.5.5 Offline Support

- [ ] Setup Hive local storage
- [ ] Implement local caching untuk products, transactions, expenses
- [ ] Implement sync queue untuk offline transactions
- [ ] Implement conflict resolution logic
- [ ] Add offline indicator UI

#### 4.5.6 Testing & Validation

- [ ] Test real-time updates dengan multiple devices
- [ ] Test offline mode & sync
- [ ] Test error handling & retry
- [ ] Test performance & latency
- [ ] Test data consistency

---

## 🛠️ TECHNICAL STACK

### Dependencies to Add/Update

```yaml
# Real-time & Streaming
supabase_flutter: ^2.0.0 # Already have, but need to enable real-time
realtime_client: ^1.0.0 # For WebSocket subscriptions

# Local Storage
hive: ^2.2.3 # Already have
hive_flutter: ^1.1.0 # Already have

# Async & Streams
async: ^2.11.0 # For stream utilities

# Logging
logger: ^2.0.0 # Already have
```

### Architecture Pattern

```
Repository Layer:
├── ProductRepository
│   ├── getProducts() → Future<List<Product>>
│   ├── getProductsStream() → Stream<List<Product>>  [NEW]
│   ├── createProduct() → Future<Product>
│   ├── updateProduct() → Future<Product>
│   └── deleteProduct() → Future<void>
│
├── TransactionRepository
│   ├── getTransactions() → Future<List<Transaction>>
│   ├── getTransactionsStream() → Stream<List<Transaction>>  [NEW]
│   ├── createTransaction() → Future<Transaction>
│   └── ...
│
└── [Similar for Expense, Dashboard, Tax]

Provider Layer:
├── productListProvider (StateNotifierProvider)
│   └── Convert to StreamProvider  [CHANGE]
│
├── transactionListProvider (StateNotifierProvider)
│   └── Convert to StreamProvider  [CHANGE]
│
└── [Similar for Expense, Dashboard, Tax]

UI Layer:
├── Transaction Screen
│   ├── Watch productListProvider (real-time)
│   ├── Watch cartProvider (local state)
│   └── Show sync status
│
├── Dashboard Screen
│   ├── Watch dashboardProvider (real-time)
│   └── Show sync status
│
└── [Similar for other screens]
```

---

## 📊 DATA FLOW EXAMPLES

### Example 1: Real-time Product Update

```
Scenario: Admin update harga produk di device A
         Kasir lihat harga berubah di device B secara real-time

Timeline:
1. Admin di device A: Update harga Ban Michelin dari 450k → 460k
2. Device A: Send update ke Supabase REST API
3. Supabase: Update products table
4. Supabase: Broadcast UPDATE event via WebSocket
5. Device B: Receive UPDATE event
6. Device B: productListProvider stream emit new data
7. Device B: Inventory Screen rebuild dengan harga baru
8. Device B: Transaction Screen update harga di product list
9. Device B: If Ban Michelin sudah di cart, show warning "Harga berubah"
```

### Example 2: Real-time Transaction Sync

```
Scenario: Kasir create transaksi di device A
         Admin lihat transaksi baru di dashboard device B secara real-time

Timeline:
1. Kasir di device A: Click "Selesaikan" transaksi
2. Device A: Send transaction data ke Supabase
3. Supabase: Insert ke transactions & transaction_items tables
4. Supabase: Trigger auto-deduct stock
5. Supabase: Broadcast INSERT events via WebSocket
6. Device B: Receive INSERT events
7. Device B: transactionListProvider stream emit new data
8. Device B: dashboardProvider recalculate profit/tax
9. Device B: Dashboard Screen rebuild dengan data baru
10. Device B: Show "Transaksi baru dari Kasir" notification
```

### Example 3: Offline Transaction & Sync

```
Scenario: Kasir create transaksi saat offline
         Transaksi auto-sync saat online

Timeline:
1. Kasir offline: Create transaksi (saved to Hive local cache)
2. Kasir: See "Offline Mode" indicator
3. Kasir: Can continue create more transactions
4. Kasir: Internet back online
5. App: Detect online status
6. App: Start sync queue (transaksi 1, 2, 3, ...)
7. App: Send transaksi ke Supabase one by one
8. Supabase: Process & return success
9. App: Remove from sync queue
10. App: Show "Sync Berhasil" notification
11. App: Update local cache dengan server data
```

---

## ⚠️ POTENTIAL CHALLENGES & SOLUTIONS

### Challenge 1: Network Latency

**Problem:** Real-time updates bisa lambat di network yang buruk  
**Solution:**

- Implement optimistic updates (update UI immediately, sync later)
- Add loading skeleton untuk better UX
- Implement retry logic dengan exponential backoff

### Challenge 2: Data Conflicts

**Problem:** Offline changes conflict dengan server data  
**Solution:**

- Use timestamp-based conflict resolution (server wins)
- Implement merge strategy untuk non-conflicting fields
- Show conflict resolution UI untuk user

### Challenge 3: Battery & Data Usage

**Problem:** Real-time subscriptions drain battery & data  
**Solution:**

- Pause subscriptions saat app backgrounded
- Implement polling fallback (5 detik) instead of always-on WebSocket
- Selective subscriptions (only subscribe to needed tables)
- Compress data transfer

### Challenge 4: State Management Complexity

**Problem:** Multiple streams + local state = complex state management  
**Solution:**

- Use Riverpod's built-in stream handling
- Separate concerns: remote state (providers) vs local state (notifiers)
- Use `.select()` untuk granular rebuilds

### Challenge 5: Testing Complexity

**Problem:** Hard to test real-time behavior  
**Solution:**

- Mock Supabase client untuk unit tests
- Use fake streams untuk widget tests
- Integration tests dengan real Supabase instance

---

## 📈 IMPLEMENTATION TIMELINE ESTIMATE

| Phase     | Task                     | Estimate        | Dependencies |
| --------- | ------------------------ | --------------- | ------------ |
| 4.5.1     | Backend Preparation      | 1-2 hours       | None         |
| 4.5.2     | Repository Layer Updates | 4-6 hours       | 4.5.1        |
| 4.5.3     | Provider Layer Updates   | 3-4 hours       | 4.5.2        |
| 4.5.4     | UI Layer Updates         | 6-8 hours       | 4.5.3        |
| 4.5.5     | Offline Support          | 4-6 hours       | 4.5.4        |
| 4.5.6     | Testing & Validation     | 4-6 hours       | 4.5.5        |
| **Total** |                          | **22-32 hours** |              |

---

## 🎯 SUCCESS CRITERIA

### Functional Requirements

- [ ] All 5 screens show real-time data from Supabase
- [ ] Data updates automatically without manual refresh
- [ ] Offline mode works with local caching
- [ ] Sync queue processes offline transactions
- [ ] Error handling shows user-friendly messages

### Performance Requirements

- [ ] Data updates within 2-3 seconds of change
- [ ] App doesn't freeze during sync
- [ ] Memory usage stays under 150MB
- [ ] Battery drain acceptable (< 5% per hour)

### User Experience Requirements

- [ ] Sync status clearly visible
- [ ] Loading states show during data fetch
- [ ] Error messages are helpful
- [ ] Offline mode is seamless
- [ ] No data loss during sync

---

## 📝 NEXT STEPS (After Planning Approval)

1. **Review & Approve Planning** - User confirms scope & approach
2. **Create Detailed Spec** - Break down into smaller tasks
3. **Setup Testing Environment** - Prepare Supabase test instance
4. **Start Implementation** - Phase 4.5.1 Backend Preparation
5. **Iterative Development** - Complete phases sequentially
6. **Integration Testing** - Test all screens together
7. **Performance Testing** - Optimize & benchmark
8. **User Acceptance Testing** - Validate with real data

---

## 📞 QUESTIONS FOR USER

Before proceeding with implementation, please clarify:

1. **Real-time Frequency:** Seberapa sering data harus update? (Real-time instant, 5 detik, 10 detik?)
2. **Offline Priority:** Seberapa penting offline support? (Critical, Nice-to-have, Not needed?)
3. **Data Volume:** Berapa banyak data yang akan disimpan? (Ribuan produk? Puluhan ribu transaksi?)
4. **Network Conditions:** Apa kondisi network target? (Good 4G, Poor 3G, Mixed?)
5. **Testing Environment:** Sudah ada Supabase project untuk testing? (Credentials ready?)
6. **Timeline:** Berapa urgent implementasi ini? (ASAP, Next week, Next month?)

---

_Document Status: PLANNING PHASE - Ready for Review_  
_Last Updated: December 14, 2025_
