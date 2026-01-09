-- Migration: Add MARKETING category to expenses and fixed_expenses tables
-- Run this in Supabase SQL Editor to update existing database

-- Update expenses table constraint
ALTER TABLE public.expenses 
DROP CONSTRAINT IF EXISTS expenses_category_check;

ALTER TABLE public.expenses 
ADD CONSTRAINT expenses_category_check 
CHECK (category IN ('GAJI', 'SEWA', 'LISTRIK', 'TRANSPORTASI', 'PERAWATAN', 'SUPPLIES', 'MARKETING', 'LAINNYA'));

-- Update fixed_expenses table constraint
ALTER TABLE public.fixed_expenses 
DROP CONSTRAINT IF EXISTS fixed_expenses_category_check;

ALTER TABLE public.fixed_expenses 
ADD CONSTRAINT fixed_expenses_category_check 
CHECK (category IN ('GAJI', 'SEWA', 'LISTRIK', 'TRANSPORTASI', 'PERAWATAN', 'SUPPLIES', 'MARKETING', 'LAINNYA'));

-- Verify the constraints
SELECT conname, consrc 
FROM pg_constraint 
WHERE conrelid IN (
    SELECT oid FROM pg_class WHERE relname IN ('expenses', 'fixed_expenses')
) 
AND contype = 'c';