-- Insert dummy fixed expenses for testing
INSERT INTO public.fixed_expenses (
    id,
    name,
    description,
    amount,
    category,
    is_active,
    recurrence_type,
    created_at,
    updated_at
) VALUES 
(
    uuid_generate_v4(),
    'Gaji Karyawan Bulanan',
    'Gaji untuk 2 karyawan per bulan',
    8000000,
    'GAJI',
    true,
    'MONTHLY',
    NOW(),
    NOW()
),
(
    uuid_generate_v4(),
    'Sewa Toko',
    'Sewa tempat usaha per bulan',
    2500000,
    'SEWA',
    true,
    'MONTHLY',
    NOW(),
    NOW()
),
(
    uuid_generate_v4(),
    'Listrik & Air',
    'Tagihan listrik dan air bulanan',
    800000,
    'LISTRIK',
    true,
    'MONTHLY',
    NOW(),
    NOW()
),
(
    uuid_generate_v4(),
    'Internet & Telepon',
    'Biaya komunikasi bulanan',
    300000,
    'TRANSPORTASI',
    true,
    'MONTHLY',
    NOW(),
    NOW()
);