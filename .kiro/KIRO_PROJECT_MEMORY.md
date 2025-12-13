# 🧠 KIRO PROJECT MEMORY - POSFELIX

> **PENTING:** File ini adalah dokumentasi lengkap untuk Kiro AI agar dapat mengingat konteks project saat dipindahkan ke direktori lain. Baca file ini terlebih dahulu saat memulai sesi baru.

---

## 📋 PROJECT OVERVIEW

### Identitas Project

- **Nama:** PosFELIX (MotoParts POS)
- **Deskripsi:** Sistem POS terintegrasi untuk toko suku cadang motor dengan modul keuangan & pajak
- **Framework:** Flutter (Dart)
- **Target Platform:** Mobile (Android/iOS), Web, Desktop
- **Status:** Phase 1 - Frontend Implementation (In Progress)

### Tujuan Utama

1. Mengelola inventory dengan ribuan produk dan varian kompleks
2. Transaksi penjualan dengan 3 tier harga (Umum/Bengkel/Grossir)
3. Dashboard financial cockpit real-time untuk owner
4. Expense tracking dan margin management
5. Laporan keuangan & pajak otomatis (PPh Final 0.5%)
6. Offline-first dengan sync real-time

---

## 🏗️ ARSITEKTUR & STRUKTUR

### Clean Architecture Pattern

```
┌─────────────────────────────────────────┐
│           PRESENTATION                   │
│  Screens  │  Widgets  │  Providers      │
├─────────────────────────────────────────┤
│              DOMAIN                      │
│  Entities  │  UseCases  │  Repositories │
├─────────────────────────────────────────┤
│               DATA                       │
│  Models  │  DataSources  │  Impl        │
└─────────────────────────────────────────┘
```

### Folder Structure (Current Implementation)

```
lib/
├── main.dart                    # Entry point dengan ProviderScope
├── injection_container.dart     # GetIt dependency injection
├── config/
│   ├── constants/
│   │   └── app_constants.dart   # API URLs, keys, tax rate, tiers
│   ├── routes/
│   │   ├── app_routes.dart      # Route path definitions
│   │   └── route_generator.dart # GoRouter configuration
│   └── theme/
│       ├── app_colors.dart      # Color palette (#1DB584 primary)
│       ├── app_spacing.dart     # Spacing constants (4-48px)
│       ├── app_typography.dart  # Text styles
│       └── app_theme.dart       # Material 3 ThemeData
├── core/
│   ├── errors/
│   │   ├── exceptions.dart      # Custom exceptions
│   │   └── failures.dart        # Failure classes (Equatable)
│   └── utils/
│       ├── extensions.dart      # String, Int, DateTime extensions
│       ├── logger.dart          # AppLogger with PrettyPrinter
│       └── validators.dart      # Input validation (email, price, etc)
└── presentation/
    ├── pages/
    │   └── splash_screen.dart   # Splash → Login redirect
    ├── screens/
    │   ├── admin/
    │   │   ├── admin_main_screen.dart    # 5-tab navigation
    │   │   ├── dashboard/
    │   │   │   └── dashboard_screen.dart # Financial cockpit
    │   │   ├── expense/
    │   │   │   └── expense_screen.dart   # Expense manager
    │   │   └── tax/
    │   │       └── tax_center_screen.dart # Tax reports & calculator
    │   ├── auth/
    │   │   └── login_screen.dart         # Login with demo credentials
    │   └── kasir/
    │       ├── kasir_main_screen.dart    # 2-tab navigation
    │       ├── inventory/
    │       │   └── inventory_screen.dart # Product management
    │       └── transaction/
    │           └── transaction_screen.dart # POS transaction
    └── widgets/
        └── common/
            ├── app_header.dart           # Header with sync status
            ├── custom_button.dart        # Primary/Secondary variants
            ├── custom_text_field.dart    # Styled text input
            ├── empty_state_widget.dart   # Empty state display
            ├── error_widget.dart         # Error display
            ├── loading_widget.dart       # Loading indicator
            ├── pill_selector.dart        # Horizontal pill buttons
            └── sync_status_widget.dart   # Online/Offline indicator
```

---

## 🎨 DESIGN SYSTEM

### Color Palette

```dart
// Primary
primary: #1DB584 (Teal)
primaryLight: #2DD4A4
primaryDark: #0F9B6F

// Status
success: #10B981 (Green)
warning: #F59E0B (Orange)
error: #EF4444 (Red)
info: #3B82F6 (Blue)

// Neutral
textDark: #1F2937
textGray: #6B7280
textLight: #9CA3AF
background: #FFFFFF
backgroundLight: #FAFAFA
border: #E5E7EB
secondary: #F0F0F0
```

### Spacing System

```dart
xs: 4.0    // Tight spacing
sm: 8.0    // Small gaps
md: 16.0   // Standard padding
lg: 24.0   // Section spacing
xl: 32.0   // Large gaps
xxl: 48.0  // Extra large

// Border Radius
radiusSm: 6.0
radiusMd: 8.0
radiusLg: 12.0
radiusXl: 16.0

// Component Heights
buttonHeight: 48.0
inputHeight: 48.0
appBarHeight: 56.0
bottomNavHeight: 64.0
```

### Typography

```dart
heading1: 28px, Bold
heading2: 24px, Bold
heading3: 20px, SemiBold
bodyLarge: 16px, Medium
bodyRegular: 16px, Normal
bodySmall: 14px, Normal
caption: 12px, Normal
```

---

## 🔐 USER ROLES & ACCESS

### Admin (Owner/Bos)

- **Default Screen:** Dashboard
- **Akses Penuh:**
  - Dashboard (Financial Cockpit)
  - Inventory Management (Full CRUD)
  - Transaction Management (Full CRUD + Refund)
  - Expense Manager
  - Tax Center & Laporan
  - Settings & User Management
  - Diskon & Promo Management

### Kasir (Cashier)

- **Default Screen:** Transaction
- **Akses Terbatas:**
  - Inventory Management (Full CRUD)
  - Transaction Management (Full CRUD + Refund)
  - Diskon Selection (tidak bisa membuat diskon baru)
- **TIDAK BISA AKSES:**
  - Dashboard
  - Expense Manager
  - Tax Center
  - Settings

### Demo Credentials

```
Admin: admin@toko.com / admin123
Kasir: kasir@toko.com / kasir123
```

---

## 📱 SCREENS IMPLEMENTATION STATUS

### ✅ Completed Screens

#### 1. Splash Screen (`splash_screen.dart`)

- Logo dengan animasi loading
- Auto-redirect ke Login setelah 2 detik

#### 2. Login Screen (`login_screen.dart`)

- Email & password input dengan validation
- Remember me checkbox
- Demo credentials display
- Role-based redirect (admin → Dashboard, kasir → Transaction)

#### 3. Kasir Main Screen (`kasir_main_screen.dart`)

- Bottom navigation: Produk | Transaksi
- Default tab: Transaksi (index 1)

#### 4. Transaction Screen (`transaction_screen.dart`)

- **Tier Selector:** Orang Umum / Bengkel / Grossir (PillSelector)
- **Product Search:** Real-time search
- **Product List:** Scrollable dengan Add button
- **Cart Section:**
  - Cart items dengan quantity controls (−/+)
  - Remove button per item
  - Summary: Subtotal, Diskon, Total
- **Payment Method:** Cash / Transfer / QRIS (PillSelector)
- **Notes:** Optional text field
- **Actions:** Batal (secondary) | Selesaikan (primary)
- **Mock Data:** 5 produk dengan 3 tier harga

#### 5. Inventory Screen (`inventory_screen.dart`)

- **Header:** AppHeader dengan sync status
- **Search & Filter:** Search bar + Category dropdown
- **Result Count:** "Hasil: X produk"
- **Product Cards:**
  - Nama produk
  - Kategori | Brand
  - Stok (dengan color indicator)
  - Margin % (color coded: green ≥30%, yellow ≥20%, red <20%)
  - HPP & Harga Jual
  - Edit & Delete buttons
- **FAB:** + Tambah produk
- **Mock Data:** 4 produk

#### 6. Admin Main Screen (`admin_main_screen.dart`)

- Bottom navigation: Dashboard | Produk | Transaksi | Keuangan | Pajak
- 5 tabs dengan icons

#### 7. Dashboard Screen (`dashboard_screen.dart`)

- **Header:** Greeting berdasarkan waktu + Logout button
- **Sync Status:** Online indicator
- **Profit Card:** Gradient teal dengan breakdown (Penjualan, HPP, Pengeluaran)
- **Tax Indicator:** Progress bar tabungan pajak 0.5%
- **Quick Stats:** 4 cards (Transaksi, Rata-rata, Pengeluaran, Margin)
- **Trend Chart:** Custom painter line chart (Omset vs Profit 7 hari)
- **Tier Breakdown:** 3 tier dengan progress bar

#### 8. Expense Screen (`expense_screen.dart`)

- **Total Card:** Total pengeluaran hari ini (red theme)
- **Category Breakdown:** Cards per kategori dengan progress bar
- **Expense List:** Cards dengan icon, amount, time, notes
- **Add Modal:** BottomSheet dengan form (Kategori, Nominal, Catatan)
- **Categories:** Listrik, Gaji, Plastik, Makan Siang, Lainnya

#### 9. Tax Center Screen (`tax_center_screen.dart`)

- **Tab Bar:** Laporan | Kalkulator Pajak
- **Tab Laporan:**
  - Month selector dropdown
  - Profit/Loss card (Omset, HPP, Pengeluaran, Profit Bersih)
  - Tier Breakdown (expandable dengan detail)
  - Export PDF button
- **Tab Kalkulator:**
  - Month selector
  - Omset display
  - Tax calculation (0.5%)
  - Payment status indicator
  - Mark as paid button
  - Payment history list

---

## 🔧 DEPENDENCIES

### pubspec.yaml

```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8

  # State Management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  riverpod_generator: ^2.3.0

  # Dependency Injection
  get_it: ^7.6.0

  # HTTP Client
  dio: ^5.3.0

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # Serialization
  json_serializable: ^6.7.0
  freezed_annotation: ^2.4.1

  # Routing
  go_router: ^13.0.0

  # Internationalization
  intl: ^0.19.0

  # Utilities
  equatable: ^2.0.5
  uuid: ^4.0.0
  logger: ^2.0.0

  # UI
  google_fonts: ^6.1.0
  cached_network_image: ^3.3.0

dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^6.0.0
  build_runner: ^2.4.0
  freezed: ^2.4.1
  hive_generator: ^2.0.0
```

---

## 🛣️ ROUTING

### Route Definitions (`app_routes.dart`)

```dart
// Auth Routes
splash: '/splash'
login: '/login'

// Kasir Routes
kasirMain: '/kasir'
kasirTransaction: '/kasir/transaction'
kasirInventory: '/kasir/inventory'

// Admin Routes
adminMain: '/admin'
adminDashboard: '/admin/dashboard'
adminInventory: '/admin/inventory'
adminTransaction: '/admin/transaction'
adminExpense: '/admin/expense'
adminTaxCenter: '/admin/tax-center'
adminSettings: '/admin/settings'
```

### GoRouter Configuration (`route_generator.dart`)

- Initial location: `/splash`
- Debug logging enabled
- Error page untuk route tidak ditemukan

---

## 📊 BUSINESS LOGIC

### Buyer Tiers

```dart
tierUmum: 'UMUM'      // Harga tertinggi (retail)
tierBengkel: 'BENGKEL' // Harga menengah (reseller)
tierGrossir: 'GROSSIR' // Harga terendah (wholesale)
```

### Payment Methods

```dart
paymentCash: 'CASH'
paymentTransfer: 'TRANSFER'
paymentQris: 'QRIS'
```

### Expense Categories

```dart
expenseListrik: 'LISTRIK'
expenseGaji: 'GAJI'
expensePlastik: 'PLASTIK'
expenseMakanSiang: 'MAKAN_SIANG'
expenseLainnya: 'LAINNYA'
```

### Tax Configuration

```dart
taxPercentage: 0.005  // 0.5% PPh Final dari omset bruto
```

### Profit Calculation

```
Laba Bersih = Total Penjualan - Total HPP - Total Pengeluaran
```

---

## 🔄 IMPLEMENTATION PHASES

### Phase 1: Foundation & Setup ✅ COMPLETE

- [x] Project setup & dependencies
- [x] Theme & design system
- [x] Routing setup (GoRouter)
- [x] Dependency injection (GetIt)
- [x] Base widgets & utilities
- [x] Authentication flow (UI only)

### Phase 2: Core Features - Kasir ✅ COMPLETE

- [x] Inventory screen (UI with mock data)
- [x] Transaction screen (UI with mock data)
- [x] Kasir main screen with navigation

### Phase 3: Core Features - Admin ✅ COMPLETE

- [x] Dashboard screen (UI with mock data)
- [x] Expense manager screen (UI with mock data)
- [x] Tax center screen (UI with mock data)
- [x] Admin main screen with navigation

### Phase 4: Backend Integration 🔜 NEXT

- [ ] Supabase setup
- [ ] Data models with Freezed
- [ ] Repository implementations
- [ ] Real API integration
- [ ] Offline sync with Hive

### Phase 5: Polish & Testing 📋 PLANNED

- [ ] Error handling
- [ ] Loading states
- [ ] Unit tests
- [ ] Widget tests
- [ ] Performance optimization

---

## 📁 DOCUMENTATION LOCATIONS

### Specs (Detailed Requirements)

```
.kiro/specs/pos-keuangan-pajak/
├── requirements.md          # 11 requirements dengan acceptance criteria
├── design.md               # Architecture, data models, properties
├── implementation-plan-kasir.md  # Task breakdown dengan estimasi
├── project-structure.md    # Folder structure & patterns
├── layout-analysis.md      # UI mockup analysis
├── ui-ux-prompt.md         # Responsive design guidelines
└── SETUP_COMPLETE.md       # Setup checklist
```

### Developer Docs

```
docs/developer/
├── architecture.md         # Clean architecture explanation
├── setup-guide.md          # Installation & build commands
├── components.md           # Widget documentation
└── api-integration.md      # Planned API endpoints
```

### Client & Stakeholder Docs

```
docs/client/
└── fitur-aplikasi.md       # Feature list untuk client

docs/stakeholder/
├── business-requirements.md # Business needs
└── project-scope.md        # In/out of scope
```

---

## ⚠️ KNOWN ISSUES & NOTES

### Current Limitations

1. **Mock Data Only** - Semua data masih hardcoded, belum ada backend
2. **No Persistence** - Data hilang saat app restart
3. **No Real Auth** - Login hanya redirect berdasarkan email
4. **No Offline Support** - Belum ada local caching

### Code Quality Notes

- Beberapa widget menggunakan `Key? key` yang bisa diubah ke super parameter
- `withOpacity` deprecated, gunakan `withValues(alpha: x)`
- Duplicate dependency di pubspec.yaml (json_serializable, riverpod_generator)

### UI/UX Notes

- Semua screen sudah responsive untuk mobile
- Bottom navigation menggunakan custom implementation (bukan BottomNavigationBar)
- Chart di dashboard menggunakan CustomPainter (bukan fl_chart)

---

## 🚀 QUICK START COMMANDS

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk --release

# Generate code (freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes
flutter pub run build_runner watch
```

---

## 📝 UNTUK KIRO: CARA MELANJUTKAN

Saat memulai sesi baru setelah project dipindahkan:

1. **Baca file ini terlebih dahulu** untuk memahami konteks
2. **Cek status implementation** di section "IMPLEMENTATION PHASES"
3. **Lihat specs** di `.kiro/specs/pos-keuangan-pajak/` untuk detail requirements
4. **Lihat docs** di `docs/` untuk dokumentasi teknis

### Next Steps yang Disarankan:

1. Setup Supabase backend
2. Implementasi data models dengan Freezed
3. Buat repository pattern untuk data access
4. Integrasi API ke screens yang sudah ada
5. Implementasi offline caching dengan Hive

---

_Last Updated: December 14, 2025_
_Created by: Kiro AI Assistant_
