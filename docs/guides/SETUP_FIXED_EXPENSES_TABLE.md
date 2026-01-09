# Setup Fixed Expenses Table

Untuk mengatasi error PostgrestException saat menambah pengeluaran tetap, Anda perlu membuat tabel `fixed_expenses` di database Supabase.

## Langkah-langkah:

### 1. Buka Supabase Dashboard
- Login ke [supabase.com](https://supabase.com)
- Pilih project Anda

### 2. Buka SQL Editor
- Di sidebar kiri, klik "SQL Editor"
- Klik "New query"

### 3. Jalankan SQL berikut:

```sql
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
```

### 4. Klik "Run" untuk menjalankan SQL

### 5. Verifikasi tabel sudah dibuat
- Buka "Table Editor" di sidebar
- Pastikan tabel `fixed_expenses` sudah muncul

## Setelah tabel dibuat:

1. **Restart aplikasi Flutter** untuk memastikan koneksi database fresh
2. **Coba tambah pengeluaran tetap baru** - seharusnya tidak ada error lagi
3. **Dashboard akan otomatis menggunakan data real** dari tabel fixed_expenses

## Troubleshooting:

Jika masih ada error:
1. Pastikan RLS policy sudah aktif
2. Cek di "Authentication" > "Users" bahwa user sudah authenticated
3. Restart aplikasi Flutter sepenuhnya

## Fitur yang akan berfungsi setelah setup:

✅ Tambah pengeluaran tetap baru
✅ Edit pengeluaran tetap
✅ Hapus pengeluaran tetap  
✅ Dashboard menggunakan data real (bukan hardcoded)
✅ Perhitungan profit yang akurat