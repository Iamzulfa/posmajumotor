-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Products
CREATE INDEX idx_products_category ON public.products(category_id);
CREATE INDEX idx_products_brand ON public.products(brand_id);
CREATE INDEX idx_products_sku ON public.products(sku);
CREATE INDEX idx_products_barcode ON public.products(barcode);
CREATE INDEX idx_products_name ON public.products(name);

-- Transactions
CREATE INDEX idx_transactions_created_at ON public.transactions(created_at);
CREATE INDEX idx_transactions_tier ON public.transactions(tier);
CREATE INDEX idx_transactions_cashier ON public.transactions(cashier_id);
CREATE INDEX idx_transactions_number ON public.transactions(transaction_number);

-- Transaction Items
CREATE INDEX idx_transaction_items_transaction ON public.transaction_items(transaction_id);
CREATE INDEX idx_transaction_items_product ON public.transaction_items(product_id);

-- Expenses
CREATE INDEX idx_expenses_category ON public.expenses(category);
CREATE INDEX idx_expenses_date ON public.expenses(expense_date);
CREATE INDEX idx_expenses_created_by ON public.expenses(created_by);

-- Inventory Logs
CREATE INDEX idx_inventory_logs_product ON public.inventory_logs(product_id);
CREATE INDEX idx_inventory_logs_type ON public.inventory_logs(type);
CREATE INDEX idx_inventory_logs_created_at ON public.inventory_logs(created_at);

-- Tax Payments
CREATE INDEX idx_tax_payments_period ON public.tax_payments(period_year, period_month);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brands ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tax_payments ENABLE ROW LEVEL SECURITY;

-- ============================================
-- RLS POLICIES
-- ============================================

-- Helper function to get user role
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS TEXT AS $$
BEGIN
    RETURN (SELECT role FROM public.users WHERE id = auth.uid());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- USERS: Users can read their own data, Admin can read all
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Admin can view all users" ON public.users
    FOR SELECT USING (public.get_user_role() = 'ADMIN');

CREATE POLICY "Admin can manage users" ON public.users
    FOR ALL USING (public.get_user_role() = 'ADMIN');

-- CATEGORIES & BRANDS: All authenticated users can read, Admin can manage
CREATE POLICY "Authenticated users can view categories" ON public.categories
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admin can manage categories" ON public.categories
    FOR ALL USING (public.get_user_role() = 'ADMIN');

CREATE POLICY "Authenticated users can view brands" ON public.brands
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admin can manage brands" ON public.brands
    FOR ALL USING (public.get_user_role() = 'ADMIN');

-- PRODUCTS: All authenticated users can read & manage (Kasir needs CRUD)
CREATE POLICY "Authenticated users can view products" ON public.products
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can manage products" ON public.products
    FOR ALL USING (auth.role() = 'authenticated');

-- TRANSACTIONS: All authenticated users can read & create
CREATE POLICY "Authenticated users can view transactions" ON public.transactions
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can create transactions" ON public.transactions
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admin can manage transactions" ON public.transactions
    FOR ALL USING (public.get_user_role() = 'ADMIN');

-- TRANSACTION ITEMS: Follow transaction access
CREATE POLICY "Authenticated users can view transaction items" ON public.transaction_items
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can create transaction items" ON public.transaction_items
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- EXPENSES: Only Admin can access
CREATE POLICY "Admin can manage expenses" ON public.expenses
    FOR ALL USING (public.get_user_role() = 'ADMIN');

-- INVENTORY LOGS: All authenticated can view, system creates
CREATE POLICY "Authenticated users can view inventory logs" ON public.inventory_logs
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can create inventory logs" ON public.inventory_logs
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- TAX PAYMENTS: Only Admin can access
CREATE POLICY "Admin can manage tax payments" ON public.tax_payments
    FOR ALL USING (public.get_user_role() = 'ADMIN');

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON public.categories
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_brands_updated_at
    BEFORE UPDATE ON public.brands
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_transactions_updated_at
    BEFORE UPDATE ON public.transactions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_expenses_updated_at
    BEFORE UPDATE ON public.expenses
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_tax_payments_updated_at
    BEFORE UPDATE ON public.tax_payments
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

-- ============================================
-- GENERATE TRANSACTION NUMBER
-- ============================================
CREATE OR REPLACE FUNCTION public.generate_transaction_number()
RETURNS TEXT AS $$
DECLARE
    today_date TEXT;
    seq_num INTEGER;
    result TEXT;
BEGIN
    today_date := TO_CHAR(NOW(), 'YYYYMMDD');
    
    SELECT COUNT(*) + 1 INTO seq_num
    FROM public.transactions
    WHERE DATE(created_at) = CURRENT_DATE;
    
    result := 'TRX-' || today_date || '-' || LPAD(seq_num::TEXT, 4, '0');
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Auto-generate transaction number on insert
CREATE OR REPLACE FUNCTION public.set_transaction_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.transaction_number IS NULL OR NEW.transaction_number = '' THEN
        NEW.transaction_number := public.generate_transaction_number();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_transaction_number_trigger
    BEFORE INSERT ON public.transactions
    FOR EACH ROW EXECUTE FUNCTION public.set_transaction_number();

-- ============================================
-- AUTO-UPDATE STOCK ON TRANSACTION
-- ============================================
CREATE OR REPLACE FUNCTION public.update_stock_on_transaction_item()
RETURNS TRIGGER AS $$
DECLARE
    current_stock INTEGER;
BEGIN
    -- Get current stock
    SELECT stock INTO current_stock FROM public.products WHERE id = NEW.product_id;
    
    -- Deduct stock
    UPDATE public.products
    SET stock = stock - NEW.quantity
    WHERE id = NEW.product_id;
    
    -- Log inventory change
    INSERT INTO public.inventory_logs (
        product_id, type, quantity, stock_before, stock_after,
        reference_type, reference_id, created_by
    ) VALUES (
        NEW.product_id, 'OUT', -NEW.quantity, current_stock, current_stock - NEW.quantity,
        'SALE', NEW.transaction_id, (SELECT cashier_id FROM public.transactions WHERE id = NEW.transaction_id)
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_stock_on_sale
    AFTER INSERT ON public.transaction_items
    FOR EACH ROW EXECUTE FUNCTION public.update_stock_on_transaction_item();
