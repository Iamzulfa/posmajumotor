# 📊 KIRO DATA MODELS - POSFELIX

> **File ini berisi referensi data models dan business logic yang direncanakan untuk backend integration.**

---

## 🗄️ DATABASE SCHEMA (Planned - Supabase)

### Products Table

```sql
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100) NOT NULL,
  sub_category VARCHAR(100),
  brand VARCHAR(100),
  stock INTEGER DEFAULT 0,
  hpp INTEGER NOT NULL,
  price_umum INTEGER NOT NULL,
  price_bengkel INTEGER NOT NULL,
  price_grossir INTEGER NOT NULL,
  margin_umum DECIMAL(5,2) GENERATED ALWAYS AS
    (CASE WHEN hpp > 0 THEN ((price_umum - hpp)::DECIMAL / hpp * 100) ELSE 0 END) STORED,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Transactions Table

```sql
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  transaction_number VARCHAR(50) UNIQUE NOT NULL,
  tier VARCHAR(20) NOT NULL CHECK (tier IN ('UMUM', 'BENGKEL', 'GROSSIR')),
  payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('CASH', 'TRANSFER', 'QRIS')),
  subtotal INTEGER NOT NULL,
  discount_id UUID REFERENCES discounts(id),
  discount_amount INTEGER DEFAULT 0,
  total INTEGER NOT NULL,
  notes TEXT,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Transaction Items Table

```sql
CREATE TABLE transaction_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  transaction_id UUID REFERENCES transactions(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  product_name VARCHAR(255) NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price INTEGER NOT NULL,
  subtotal INTEGER NOT NULL,
  hpp_at_time INTEGER NOT NULL
);
```

### Expenses Table

```sql
CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category VARCHAR(50) NOT NULL CHECK (category IN ('LISTRIK', 'GAJI', 'PLASTIK', 'MAKAN_SIANG', 'LAINNYA')),
  amount INTEGER NOT NULL,
  notes TEXT,
  expense_date DATE DEFAULT CURRENT_DATE,
  expense_time TIME DEFAULT CURRENT_TIME,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Users Table

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('ADMIN', 'KASIR')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Discounts Table

```sql
CREATE TABLE discounts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  type VARCHAR(20) NOT NULL CHECK (type IN ('PERCENTAGE', 'NOMINAL')),
  value DECIMAL(10,2) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Tax Payments Table

```sql
CREATE TABLE tax_payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INTEGER NOT NULL,
  total_omset INTEGER NOT NULL,
  tax_amount INTEGER NOT NULL,
  is_paid BOOLEAN DEFAULT false,
  paid_date DATE,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(month, year)
);
```

### Refunds Table

```sql
CREATE TABLE refunds (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  transaction_id UUID REFERENCES transactions(id),
  category VARCHAR(50) NOT NULL CHECK (category IN ('RUSAK', 'TIDAK_SESUAI', 'TIDAK_DIPERLUKAN')),
  reason TEXT NOT NULL,
  total_refund INTEGER NOT NULL,
  refund_method VARCHAR(20) NOT NULL CHECK (refund_method IN ('CASH', 'TRANSFER', 'QRIS')),
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Refund Items Table

```sql
CREATE TABLE refund_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  refund_id UUID REFERENCES refunds(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  quantity INTEGER NOT NULL,
  refund_amount INTEGER NOT NULL
);
```

---

## 🔷 DART ENTITIES (Domain Layer)

### Product Entity

```dart
class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final String? subCategory;
  final String? brand;
  final int stock;
  final int hpp;
  final int priceUmum;
  final int priceBengkel;
  final int priceGrossir;
  final double marginUmum;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.category,
    this.subCategory,
    this.brand,
    required this.stock,
    required this.hpp,
    required this.priceUmum,
    required this.priceBengkel,
    required this.priceGrossir,
    required this.marginUmum,
    required this.createdAt,
    required this.updatedAt,
  });

  int getPriceByTier(String tier) {
    switch (tier) {
      case 'BENGKEL': return priceBengkel;
      case 'GROSSIR': return priceGrossir;
      default: return priceUmum;
    }
  }

  @override
  List<Object?> get props => [id, name, category, stock, hpp, priceUmum];
}
```

### Transaction Entity

```dart
class TransactionEntity extends Equatable {
  final String id;
  final String transactionNumber;
  final String tier;
  final String paymentMethod;
  final List<TransactionItemEntity> items;
  final int subtotal;
  final String? discountId;
  final int discountAmount;
  final int total;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.transactionNumber,
    required this.tier,
    required this.paymentMethod,
    required this.items,
    required this.subtotal,
    this.discountId,
    required this.discountAmount,
    required this.total,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  int get totalHpp => items.fold(0, (sum, item) => sum + (item.hppAtTime * item.quantity));
  int get profit => total - totalHpp;

  @override
  List<Object?> get props => [id, transactionNumber, tier, total];
}
```

### Transaction Item Entity

```dart
class TransactionItemEntity extends Equatable {
  final String id;
  final String transactionId;
  final String productId;
  final String productName;
  final int quantity;
  final int unitPrice;
  final int subtotal;
  final int hppAtTime;

  const TransactionItemEntity({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.hppAtTime,
  });

  @override
  List<Object?> get props => [id, productId, quantity, subtotal];
}
```

### Cart Item Entity

```dart
class CartItemEntity extends Equatable {
  final ProductEntity product;
  final int quantity;
  final int unitPrice;

  const CartItemEntity({
    required this.product,
    required this.quantity,
    required this.unitPrice,
  });

  int get subtotal => unitPrice * quantity;
  int get hppSubtotal => product.hpp * quantity;

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      product: product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
    );
  }

  @override
  List<Object?> get props => [product.id, quantity, unitPrice];
}
```

### Expense Entity

```dart
class ExpenseEntity extends Equatable {
  final String id;
  final String category;
  final int amount;
  final String? notes;
  final DateTime expenseDate;
  final TimeOfDay expenseTime;
  final String createdBy;
  final DateTime createdAt;

  const ExpenseEntity({
    required this.id,
    required this.category,
    required this.amount,
    this.notes,
    required this.expenseDate,
    required this.expenseTime,
    required this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, category, amount, expenseDate];
}
```

### User Entity

```dart
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  bool get isAdmin => role == 'ADMIN';
  bool get isKasir => role == 'KASIR';

  @override
  List<Object?> get props => [id, email, role];
}
```

---

## 📦 DART MODELS (Data Layer - with Freezed)

### Product Model

```dart
@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String category,
    String? subCategory,
    String? brand,
    required int stock,
    required int hpp,
    required int priceUmum,
    required int priceBengkel,
    required int priceGrossir,
    required double marginUmum,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);
}
```

### Transaction Model

```dart
@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    required String transactionNumber,
    required String tier,
    required String paymentMethod,
    required List<TransactionItemModel> items,
    required int subtotal,
    String? discountId,
    required int discountAmount,
    required int total,
    String? notes,
    required String createdBy,
    required DateTime createdAt,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) => _$TransactionModelFromJson(json);
}
```

---

## 🔄 REPOSITORY INTERFACES (Domain Layer)

### Product Repository

```dart
abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts();
  Future<Either<Failure, ProductEntity>> getProductById(String id);
  Future<Either<Failure, List<ProductEntity>>> searchProducts(String query);
  Future<Either<Failure, void>> createProduct(ProductEntity product);
  Future<Either<Failure, void>> updateProduct(ProductEntity product);
  Future<Either<Failure, void>> deleteProduct(String id);
  Future<Either<Failure, void>> updateStock(String id, int newStock);
}
```

### Transaction Repository

```dart
abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({DateTime? date});
  Future<Either<Failure, TransactionEntity>> getTransactionById(String id);
  Future<Either<Failure, TransactionEntity>> createTransaction(TransactionEntity transaction);
  Future<Either<Failure, DailySummary>> getDailySummary(DateTime date);
  Future<Either<Failure, TierBreakdown>> getTierBreakdown(DateTime date);
}
```

### Expense Repository

```dart
abstract class ExpenseRepository {
  Future<Either<Failure, List<ExpenseEntity>>> getExpenses({DateTime? date});
  Future<Either<Failure, ExpenseEntity>> createExpense(ExpenseEntity expense);
  Future<Either<Failure, void>> updateExpense(ExpenseEntity expense);
  Future<Either<Failure, void>> deleteExpense(String id);
  Future<Either<Failure, int>> getDailyTotal(DateTime date);
  Future<Either<Failure, Map<String, int>>> getCategoryBreakdown(DateTime date);
}
```

### Auth Repository

```dart
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, bool>> isLoggedIn();
}
```

---

## 📈 BUSINESS LOGIC CALCULATIONS

### Profit Calculation

```dart
class ProfitCalculator {
  /// Laba Bersih = Total Penjualan - Total HPP - Total Pengeluaran
  static int calculateDailyProfit({
    required int totalSales,
    required int totalHpp,
    required int totalExpenses,
  }) {
    return totalSales - totalHpp - totalExpenses;
  }

  /// Margin = (Harga Jual - HPP) / HPP * 100
  static double calculateMargin(int sellingPrice, int hpp) {
    if (hpp <= 0) return 0;
    return ((sellingPrice - hpp) / hpp) * 100;
  }

  /// Profit per Transaction = Total - HPP Items
  static int calculateTransactionProfit(TransactionEntity transaction) {
    return transaction.total - transaction.totalHpp;
  }
}
```

### Tax Calculation

```dart
class TaxCalculator {
  static const double taxRate = 0.005; // 0.5% PPh Final

  /// Estimasi Pajak = Total Omset * 0.5%
  static int calculateMonthlyTax(int totalOmset) {
    return (totalOmset * taxRate).round();
  }

  /// Progress Tabungan Pajak
  static double calculateTaxProgress(int currentSaved, int targetTax) {
    if (targetTax <= 0) return 0;
    return (currentSaved / targetTax).clamp(0.0, 1.0);
  }
}
```

### Cart Calculation

```dart
class CartCalculator {
  static int calculateSubtotal(List<CartItemEntity> items) {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  static int calculateDiscount(int subtotal, DiscountEntity? discount) {
    if (discount == null) return 0;
    if (discount.type == 'PERCENTAGE') {
      return (subtotal * discount.value / 100).round();
    }
    return discount.value.toInt();
  }

  static int calculateTotal(int subtotal, int discount) {
    return subtotal - discount;
  }

  static int calculateTotalHpp(List<CartItemEntity> items) {
    return items.fold(0, (sum, item) => sum + item.hppSubtotal);
  }
}
```

---

## 📊 REPORT DATA STRUCTURES

### Daily Summary

```dart
class DailySummary {
  final DateTime date;
  final int totalOmset;
  final int totalHpp;
  final int totalExpenses;
  final int profit;
  final int transactionCount;
  final double averageTransaction;
  final double margin;

  DailySummary({
    required this.date,
    required this.totalOmset,
    required this.totalHpp,
    required this.totalExpenses,
    required this.transactionCount,
  }) : profit = totalOmset - totalHpp - totalExpenses,
       averageTransaction = transactionCount > 0 ? totalOmset / transactionCount : 0,
       margin = totalOmset > 0 ? ((totalOmset - totalHpp) / totalOmset * 100) : 0;
}
```

### Tier Breakdown

```dart
class TierBreakdown {
  final TierData umum;
  final TierData bengkel;
  final TierData grossir;

  TierBreakdown({
    required this.umum,
    required this.bengkel,
    required this.grossir,
  });

  int get totalOmset => umum.omset + bengkel.omset + grossir.omset;
}

class TierData {
  final String tier;
  final int omset;
  final int hpp;
  final int profit;
  final int transactionCount;
  final double margin;
  final double percentage;

  TierData({
    required this.tier,
    required this.omset,
    required this.hpp,
    required this.transactionCount,
    required this.totalOmset,
  }) : profit = omset - hpp,
       margin = omset > 0 ? ((omset - hpp) / omset * 100) : 0,
       percentage = totalOmset > 0 ? (omset / totalOmset) : 0;
}
```

### Monthly Report

```dart
class MonthlyReport {
  final int month;
  final int year;
  final int totalOmset;
  final int totalHpp;
  final int totalExpenses;
  final int profit;
  final int estimatedTax;
  final TierBreakdown tierBreakdown;
  final List<DailySummary> dailySummaries;

  MonthlyReport({
    required this.month,
    required this.year,
    required this.totalOmset,
    required this.totalHpp,
    required this.totalExpenses,
    required this.tierBreakdown,
    required this.dailySummaries,
  }) : profit = totalOmset - totalHpp - totalExpenses,
       estimatedTax = TaxCalculator.calculateMonthlyTax(totalOmset);
}
```

---

## 🔌 API ENDPOINTS (Planned)

### Authentication

```
POST /auth/login
  Body: { email, password }
  Response: { user, token }

POST /auth/logout
  Headers: Authorization: Bearer <token>

GET /auth/me
  Headers: Authorization: Bearer <token>
  Response: { user }
```

### Products

```
GET /products
  Query: ?search=&category=&page=&limit=
  Response: { data: [], total, page, limit }

GET /products/:id
  Response: { product }

POST /products
  Body: { name, category, brand, stock, hpp, priceUmum, priceBengkel, priceGrossir }
  Response: { product }

PUT /products/:id
  Body: { ...fields }
  Response: { product }

DELETE /products/:id
  Response: { success }

PATCH /products/:id/stock
  Body: { stock, reason }
  Response: { product }
```

### Transactions

```
GET /transactions
  Query: ?date=&tier=&page=&limit=
  Response: { data: [], total }

GET /transactions/:id
  Response: { transaction }

POST /transactions
  Body: { tier, paymentMethod, items, discountId, notes }
  Response: { transaction }

GET /transactions/daily-summary
  Query: ?date=
  Response: { summary }

GET /transactions/tier-breakdown
  Query: ?date=
  Response: { breakdown }
```

### Expenses

```
GET /expenses
  Query: ?date=&category=&page=&limit=
  Response: { data: [], total }

POST /expenses
  Body: { category, amount, notes }
  Response: { expense }

PUT /expenses/:id
  Body: { ...fields }
  Response: { expense }

DELETE /expenses/:id
  Response: { success }

GET /expenses/daily-summary
  Query: ?date=
  Response: { total, breakdown }
```

### Reports

```
GET /reports/profit-loss
  Query: ?month=&year=
  Response: { report }

GET /reports/tax-calculation
  Query: ?month=&year=
  Response: { omset, tax, isPaid }

POST /reports/mark-tax-paid
  Body: { month, year }
  Response: { success }

GET /reports/export-pdf
  Query: ?month=&year=
  Response: { pdfUrl }
```

---

## 💾 LOCAL STORAGE (Hive)

### Boxes

```dart
// Product cache
@HiveType(typeId: 0)
class ProductHiveModel extends HiveObject { ... }

// Pending transactions (offline)
@HiveType(typeId: 1)
class PendingTransactionHiveModel extends HiveObject { ... }

// Pending expenses (offline)
@HiveType(typeId: 2)
class PendingExpenseHiveModel extends HiveObject { ... }

// User session
@HiveType(typeId: 3)
class UserSessionHiveModel extends HiveObject { ... }
```

### Box Names

```dart
class HiveBoxes {
  static const String products = 'products_box';
  static const String pendingTransactions = 'pending_transactions_box';
  static const String pendingExpenses = 'pending_expenses_box';
  static const String userSession = 'user_session_box';
  static const String settings = 'settings_box';
}
```

---

## 🔄 SYNC STRATEGY

### Offline Queue

```dart
class SyncQueue {
  final List<SyncItem> items;

  Future<void> addTransaction(TransactionEntity transaction);
  Future<void> addExpense(ExpenseEntity expense);
  Future<void> processQueue();
  Future<void> clearQueue();
}

class SyncItem {
  final String id;
  final String type; // 'transaction', 'expense'
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;
}
```

### Conflict Resolution

```
1. Server timestamp wins (last write wins)
2. If same timestamp, server data wins
3. Log conflicts for manual review
```

---

_Last Updated: December 14, 2025_
