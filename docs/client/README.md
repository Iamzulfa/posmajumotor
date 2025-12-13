# Panduan Pengguna - MotoParts POS

## Tentang Aplikasi

MotoParts POS adalah aplikasi kasir untuk toko suku cadang motor dengan fitur:

- Manajemen produk & stok
- Transaksi penjualan multi-tier
- Pencatatan pengeluaran
- Laporan keuangan & pajak

## Cara Login

1. Buka aplikasi MotoParts POS
2. Masukkan email dan password
3. Tekan tombol "Masuk"

**Akun Demo:**
| Role | Email | Password |
|------|-------|----------|
| Admin | admin@toko.com | admin123 |
| Kasir | kasir@toko.com | kasir123 |

## Fitur Berdasarkan Role

### Admin (Pemilik Toko)

- ✅ Dashboard keuangan
- ✅ Kelola produk (tambah/edit/hapus)
- ✅ Transaksi penjualan
- ✅ Catat pengeluaran
- ✅ Laporan pajak

### Kasir

- ✅ Kelola produk (tambah/edit/hapus)
- ✅ Transaksi penjualan
- ❌ Dashboard (tidak bisa akses)
- ❌ Pengeluaran (tidak bisa akses)
- ❌ Pajak (tidak bisa akses)

## Panduan Fitur

### 1. Transaksi Penjualan

**Langkah:**

1. Pilih tier pembeli (Orang Umum / Bengkel / Grossir)
2. Cari produk yang ingin dijual
3. Tekan tombol (+) untuk menambah ke keranjang
4. Atur jumlah dengan tombol (-) dan (+)
5. Pilih metode pembayaran (Cash / Transfer / QRIS)
6. Tekan "Selesaikan" untuk menyelesaikan transaksi

**Tier Harga:**

- **Orang Umum**: Harga tertinggi (retail)
- **Bengkel**: Harga menengah (diskon untuk bengkel)
- **Grossir**: Harga terendah (pembelian besar)

### 2. Kelola Produk (Inventory)

**Melihat Produk:**

- Gunakan search untuk mencari produk
- Filter berdasarkan kategori

**Informasi Produk:**

- Nama produk
- Kategori & merek
- Stok tersedia
- Margin keuntungan (%)
- HPP (Harga Pokok Pembelian)
- Harga jual

### 3. Catat Pengeluaran (Admin)

**Langkah:**

1. Buka menu "Keuangan"
2. Tekan tombol "+ Tambah"
3. Pilih kategori (Listrik/Gaji/Plastik/Makan Siang/Lainnya)
4. Masukkan nominal
5. Tambahkan catatan (opsional)
6. Tekan "Simpan"

### 4. Dashboard (Admin)

**Informasi yang ditampilkan:**

- Laba bersih hari ini
- Tabungan pajak bulan ini
- Jumlah transaksi
- Rata-rata transaksi
- Total pengeluaran
- Margin keuntungan
- Grafik trend 7 hari
- Breakdown per tier pembeli

### 5. Tax Center (Admin)

**Tab Laporan:**

- Laporan laba rugi bulanan
- Breakdown per tier pembeli
- Export PDF

**Tab Kalkulator Pajak:**

- Kalkulasi PPh Final (0.5% dari omset)
- Status pembayaran
- Riwayat pembayaran pajak

## Tips Penggunaan

1. **Sync Status**: Perhatikan indikator "Online/Offline" di header
2. **Logout**: Tekan ikon (→) di pojok kanan atas untuk keluar
3. **Navigasi**: Gunakan menu di bawah layar untuk berpindah fitur
