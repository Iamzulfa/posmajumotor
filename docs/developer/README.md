# Developer Documentation - MotoParts POS

## Overview

Aplikasi POS (Point of Sale) untuk toko suku cadang motor dengan fitur manajemen keuangan dan perpajakan.

## Tech Stack

| Layer                | Technology        |
| -------------------- | ----------------- |
| Frontend             | Flutter 3.x       |
| State Management     | Riverpod          |
| Routing              | GoRouter          |
| Local Storage        | Hive              |
| Backend (planned)    | Supabase          |
| Automation (planned) | n8n (self-hosted) |

## Project Structure

```
lib/
├── config/
│   ├── constants/      # App constants
│   ├── routes/         # GoRouter configuration
│   └── theme/          # Colors, typography, spacing
├── core/
│   ├── errors/         # Exception & failure classes
│   └── utils/          # Validators, extensions, logger
├── presentation/
│   ├── screens/
│   │   ├── admin/      # Admin-only screens
│   │   │   ├── dashboard/
│   │   │   ├── expense/
│   │   │   └── tax/
│   │   ├── auth/       # Login screen
│   │   └── kasir/      # Kasir & shared screens
│   │       ├── inventory/
│   │       └── transaction/
│   └── widgets/
│       └── common/     # Reusable widgets
├── injection_container.dart
└── main.dart
```

## Prerequisites

- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / VS Code
- Android SDK (for Android build)
- Xcode (for iOS build, macOS only)

## Setup

```bash
# Clone repository
git clone <repo-url>
cd posfelix

# Install dependencies
flutter pub get

# Run app
flutter run
```

## Architecture

Clean Architecture dengan separation of concerns:

```
Presentation → Domain → Data
     ↓           ↓        ↓
  Widgets    UseCases  Repositories
  Screens    Entities  DataSources
```

## Key Features Implementation

### 1. Role-Based Access

| Feature     | Admin   | Kasir   |
| ----------- | ------- | ------- |
| Dashboard   | ✅      | ❌      |
| Inventory   | ✅ CRUD | ✅ CRUD |
| Transaction | ✅      | ✅      |
| Expense     | ✅      | ❌      |
| Tax Center  | ✅      | ❌      |

### 2. Multi-Tier Pricing

```dart
// Tier enum
enum BuyerTier { UMUM, BENGKEL, GROSSIR }

// Price calculation
int getPrice(Product product, BuyerTier tier) {
  switch (tier) {
    case BuyerTier.UMUM: return product.priceUmum;
    case BuyerTier.BENGKEL: return product.priceBengkel;
    case BuyerTier.GROSSIR: return product.priceGrossir;
  }
}
```

### 3. Tax Calculation

```dart
// PPh Final 0.5% dari omset
int calculateTax(int omset) => (omset * 0.005).toInt();
```

## Theme System

### Colors

- Primary: `#1DB584` (Teal)
- Error: `#EF4444`
- Success: `#10B981`
- Warning: `#F59E0B`

### Spacing

- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px

## Demo Credentials

| Role  | Email          | Password |
| ----- | -------------- | -------- |
| Admin | admin@toko.com | admin123 |
| Kasir | kasir@toko.com | kasir123 |

## Next Steps (Backend Integration)

1. Setup Supabase project
2. Create database schema
3. Implement repository pattern
4. Connect screens to real data
5. Setup n8n for PDF generation & notifications
