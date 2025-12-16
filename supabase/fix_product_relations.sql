-- Check current state
SELECT 'Categories count:' as info, COUNT(*) as count FROM public.categories
UNION ALL
SELECT 'Brands count:', COUNT(*) FROM public.brands
UNION ALL
SELECT 'Products with category_id:', COUNT(*) FROM public.products WHERE category_id IS NOT NULL
UNION ALL
SELECT 'Products with brand_id:', COUNT(*) FROM public.products WHERE brand_id IS NOT NULL;

-- If categories and brands are empty, insert them first
INSERT INTO public.categories (name, description, is_active)
SELECT 'Lampu', 'Lampu dan penerangan', true
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Lampu');

INSERT INTO public.categories (name, description, is_active)
SELECT 'Oli', 'Oli dan cairan mesin', true
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Oli');

INSERT INTO public.categories (name, description, is_active)
SELECT 'Aki', 'Aki dan baterai', true
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Aki');

INSERT INTO public.brands (name, description, is_active)
SELECT 'LED', 'LED lighting', true
WHERE NOT EXISTS (SELECT 1 FROM public.brands WHERE name = 'LED');

INSERT INTO public.brands (name, description, is_active)
SELECT 'Motul', 'Motul oil', true
WHERE NOT EXISTS (SELECT 1 FROM public.brands WHERE name = 'Motul');

INSERT INTO public.brands (name, description, is_active)
SELECT 'Yuasa', 'Yuasa battery', true
WHERE NOT EXISTS (SELECT 1 FROM public.brands WHERE name = 'Yuasa');

-- Now update products with category and brand
UPDATE public.products
SET category_id = (SELECT id FROM public.categories WHERE name = 'Lampu' LIMIT 1),
    brand_id = (SELECT id FROM public.brands WHERE name = 'LED' LIMIT 1)
WHERE name = 'Lampu Sein LED Orange' AND category_id IS NULL;

UPDATE public.products
SET category_id = (SELECT id FROM public.categories WHERE name = 'Oli' LIMIT 1),
    brand_id = (SELECT id FROM public.brands WHERE name = 'Motul' LIMIT 1)
WHERE name = 'Oli Motul scooter LE 300 botol' AND category_id IS NULL;

UPDATE public.products
SET category_id = (SELECT id FROM public.categories WHERE name = 'Aki' LIMIT 1),
    brand_id = (SELECT id FROM public.brands WHERE name = 'Yuasa' LIMIT 1)
WHERE name = 'Aki Motor' AND category_id IS NULL;

-- Verify results
SELECT 'After update - Products with relations:' as info;
SELECT name, category_id, brand_id FROM public.products LIMIT 5;
