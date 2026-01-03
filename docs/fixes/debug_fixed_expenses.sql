-- Debug script untuk melihat data fixed expenses
-- Jalankan di Supabase SQL Editor

-- 1. Cek apakah tabel ada
SELECT EXISTS (
   SELECT FROM information_schema.tables 
   WHERE table_schema = 'public' 
   AND table_name = 'fixed_expenses'
) as table_exists;

-- 2. Cek struktur tabel
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'fixed_expenses'
ORDER BY ordinal_position;

-- 3. Cek semua data di tabel (termasuk yang inactive)
SELECT 
    id,
    name,
    description,
    amount,
    category,
    is_active,
    recurrence_type,
    created_at,
    updated_at
FROM fixed_expenses
ORDER BY created_at DESC;

-- 4. Cek hanya data aktif (yang seharusnya muncul di app)
SELECT 
    id,
    name,
    description,
    amount,
    category,
    is_active,
    recurrence_type,
    created_at,
    updated_at
FROM fixed_expenses
WHERE is_active = true
ORDER BY created_at DESC;

-- 5. Cek total jumlah records
SELECT 
    COUNT(*) as total_records,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_records,
    COUNT(CASE WHEN is_active = false THEN 1 END) as inactive_records
FROM fixed_expenses;

-- 6. Cek RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename = 'fixed_expenses';