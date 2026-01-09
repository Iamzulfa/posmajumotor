-- Create fixed_expenses table
CREATE TABLE IF NOT EXISTS fixed_expenses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    amount INTEGER NOT NULL CHECK (amount > 0),
    category VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    recurrence_type VARCHAR(20) DEFAULT 'MONTHLY' CHECK (recurrence_type IN ('DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for better query performance
CREATE INDEX IF NOT EXISTS idx_fixed_expenses_active ON fixed_expenses(is_active);
CREATE INDEX IF NOT EXISTS idx_fixed_expenses_category ON fixed_expenses(category);
CREATE INDEX IF NOT EXISTS idx_fixed_expenses_created_at ON fixed_expenses(created_at);

-- Create trigger to automatically update updated_at
CREATE OR REPLACE FUNCTION update_fixed_expenses_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IF NOT EXISTS trigger_update_fixed_expenses_updated_at
    BEFORE UPDATE ON fixed_expenses
    FOR EACH ROW
    EXECUTE FUNCTION update_fixed_expenses_updated_at();

-- Enable Row Level Security (RLS)
ALTER TABLE fixed_expenses ENABLE ROW LEVEL SECURITY;

-- Create policy to allow all operations for authenticated users
CREATE POLICY IF NOT EXISTS "Allow all operations for authenticated users" ON fixed_expenses
    FOR ALL USING (auth.role() = 'authenticated');

-- Insert some sample data for testing
INSERT INTO fixed_expenses (name, description, amount, category, is_active, recurrence_type) VALUES
    ('Gaji Karyawan', 'Gaji bulanan untuk 2 karyawan', 8000000, 'GAJI', true, 'MONTHLY'),
    ('Sewa Toko', 'Sewa tempat usaha per bulan', 2500000, 'SEWA', true, 'MONTHLY'),
    ('Listrik & Air', 'Tagihan listrik dan air bulanan', 800000, 'LISTRIK', true, 'MONTHLY')
ON CONFLICT (id) DO NOTHING;