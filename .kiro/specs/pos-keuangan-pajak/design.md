# Design Document: POS + Modul Keuangan & Pajak

## Overview

Sistem POS terintegrasi dibangun dengan arsitektur client-server menggunakan Flutter untuk frontend (mobile/web) dan Supabase (PostgreSQL) untuk backend. Sistem mendukung offline-first dengan local SQLite cache yang sync otomatis ke server saat online. Fitur utama mencakup manajemen inventory kompleks, transaksi multi-tier pricing, tracking keuangan real-time, dan integrasi n8n untuk automation laporan pajak.

**Key Features:**

- Inventory management dengan ribuan produk dan varian kompleks
- Transaksi penjualan dengan 3 tier harga (Umum/Bengkel/Grossir)
- Dashboard financial cockpit real-time
- Expense tracking dan margin management
- Laporan keuangan & pajak otomatis
- Integrasi n8n untuk PDF generation dan notifikasi
- Offline-first dengan sync real-time

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App (Mobile/Web)                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  UI Layer (Dashboard, Transaksi, Inventory, Laporan) │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Business Logic Layer (Kalkulasi, Validasi, Sync)    │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Local SQLite Cache (Offline Support)                │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↕ REST API
┌─────────────────────────────────────────────────────────────┐
│                  Supabase (PostgreSQL)                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Database (Products, Transactions, Expenses, etc)    │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Authentication & Authorization                      │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↕ Webhook
┌─────────────────────────────────────────────────────────────┐
│                    n8n (Self-Hosted)                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  PDF Generation, Notifications, Automation           │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Transaksi Penjualan:**

   - Cashier input transaksi di Flutter app
   - Data disimpan ke local SQLite (offline)
   - Saat online, sync ke Supabase via REST API
   - Stok produk otomatis berkurang
   - Dashboard update real-time

2. **Laporan Pajak:**

   - Admin klik "Export PDF"
   - Flutter app kirim data ke n8n via webhook
   - n8n generate PDF dan kirim notifikasi
   - Admin download PDF dari link yang dikirim

3. **Offline Sync:**
   - Saat offline, semua transaksi disimpan ke SQLite lokal
   - Saat online, app detect koneksi dan mulai sync
   - Gunakan timestamp untuk resolve konflik
   - Update UI setelah sync berhasil

---

## Role-Based Access Control

### Admin Role

- Dashboard (Financial Cockpit)
- Inventory Management (Full CRUD)
- Transaction Management (Full CRUD + Refund)
- Expense Manager
- Tax Center & Laporan
- Refund Management
- Settings & User Management
- Diskon & Promo Management

### Cashier Role

- Inventory Management (Full CRUD)
- Transaction Management (Full CRUD + Refund)
- Diskon Selection (tidak bisa membuat diskon baru)

### Access Restrictions

- Cashier CANNOT access: Dashboard, Expense Manager, Tax Center, Settings, User Management
- Admin CAN access all features

---

## Components and Interfaces

### Frontend Components (Flutter)

#### 1. Dashboard Screen (Admin Only)

- Real-time Profit Widget
- Pajak Berjalan Indicator
- Trend Grafik (7 hari)
- Breakdown per Buyer Tier
- Total Transaksi & Rata-rata

#### 2. Inventory Management Screen (Admin & Cashier)

- Daftar produk dengan kategori/sub-kategori
- Search & filter
- Add/Edit/Delete produk
- Stock opname manual
- HPP & margin management

#### 3. Transaction Screen

- Form transaksi penjualan
- Buyer tier selection
- Product selection & quantity
- Diskon selection
- Payment method selection
- Transaction history

#### 4. Expense Manager Screen

- Quick add expense
- Kategori expense
- Expense history
- Daily total & breakdown

#### 5. Tax Center Screen

- Laporan Laba Rugi
- Export PDF button
- PPh Final calculator
- Payment tracking

#### 6. Refund Management Screen

- Refund form
- Kategori & alasan refund
- Refund history

#### 7. Settings Screen

- User management (Admin/Cashier)
- Diskon management
- Promo management
- Sync status

### Backend API Endpoints (Supabase REST API)

```
POST   /products              - Create product
GET    /products              - Get all products
GET    /products/:id          - Get product detail
PUT    /products/:id          - Update product
DELETE /products/:id          - Delete product

POST   /transactions          - Create transaction
GET    /transactions          - Get all transactions
GET    /transactions/:id      - Get transaction detail
PUT    /transactions/:id      - Update transaction (refund)

POST   /expenses              - Create expense
GET    /expenses              - Get all expenses
GET    /expenses/daily        - Get daily expenses

POST   /discounts             - Create discount
GET    /discounts             - Get all discounts

GET    /reports/daily         - Get daily report
GET    /reports/monthly       - Get monthly report
GET    /reports/profit        - Get profit calculation

POST   /sync/transactions     - Sync offline transactions
POST   /sync/expenses         - Sync offline expenses
```

### n8n Webhook Endpoints

```
POST   /webhook/export-pdf    - Trigger PDF generation
POST   /webhook/notify-tax    - Send tax reminder notification
```

---

## Data Models

### Product

```
{
  id: UUID,
  name: String,
  category: String (oli, gearset, rantai, dll),
  sub_category: String (imitasi, orisinil_yamaha, orisinil_honda),
  brand: String,
  variants: [
    {
      id: UUID,
      size: String (90/90, 80/90, ring 14, dll),
      color: String,
      hpp: Decimal (harga beli),
      price_umum: Decimal,
      price_bengkel: Decimal,
      price_grossir: Decimal,
      stock: Integer,
      created_at: Timestamp,
      updated_at: Timestamp
    }
  ],
  created_at: Timestamp,
  updated_at: Timestamp
}
```

### Transaction

```
{
  id: UUID,
  transaction_date: Date,
  transaction_time: Time (HH:MM:SS),
  buyer_tier: Enum (UMUM, BENGKEL, GROSSIR),
  items: [
    {
      product_variant_id: UUID,
      quantity: Integer,
      unit_price: Decimal,
      subtotal: Decimal
    }
  ],
  discount_id: UUID (nullable),
  discount_amount: Decimal,
  total_before_discount: Decimal,
  total_after_discount: Decimal,
  payment_method: Enum (CASH, TRANSFER, QRIS),
  payment_status: Enum (PENDING, COMPLETED, FAILED),
  notes: String (nullable),
  created_by: UUID (cashier/admin),
  created_at: Timestamp,
  updated_at: Timestamp
}
```

### Expense

```
{
  id: UUID,
  expense_date: Date,
  expense_time: Time (HH:MM:SS),
  category: Enum (LISTRIK, GAJI, PLASTIK, MAKAN_SIANG, LAINNYA),
  amount: Decimal,
  notes: String,
  created_by: UUID,
  created_at: Timestamp,
  updated_at: Timestamp
}
```

### Discount

```
{
  id: UUID,
  name: String,
  type: Enum (PERCENTAGE, NOMINAL),
  value: Decimal,
  start_date: Date,
  end_date: Date,
  created_by: UUID,
  created_at: Timestamp,
  updated_at: Timestamp
}
```

### Refund

```
{
  id: UUID,
  transaction_id: UUID,
  refund_date: Date,
  refund_time: Time (HH:MM:SS),
  category: Enum (RUSAK, TIDAK_SESUAI, TIDAK_DIPERLUKAN),
  reason: String,
  items: [
    {
      product_variant_id: UUID,
      quantity: Integer,
      refund_amount: Decimal
    }
  ],
  total_refund: Decimal,
  refund_method: Enum (CASH, TRANSFER, QRIS),
  created_by: UUID,
  created_at: Timestamp,
  updated_at: Timestamp
}
```

### User

```
{
  id: UUID,
  email: String,
  name: String,
  role: Enum (ADMIN, CASHIER),
  store_id: UUID,
  created_at: Timestamp,
  updated_at: Timestamp
}
```

---

## Correctness Properties

A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.

### Property 1: Stock Consistency After Transaction

_For any_ product variant and transaction, when a transaction is completed, the product stock should decrease by the quantity sold.

**Validates: Requirements 1.4**

### Property 2: Profit Calculation Accuracy

_For any_ transaction, the profit calculation should equal: (Total Penjualan) - (Total HPP Terjual) - (Pengeluaran Hari Ini).

**Validates: Requirements 4.1**

### Property 3: Margin Validation

_For any_ product variant, if the selling price is less than HPP, the system should reject the transaction and display a "RUGI!" alert.

**Validates: Requirements 5.4**

### Property 4: Buyer Tier Pricing Consistency

_For any_ transaction, the price applied should match the selected buyer tier (Umum ≥ Bengkel ≥ Grossir).

**Validates: Requirements 2.2**

### Property 5: Discount Application Correctness

_For any_ transaction with a discount, the final amount should equal: (Total Before Discount) - (Discount Amount).

**Validates: Requirements 2.3**

### Property 6: Refund Stock Restoration

_For any_ refund transaction, the product stock should increase by the quantity refunded.

**Validates: Requirements 7.4**

### Property 7: Expense Tracking Completeness

_For any_ expense entry, the system should record: category, amount, timestamp (HH:MM:SS), and notes without loss of data.

**Validates: Requirements 3.2, 3.3**

### Property 8: Tax Calculation Accuracy

_For any_ month, the estimated tax should equal 0.5% of total omset for that month.

**Validates: Requirements 6.6**

### Property 9: Real-time Dashboard Update

_For any_ new transaction or expense, the dashboard should reflect the changes within 5 seconds or immediately upon sync.

**Validates: Requirements 4.6**

### Property 10: Offline Sync Idempotency

_For any_ offline transaction, syncing multiple times should result in the same final state (no duplicate transactions).

**Validates: Requirements 10.2**

### Property 11: Access Control Enforcement

_For any_ cashier user, attempting to access admin-only features should be rejected and not display the feature.

**Validates: Requirements 8.3**

### Property 12: Timestamp Accuracy

_For any_ transaction or expense, the recorded timestamp should match the actual time of creation with accuracy within 1 second.

**Validates: Requirements 2.4, 3.3, 11.1**

---

## Error Handling

### Transaction Errors

- **Insufficient Stock**: Tampilkan error "Stok tidak cukup" dan cegah transaksi
- **Invalid Payment**: Tampilkan error "Metode pembayaran tidak valid"
- **Negative Amount**: Tampilkan error "Jumlah tidak boleh negatif"
- **Margin Violation**: Tampilkan alert "RUGI!" dan cegah penyimpanan

### Sync Errors

- **Network Timeout**: Tampilkan "Koneksi timeout, data disimpan lokal"
- **Conflict Resolution**: Gunakan timestamp untuk menentukan data mana yang lebih baru
- **Sync Failure**: Retry otomatis setiap 30 detik, tampilkan status di UI

### Authentication Errors

- **Invalid Credentials**: Tampilkan "Email atau password salah"
- **Unauthorized Access**: Tampilkan "Akses ditolak untuk role ini"
- **Session Expired**: Redirect ke login page

### Data Validation Errors

- **Missing Required Fields**: Tampilkan "Field [nama] harus diisi"
- **Invalid Format**: Tampilkan "Format [field] tidak valid"
- **Duplicate Entry**: Tampilkan "Data sudah ada di sistem"

---

## Testing Strategy

### Unit Testing

- Test kalkulasi profit, margin, dan pajak
- Test validasi input (harga, stok, diskon)
- Test access control logic
- Test offline sync logic
- Test timestamp handling

### Property-Based Testing

- **Property 1**: Stock consistency - generate random transactions dan verify stok berkurang
- **Property 2**: Profit calculation - generate random transaksi dengan berbagai expense dan verify rumus
- **Property 3**: Margin validation - generate produk dengan HPP berbeda dan verify alert
- **Property 4**: Buyer tier pricing - generate transaksi dengan tier berbeda dan verify harga
- **Property 5**: Discount application - generate transaksi dengan diskon berbeda dan verify total
- **Property 6**: Refund stock restoration - generate refund dan verify stok bertambah
- **Property 7**: Expense tracking - generate expense dengan kategori berbeda dan verify data tersimpan
- **Property 8**: Tax calculation - generate transaksi bulanan dan verify pajak 0.5%
- **Property 9**: Real-time update - generate transaksi dan verify dashboard update dalam 5 detik
- **Property 10**: Offline sync idempotency - sync transaksi offline multiple times dan verify no duplicates
- **Property 11**: Access control - generate request dari cashier ke admin feature dan verify rejected
- **Property 12**: Timestamp accuracy - generate transaksi dan verify timestamp akurat

### Integration Testing

- Test end-to-end transaksi dari input hingga laporan
- Test offline-to-online sync flow
- Test n8n webhook integration
- Test multi-user concurrent transactions

### Testing Framework

- **Unit & Integration Tests**: Dart `test` package
- **Property-Based Tests**: Dart `test` package dengan custom generators
- **Minimum Iterations**: 100 iterations per property test
