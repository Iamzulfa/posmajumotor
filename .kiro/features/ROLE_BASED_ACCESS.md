# Role-Based Access Control (RBAC)

> **Status:** Implemented  
> **Date:** December 14, 2025

---

## Overview

PosFELIX menggunakan role-based access control untuk membedakan akses antara Admin dan Kasir.

---

## Roles

### 1. ADMIN

**Akses ke:**

- Dashboard (analytics & reports)
- Inventory (view, add, edit, delete products)
- Transaction (view, manage transactions)
- Expense (manage expenses)
- Tax Center (tax calculations & reports)

**Permissions:**

- ✅ Create products
- ✅ Edit products
- ✅ Delete products
- ✅ View all transactions
- ✅ Manage expenses
- ✅ View tax reports
- ✅ View dashboard analytics

### 2. KASIR

**Akses ke:**

- Inventory (view products only)
- Transaction (create & manage transactions)

**Permissions:**

- ✅ View products
- ✅ Create transactions
- ✅ View transaction history
- ❌ Cannot add/edit/delete products
- ❌ Cannot access dashboard
- ❌ Cannot manage expenses
- ❌ Cannot access tax center

---

## Implementation

### Database Schema

```sql
-- users table
CREATE TABLE public.users (
  id uuid PRIMARY KEY,
  email text UNIQUE NOT NULL,
  full_name text NOT NULL,
  role text NOT NULL CHECK (role = ANY (ARRAY['ADMIN'::text, 'KASIR'::text])),
  is_active boolean DEFAULT true,
  created_at timestamp DEFAULT now(),
  updated_at timestamp DEFAULT now()
);
```

### Auth Provider

```dart
// lib/presentation/providers/auth_provider.dart
class AuthState {
  bool get isAdmin => user?.role == 'ADMIN';
  bool get isKasir => user?.role == 'KASIR';
}
```

### Routing

```dart
// lib/presentation/screens/auth/login_screen.dart
if (user?.role == 'ADMIN') {
  context.go(AppRoutes.adminMain);  // Admin dashboard
} else {
  context.go(AppRoutes.kasirMain);  // Kasir dashboard
}
```

### Screen Structure

```
AdminMainScreen
├── Dashboard
├── Inventory (shared with Kasir)
├── Transaction (shared with Kasir)
├── Expense
└── Tax Center

KasirMainScreen
├── Inventory (read-only)
└── Transaction
```

---

## Test Credentials

### Admin Account

- **Email:** `admin@toko.com`
- **Password:** `admin123`
- **Role:** ADMIN
- **Access:** Full access to all features

### Kasir Account

- **Email:** `kasir@toko.com`
- **Password:** `kasir123`
- **Role:** KASIR
- **Access:** Inventory (view) + Transaction (create/manage)

---

## Features by Role

### Inventory Management

| Feature        | Admin | Kasir |
| -------------- | ----- | ----- |
| View Products  | ✅    | ✅    |
| Add Product    | ✅    | ❌    |
| Edit Product   | ✅    | ❌    |
| Delete Product | ✅    | ❌    |
| Search/Filter  | ✅    | ✅    |

### Transaction Management

| Feature            | Admin | Kasir |
| ------------------ | ----- | ----- |
| View Transactions  | ✅    | ✅    |
| Create Transaction | ✅    | ✅    |
| Edit Transaction   | ✅    | ✅    |
| Delete Transaction | ✅    | ✅    |
| View History       | ✅    | ✅    |

### Admin Features

| Feature            | Admin | Kasir |
| ------------------ | ----- | ----- |
| Dashboard          | ✅    | ❌    |
| Expense Management | ✅    | ❌    |
| Tax Center         | ✅    | ❌    |
| Reports            | ✅    | ❌    |

---

## Future Enhancements

1. **Permission-based UI**

   - Hide/disable buttons based on role
   - Show role-specific features only

2. **Audit Logging**

   - Track who created/edited/deleted what
   - Timestamp all actions

3. **Additional Roles**

   - MANAGER (between Admin & Kasir)
   - OWNER (full access + settings)

4. **Fine-grained Permissions**
   - Product category restrictions
   - Transaction amount limits
   - Time-based access

---

## Security Notes

- Roles are stored in database and verified on backend
- Frontend checks role for UI purposes only
- Backend should always verify role before allowing operations
- RLS policies should enforce role-based access at database level

---

_Last Updated: December 14, 2025_
