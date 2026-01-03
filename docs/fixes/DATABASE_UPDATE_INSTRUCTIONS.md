# Database Update Instructions

## Issue Fixed: Daily Expense Creation Error

**Problem**: When trying to add a daily expense with "Marketing" category, you got this error:
```
PostgrestException: new row for relation "expenses" violates check constraint "expenses_category_check"
```

**Root Cause**: The database constraint only allowed these categories:
- GAJI, SEWA, LISTRIK, TRANSPORTASI, PERAWATAN, SUPPLIES, LAINNYA

But the app was trying to save "MARKETING" which wasn't in the allowed list.

## Solution: Update Database Constraint

### Step 1: Open Supabase SQL Editor
1. Go to your Supabase dashboard
2. Navigate to "SQL Editor"
3. Create a new query

### Step 2: Run This SQL Command
Copy and paste this SQL command to update the constraint:

```sql
-- Update expenses table constraint to include MARKETING
ALTER TABLE public.expenses 
DROP CONSTRAINT IF EXISTS expenses_category_check;

ALTER TABLE public.expenses 
ADD CONSTRAINT expenses_category_check 
CHECK (category IN ('GAJI', 'SEWA', 'LISTRIK', 'TRANSPORTASI', 'PERAWATAN', 'SUPPLIES', 'MARKETING', 'LAINNYA'));

-- Update fixed_expenses table constraint to include MARKETING
ALTER TABLE public.fixed_expenses 
DROP CONSTRAINT IF EXISTS fixed_expenses_category_check;

ALTER TABLE public.fixed_expenses 
ADD CONSTRAINT fixed_expenses_category_check 
CHECK (category IN ('GAJI', 'SEWA', 'LISTRIK', 'TRANSPORTASI', 'PERAWATAN', 'SUPPLIES', 'MARKETING', 'LAINNYA'));
```

### Step 3: Execute the Query
Click "Run" to execute the SQL commands.

### Step 4: Verify the Fix
After running the SQL, try adding a daily expense with "Marketing" category again. It should work now!

## What This Does
- Adds "MARKETING" as a valid category for both daily expenses and fixed expenses
- Allows you to create marketing-related expenses like "Pembelian kaos motul"
- Maintains all existing functionality

## Available Categories After Update
- **GAJI** - Salary expenses
- **SEWA** - Rent expenses  
- **LISTRIK** - Electricity expenses
- **TRANSPORTASI** - Transportation expenses
- **PERAWATAN** - Maintenance expenses
- **SUPPLIES** - Supply expenses
- **MARKETING** - Marketing expenses ✅ (newly added)
- **LAINNYA** - Other expenses

The app has been updated to include "Marketing" in the category dropdown, so once you update the database constraint, everything will work perfectly!