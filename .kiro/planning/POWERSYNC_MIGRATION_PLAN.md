# 🔄 POWERSYNC MIGRATION PLAN

> **Priority:** Phase 5B - High Priority  
> **Effort:** 3-5 days  
> **Impact:** High (Reliability & Offline Support)  
> **Status:** Planning

---

## 🎯 OBJECTIVES

1. Migrate from Hive to PowerSync for better offline support
2. Implement automatic bi-directional sync
3. Handle network interruptions gracefully (kabel ambrol scenario)
4. Reduce manual queue management
5. Improve data integrity & conflict resolution

---

## 📊 POWERSYNC VS HIVE COMPARISON

### Current State (Hive)

```
Offline Flow:
1. User creates transaction (offline)
2. Transaction saved to Hive
3. Added to queue
4. When online: manual sync triggered
5. Sync to Supabase
6. Clear queue

Issues:
- Manual sync management
- No automatic conflict resolution
- Requires manual invalidation
- Complex error handling
```

### Target State (PowerSync)

```
Offline Flow:
1. User creates transaction (offline)
2. PowerSync saves to local SQLite
3. Automatic sync when online
4. Conflict resolution built-in
5. Real-time updates

Benefits:
- Automatic sync
- Built-in conflict resolution
- Less boilerplate
- Better reliability
```

---

## 🛠️ IMPLEMENTATION ARCHITECTURE

### 1. PowerSync Setup

**File:** `lib/core/services/powersync_service.dart`

```dart
import 'package:powersync/powersync.dart';

class PowerSyncService {
  late PowerSyncDatabase db;

  Future<void> initialize() async {
    // Initialize PowerSync with Supabase
    db = PowerSyncDatabase(
      schema: schema,
      // Connect to Supabase
    );

    await db.initialize();

    // Start sync
    await db.connect(
      connector: SupabaseConnector(),
    );
  }

  // Get products stream
  Stream<List<ProductModel>> getProductsStream() {
    return db.watch(
      'SELECT * FROM products ORDER BY created_at DESC',
      mapper: (row) => ProductModel.fromJson(row),
    );
  }

  // Create transaction
  Future<void> createTransaction(TransactionModel transaction) async {
    await db.execute(
      'INSERT INTO transactions (id, number, total, created_at) VALUES (?, ?, ?, ?)',
      [transaction.id, transaction.number, transaction.total, transaction.createdAt],
    );
  }

  // Sync status stream
  Stream<SyncStatus> getSyncStatusStream() {
    return db.syncStatusStream;
  }
}
```

### 2. PowerSync Schema

**File:** `lib/core/services/powersync_schema.dart`

```dart
import 'package:powersync/powersync.dart';

final schema = Schema([
  Table(
    name: 'products',
    columns: [
      Column.text('id'),
      Column.text('name'),
      Column.text('sku'),
      Column.text('category_id'),
      Column.text('brand_id'),
      Column.integer('stock'),
      Column.real('price_umum'),
      Column.real('price_bengkel'),
      Column.real('price_grossir'),
      Column.real('hpp'),
      Column.integer('min_stock'),
      Column.text('created_at'),
      Column.text('updated_at'),
    ],
  ),
  Table(
    name: 'transactions',
    columns: [
      Column.text('id'),
      Column.text('number'),
      Column.real('total_omset'),
      Column.real('total_hpp'),
      Column.real('total_profit'),
      Column.text('payment_method'),
      Column.text('created_at'),
      Column.text('updated_at'),
    ],
  ),
  Table(
    name: 'transaction_items',
    columns: [
      Column.text('id'),
      Column.text('transaction_id'),
      Column.text('product_id'),
      Column.integer('quantity'),
      Column.text('tier'),
      Column.real('price'),
      Column.real('hpp'),
      Column.real('profit'),
      Column.text('created_at'),
    ],
  ),
  Table(
    name: 'expenses',
    columns: [
      Column.text('id'),
      Column.text('category'),
      Column.real('amount'),
      Column.text('description'),
      Column.text('created_at'),
      Column.text('updated_at'),
    ],
  ),
  // Add other tables...
]);
```

### 3. PowerSync Connector (Supabase Integration)

**File:** `lib/core/services/powersync_connector.dart`

```dart
import 'package:powersync/powersync.dart';

class SupabaseConnector extends PowerSyncBackendConnector {
  final supabase = Supabase.instance.client;

  @override
  Future<PowerSyncBackendConnectorResponse> uploadData(
    PowerSyncDatabase database,
  ) async {
    try {
      // Get pending changes
      final changes = await database.getPendingChanges();

      // Upload to Supabase
      for (final change in changes) {
        if (change.type == ChangeType.insert) {
          await supabase
              .from(change.table)
              .insert(change.changes);
        } else if (change.type == ChangeType.update) {
          await supabase
              .from(change.table)
              .update(change.changes)
              .eq('id', change.id);
        } else if (change.type == ChangeType.delete) {
          await supabase
              .from(change.table)
              .delete()
              .eq('id', change.id);
        }
      }

      return PowerSyncBackendConnectorResponse(
        success: true,
      );
    } catch (e) {
      return PowerSyncBackendConnectorResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  @override
  Future<void> downloadData(PowerSyncDatabase database) async {
    try {
      // Download products
      final products = await supabase
          .from('products')
          .select()
          .order('updated_at', ascending: false);

      await database.execute(
        'DELETE FROM products',
      );

      for (final product in products) {
        await database.execute(
          'INSERT INTO products VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            product['id'],
            product['name'],
            product['sku'],
            product['category_id'],
            product['brand_id'],
            product['stock'],
            product['price_umum'],
            product['price_bengkel'],
            product['price_grossir'],
            product['hpp'],
            product['min_stock'],
            product['created_at'],
            product['updated_at'],
          ],
        );
      }

      // Download other tables similarly...
    } catch (e) {
      print('Download error: $e');
    }
  }
}
```

### 4. PowerSync Provider

**File:** `lib/presentation/providers/powersync_provider.dart`

```dart
import 'package:riverpod/riverpod.dart';

final powerSyncServiceProvider = Provider((ref) {
  return PowerSyncService();
});

final syncStatusProvider = StreamProvider((ref) {
  final service = ref.watch(powerSyncServiceProvider);
  return service.getSyncStatusStream();
});

final productsStreamProvider = StreamProvider((ref) {
  final service = ref.watch(powerSyncServiceProvider);
  return service.getProductsStream();
});

final transactionsStreamProvider = StreamProvider((ref) {
  final service = ref.watch(powerSyncServiceProvider);
  return service.getTransactionsStream();
});

// Usage in UI:
// final syncStatus = ref.watch(syncStatusProvider);
// syncStatus.when(
//   data: (status) => Text('Syncing: ${status.isSyncing}'),
//   loading: () => CircularProgressIndicator(),
//   error: (err, stack) => Text('Error: $err'),
// )
```

### 5. Sync Status Widget

**File:** `lib/presentation/widgets/sync_status_indicator.dart`

```dart
class SyncStatusIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    return syncStatus.when(
      data: (status) {
        if (status.isSyncing) {
          return Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Syncing...'),
            ],
          );
        } else if (status.lastSyncTime != null) {
          return Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 8),
              Text('Synced'),
            ],
          );
        } else {
          return Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.grey, size: 16),
              SizedBox(width: 8),
              Text('Offline'),
            ],
          );
        }
      },
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Sync Error'),
    );
  }
}
```

---

## 📋 MIGRATION CHECKLIST

### Phase 1: Setup (Day 1)

- [ ] Add PowerSync dependency to pubspec.yaml
- [ ] Create PowerSync schema
- [ ] Create PowerSync service
- [ ] Create PowerSync connector
- [ ] Create PowerSync provider
- [ ] Create sync status widget

### Phase 2: Repository Migration (Day 2)

- [ ] Update ProductRepository to use PowerSync
- [ ] Update TransactionRepository to use PowerSync
- [ ] Update ExpenseRepository to use PowerSync
- [ ] Update TaxRepository to use PowerSync
- [ ] Remove Hive dependencies from repositories

### Phase 3: Provider Migration (Day 2-3)

- [ ] Update product providers
- [ ] Update transaction providers
- [ ] Update expense providers
- [ ] Update dashboard providers
- [ ] Update tax providers

### Phase 4: UI Updates (Day 3)

- [ ] Add sync status indicator to screens
- [ ] Update screens to use PowerSync providers
- [ ] Remove Hive-specific code
- [ ] Test sync functionality

### Phase 5: Testing & Cleanup (Day 4-5)

- [ ] Test offline mode
- [ ] Test sync when online
- [ ] Test conflict resolution
- [ ] Remove old Hive code
- [ ] Update documentation

---

## 🔧 MIGRATION STEPS

### Step 1: Add Dependency

```yaml
# pubspec.yaml
dependencies:
  powersync: ^1.0.0
  sqlite3_flutter_libs: ^0.5.0
```

### Step 2: Initialize PowerSync

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize PowerSync
  final powerSyncService = PowerSyncService();
  await powerSyncService.initialize();

  // ... rest of initialization
  runApp(MyApp());
}
```

### Step 3: Update Repositories

```dart
// Before (Hive)
Future<List<ProductModel>> getProducts() async {
  final box = Hive.box('products');
  return box.values.toList();
}

// After (PowerSync)
Future<List<ProductModel>> getProducts() async {
  final results = await db.query(
    'SELECT * FROM products ORDER BY created_at DESC',
  );
  return results.map((row) => ProductModel.fromJson(row)).toList();
}
```

### Step 4: Update Providers

```dart
// Before (FutureProvider)
final productsProvider = FutureProvider((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProducts();
});

// After (StreamProvider)
final productsProvider = StreamProvider((ref) {
  final service = ref.watch(powerSyncServiceProvider);
  return service.getProductsStream();
});
```

---

## 🌐 OFFLINE SCENARIO HANDLING

### Scenario: Kabel Ambrol (Network Interrupted)

```
Timeline:
1. 13:00 - User creating transaction (online)
2. 13:05 - Kabel ambrol, internet mati
3. 13:06 - User finishes transaction (offline)
   - PowerSync saves to local SQLite
   - Transaction queued for sync
4. 13:15 - Kabel diperbaiki, internet kembali
5. 13:16 - PowerSync detects connection
   - Automatic sync triggered
   - Transaction uploaded to Supabase
   - Conflict resolution (if any)
   - Local data updated
6. 13:17 - User sees "Synced" indicator
```

### Error Handling

```dart
// PowerSync handles automatically:
- Network timeouts
- Partial uploads
- Conflict resolution
- Retry logic
- Data integrity

// App just needs to:
- Show sync status
- Handle sync errors gracefully
- Provide manual sync button (optional)
```

---

## 📊 BENEFITS COMPARISON

### Before (Hive)

```
Offline Transaction:
1. Save to Hive ✓
2. Add to queue ✓
3. Manual sync trigger ✗
4. Handle conflicts manually ✗
5. Update UI manually ✗

Issues:
- User must remember to sync
- No automatic conflict resolution
- Complex error handling
- Manual invalidation needed
```

### After (PowerSync)

```
Offline Transaction:
1. Save to SQLite ✓
2. Automatic sync ✓
3. Conflict resolution ✓
4. Real-time updates ✓
5. Sync status indicator ✓

Benefits:
- Automatic sync
- Built-in conflict resolution
- Less code
- Better reliability
- Better UX
```

---

## 🚀 NEXT STEPS

1. **Review Plan** - Discuss PowerSync approach
2. **Setup** - Add PowerSync to project
3. **Migrate** - Update repositories & providers
4. **Test** - Test offline/online scenarios
5. **Deploy** - Push to production

---

## 📚 RESOURCES

- PowerSync Docs: https://docs.powersync.co/
- PowerSync Flutter: https://pub.dev/packages/powersync
- Supabase Integration: https://docs.powersync.co/integration-guides/supabase

---

_Plan created: 16 Desember 2025_  
_Status: Ready for Implementation_
