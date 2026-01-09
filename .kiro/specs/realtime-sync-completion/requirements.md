# Requirements Document

## Introduction

Dokumen ini mendefinisikan requirements untuk menyelesaikan implementasi Real-Time Sync pada aplikasi POS Keuangan Pajak (Posfelix). Berdasarkan analisis kode, implementasi real-time sync sudah 95% complete. Fokus utama sekarang adalah **Offline Support** dan **Testing** untuk memastikan aplikasi berfungsi dengan baik dalam berbagai kondisi jaringan.

## Status Implementasi Saat Ini

### ✅ SUDAH COMPLETE (95%)

- ProductRepository dengan Stream methods
- TransactionRepository dengan Stream methods
- ExpenseRepository dengan Stream methods
- TaxRepository dengan Stream methods
- DashboardRepository dengan Stream methods
- Semua StreamProviders di Provider layer
- Dashboard Screen menggunakan real-time streams
- Tax Center Screen menggunakan real-time streams
- Inventory Screen menggunakan real-time streams
- Transaction Screen menggunakan real-time streams

### 🔴 BELUM COMPLETE (5%)

- Offline Support (Local Cache)
- Offline Transaction Queue
- Sync Manager
- Unit Tests untuk Repositories
- Widget Tests untuk Screens

## Glossary

- **Posfelix**: Aplikasi POS (Point of Sale) untuk manajemen keuangan dan pajak
- **Real-Time Sync**: Sinkronisasi data secara real-time menggunakan Supabase WebSocket streams
- **Offline Support**: Kemampuan aplikasi untuk berfungsi tanpa koneksi internet
- **Local Cache**: Penyimpanan data lokal menggunakan Hive untuk akses offline
- **Sync Queue**: Antrian transaksi yang dibuat offline untuk disinkronkan saat online
- **Hive**: Database NoSQL lokal untuk Flutter
- **Supabase**: Backend-as-a-Service yang menyediakan database PostgreSQL dengan real-time capabilities

## Requirements

### Requirement 1

**User Story:** As a kasir, I want to create transactions when offline, so that I can continue serving customers even without internet connection.

#### Acceptance Criteria

1. WHEN the device is offline THEN the Transaction_Screen SHALL allow creating new transactions
2. WHEN a transaction is created offline THEN the system SHALL store the transaction in local queue
3. WHEN the device reconnects THEN the system SHALL automatically sync queued transactions to Supabase
4. WHEN syncing queued transactions THEN the system SHALL process them in chronological order

### Requirement 2

**User Story:** As a kasir, I want to view product list when offline, so that I can see product information without internet.

#### Acceptance Criteria

1. WHEN the device is offline THEN the Inventory_Screen SHALL display cached products
2. WHEN products are fetched from Supabase THEN the system SHALL cache them locally using Hive
3. WHEN the cache is older than 24 hours THEN the system SHALL refresh the cache when online
4. WHEN viewing cached products THEN the system SHALL display a visual indicator showing offline mode

### Requirement 3

**User Story:** As a user, I want to see sync status, so that I know whether my data is up-to-date.

#### Acceptance Criteria

1. WHEN the device is online THEN the Sync_Status_Widget SHALL display "Online" status
2. WHEN the device is offline THEN the Sync_Status_Widget SHALL display "Offline" status
3. WHEN there are pending transactions in queue THEN the Sync_Status_Widget SHALL display queue count
4. WHEN syncing is in progress THEN the Sync_Status_Widget SHALL display "Syncing..." status

### Requirement 4

**User Story:** As a developer, I want a LocalCacheManager, so that data can be stored and retrieved locally.

#### Acceptance Criteria

1. WHEN implementing LocalCacheManager THEN the system SHALL provide cacheProducts() method
2. WHEN implementing LocalCacheManager THEN the system SHALL provide getCachedProducts() method
3. WHEN implementing LocalCacheManager THEN the system SHALL provide cacheTransactions() method
4. WHEN implementing LocalCacheManager THEN the system SHALL provide clearCache() method
5. WHEN caching data THEN the system SHALL store timestamp for cache invalidation

### Requirement 5

**User Story:** As a developer, I want an OfflineSyncManager, so that offline transactions can be synced when online.

#### Acceptance Criteria

1. WHEN implementing OfflineSyncManager THEN the system SHALL provide addToQueue() method
2. WHEN implementing OfflineSyncManager THEN the system SHALL provide processQueue() method
3. WHEN implementing OfflineSyncManager THEN the system SHALL provide getQueueCount() method
4. WHEN processing queue THEN the system SHALL handle errors and retry failed transactions
5. WHEN a transaction fails to sync THEN the system SHALL keep it in queue for retry

### Requirement 6

**User Story:** As a developer, I want unit tests for repositories, so that I can ensure data operations work correctly.

#### Acceptance Criteria

1. WHEN testing ProductRepository THEN the tests SHALL cover getProducts, createProduct, updateProduct, deleteProduct
2. WHEN testing TransactionRepository THEN the tests SHALL cover createTransaction, getTransactions, refundTransaction
3. WHEN testing ExpenseRepository THEN the tests SHALL cover createExpense, getExpenses, deleteExpense
4. WHEN testing TaxRepository THEN the tests SHALL cover calculateTax, markAsPaid, getProfitLossReport

### Requirement 7

**User Story:** As a developer, I want widget tests for screens, so that I can ensure UI components render correctly.

#### Acceptance Criteria

1. WHEN testing Dashboard_Screen THEN the tests SHALL verify profit card, tax indicator, and tier breakdown render correctly
2. WHEN testing Tax_Center_Screen THEN the tests SHALL verify laporan tab and kalkulator tab render correctly
3. WHEN testing Inventory_Screen THEN the tests SHALL verify product list and search functionality work correctly
4. WHEN testing Transaction_Screen THEN the tests SHALL verify cart operations and payment flow work correctly
