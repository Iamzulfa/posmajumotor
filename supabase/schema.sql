-- ============================================
-- POSFELIX DATABASE SCHEMA
-- ============================================
-- Run this in Supabase SQL Editor
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. USERS TABLE (extends Supabase auth.users)
-- ============================================
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('ADMIN', 'KASIR')),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 2. CATEGORIES TABLE
-- ============================================
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 3. BRANDS TABLE
-- ============================================
CREATE TABLE public.brands (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 4. PRODUCTS TABLE
-- ============================================
CREATE TABLE public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku TEXT UNIQUE,
    barcode TEXT UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    category_id UUID REFERENCES public.categories(id),
    brand_id UUID REFERENCES public.brands(id),
    
    -- Stock
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    min_stock INTEGER DEFAULT 5,
    
    -- Pricing (dalam Rupiah, tanpa desimal)
    hpp BIGINT NOT NULL DEFAULT 0,           -- Harga Pokok Pembelian
    harga_umum BIGINT NOT NULL DEFAULT 0,    -- Harga untuk tier Umum
    harga_bengkel BIGINT NOT NULL DEFAULT 0, -- Harga untuk tier Bengkel
    harga_grossir BIGINT NOT NULL DEFAULT 0, -- Harga untuk tier Grossir
    
    -- Metadata
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 5. TRANSACTIONS TABLE
-- ============================================
CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_number TEXT NOT NULL UNIQUE,
    
    -- Buyer info
    tier TEXT NOT NULL CHECK (tier IN ('UMUM', 'BENGKEL', 'GROSSIR')),
    customer_name TEXT,
    
    -- Amounts (dalam Rupiah)
    subtotal BIGINT NOT NULL DEFAULT 0,
    discount_amount BIGINT DEFAULT 0,
    total BIGINT NOT NULL DEFAULT 0,
    total_hpp BIGINT NOT NULL DEFAULT 0,     -- Total HPP untuk profit calculation
    profit BIGINT NOT NULL DEFAULT 0,        -- total - total_hpp
    
    -- Payment
    payment_method TEXT NOT NULL CHECK (payment_method IN ('CASH', 'TRANSFER', 'QRIS')),
    payment_status TEXT DEFAULT 'COMPLETED' CHECK (payment_status IN ('PENDING', 'COMPLETED', 'REFUNDED')),
    
    -- Metadata
    notes TEXT,
    cashier_id UUID REFERENCES public.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 6. TRANSACTION ITEMS TABLE
-- ============================================
CREATE TABLE public.transaction_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id),
    
    -- Snapshot data (untuk historical accuracy)
    product_name TEXT NOT NULL,
    product_sku TEXT,
    
    -- Quantity & Pricing
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price BIGINT NOT NULL,              -- Harga per unit saat transaksi
    unit_hpp BIGINT NOT NULL,                -- HPP per unit saat transaksi
    subtotal BIGINT NOT NULL,                -- quantity * unit_price
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 7. EXPENSES TABLE
-- ============================================
CREATE TABLE public.expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category TEXT NOT NULL CHECK (category IN ('GAJI', 'SEWA', 'LISTRIK', 'TRANSPORTASI', 'PERAWATAN', 'SUPPLIES', 'LAINNYA')),
    amount BIGINT NOT NULL CHECK (amount > 0),
    description TEXT,
    expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
    
    -- Metadata
    created_by UUID REFERENCES public.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 8. FIXED EXPENSES TABLE
-- ============================================
CREATE TABLE public.fixed_expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    amount BIGINT NOT NULL CHECK (amount > 0),
    category TEXT NOT NULL CHECK (category IN ('GAJI', 'SEWA', 'LISTRIK', 'TRANSPORTASI', 'PERAWATAN', 'SUPPLIES', 'LAINNYA')),
    
    -- Recurrence
    is_active BOOLEAN DEFAULT true,
    recurrence_type TEXT NOT NULL CHECK (recurrence_type IN ('MONTHLY', 'WEEKLY', 'DAILY')),
    
    -- Metadata
    created_by UUID REFERENCES public.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 9. INVENTORY LOGS TABLE (Audit Trail)
-- ============================================
CREATE TABLE public.inventory_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id),
    
    -- Change info
    type TEXT NOT NULL CHECK (type IN ('IN', 'OUT', 'ADJUSTMENT')),
    quantity INTEGER NOT NULL,               -- Positive for IN, negative for OUT
    stock_before INTEGER NOT NULL,
    stock_after INTEGER NOT NULL,
    
    -- Reference
    reference_type TEXT CHECK (reference_type IN ('PURCHASE', 'SALE', 'ADJUSTMENT', 'OPNAME', 'RETURN')),
    reference_id UUID,                       -- transaction_id atau expense_id
    reason TEXT,
    
    -- Metadata
    created_by UUID REFERENCES public.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 10. TAX PAYMENTS TABLE
-- ============================================
CREATE TABLE public.tax_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    period_month INTEGER NOT NULL CHECK (period_month BETWEEN 1 AND 12),
    period_year INTEGER NOT NULL,
    
    -- Amounts
    total_omset BIGINT NOT NULL DEFAULT 0,
    tax_amount BIGINT NOT NULL DEFAULT 0,    -- 0.5% dari omset
    
    -- Payment info
    is_paid BOOLEAN DEFAULT false,
    paid_at TIMESTAMPTZ,
    payment_proof TEXT,                      -- URL to uploaded proof
    
    -- Metadata
    created_by UUID REFERENCES public.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(period_month, period_year)
);
