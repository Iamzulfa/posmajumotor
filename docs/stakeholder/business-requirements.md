# Business Requirements Document

## 1. Latar Belakang

Toko suku cadang motor membutuhkan sistem POS digital untuk:

- Menggantikan pencatatan manual yang rawan error
- Mengelola ribuan produk dengan berbagai varian
- Menerapkan harga berbeda untuk kategori pembeli
- Memantau keuangan dan kepatuhan pajak

## 2. Kebutuhan Bisnis

### 2.1 Manajemen Produk

**Kebutuhan:**

- Produk ratusan/ribuan item dari berbagai merek
- Varian produk (ukuran, warna, tipe)
- Kategorisasi (Ban, Oli, Rantai, Gearset, dll)
- Sub-kategori (Imitasi, Original Yamaha, Original Honda)
- Input manual (tidak semua distributor punya barcode)

**Solusi:**

- Database produk dengan kategori & sub-kategori
- Search & filter untuk pencarian cepat
- Form input produk yang fleksibel

### 2.2 Multi-Tier Pricing

**Kebutuhan:**

- Harga berbeda untuk 3 kategori pembeli
- Orang Umum: harga tertinggi (retail)
- Bengkel: harga menengah (diskon untuk reseller)
- Grossir: harga terendah (pembelian besar)

**Solusi:**

- 3 kolom harga per produk
- Selector tier saat transaksi
- Harga otomatis berubah sesuai tier

### 2.3 Metode Pembayaran

**Kebutuhan:**

- Cash (mayoritas transaksi)
- Transfer ke rekening owner
- QRIS

**Solusi:**

- Selector metode pembayaran
- Pencatatan per metode untuk rekonsiliasi

### 2.4 Tracking Keuangan

**Kebutuhan:**

- Profit harian (bukan hanya omset)
- Pengeluaran operasional
- Margin per produk
- Breakdown per tier pembeli

**Solusi:**

- Dashboard dengan rumus: Profit = Omset - HPP - Pengeluaran
- Input pengeluaran dengan kategorisasi
- Laporan breakdown per tier

### 2.5 Perpajakan

**Kebutuhan:**

- PPh Final 0.5% dari omset bruto
- Laporan untuk konsultan pajak
- Tracking status pembayaran

**Solusi:**

- Kalkulator pajak otomatis
- Export PDF laporan
- History pembayaran pajak

## 3. User Roles

### Admin (Owner)

- Akses penuh ke semua fitur
- Setting harga & diskon
- Lihat laporan keuangan
- Kelola pajak

### Kasir

- Transaksi penjualan
- Kelola stok produk
- Tidak bisa akses keuangan & pajak

## 4. Constraints

- **Single Store** - Satu toko, satu lokasi stok
- **Offline-First** - Harus bisa jalan tanpa internet
- **Mobile-Only** - Fokus di smartphone

## 5. Future Considerations

- Loyalty program untuk pelanggan
- Multi-store support
- Integrasi dengan aplikasi pajak pemerintah
- Barcode scanner
