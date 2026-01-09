# Supabase User Setup Guide

> **Purpose:** Setup test user untuk development dan testing  
> **Date:** December 14, 2025

---

## 🚀 CARA MEMBUAT TEST USER

### Step 1: Login ke Supabase Dashboard

1. Buka https://supabase.com
2. Login dengan akun Supabase kamu
3. Pilih project **PosFELIX**

### Step 2: Buat Test User

1. Go to **Authentication** → **Users**
2. Click **Add user**
3. Isi form:
   - **Email:** `admin@posfelix.local`
   - **Password:** `Admin@123456`
4. Click **Create user**

### Step 3: Test Login di App

1. Buka PosFELIX app
2. Login dengan:
   - **Email:** `admin@posfelix.local`
   - **Password:** `Admin@123456`
3. Kamu seharusnya bisa masuk ke dashboard

---

## 📝 TEST CREDENTIALS

```
Email:    admin@posfelix.local
Password: Admin@123456
```

---

## ✅ VERIFICATION

Setelah membuat user, verify di Supabase Dashboard:

1. Go to **Authentication** → **Users**
2. Cari user dengan email `admin@posfelix.local`
3. Status seharusnya **Active**

---

## 🐛 TROUBLESHOOTING

### Error: "Invalid login credentials"

**Solution:** Pastikan:

1. User sudah di-create di Supabase Dashboard
2. Email dan password benar
3. User status adalah **Active**
4. Supabase credentials di app sudah benar (check `lib/config/constants/supabase_config.dart`)

### User tidak bisa login

**Solution:**

1. Verify user ada di Supabase Dashboard
2. Restart app
3. Check internet connection

---

_Last Updated: December 14, 2025_
