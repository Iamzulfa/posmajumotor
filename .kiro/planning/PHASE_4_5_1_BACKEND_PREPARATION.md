# 🔧 PHASE 4.5.1: BACKEND PREPARATION

> **Purpose:** Enable real-time subscriptions on Supabase & verify configuration  
> **Status:** Ready for Execution  
> **Estimated Time:** 1-2 hours  
> **Date:** December 14, 2025

---

## 📋 OVERVIEW

Phase ini fokus pada konfigurasi backend Supabase untuk mendukung real-time synchronization. Semua task di phase ini dikerjakan di Supabase dashboard, bukan di code.

---

## ✅ CHECKLIST

### Step 1: Enable Real-time on Tables

Real-time subscriptions perlu di-enable per table di Supabase. Follow langkah-langkah ini:

#### 1.1 Enable Real-time on `products` Table

1. Login ke Supabase Dashboard
2. Pilih project PosFELIX
3. Go to **Database** → **Tables**
4. Cari table `products`
5. Click table name untuk buka detail
6. Go to **Realtime** tab
7. Toggle **Enable Realtime** ON
8. Pilih columns yang ingin di-subscribe (atau pilih semua)
9. Click **Save**

**Columns to enable:**

- id
- sku
- barcode
- name
- description
- category_id
- brand_id
- stock
- min_stock
- hpp
- harga_umum
- harga_bengkel
- harga_grossir
- is_active
- created_at
- updated_at

**Verification:**

- [ ] Real-time toggle is ON
- [ ] All columns selected
- [ ] Status shows "Enabled"

---

#### 1.2 Enable Real-time on `transactions` Table

1. Go to **Database** → **Tables**
2. Cari table `transactions`
3. Click table name
4. Go to **Realtime** tab
5. Toggle **Enable Realtime** ON
6. Select columns:
   - id
   - transaction_number
   - tier
   - customer_name
   - subtotal
   - discount_amount
   - total
   - total_hpp
   - profit
   - payment_method
   - payment_status
   - notes
   - cashier_id
   - created_at
   - updated_at
7. Click **Save**

**Verification:**

- [ ] Real-time toggle is ON
- [ ] All columns selected
- [ ] Status shows "Enabled"

---

#### 1.3 Enable Real-time on `transaction_items` Table

1. Go to **Database** → **Tables**
2. Cari table `transaction_items`
3. Click table name
4. Go to **Realtime** tab
5. Toggle **Enable Realtime** ON
6. Select columns:
   - id
   - transaction_id
   - product_id
   - product_name
   - product_sku
   - quantity
   - unit_price
   - unit_hpp
   - subtotal
   - created_at
7. Click **Save**

**Verification:**

- [ ] Real-time toggle is ON
- [ ] All columns selected
- [ ] Status shows "Enabled"

---

#### 1.4 Enable Real-time on `expenses` Table

1. Go to **Database** → **Tables**
2. Cari table `expenses`
3. Click table name
4. Go to **Realtime** tab
5. Toggle **Enable Realtime** ON
6. Select columns:
   - id
   - category
   - amount
   - description
   - expense_date
   - created_by
   - created_at
   - updated_at
7. Click **Save**

**Verification:**

- [ ] Real-time toggle is ON
- [ ] All columns selected
- [ ] Status shows "Enabled"

---

#### 1.5 Enable Real-time on `inventory_logs` Table

1. Go to **Database** → **Tables**
2. Cari table `inventory_logs`
3. Click table name
4. Go to **Realtime** tab
5. Toggle **Enable Realtime** ON
6. Select columns:
   - id
   - product_id
   - type
   - quantity
   - stock_before
   - stock_after
   - reference_type
   - reference_id
   - reason
   - created_by
   - created_at
7. Click **Save**

**Verification:**

- [ ] Real-time toggle is ON
- [ ] All columns selected
- [ ] Status shows "Enabled"

---

#### 1.6 Enable Real-time on `tax_payments` Table

1. Go to **Database** → **Tables**
2. Cari table `tax_payments`
3. Click table name
4. Go to **Realtime** tab
5. Toggle **Enable Realtime** ON
6. Select columns:
   - id
   - period_month
   - period_year
   - total_omset
   - tax_amount
   - is_paid
   - paid_at
   - payment_proof
   - created_by
   - created_at
   - updated_at
7. Click **Save**

**Verification:**

- [ ] Real-time toggle is ON
- [ ] All columns selected
- [ ] Status shows "Enabled"

---

### Step 2: Verify RLS Policies

RLS (Row Level Security) policies harus allow SELECT untuk real-time subscriptions. Verify setiap table:

#### 2.1 Check `products` Table RLS

1. Go to **Database** → **Tables** → `products`
2. Go to **RLS** tab
3. Verify policies:
   - [ ] SELECT policy exists
   - [ ] SELECT policy allows authenticated users
   - [ ] SELECT policy allows anonymous users (if needed)

**Expected Policies:**

```
- SELECT: (auth.role() = 'authenticated'::text) OR (auth.role() = 'anon'::text)
```

If missing, create:

1. Click **New Policy**
2. Choose **SELECT**
3. Set condition: `true` (allow all)
4. Click **Save**

---

#### 2.2 Check `transactions` Table RLS

1. Go to **Database** → **Tables** → `transactions`
2. Go to **RLS** tab
3. Verify SELECT policy exists
4. If missing, create with condition: `true`

---

#### 2.3 Check `transaction_items` Table RLS

1. Go to **Database** → **Tables** → `transaction_items`
2. Go to **RLS** tab
3. Verify SELECT policy exists
4. If missing, create with condition: `true`

---

#### 2.4 Check `expenses` Table RLS

1. Go to **Database** → **Tables** → `expenses`
2. Go to **RLS** tab
3. Verify SELECT policy exists
4. If missing, create with condition: `true`

---

#### 2.5 Check `inventory_logs` Table RLS

1. Go to **Database** → **Tables** → `inventory_logs`
2. Go to **RLS** tab
3. Verify SELECT policy exists
4. If missing, create with condition: `true`

---

#### 2.6 Check `tax_payments` Table RLS

1. Go to **Database** → **Tables** → `tax_payments`
2. Go to **RLS** tab
3. Verify SELECT policy exists
4. If missing, create with condition: `true`

---

### Step 3: Test Real-time Subscriptions

Test real-time subscriptions menggunakan Supabase SQL Editor:

#### 3.1 Test `products` Subscription

1. Go to **SQL Editor**
2. Create new query
3. Paste code ini:

```sql
-- Test real-time subscription on products table
SELECT * FROM products LIMIT 5;
```

4. Run query
5. Verify data returns successfully

#### 3.2 Test WebSocket Connection

1. Go to **Database** → **Realtime** (top menu)
2. Check status:
   - [ ] WebSocket server is running
   - [ ] Connection status shows "Connected"
   - [ ] No error messages

#### 3.3 Manual Subscription Test (Optional)

Jika ingin test lebih detail, bisa gunakan Supabase CLI:

```bash
# Install Supabase CLI (if not already installed)
npm install -g supabase

# Login
supabase login

# Test subscription
supabase realtime --project-id YOUR_PROJECT_ID
```

---

### Step 4: Verify Configuration

Checklist final untuk memastikan semua configured dengan benar:

#### 4.1 Real-time Status

- [ ] `products` table: Real-time ENABLED
- [ ] `transactions` table: Real-time ENABLED
- [ ] `transaction_items` table: Real-time ENABLED
- [ ] `expenses` table: Real-time ENABLED
- [ ] `inventory_logs` table: Real-time ENABLED
- [ ] `tax_payments` table: Real-time ENABLED

#### 4.2 RLS Policies

- [ ] `products` table: SELECT policy exists
- [ ] `transactions` table: SELECT policy exists
- [ ] `transaction_items` table: SELECT policy exists
- [ ] `expenses` table: SELECT policy exists
- [ ] `inventory_logs` table: SELECT policy exists
- [ ] `tax_payments` table: SELECT policy exists

#### 4.3 WebSocket Connection

- [ ] Supabase Realtime server is running
- [ ] WebSocket connection is active
- [ ] No connection errors

#### 4.4 Credentials

- [ ] Supabase URL is correct in `lib/config/constants/supabase_config.dart`
- [ ] Supabase Anon Key is correct
- [ ] Credentials are not exposed in version control

---

## 🧪 TESTING REAL-TIME UPDATES

Setelah semua configured, test real-time updates:

### Test 1: Update Product Price

1. Open Supabase Dashboard
2. Go to **Database** → **Tables** → `products`
3. Edit satu product (ubah harga)
4. Save changes
5. Check app - harga harus update otomatis dalam 2-3 detik

### Test 2: Create New Transaction

1. Open app
2. Create new transaction
3. Check Supabase - transaction harus muncul di table
4. Check app - transaction list harus update otomatis

### Test 3: Multi-device Sync

1. Open app di 2 devices/emulators
2. Create transaction di device 1
3. Check device 2 - transaction harus muncul otomatis
4. Update product di device 2
5. Check device 1 - product harus update otomatis

---

## 🔍 TROUBLESHOOTING

### Issue: Real-time toggle tidak bisa di-enable

**Solution:**

1. Check Supabase project status (harus active)
2. Check user permissions (harus admin)
3. Try refresh page
4. Try different browser

### Issue: WebSocket connection failed

**Solution:**

1. Check internet connection
2. Check Supabase status page
3. Check firewall/proxy settings
4. Try disable VPN

### Issue: RLS policy blocking subscriptions

**Solution:**

1. Verify SELECT policy exists
2. Check policy condition (harus allow SELECT)
3. Try set condition to `true` (allow all)
4. Check user role (harus authenticated atau anon)

### Issue: No data received from subscription

**Solution:**

1. Verify real-time is enabled on table
2. Verify RLS policy allows SELECT
3. Check WebSocket connection
4. Try refresh app
5. Check browser console for errors

---

## 📝 NOTES

### Important Points

1. **Real-time vs Polling:** Real-time menggunakan WebSocket (instant), polling menggunakan HTTP (5 detik). App akan fallback ke polling jika WebSocket gagal.

2. **RLS Policies:** Penting untuk security. Jangan set condition ke `true` di production kecuali benar-benar diperlukan.

3. **Column Selection:** Hanya select columns yang benar-benar dibutuhkan untuk reduce bandwidth.

4. **Testing:** Test di multiple devices untuk memastikan sync bekerja dengan baik.

### Performance Considerations

- Real-time subscriptions consume WebSocket connections
- Each subscription = 1 WebSocket connection
- Supabase free tier: 2 concurrent connections
- Supabase paid tier: unlimited connections

Jika perlu optimize, bisa implement selective subscriptions (hanya subscribe ke tables yang dibutuhkan).

---

## ✅ SIGN-OFF

Setelah semua steps di atas selesai, checklist ini:

- [ ] All 6 tables have real-time enabled
- [ ] All RLS policies verified
- [ ] WebSocket connection tested
- [ ] Manual subscription test passed
- [ ] Multi-device sync tested
- [ ] No errors in browser console
- [ ] Ready to proceed to Phase 4.5.3

---

## 📞 NEXT STEPS

Setelah Phase 4.5.1 complete:

1. **Phase 4.5.3: Provider Layer Updates**

   - Convert providers to StreamProvider
   - Add auto-refresh logic
   - Add error handling

2. **Phase 4.5.4: UI Layer Updates**
   - Update screens to use real-time data
   - Add loading/error states
   - Add sync status indicator

---

_Phase Status: READY FOR EXECUTION_  
_Last Updated: December 14, 2025_  
_Prepared by: Kiro AI Assistant_
