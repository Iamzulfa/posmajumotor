# 🚀 SUPABASE SETUP GUIDE - POSFELIX

## 1. CREATE SUPABASE PROJECT

1. Buka [supabase.com](https://supabase.com)
2. Login atau Sign up
3. Click "New Project"
4. Isi form:
   - **Organization:** Pilih atau buat baru
   - **Project name:** `posfelix`
   - **Database password:** (SIMPAN BAIK-BAIK!)
   - **Region:** Southeast Asia (Singapore)
5. Click "Create new project"
6. Tunggu ~2 menit sampai selesai

---

## 2. GET API CREDENTIALS

Setelah project ready:

1. Go to **Settings** (gear icon) → **API**
2. Catat credentials berikut:

```
Project URL: https://xxxxx.supabase.co
Anon/Public Key: eyJhbGciOiJIUzI1NiIs...
Service Role Key: eyJhbGciOiJIUzI1NiIs... (JANGAN EXPOSE!)
```

---

## 3. RUN DATABASE SCHEMA

1. Go to **SQL Editor** (di sidebar)
2. Click "New query"
3. Copy-paste isi file `schema.sql`
4. Click "Run" (atau Ctrl+Enter)
5. Pastikan tidak ada error
6. Ulangi untuk `schema_part2.sql`
7. Ulangi untuk `seed_data.sql`

**Urutan PENTING:**

```
1. schema.sql        → Tables
2. schema_part2.sql  → Indexes, RLS, Functions, Triggers
3. seed_data.sql     → Sample data
```

---

## 4. SETUP AUTHENTICATION

### Enable Email Auth:

1. Go to **Authentication** → **Providers**
2. Pastikan **Email** enabled
3. Disable "Confirm email" untuk development (optional)

### Create Test Users:

1. Go to **Authentication** → **Users**
2. Click "Add user" → "Create new user"
3. Buat 2 users:

**Admin:**

```
Email: admin@toko.com
Password: admin123
```

**Kasir:**

```
Email: kasir@toko.com
Password: kasir123
```

### Link Users to public.users:

Setelah create users di Auth, jalankan SQL ini:

```sql
-- Get user IDs from auth.users
SELECT id, email FROM auth.users;

-- Insert into public.users (ganti UUID dengan yang benar)
INSERT INTO public.users (id, email, full_name, role) VALUES
    ('uuid-admin-dari-auth', 'admin@toko.com', 'Admin Toko', 'ADMIN'),
    ('uuid-kasir-dari-auth', 'kasir@toko.com', 'Kasir Toko', 'KASIR');
```

---

## 5. VERIFY SETUP

### Check Tables:

```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';
```

Expected: users, categories, brands, products, transactions, transaction_items, expenses, inventory_logs, tax_payments

### Check Sample Data:

```sql
SELECT COUNT(*) FROM products;  -- Should be 16
SELECT COUNT(*) FROM categories; -- Should be 10
SELECT COUNT(*) FROM brands;     -- Should be 10
```

### Test RLS:

```sql
-- This should work (as authenticated user)
SELECT * FROM products LIMIT 5;
```

---

## 6. FLUTTER CONFIGURATION

Setelah Supabase ready, update Flutter app:

### Install Supabase Package:

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.3.0
```

### Create Config File:

```dart
// lib/config/constants/supabase_config.dart
class SupabaseConfig {
  static const String url = 'https://xxxxx.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIs...';
}
```

### Initialize in main.dart:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const MyApp());
}
```

---

## 📊 DATABASE SCHEMA OVERVIEW

```
┌─────────────────┐     ┌─────────────────┐
│     users       │     │   categories    │
├─────────────────┤     ├─────────────────┤
│ id (UUID, PK)   │     │ id (UUID, PK)   │
│ email           │     │ name            │
│ full_name       │     │ description     │
│ role            │     └────────┬────────┘
└────────┬────────┘              │
         │                       │
         │     ┌─────────────────┼─────────────────┐
         │     │                 │                 │
         ▼     ▼                 ▼                 ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   transactions  │     │    products     │     │     brands      │
├─────────────────┤     ├─────────────────┤     ├─────────────────┤
│ id (UUID, PK)   │     │ id (UUID, PK)   │     │ id (UUID, PK)   │
│ transaction_num │     │ sku, barcode    │     │ name            │
│ tier            │     │ name            │     │ description     │
│ subtotal        │     │ category_id(FK) │     └─────────────────┘
│ total           │     │ brand_id (FK)   │
│ total_hpp       │     │ stock           │
│ profit          │     │ hpp             │
│ payment_method  │     │ harga_umum      │
│ cashier_id (FK) │     │ harga_bengkel   │
└────────┬────────┘     │ harga_grossir   │
         │              └────────┬────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│transaction_items│     │ inventory_logs  │
├─────────────────┤     ├─────────────────┤
│ id (UUID, PK)   │     │ id (UUID, PK)   │
│ transaction_id  │     │ product_id (FK) │
│ product_id (FK) │     │ type (IN/OUT)   │
│ quantity        │     │ quantity        │
│ unit_price      │     │ stock_before    │
│ unit_hpp        │     │ stock_after     │
│ subtotal        │     │ reference_type  │
└─────────────────┘     └─────────────────┘

┌─────────────────┐     ┌─────────────────┐
│    expenses     │     │  tax_payments   │
├─────────────────┤     ├─────────────────┤
│ id (UUID, PK)   │     │ id (UUID, PK)   │
│ category        │     │ period_month    │
│ amount          │     │ period_year     │
│ description     │     │ total_omset     │
│ expense_date    │     │ tax_amount      │
│ created_by (FK) │     │ is_paid         │
└─────────────────┘     └─────────────────┘
```

---

## ⚠️ IMPORTANT NOTES

1. **JANGAN commit credentials ke Git!**

   - Gunakan environment variables atau .env file
   - Add ke .gitignore

2. **Service Role Key hanya untuk server-side**

   - Jangan gunakan di Flutter app
   - Hanya untuk admin scripts

3. **RLS sudah aktif**

   - Users harus authenticated untuk akses data
   - Admin punya full access
   - Kasir terbatas sesuai policy

4. **Triggers otomatis:**
   - `updated_at` auto-update saat record diubah
   - `transaction_number` auto-generate saat transaksi baru
   - Stock auto-deduct saat transaction_item dibuat

---

_Created: December 14, 2025_
