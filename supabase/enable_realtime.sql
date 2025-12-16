-- Check which tables are already in supabase_realtime publication
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime'
ORDER BY tablename;

-- Enable real-time on tables that are not yet enabled
-- Run each one individually if you get errors

-- Try to add categories
ALTER PUBLICATION supabase_realtime ADD TABLE public.categories;

-- Try to add brands
ALTER PUBLICATION supabase_realtime ADD TABLE public.brands;

-- Try to add transactions
ALTER PUBLICATION supabase_realtime ADD TABLE public.transactions;

-- Try to add transaction_items
ALTER PUBLICATION supabase_realtime ADD TABLE public.transaction_items;

-- Try to add expenses
ALTER PUBLICATION supabase_realtime ADD TABLE public.expenses;

-- Try to add inventory_logs
ALTER PUBLICATION supabase_realtime ADD TABLE public.inventory_logs;

-- Try to add tax_payments
ALTER PUBLICATION supabase_realtime ADD TABLE public.tax_payments;

-- Try to add users
ALTER PUBLICATION supabase_realtime ADD TABLE public.users;

-- Verify final state
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime'
ORDER BY tablename;
