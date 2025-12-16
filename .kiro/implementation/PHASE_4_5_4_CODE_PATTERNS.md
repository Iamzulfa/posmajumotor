# 💻 PHASE 4.5.4: CODE PATTERNS & EXAMPLES

> **Purpose:** Exact code patterns to use when updating UI screens  
> **Date:** December 14, 2025

---

## 🎯 OVERVIEW

This document provides copy-paste ready code patterns for updating screens in Phase 4.5.4. Each pattern shows:

1. **Before** - Current mock data approach
2. **After** - New real-time stream approach
3. **Explanation** - Why this pattern works

---

## 📋 PATTERN 1: SINGLE STREAM WITH LOADING/ERROR

### Use Case

Displaying a single list of data (products, expenses, transactions)

### Before (Mock Data)

```dart
class ProductListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data - always available
    final products = mockProducts;

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}
```

### After (Real-time Stream)

```dart
class ProductListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the stream provider
    final productsAsync = ref.watch(productsStreamProvider);

    // Handle loading, error, and data states
    return productsAsync.when(
      // Data state - show the list
      data: (products) => ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),

      // Loading state - show skeleton
      loading: () => ProductListSkeleton(),

      // Error state - show error with retry
      error: (error, stackTrace) => ErrorStateWidget(
        icon: Icons.error_outline,
        title: 'Gagal memuat produk',
        subtitle: error.toString(),
        buttonText: 'Coba lagi',
        onRetry: () => ref.refresh(productsStreamProvider),
      ),
    );
  }
}
```

### Key Points

✅ `ref.watch()` subscribes to the stream  
✅ `.when()` handles all 3 states (data, loading, error)  
✅ `ref.refresh()` manually triggers refresh  
✅ Skeleton shows while loading  
✅ Error shows with retry button

---

## 📋 PATTERN 2: MULTIPLE STREAMS (NESTED)

### Use Case

Displaying data from multiple streams (e.g., products + categories)

### Before (Mock Data)

```dart
class InventoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = mockProducts;
    final categories = mockCategories;

    return Column(
      children: [
        CategoryPills(categories: categories),
        ProductList(products: products),
      ],
    );
  }
}
```

### After (Real-time Streams - Nested)

```dart
class InventoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    // Nested when for multiple streams
    return categoriesAsync.when(
      data: (categories) => productsAsync.when(
        data: (products) => Column(
          children: [
            CategoryPills(categories: categories),
            ProductList(products: products),
          ],
        ),
        loading: () => ProductListSkeleton(),
        error: (err, stack) => ErrorStateWidget(
          title: 'Gagal memuat produk',
          onRetry: () => ref.refresh(productsStreamProvider),
        ),
      ),
      loading: () => CategorySkeleton(),
      error: (err, stack) => ErrorStateWidget(
        title: 'Gagal memuat kategori',
        onRetry: () => ref.refresh(categoriesStreamProvider),
      ),
    );
  }
}
```

### Key Points

✅ Watch multiple providers  
✅ Nest `.when()` calls for multiple streams  
✅ Each stream has its own loading/error state  
✅ Shows most relevant error first

---

## 📋 PATTERN 3: MULTIPLE STREAMS (OPTIMIZED WITH SELECT)

### Use Case

Multiple streams but want to avoid nested when (cleaner code)

### After (Real-time Streams - Optimized)

```dart
class InventoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use select to extract just the data (or null if loading/error)
    final products = ref.watch(
      productsStreamProvider.select((async) => async.value),
    );
    final categories = ref.watch(
      categoriesStreamProvider.select((async) => async.value),
    );

    // Check if both are loaded
    if (products == null || categories == null) {
      return ProductListSkeleton();
    }

    return Column(
      children: [
        CategoryPills(categories: categories),
        ProductList(products: products),
      ],
    );
  }
}
```

### Key Points

✅ `.select()` extracts just the data  
✅ Cleaner than nested `.when()`  
✅ Returns null if loading/error  
✅ More efficient rebuilds

---

## 📋 PATTERN 4: PULL-TO-REFRESH

### Use Case

Allow user to manually refresh data

### Before (No Refresh)

```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardStreamProvider);

    return dashboardAsync.when(
      data: (dashboard) => DashboardContent(data: dashboard),
      loading: () => DashboardSkeleton(),
      error: (err, stack) => ErrorStateWidget(...),
    );
  }
}
```

### After (With Pull-to-Refresh)

```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardStreamProvider);

    return RefreshIndicator(
      // Called when user pulls down
      onRefresh: () async {
        // Refresh the provider and wait for new data
        await ref.refresh(dashboardStreamProvider).future;
      },
      child: dashboardAsync.when(
        data: (dashboard) => SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: DashboardContent(data: dashboard),
        ),
        loading: () => DashboardSkeleton(),
        error: (err, stack) => ErrorStateWidget(...),
      ),
    );
  }
}
```

### Key Points

✅ `RefreshIndicator` wraps the content  
✅ `onRefresh` calls `ref.refresh()` and waits for future  
✅ `AlwaysScrollableScrollPhysics()` allows pull-to-refresh even if content fits  
✅ `SingleChildScrollView` makes content scrollable

---

## 📋 PATTERN 5: SYNC STATUS INDICATOR

### Use Case

Show user the sync status (online, offline, syncing)

### Before (No Status)

```dart
class TransactionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaksi')),
      body: ProductList(),
    );
  }
}
```

### After (With Sync Status)

```dart
class TransactionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);

    // Determine sync status from AsyncValue
    final syncStatus = productsAsync.when(
      data: (_) => SyncStatus.synced,
      loading: () => SyncStatus.syncing,
      error: (_, __) => SyncStatus.error,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Transaksi'),
        // Add sync status to header
        actions: [
          SyncStatusWidget(status: syncStatus),
        ],
      ),
      body: productsAsync.when(
        data: (products) => ProductList(products: products),
        loading: () => ProductListSkeleton(),
        error: (err, stack) => ErrorStateWidget(...),
      ),
    );
  }
}
```

### SyncStatusWidget

```dart
class SyncStatusWidget extends StatelessWidget {
  final SyncStatus status;

  const SyncStatusWidget({required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Center(
        child: switch (status) {
          SyncStatus.synced => Tooltip(
            message: 'Data tersinkronisasi',
            child: Icon(Icons.cloud_done, color: Colors.green),
          ),
          SyncStatus.syncing => Tooltip(
            message: 'Sedang sinkronisasi...',
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          SyncStatus.error => Tooltip(
            message: 'Gagal sinkronisasi',
            child: Icon(Icons.cloud_off, color: Colors.red),
          ),
        },
      ),
    );
  }
}

enum SyncStatus { synced, syncing, error }
```

### Key Points

✅ Determine status from AsyncValue state  
✅ Show icon in AppBar  
✅ Use tooltip for explanation  
✅ Show spinner while syncing

---

## 📋 PATTERN 6: AUTO-UPDATE DETECTION

### Use Case

Detect when data changes and show notification

### Example: Product Price Change in Cart

```dart
class TransactionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);
    final cart = ref.watch(cartProvider);

    // Detect price changes
    ref.listen(productsStreamProvider, (previous, next) {
      next.whenData((products) {
        // Check if any product in cart has price change
        for (var cartItem in cart) {
          final updatedProduct = products.firstWhere(
            (p) => p.id == cartItem.productId,
            orElse: () => null,
          );

          if (updatedProduct != null &&
              updatedProduct.price != cartItem.price) {
            // Show snackbar notification
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Harga ${updatedProduct.name} berubah dari '
                  '${cartItem.price} menjadi ${updatedProduct.price}',
                ),
                action: SnackBarAction(
                  label: 'Perbarui',
                  onPressed: () {
                    // Update cart with new price
                    ref.read(cartProvider.notifier).updatePrice(
                      cartItem.productId,
                      updatedProduct.price,
                    );
                  },
                ),
              ),
            );
          }
        }
      });
    });

    return productsAsync.when(
      data: (products) => TransactionContent(products: products),
      loading: () => TransactionSkeleton(),
      error: (err, stack) => ErrorStateWidget(...),
    );
  }
}
```

### Key Points

✅ Use `ref.listen()` to detect changes  
✅ Compare previous and next values  
✅ Show snackbar notification  
✅ Allow user to update or ignore

---

## 📋 PATTERN 7: LOADING SKELETON

### Use Case

Show placeholder while data is loading

### ProductListSkeleton

```dart
class ProductListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // Show 5 skeleton items
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.all(8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

### DashboardSkeleton

```dart
class DashboardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Profit widget skeleton
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 120,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Chart skeleton
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 200,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Stats skeleton
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 80,
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Key Points

✅ Use Shimmer for animated skeleton  
✅ Match actual content layout  
✅ Show 3-5 skeleton items  
✅ Use grey colors for placeholder

---

## 📋 PATTERN 8: ERROR STATE WITH RETRY

### Use Case

Show error message with retry button

### ErrorStateWidget

```dart
class ErrorStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    this.icon = Icons.error_outline,
    required this.title,
    required this.subtitle,
    this.buttonText = 'Coba lagi',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
```

### Usage

```dart
productsAsync.when(
  data: (products) => ProductList(products: products),
  loading: () => ProductListSkeleton(),
  error: (error, stackTrace) => ErrorStateWidget(
    icon: Icons.cloud_off,
    title: 'Gagal memuat produk',
    subtitle: error.toString(),
    buttonText: 'Coba lagi',
    onRetry: () => ref.refresh(productsStreamProvider),
  ),
)
```

### Key Points

✅ Show icon, title, subtitle  
✅ Provide retry button  
✅ Call `ref.refresh()` on retry  
✅ Center content vertically

---

## 📋 PATTERN 9: COMBINING PATTERNS

### Complete Example: Dashboard Screen

```dart
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardStreamProvider);

    // Detect sync status
    final isSyncing = dashboardAsync.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          SyncStatusWidget(
            isSyncing: isSyncing,
            hasError: dashboardAsync.hasError,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.refresh(dashboardStreamProvider).future;
        },
        child: dashboardAsync.when(
          data: (dashboard) => SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: DashboardContent(data: dashboard),
          ),
          loading: () => DashboardSkeleton(),
          error: (error, stackTrace) => ErrorStateWidget(
            icon: Icons.cloud_off,
            title: 'Gagal memuat dashboard',
            subtitle: error.toString(),
            buttonText: 'Coba lagi',
            onRetry: () => ref.refresh(dashboardStreamProvider),
          ),
        ),
      ),
    );
  }
}
```

### Key Points

✅ Combine all patterns  
✅ Show sync status in AppBar  
✅ Add pull-to-refresh  
✅ Show skeleton while loading  
✅ Show error with retry  
✅ Scroll content

---

## 🎯 IMPLEMENTATION CHECKLIST

For each screen, use this checklist:

- [ ] Replace mock data with `ref.watch(streamProvider)`
- [ ] Add `.when()` for data/loading/error states
- [ ] Create loading skeleton
- [ ] Add error state with retry
- [ ] Add sync status indicator
- [ ] Add pull-to-refresh (if list)
- [ ] Test real-time updates
- [ ] Test error handling
- [ ] Test offline mode

---

## 📝 COMMON MISTAKES TO AVOID

### ❌ Mistake 1: Creating provider in build method

```dart
// WRONG - Creates new provider every build
@override
Widget build(BuildContext context, WidgetRef ref) {
  final provider = StreamProvider((ref) => ...); // ❌ WRONG
  final data = ref.watch(provider);
}
```

### ✅ Correct: Define provider at top level

```dart
// CORRECT - Provider defined once
final myProvider = StreamProvider((ref) => ...);

@override
Widget build(BuildContext context, WidgetRef ref) {
  final data = ref.watch(myProvider); // ✅ CORRECT
}
```

---

### ❌ Mistake 2: Not handling all states

```dart
// WRONG - Only handles data state
final data = ref.watch(streamProvider).value;
if (data != null) {
  return ListView(...); // ❌ Crashes if loading/error
}
```

### ✅ Correct: Use .when() for all states

```dart
// CORRECT - Handles all states
ref.watch(streamProvider).when(
  data: (data) => ListView(...),
  loading: () => Skeleton(),
  error: (err, stack) => ErrorWidget(...),
)
```

---

### ❌ Mistake 3: Forgetting to refresh

```dart
// WRONG - No way to retry
ErrorStateWidget(
  title: 'Error',
  onRetry: () {}, // ❌ Does nothing
)
```

### ✅ Correct: Call ref.refresh()

```dart
// CORRECT - Refreshes the provider
ErrorStateWidget(
  title: 'Error',
  onRetry: () => ref.refresh(streamProvider), // ✅ Retries
)
```

---

## 🚀 NEXT STEPS

1. Copy these patterns
2. Apply to each screen
3. Test real-time updates
4. Verify error handling
5. Check performance

---

_Document Status: READY FOR USE_  
_Last Updated: December 14, 2025_
