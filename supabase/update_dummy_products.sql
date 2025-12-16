-- Step 1: Insert categories
INSERT INTO public.categories (name, description, is_active)
VALUES 
  ('Lampu', 'Lampu dan penerangan', true),
  ('Oli', 'Oli dan cairan mesin', true),
  ('Aki', 'Aki dan baterai', true),
  ('Suku Cadang', 'Suku cadang motor', true)
ON CONFLICT (name) DO NOTHING;

-- Step 2: Insert brands
INSERT INTO public.brands (name, description, is_active)
VALUES 
  ('LED', 'LED lighting brand', true),
  ('Motul', 'Motul oil brand', true),
  ('Yuasa', 'Yuasa battery brand', true),
  ('NGK', 'NGK spark plugs', true)
ON CONFLICT (name) DO NOTHING;

-- Step 3: Update products with category and brand
-- Get the IDs and update
WITH cat_ids AS (
  SELECT id, name FROM public.categories
),
brand_ids AS (
  SELECT id, name FROM public.brands
)
UPDATE public.products p
SET 
  category_id = CASE 
    WHEN p.name = 'Lampu Sein LED Orange' THEN (SELECT id FROM cat_ids WHERE name = 'Lampu')
    WHEN p.name = 'Oli Motul scooter LE 300 botol' THEN (SELECT id FROM cat_ids WHERE name = 'Oli')
    WHEN p.name = 'Aki Motor' THEN (SELECT id FROM cat_ids WHERE name = 'Aki')
    ELSE p.category_id
  END,
  brand_id = CASE 
    WHEN p.name = 'Lampu Sein LED Orange' THEN (SELECT id FROM brand_ids WHERE name = 'LED')
    WHEN p.name = 'Oli Motul scooter LE 300 botol' THEN (SELECT id FROM brand_ids WHERE name = 'Motul')
    WHEN p.name = 'Aki Motor' THEN (SELECT id FROM brand_ids WHERE name = 'Yuasa')
    ELSE p.brand_id
  END
WHERE p.name IN ('Lampu Sein LED Orange', 'Oli Motul scooter LE 300 botol', 'Aki Motor');
