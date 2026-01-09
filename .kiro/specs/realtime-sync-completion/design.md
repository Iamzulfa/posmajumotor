# Design Document - Real-Time Sync Completion

## Overview

Dokumen ini menjelaskan design untuk menyelesaikan implementasi Real-Time Sync pada Posfelix. Fokus utama adalah **Offline Support** yang memungkinkan aplikasi berfungsi tanpa koneksi internet, dan **Testing** untuk memastikan kualitas kode.

### Current State

- ✅ Real-time streams sudah diimplementasikan di semua repository
- ✅ StreamProviders sudah ada di semua provider
- ✅ UI screens sudah menggunakan real-time data
- 🔴 Offline support belum ada
- 🔴 Unit tests dan widget tests belum ada

### Target State

- Aplikasi dapat membuat transaksi saat offline
- Data di-cache secara lokal untuk akses offline
- Transaksi offline di-sync otomatis saat online
- Unit tests untuk semua repository
- Widget tests untuk semua screens

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Screens   │  │  Providers  │  │ SyncStatusWidget    │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
└─────────┼────────────────┼────────────────────┼─────────────┘
          │                │                    │
┌─────────┼────────────────┼────────────────────┼─────────────┐
│         │           Core Layer                │             │
│  ┌──────▼──────────────────────────────────────▼──────┐     │
│  │              OfflineSyncManager                     │     │
│  │  - addToQueue()                                     │     │
│  │  - processQueue()                                   │     │
│  │  - getQueueCount()                                  │     │
│  └──────────────────────┬──────────────────────────────┘     │
│                         │                                    │
│  ┌──────────────────────▼──────────────────────────────┐     │
│  │              LocalCacheManager                       │     │
│  │  - cacheProducts()                                   │     │
│  │  - getCachedProducts()                               │     │
│  │  - cacheTransactions()                               │     │
│  │  - clearCache()                                      │     │
│  └──────────────────────┬──────────────────────────────┘     │
└─────────────────────────┼────────────────────────────────────┘
                          │
┌─────────────────────────┼────────────────────────────────────┐
│                    Data Layer                                │
│  ┌──────────────────────▼──────────────────────────────┐     │
│  │                    Hive                              │     │
│  │  - products_cache (Box<ProductModel>)                │     │
│  │  - transactions_queue (Box<TransactionModel>)        │     │
│  │  - cache_metadata (Box<CacheMetadata>)               │     │
│  └─────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. LocalCacheManager

**Location:** `lib/core/services/local_cache_manager.dart`

```dart
abstract class LocalCacheManager {
  // Products
  Future<void> cacheProducts(List<ProductModel> products);
  Future<List<ProductModel>> getCachedProducts();
  Future<void> clearProductsCache();

  // Transactions
  Future<void> cacheTransactions(List<TransactionModel> transactions);
  Future<List<TransactionModel>> getCachedTransactions();
  Future<void> clearTransactionsCache();

  // Cache metadata
  Future<DateTime?> getLastCacheTime(String cacheKey);
  Future<bool> isCacheValid(String cacheKey, Duration maxAge);
  Future<void> clearAllCache();
}
```

### 2. OfflineSyncManager

**Location:** `lib/core/services/offline_sync_manager.dart`

```dart
abstract class OfflineSyncManager {
  // Queue management
  Future<void> addToQueue(TransactionModel transaction);
  Future<List<TransactionModel>> getQueuedTransactions();
  Future<int> getQueueCount();
  Future<void> removeFromQueue(String transactionId);
  Future<void> clearQueue();

  // Sync operations
  Future<SyncResult> processQueue();
  Stream<SyncStatus> get syncStatusStream;

  // Connectivity
  bool get isOnline;
  Stream<bool> get connectivityStream;
}

class SyncResult {
  final int successCount;
  final int failedCount;
  final List<String> failedIds;
}

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}
```

### 3. ConnectivityService

**Location:** `lib/core/services/connectivity_service.dart`

```dart
abstract class ConnectivityService {
  bool get isOnline;
  Stream<bool> get connectivityStream;
  Future<bool> checkConnectivity();
}
```

## Data Models

### CacheMetadata

```dart
@HiveType(typeId: 10)
class CacheMetadata {
  @HiveField(0)
  final String cacheKey;

  @HiveField(1)
  final DateTime cachedAt;

  @HiveField(2)
  final int itemCount;
}
```

### QueuedTransaction

```dart
@HiveType(typeId: 11)
class QueuedTransaction {
  @HiveField(0)
  final String localId;

  @HiveField(1)
  final TransactionModel transaction;

  @HiveField(2)
  final DateTime queuedAt;

  @HiveField(3)
  final int retryCount;

  @HiveField(4)
  final String? lastError;
}
```

## Correctness Properties

_A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees._

### Property 1: Cache Round-Trip Consistency

_For any_ list of products, caching then retrieving should return an equivalent list with the same items.
**Validates: Requirements 4.1, 4.2**

### Property 2: Queue Count Accuracy

_For any_ sequence of addToQueue operations, getQueueCount should return the exact number of items added minus items removed.
**Validates: Requirements 5.1, 5.3**

### Property 3: Queue Ordering Preservation

_For any_ sequence of transactions added to queue, processQueue should process them in the order they were added (FIFO).
**Validates: Requirements 1.4**

### Property 4: Failed Transaction Retention

_For any_ transaction that fails to sync, the transaction should remain in the queue with incremented retry count.
**Validates: Requirements 5.5**

### Property 5: Cache Invalidation

_For any_ cache with timestamp older than maxAge, isCacheValid should return false.
**Validates: Requirements 4.5, 2.3**

### Property 6: Clear Cache Completeness

_For any_ cache state, after clearAllCache, all getCached methods should return empty lists.
**Validates: Requirements 4.4**

## Error Handling

### Offline Errors

- **No connectivity:** Store transaction in queue, show offline indicator
- **Sync failure:** Keep in queue, increment retry count, log error
- **Cache corruption:** Clear cache, re-fetch from server when online

### Sync Errors

- **Network timeout:** Retry with exponential backoff (max 3 retries)
- **Server error (5xx):** Keep in queue, retry later
- **Client error (4xx):** Log error, remove from queue (invalid data)
- **Conflict:** Server wins, update local data

### Error Codes

```dart
enum OfflineError {
  noConnectivity,
  cacheCorrupted,
  syncFailed,
  queueFull,
  invalidData,
}
```

## Testing Strategy

### Unit Testing Framework

- **Framework:** `flutter_test` (built-in)
- **Mocking:** `mocktail` package
- **Property-based testing:** `glados` package

### Property-Based Testing Requirements

- Each property test MUST run minimum 100 iterations
- Each property test MUST be tagged with format: `**Feature: realtime-sync-completion, Property {number}: {property_text}**`
- Generators MUST produce valid domain objects

### Test Structure

```
test/
├── unit/
│   ├── services/
│   │   ├── local_cache_manager_test.dart
│   │   └── offline_sync_manager_test.dart
│   └── repositories/
│       ├── product_repository_test.dart
│       ├── transaction_repository_test.dart
│       ├── expense_repository_test.dart
│       └── tax_repository_test.dart
├── widget/
│   ├── screens/
│   │   ├── dashboard_screen_test.dart
│   │   ├── tax_center_screen_test.dart
│   │   ├── inventory_screen_test.dart
│   │   └── transaction_screen_test.dart
│   └── widgets/
│       └── sync_status_widget_test.dart
└── integration/
    └── offline_sync_integration_test.dart
```

### Test Coverage Targets

- Unit tests: 80% coverage
- Widget tests: 70% coverage
- Integration tests: Key user flows

### Mock Strategy

- Mock Supabase client for repository tests
- Mock repositories for provider tests
- Mock providers for widget tests
- Use real Hive for cache tests (in-memory)
