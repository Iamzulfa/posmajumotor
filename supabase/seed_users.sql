-- Supabase User Seeder
-- Purpose: Create test users (Admin & Kasir) for development and testing
-- Date: December 14, 2025

-- Optional: Delete existing users if you want to re-seed
-- DELETE FROM public.users WHERE email IN ('admin@toko.com', 'kasir@toko.com');

-- Create Admin User (reference auth.users id)
INSERT INTO public.users (id, email, full_name, role, created_at, updated_at) VALUES (
  '77f26a67-d186-4684-b1d3-2adb121dacad',
  'admin@toko.com',
  'Admin Toko',
  'ADMIN',
  NOW(),
  NOW()
);

-- Create Kasir User (reference auth.users id)
INSERT INTO public.users (id, email, full_name, role, created_at, updated_at) VALUES (
  'dd689e00-814c-498e-9335-c5e515cb9fbd',
  'kasir@toko.com',
  'Kasir Toko',
  'KASIR',
  NOW(),
  NOW()
);

-- Verify users were created
SELECT id, email, full_name, role FROM public.users WHERE email IN ('admin@toko.com', 'kasir@toko.com');
