# API Integration Guide (Planned)

## Overview

Backend akan menggunakan Supabase dengan REST API.

## Database Schema (Planned)

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
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Transactions Table

```sql
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tier VARCHAR(20) NOT NULL,
  payment_method VARCHAR(20) NOT NULL,
  subtotal INTEGER NOT NULL,
  discount INTEGER DEFAULT 0,
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
  transaction_id UUID REFERENCES transactions(id),
  product_id UUID REFERENCES products(id),
  quantity INTEGER NOT NULL,
  price INTEGER NOT NULL,
  subtotal INTEGER NOT NULL
);
```

### Expenses Table

```sql
CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category VARCHAR(50) NOT NULL,
  amount INTEGER NOT NULL,
  notes TEXT,
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
  role VARCHAR(20) NOT NULL,
  name VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW()
);
```

## API Endpoints (Planned)

### Authentication

```
POST /auth/login
POST /auth/logout
GET  /auth/me
```

### Products

```
GET    /products
GET    /products/:id
POST   /products
PUT    /products/:id
DELETE /products/:id
```

### Transactions

```
GET    /transactions
GET    /transactions/:id
POST   /transactions
GET    /transactions/daily-summary
GET    /transactions/tier-breakdown
```

### Expenses

```
GET    /expenses
GET    /expenses/:id
POST   /expenses
GET    /expenses/daily-summary
GET    /expenses/category-breakdown
```

### Reports

```
GET /reports/profit-loss?month=12&year=2025
GET /reports/tax-calculation?month=12&year=2025
```

## Repository Pattern

```dart
// Abstract repository
abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProduct(String id);
  Future<void> createProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}

// Implementation
class ProductRepositoryImpl implements ProductRepository {
  final SupabaseClient _client;

  @override
  Future<List<Product>> getProducts() async {
    final response = await _client
        .from('products')
        .select()
        .order('name');
    return response.map((e) => Product.fromJson(e)).toList();
  }
}
```

## Offline Support

```dart
// Hive for local cache
class LocalProductDataSource {
  final Box<Product> _box;

  Future<void> cacheProducts(List<Product> products) async {
    await _box.clear();
    for (final product in products) {
      await _box.put(product.id, product);
    }
  }

  List<Product> getCachedProducts() {
    return _box.values.toList();
  }
}
```

## Sync Strategy

```
1. App Start
   └── Check connectivity
       ├── Online: Fetch from API → Cache locally
       └── Offline: Load from cache

2. Data Change
   └── Save locally first
       ├── Online: Sync to server immediately
       └── Offline: Queue for later sync

3. Reconnect
   └── Process sync queue
       └── Resolve conflicts (server wins)
```
