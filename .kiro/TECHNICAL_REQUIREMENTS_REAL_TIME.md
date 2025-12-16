# 🔧 TECHNICAL REQUIREMENTS: Real-time Synchronization

> **Purpose:** Detailed technical specifications untuk implementasi real-time sync  
> **Status:** Planning Phase  
> **Date:** December 14, 2025

---

## 1. SUPABASE REAL-TIME CONFIGURATION

### 1.1 Enable Real-time on Tables

**Current Status:** Database schema sudah ada, tapi real-time belum di-enable

**Required Actions:**

```sql
-- Enable real-time for products table
ALTER PUBLICATION supabase_realtime ADD TABLE products;

-- Enable real-time for transactions table
ALTER PUBLICATION supabase_realtime ADD TABLE transactions;

-- Enable real-time for transaction_items table
ALTER PUBLICATION supabase_realtime ADD TABLE transaction_items;

-- Enable real-time for expenses table
ALTER PUBLICATION supabase_realtime ADD TABLE expenses;

-- Enable real-time for inventory_logs table
ALTER PUBLICATION supabase_realtime ADD TABLE inventory_logs;

-- Enable real-time for tax_payments table
ALTER PUBLICATION supabase_realtime ADD TABLE tax_payments;
```

**Verification:**

```sql
-- Check which tables have real-time enabled
SELECT schemaname, tablename
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime';
```

### 1.2 Row Level Security (RLS) for Real-time

**Current Status:** RLS policies sudah ada

**Verification Needed:**

- [ ] Verify RLS policies allow SELECT untuk real-time subscriptions
- [ ] Verify RLS policies allow INSERT/UPDATE/DELETE untuk transactions
- [ ] Test real-time events dengan different user roles

### 1.3 Supabase Client Configuration

**Current Implementation:**

```dart
// lib/config/constants/supabase_config.dart
final supabase = SupabaseClient(
  'https://[project-id].supabase.co',
  '[anon-key]',
);
```

**Required Updates:**

```dart
// Enable real-time subscriptions
final supabase = SupabaseClient(
  'https://[project-id].supabase.co',
  '[anon-key]',
  realtimeClientOptions: RealtimeClientOptions(
    eventsPerSecond: 10,  // Rate limiting
  ),
);

// Or use default
final supabase = SupabaseClient(
  'https://[project-id].supabase.co',
  '[anon-key]',
);
```

---

## 2. REPOSITORY LAYER CHANGES

### 2.1 ProductRepository - Stream Methods

**Current Methods:**

```dart
abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}
```

**New Stream Methods to Add:**

```dart
abstract class ProductRepository {
  // Existing methods...

  // NEW: Real-time stream
  Stream<List<ProductModel>> getProductsStream();

  // NEW: Stream with filters
  Stream<List<ProductModel>> getProductsByCategory(String categoryId);
  Stream<List<ProductModel>> getProductsByBrand(String brandId);

  // NEW: Stream for single product
  Stream<ProductModel?> getProductStream(String id);
}
```

**Implementation Pattern:**

```dart
class ProductRepositoryImpl implements ProductRepository {
  final SupabaseClient supabase;

  @override
  Stream<List<ProductModel>> getProductsStream() {
    return supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .map((data) {
          return data
              .map((json) => ProductModel.fromJson(json))
              .toList();
        })
        .handleError((error) {
          logger.e('Error streaming products: $error');
          // Fallback to polling
          return _getProductsWithPolling();
        });
  }

  // Fallback polling method
  Stream<List<ProductModel>> _getProductsWithPolling() {
    return Stream.periodic(
      Duration(seconds: 5),
      (_) => getProducts(),
    ).asyncExpand((future) => future.asStream());
  }
}
```

### 2.2 TransactionRepository - Stream Methods

**New Stream Methods:**

```dart
abstract class TransactionRepository {
  // Existing methods...

  // NEW: Real-time stream
  Stream<List<TransactionModel>> getTransactionsStream();

  // NEW: Stream for today's transactions
  Stream<List<TransactionModel>> getTodayTransactionsStream();

  // NEW: Stream for transaction summary
  Stream<TransactionSummary> getTransactionSummaryStream();
}
```

### 2.3 ExpenseRepository - Stream Methods

**New Stream Methods:**

```dart
abstract class ExpenseRepository {
  // Existing methods...

  // NEW: Real-time stream
  Stream<List<ExpenseModel>> getExpensesStream();

  // NEW: Stream for today's expenses
  Stream<List<ExpenseModel>> getTodayExpensesStream();

  // NEW: Stream for expense summary
  Stream<ExpenseSummary> getExpenseSummaryStream();
}
```

### 2.4 DashboardRepository - Stream Methods

**New Stream Methods:**

```dart
abstract class DashboardRepository {
  // NEW: Real-time dashboard data
  Stream<DashboardData> getDashboardDataStream();

  // NEW: Stream for profit calculation
  Stream<ProfitData> getProfitDataStream();

  // NEW: Stream for tax indicator
  Stream<TaxIndicator> getTaxIndicatorStream();
}
```

### 2.5 TaxRepository - Stream Methods

**New Stream Methods:**

```dart
abstract class TaxRepository {
  // Existing methods...

  // NEW: Real-time stream
  Stream<TaxData> getTaxDataStream();

  // NEW: Stream for specific month
  Stream<TaxData> getTaxDataStreamForMonth(int month, int year);
}
```

---

## 3. PROVIDER LAYER CHANGES

### 3.1 Convert StateNotifierProvider to StreamProvider

**Current Pattern (StateNotifierProvider):**

```dart
final productListProvider = StateNotifierProvider<
    ProductListNotifier,
    ProductListState>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return ProductListNotifier(repository);
});
```

**New Pattern (StreamProvider):**

```dart
final productListProvider = StreamProvider<List<ProductModel>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductsStream();
});
```

**Benefits:**

- Automatic handling of loading/error/data states
- Built-in caching
- Automatic cleanup
- Simpler code

### 3.2 Provider State Handling

**Old State Class:**

```dart
class ProductListState {
  final List<ProductModel> products;
  final bool isLoading;
  final String? error;

  ProductListState({
    required this.products,
    required this.isLoading,
    this.error,
  });
}
```

**New State (Built-in):**

```dart
// StreamProvider automatically provides:
// - AsyncValue<List<ProductModel>>.loading
// - AsyncValue<List<ProductModel>>.data
// - AsyncValue<List<ProductModel>>.error

// Usage in UI:
ref.watch(productListProvider).when(
  loading: () => LoadingWidget(),
  data: (products) => ProductList(products),
  error: (error, stack) => ErrorWidget(error),
);
```

### 3.3 Provider Invalidation & Refresh

**Manual Refresh:**

```dart
// Invalidate provider to force refresh
ref.refresh(productListProvider);

// Or use RefreshIndicator
RefreshIndicator(
  onRefresh: () async {
    await ref.refresh(productListProvider.future);
  },
  child: ProductList(),
);
```

### 3.4 Selective Watching

**Watch Specific Fields:**

```dart
// Only rebuild when product count changes
ref.watch(productListProvider.select((state) => state.length));

// Only rebuild when specific product changes
ref.watch(productListProvider.select((state) =>
  state.firstWhere((p) => p.id == productId)
));
```

---

## 4. UI LAYER CHANGES

### 4.1 Transaction Screen Updates

**Current Implementation:**

```dart
class TransactionScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productListProvider);
    final cartState = ref.watch(cartProvider);

    // productState is ProductListState (custom)
    // Need to handle isLoading, error manually
  }
}
```

**New Implementation:**

```dart
class TransactionScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    final productAsyncValue = ref.watch(productListProvider);
    final cartState = ref.watch(cartProvider);

    // productAsyncValue is AsyncValue<List<ProductModel>>
    // Use .when() for automatic state handling
    return productAsyncValue.when(
      loading: () => LoadingWidget(),
      error: (error, stack) => ErrorWidget(error),
      data: (products) => _buildTransactionUI(products, cartState),
    );
  }
}
```

**Key Changes:**

- Replace manual state handling dengan `.when()`
- Auto-update product list saat ada perubahan
- Show loading indicator saat sync
- Show error message jika sync gagal

### 4.2 Dashboard Screen Updates

**Current Implementation:**

```dart
class DashboardScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);

    // dashboardState is custom DashboardState
    // Manual state handling
  }
}
```

**New Implementation:**

```dart
class DashboardScreen extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context) {
    final dashboardAsyncValue = ref.watch(dashboardProvider);

    return dashboardAsyncValue.when(
      loading: () => DashboardSkeleton(),
      error: (error, stack) => DashboardError(error),
      data: (data) => _buildDashboard(data),
    );
  }

  Widget _buildDashboard(DashboardData data) {
    // Profit widget auto-updates
    // Tax indicator auto-updates
    // Charts auto-update
    // Tier breakdown auto-updates
  }
}
```

**Key Changes:**

- Real-time profit calculation
- Real-time tax indicator
- Real-time charts
- Real-time tier breakdown

### 4.3 Sync Status Indicator

**New Widget:**

```dart
class SyncStatusIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productListProvider);
    final transactionState = ref.watch(transactionListProvider);
    final expenseState = ref.watch(expenseListProvider);

    // Determine overall sync status
    final isLoading = productState.isLoading ||
                      transactionState.isLoading ||
                      expenseState.isLoading;

    final hasError = productState.hasError ||
                     transactionState.hasError ||
                     expenseState.hasError;

    return Row(
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (hasError)
          Icon(Icons.error, color: Colors.red)
        else
          Icon(Icons.check_circle, color: Colors.green),
        SizedBox(width: 8),
        Text(isLoading ? 'Syncing...' : 'Synced'),
      ],
    );
  }
}
```

---

## 5. OFFLINE SUPPORT WITH HIVE

### 5.1 Hive Setup

**Dependencies:**

```yaml
hive: ^2.2.3
hive_flutter: ^1.1.0
```

**Initialization:**

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(ProductModelAdapter());
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(ExpenseModelAdapter());

  runApp(MyApp());
}
```

### 5.2 Local Cache Implementation

**Cache Manager:**

```dart
class LocalCacheManager {
  static const String productsBox = 'products';
  static const String transactionsBox = 'transactions';
  static const String expensesBox = 'expenses';

  // Save products to cache
  Future<void> cacheProducts(List<ProductModel> products) async {
    final box = await Hive.openBox<ProductModel>(productsBox);
    await box.clear();
    await box.addAll(products);
  }

  // Get cached products
  Future<List<ProductModel>> getCachedProducts() async {
    final box = await Hive.openBox<ProductModel>(productsBox);
    return box.values.toList();
  }

  // Clear all cache
  Future<void> clearCache() async {
    await Hive.deleteBoxFromDisk(productsBox);
    await Hive.deleteBoxFromDisk(transactionsBox);
    await Hive.deleteBoxFromDisk(expensesBox);
  }
}
```

### 5.3 Offline Transaction Queue

**Queue Manager:**

```dart
class OfflineTransactionQueue {
  static const String queueBox = 'offline_transactions';

  // Add transaction to queue
  Future<void> addToQueue(TransactionModel transaction) async {
    final box = await Hive.openBox<TransactionModel>(queueBox);
    await box.add(transaction);
  }

  // Get queued transactions
  Future<List<TransactionModel>> getQueuedTransactions() async {
    final box = await Hive.openBox<TransactionModel>(queueBox);
    return box.values.toList();
  }

  // Remove from queue after successful sync
  Future<void> removeFromQueue(String transactionId) async {
    final box = await Hive.openBox<TransactionModel>(queueBox);
    final index = box.values.toList()
        .indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      await box.deleteAt(index);
    }
  }
}
```

---

## 6. ERROR HANDLING & RETRY LOGIC

### 6.1 Retry Strategy

**Exponential Backoff:**

```dart
Future<T> retryWithBackoff<T>(
  Future<T> Function() operation, {
  int maxRetries = 3,
  Duration initialDelay = const Duration(seconds: 1),
}) async {
  int retries = 0;

  while (true) {
    try {
      return await operation();
    } catch (e) {
      if (retries >= maxRetries) {
        rethrow;
      }

      final delay = initialDelay * pow(2, retries);
      await Future.delayed(delay);
      retries++;
    }
  }
}
```

### 6.2 Network Status Detection

**Connectivity Monitoring:**

```dart
import 'connectivity_plus/connectivity_plus.dart';

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

// Usage in UI
ref.watch(connectivityProvider).when(
  data: (connectivity) {
    if (connectivity == ConnectivityResult.none) {
      return OfflineModeIndicator();
    }
    return OnlineModeIndicator();
  },
  loading: () => SizedBox(),
  error: (_, __) => SizedBox(),
);
```

---

## 7. PERFORMANCE OPTIMIZATION

### 7.1 Query Optimization

**Selective Fields:**

```dart
// Instead of SELECT *
final products = await supabase
    .from('products')
    .select('id, name, stock, harga_umum, harga_bengkel, harga_grossir')
    .execute();

// For real-time
Stream<List<ProductModel>> getProductsStream() {
  return supabase
      .from('products')
      .stream(primaryKey: ['id'])
      .select('id, name, stock, harga_umum, harga_bengkel, harga_grossir')
      .map((data) => data.map(ProductModel.fromJson).toList());
}
```

### 7.2 Pagination

**For Large Datasets:**

```dart
Stream<List<ProductModel>> getProductsStreamPaginated({
  int pageSize = 50,
}) {
  return supabase
      .from('products')
      .stream(primaryKey: ['id'])
      .limit(pageSize)
      .map((data) => data.map(ProductModel.fromJson).toList());
}
```

### 7.3 Debouncing

**For Frequent Updates:**

```dart
final productListProvider = StreamProvider<List<ProductModel>>((ref) {
  final repository = ref.watch(productRepositoryProvider);

  return repository
      .getProductsStream()
      .debounceTime(Duration(milliseconds: 500));
});
```

---

## 8. TESTING STRATEGY

### 8.1 Unit Tests

**Mock Supabase:**

```dart
class MockSupabaseClient extends Mock implements SupabaseClient {}

test('getProductsStream returns products', () async {
  final mockSupabase = MockSupabaseClient();
  final repository = ProductRepositoryImpl(mockSupabase);

  // Mock stream
  when(mockSupabase.from('products').stream(...))
      .thenAnswer((_) => Stream.value([...]));

  final products = await repository.getProductsStream().first;
  expect(products.length, 2);
});
```

### 8.2 Widget Tests

**Test Real-time Updates:**

```dart
testWidgets('ProductList updates when stream emits', (tester) async {
  final mockStream = StreamController<List<ProductModel>>();

  await tester.pumpWidget(
    ProviderContainer(
      overrides: [
        productListProvider.overrideWithValue(
          AsyncValue.data(mockStream.stream),
        ),
      ],
      child: MaterialApp(home: ProductList()),
    ),
  );

  // Emit new data
  mockStream.add([ProductModel(...), ProductModel(...)]);
  await tester.pumpAndSettle();

  expect(find.byType(ProductCard), findsWidgets);
});
```

### 8.3 Integration Tests

**Test with Real Supabase:**

```dart
test('Real-time sync works end-to-end', () async {
  final supabase = SupabaseClient(...);
  final repository = ProductRepositoryImpl(supabase);

  // Subscribe to stream
  final subscription = repository.getProductsStream().listen((products) {
    expect(products.isNotEmpty, true);
  });

  // Update product in database
  await supabase
      .from('products')
      .update({'harga_umum': 500000})
      .eq('id', 'test-product-id');

  // Wait for stream to emit
  await Future.delayed(Duration(seconds: 2));

  subscription.cancel();
});
```

---

## 9. DEPLOYMENT CHECKLIST

### Pre-deployment

- [ ] Verify Supabase real-time enabled on all tables
- [ ] Verify RLS policies correct
- [ ] Test with real Supabase credentials
- [ ] Test offline mode thoroughly
- [ ] Test sync queue with multiple transactions
- [ ] Performance test with large datasets
- [ ] Battery drain test
- [ ] Network latency test

### Deployment

- [ ] Update Supabase credentials in production
- [ ] Enable real-time on production database
- [ ] Monitor error logs
- [ ] Monitor performance metrics
- [ ] Prepare rollback plan

### Post-deployment

- [ ] Monitor user feedback
- [ ] Monitor error rates
- [ ] Monitor performance metrics
- [ ] Monitor battery drain reports
- [ ] Prepare hotfix if needed

---

## 10. DEPENDENCIES SUMMARY

### New Dependencies to Add

```yaml
dependencies:
  # Already have
  flutter: sdk
  flutter_riverpod: ^2.4.0
  supabase_flutter: ^2.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # New for real-time
  connectivity_plus: ^5.0.0 # Network status detection
  async: ^2.11.0 # Stream utilities

dev_dependencies:
  # Already have
  build_runner: ^2.4.0
  freezed: ^2.4.1

  # New for testing
  mockito: ^5.4.0 # Mocking
  mocktail: ^1.0.0 # Better mocking
```

---

## 11. MIGRATION GUIDE

### Step-by-step Migration

1. **Update Dependencies**

   - Add new packages to pubspec.yaml
   - Run `flutter pub get`

2. **Update Repositories**

   - Add Stream methods to interfaces
   - Implement Stream methods in implementations
   - Add error handling & retry logic

3. **Update Providers**

   - Convert StateNotifierProvider to StreamProvider
   - Update state handling logic
   - Add auto-refresh logic

4. **Update UI Screens**

   - Replace manual state handling dengan `.when()`
   - Add sync status indicator
   - Test real-time updates

5. **Add Offline Support**

   - Setup Hive
   - Implement local cache
   - Implement sync queue

6. **Testing**
   - Unit tests untuk repositories
   - Widget tests untuk screens
   - Integration tests dengan real Supabase

---

_Document Status: PLANNING PHASE - Ready for Review_  
_Last Updated: December 14, 2025_
