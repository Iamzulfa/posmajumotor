-- ============================================
-- SEED DATA FOR POSFELIX
-- ============================================
-- Run this AFTER schema.sql and schema_part2.sql
-- ============================================

-- ============================================
-- CATEGORIES
-- ============================================
INSERT INTO public.categories (name, description) VALUES
    ('Gear Set', 'Rantai dan gear untuk motor'),
    ('Bearing', 'Bearing roda dan mesin'),
    ('Kampas Rem', 'Kampas rem depan dan belakang'),
    ('Oli', 'Oli mesin dan transmisi'),
    ('Filter', 'Filter oli dan udara'),
    ('Busi', 'Busi motor berbagai merk'),
    ('Lampu', 'Lampu depan, belakang, sein'),
    ('Ban', 'Ban motor berbagai ukuran'),
    ('Aki', 'Aki motor kering dan basah'),
    ('Sparepart Lainnya', 'Sparepart umum lainnya');

-- ============================================
-- BRANDS
-- ============================================
INSERT INTO public.brands (name, description) VALUES
    ('Honda Genuine', 'Sparepart original Honda'),
    ('Yamaha Genuine', 'Sparepart original Yamaha'),
    ('Suzuki Genuine', 'Sparepart original Suzuki'),
    ('Federal', 'Merk aftermarket populer'),
    ('Aspira', 'Merk aftermarket Astra'),
    ('Indopart', 'Merk aftermarket lokal'),
    ('NGK', 'Spesialis busi'),
    ('Motul', 'Spesialis oli'),
    ('IRC', 'Spesialis ban'),
    ('GS Astra', 'Spesialis aki');

-- ============================================
-- SAMPLE PRODUCTS
-- ============================================
-- Note: Prices in Rupiah (no decimal)

INSERT INTO public.products (sku, barcode, name, category_id, brand_id, stock, min_stock, hpp, harga_umum, harga_bengkel, harga_grossir) VALUES
-- Gear Set
('GS-001', '8991234567001', 'Gear Set Supra X 125', 
    (SELECT id FROM categories WHERE name = 'Gear Set'),
    (SELECT id FROM brands WHERE name = 'Federal'),
    50, 10, 85000, 125000, 115000, 105000),

('GS-002', '8991234567002', 'Gear Set Vario 150', 
    (SELECT id FROM categories WHERE name = 'Gear Set'),
    (SELECT id FROM brands WHERE name = 'Aspira'),
    35, 10, 95000, 145000, 135000, 120000),

('GS-003', '8991234567003', 'Gear Set Beat FI', 
    (SELECT id FROM categories WHERE name = 'Gear Set'),
    (SELECT id FROM brands WHERE name = 'Honda Genuine'),
    25, 5, 150000, 225000, 210000, 195000),

-- Bearing
('BR-001', '8991234567010', 'Bearing Roda Depan 6301', 
    (SELECT id FROM categories WHERE name = 'Bearing'),
    (SELECT id FROM brands WHERE name = 'Federal'),
    100, 20, 15000, 25000, 22000, 19000),

('BR-002', '8991234567011', 'Bearing Roda Belakang 6302', 
    (SELECT id FROM categories WHERE name = 'Bearing'),
    (SELECT id FROM brands WHERE name = 'Federal'),
    80, 20, 18000, 30000, 27000, 24000),

-- Kampas Rem
('KR-001', '8991234567020', 'Kampas Rem Depan Vario', 
    (SELECT id FROM categories WHERE name = 'Kampas Rem'),
    (SELECT id FROM brands WHERE name = 'Aspira'),
    60, 15, 25000, 45000, 40000, 35000),

('KR-002', '8991234567021', 'Kampas Rem Belakang Beat', 
    (SELECT id FROM categories WHERE name = 'Kampas Rem'),
    (SELECT id FROM brands WHERE name = 'Federal'),
    45, 15, 20000, 35000, 32000, 28000),

-- Oli
('OL-001', '8991234567030', 'Oli Mesin 10W-40 1L', 
    (SELECT id FROM categories WHERE name = 'Oli'),
    (SELECT id FROM brands WHERE name = 'Motul'),
    40, 10, 45000, 75000, 68000, 60000),

('OL-002', '8991234567031', 'Oli Mesin 20W-50 0.8L', 
    (SELECT id FROM categories WHERE name = 'Oli'),
    (SELECT id FROM brands WHERE name = 'Federal'),
    55, 15, 28000, 45000, 40000, 35000),

-- Busi
('BS-001', '8991234567040', 'Busi Iridium CR8EIX', 
    (SELECT id FROM categories WHERE name = 'Busi'),
    (SELECT id FROM brands WHERE name = 'NGK'),
    70, 20, 65000, 95000, 88000, 80000),

('BS-002', '8991234567041', 'Busi Standard C7HSA', 
    (SELECT id FROM categories WHERE name = 'Busi'),
    (SELECT id FROM brands WHERE name = 'NGK'),
    120, 30, 18000, 28000, 25000, 22000),

-- Filter
('FL-001', '8991234567050', 'Filter Oli Beat/Vario', 
    (SELECT id FROM categories WHERE name = 'Filter'),
    (SELECT id FROM brands WHERE name = 'Aspira'),
    90, 25, 12000, 22000, 19000, 16000),

('FL-002', '8991234567051', 'Filter Udara Supra X', 
    (SELECT id FROM categories WHERE name = 'Filter'),
    (SELECT id FROM brands WHERE name = 'Honda Genuine'),
    30, 10, 35000, 55000, 50000, 45000),

-- Lampu
('LP-001', '8991234567060', 'Lampu Depan LED H4', 
    (SELECT id FROM categories WHERE name = 'Lampu'),
    (SELECT id FROM brands WHERE name = 'Indopart'),
    25, 5, 85000, 135000, 125000, 115000),

('LP-002', '8991234567061', 'Lampu Sein LED Orange', 
    (SELECT id FROM categories WHERE name = 'Lampu'),
    (SELECT id FROM brands WHERE name = 'Indopart'),
    40, 10, 15000, 28000, 25000, 22000),

-- Aki
('AK-001', '8991234567070', 'Aki Kering GTZ5S', 
    (SELECT id FROM categories WHERE name = 'Aki'),
    (SELECT id FROM brands WHERE name = 'GS Astra'),
    20, 5, 165000, 235000, 220000, 205000),

('AK-002', '8991234567071', 'Aki Kering GTZ7S', 
    (SELECT id FROM categories WHERE name = 'Aki'),
    (SELECT id FROM brands WHERE name = 'GS Astra'),
    15, 5, 245000, 335000, 315000, 295000);

-- ============================================
-- NOTE: Users will be created via Supabase Auth
-- After user signs up, insert into public.users:
-- 
-- INSERT INTO public.users (id, email, full_name, role)
-- VALUES (
--     'uuid-from-auth',
--     'admin@toko.com',
--     'Admin Toko',
--     'ADMIN'
-- );
-- ============================================
