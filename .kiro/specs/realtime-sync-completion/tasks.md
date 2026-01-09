# Implementation Plan

## Phase 1: Core Services Setup

- [x] 1. Setup Hive for Local Storage

  - [ ] 1.1 Add Hive dependencies to pubspec.yaml

    - Add `hive: ^2.2.3` and `hive_flutter: ^1.1.0`

    - Add `connectivity_plus: ^5.0.0` for connectivity detection
    - Run `flutter pub get`
    - _Requirements: 4.1, 4.2_

  - [ ] 1.2 Initialize Hive in main.dart

    - Call `Hive.initFlutter()` before runApp
    - Register type adapters for ProductModel, TransactionModel
    - Open required boxes

    - _Requirements: 4.1_

  - [ ] 1.3 Create Hive type adapters

    - Create adapter for CacheMetadata

    - Create adapter for QueuedTransaction
    - Register adapters in main.dart
    - _Requirements: 4.5_

- [ ] 2. Implement LocalCacheManager

  - [x] 2.1 Create LocalCacheManager interface

    - Create `lib/core/services/local_cache_manager.dart`
    - Define abstract methods for cache operations
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [ ] 2.2 Implement LocalCacheManagerImpl
    - Create `lib/core/services/local_cache_manager_impl.dart`
    - Implement cacheProducts() using Hive box
    - Implement getCachedProducts() with error handling
    - Implement cache metadata storage
    - _Requirements: 4.1, 4.2, 4.5_
  - [ ]\* 2.3 Write property test for cache round-trip
    - **Property 1: Cache Round-Trip Consistency**
    - **Validates: Requirements 4.1, 4.2**
  - [ ] 2.4 Implement cache invalidation logic

    - Implement isCacheValid() with maxAge check

    - Implement clearCache() methods

    - _Requirements: 4.4, 4.5, 2.3_

  - [x]\* 2.5 Write property test for cache invalidation

    - **Property 5: Cache Invalidation**
    - **Validates: Requirements 4.5, 2.3**

  - [x]\* 2.6 Write property test for clear cache

    - **Property 6: Clear Cache Completeness**

    - **Validates: Requirements 4.4**

- [x] 3. Checkpoint - Make sure all tests pass

  - Ensure all tests pass, ask the user if questions arise.

## Phase 2: Offline Sync Manager

- [ ] 4. Implement ConnectivityService

  - [x] 4.1 Create ConnectivityService interface

    - Create `lib/core/services/connectivity_service.dart`
    - Define isOnline getter and connectivityStream
    - _Requirements: 3.1, 3.2_

  - [ ] 4.2 Implement ConnectivityServiceImpl
    - Create `lib/core/services/connectivity_service_impl.dart`
    - Use connectivity_plus package
    - Implement stream for connectivity changes
    - _Requirements: 3.1, 3.2_

- [ ] 5. Implement OfflineSyncManager

  - [ ] 5.1 Create OfflineSyncManager interface

    - Create `lib/core/services/offline_sync_manager.dart`
    - Define queue management methods
    - Define sync operation methods

    - _Requirements: 5.1, 5.2, 5.3_

  - [ ] 5.2 Implement OfflineSyncManagerImpl - Queue Operations

    - Create `lib/core/services/offline_sync_manager_impl.dart`
    - Implement addToQueue() with Hive storage

    - Implement getQueuedTransactions()

    - Implement getQueueCount()
    - _Requirements: 5.1, 5.3_

  - [ ]\* 5.3 Write property test for queue count accuracy
    - **Property 2: Queue Count Accuracy**
    - **Validates: Requirements 5.1, 5.3**
  - [ ] 5.4 Implement OfflineSyncManagerImpl - Sync Operations
    - Implement processQueue() with TransactionRepository
    - Implement chronological ordering
    - Implement error handling and retry logic
    - _Requirements: 5.2, 5.4, 1.3, 1.4_
  - [ ]\* 5.5 Write property test for queue ordering
    - **Property 3: Queue Ordering Preservation**
    - **Validates: Requirements 1.4**
  - [ ]\* 5.6 Write property test for failed transaction retention
    - **Property 4: Failed Transaction Retention**
    - **Validates: Requirements 5.5**

- [x] 6. Checkpoint - Make sure all tests pass

  - Ensure all tests pass, ask the user if questions arise.

## Phase 3: Integration with Existing Code

- [ ] 7. Register Services in Dependency Injection

  - [ ] 7.1 Update injection_container.dart
    - Register LocalCacheManager
    - Register ConnectivityService
    - Register OfflineSyncManager
    - _Requirements: 4.1, 5.1_

- [x] 8. Update Providers for Offline Support

  - [x] 8.1 Create connectivity provider

    - Create `lib/presentation/providers/connectivity_provider.dart`
    - Expose isOnline state
    - Expose queue count
    - _Requirements: 3.1, 3.2, 3.3_

  - [x] 8.2 Update product_provider.dart

    - Add fallback to cached products when offline
    - Cache products after successful fetch
    - _Requirements: 2.1, 2.2_

  - [x] 8.3 Update transaction_provider.dart

    - Add offline transaction creation
    - Queue transaction when offline
    - Auto-sync when online
    - _Requirements: 1.1, 1.2, 1.3_

- [x] 9. Update UI for Offline Support

  - [x] 9.1 Update SyncStatusWidget

    - Show queue count when pending

    - Show syncing status during sync
    - _Requirements: 3.3, 3.4_

  - [x] 9.2 Update Transaction Screen

    - Allow transaction creation when offline
    - Show offline indicator
    - _Requirements: 1.1, 2.4_

  - [x] 9.3 Update Inventory Screen

    - Show cached products when offline
    - Show offline indicator
    - _Requirements: 2.1, 2.4_

- [x] 10. Checkpoint - Make sure all tests pass

  - Ensure all tests pass, ask the user if questions arise.

## Phase 4: Unit Tests for Repositories

- [ ] 11. Setup Test Infrastructure

  - [ ] 11.1 Add test dependencies
    - Add `mocktail: ^1.0.0` for mocking
    - Add `glados: ^1.1.1` for property-based testing
    - Create test utilities and mocks
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ]\* 12. Write Repository Unit Tests

  - [ ]\* 12.1 Write ProductRepository tests
    - Test getProducts with mock Supabase
    - Test createProduct, updateProduct, deleteProduct
    - Test error handling
    - _Requirements: 6.1_
  - [ ]\* 12.2 Write TransactionRepository tests
    - Test createTransaction with mock Supabase
    - Test getTransactions, refundTransaction
    - Test error handling
    - _Requirements: 6.2_
  - [ ]\* 12.3 Write ExpenseRepository tests
    - Test createExpense, getExpenses, deleteExpense
    - Test error handling
    - _Requirements: 6.3_
  - [ ]\* 12.4 Write TaxRepository tests
    - Test calculateTax, markAsPaid
    - Test getProfitLossReport
    - Test error handling
    - _Requirements: 6.4_

- [ ] 13. Checkpoint - Make sure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Phase 5: Widget Tests for Screens

- [ ]\* 14. Write Widget Tests

  - [ ]\* 14.1 Write Dashboard Screen tests
    - Test profit card renders correctly
    - Test tax indicator renders correctly
    - Test tier breakdown renders correctly
    - Test loading and error states
    - _Requirements: 7.1_
  - [ ]\* 14.2 Write Tax Center Screen tests
    - Test laporan tab renders correctly
    - Test kalkulator tab renders correctly
    - Test month selector works
    - Test loading and error states
    - _Requirements: 7.2_
  - [ ]\* 14.3 Write Inventory Screen tests
    - Test product list renders correctly
    - Test search functionality works
    - Test category filter works
    - Test loading and error states
    - _Requirements: 7.3_
  - [ ]\* 14.4 Write Transaction Screen tests
    - Test cart operations work
    - Test payment flow works
    - Test tier selector works
    - Test loading and error states
    - _Requirements: 7.4_

- [ ] 15. Final Checkpoint - Make sure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
