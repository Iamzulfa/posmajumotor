# Daftar Fitur Aplikasi

## 1. Autentikasi

| Fitur             | Deskripsi                         |
| ----------------- | --------------------------------- |
| Login             | Masuk dengan email & password     |
| Remember Me       | Ingat kredensial login            |
| Role-based Access | Akses berbeda untuk Admin & Kasir |

## 2. Dashboard (Admin Only)

| Fitur          | Deskripsi                                       |
| -------------- | ----------------------------------------------- |
| Laba Bersih    | Profit hari ini (Penjualan - HPP - Pengeluaran) |
| Tabungan Pajak | Progress pajak 0.5% dari omset                  |
| Quick Stats    | Transaksi, rata-rata, pengeluaran, margin       |
| Trend Chart    | Grafik omset vs profit 7 hari                   |
| Tier Breakdown | Penjualan per kategori pembeli                  |

## 3. Inventory (Admin & Kasir)

| Fitur         | Deskripsi                          |
| ------------- | ---------------------------------- |
| Lihat Produk  | Daftar semua produk dengan detail  |
| Search        | Cari produk berdasarkan nama/merek |
| Filter        | Filter berdasarkan kategori        |
| Tambah Produk | Input produk baru                  |
| Edit Produk   | Ubah detail produk                 |
| Hapus Produk  | Hapus produk dari sistem           |

**Informasi Produk:**

- Nama produk
- Kategori (Ban, Oli, Rantai, Gearset, dll)
- Merek
- Stok
- HPP (Harga Pokok Pembelian)
- Harga jual per tier
- Margin keuntungan

## 4. Transaksi Penjualan (Admin & Kasir)

| Fitur        | Deskripsi                      |
| ------------ | ------------------------------ |
| Pilih Tier   | Orang Umum / Bengkel / Grossir |
| Cari Produk  | Search produk untuk dijual     |
| Keranjang    | Tambah/kurang/hapus item       |
| Metode Bayar | Cash / Transfer / QRIS         |
| Catatan      | Tambah catatan transaksi       |
| Selesaikan   | Proses transaksi               |

**Tier Harga:**
| Tier | Target | Harga |
|------|--------|-------|
| Orang Umum | End consumer | Tertinggi |
| Bengkel | Bengkel motor | Menengah |
| Grossir | Reseller/grosir | Terendah |

## 5. Pengeluaran (Admin Only)

| Fitur              | Deskripsi                      |
| ------------------ | ------------------------------ |
| Total Hari Ini     | Jumlah pengeluaran hari ini    |
| Breakdown Kategori | Persentase per kategori        |
| Daftar Pengeluaran | List pengeluaran dengan detail |
| Tambah Pengeluaran | Input pengeluaran baru         |

**Kategori Pengeluaran:**

- Listrik
- Gaji
- Plastik
- Makan Siang
- Lainnya

## 6. Tax Center (Admin Only)

### Tab Laporan

| Fitur          | Deskripsi                       |
| -------------- | ------------------------------- |
| Pilih Bulan    | Filter laporan per bulan        |
| Laba Rugi      | Omset, HPP, Pengeluaran, Profit |
| Tier Breakdown | Detail per tier (expandable)    |
| Export PDF     | Generate laporan PDF            |

### Tab Kalkulator Pajak

| Fitur         | Deskripsi                |
| ------------- | ------------------------ |
| Kalkulasi PPh | 0.5% dari total omset    |
| Status Bayar  | Belum/Sudah dibayar      |
| Tandai Bayar  | Mark as paid             |
| Riwayat       | History pembayaran pajak |

## 7. Fitur Umum

| Fitur             | Deskripsi                   |
| ----------------- | --------------------------- |
| Sync Status       | Indikator online/offline    |
| Last Sync         | Waktu sinkronisasi terakhir |
| Logout            | Keluar dari aplikasi        |
| Bottom Navigation | Navigasi antar fitur        |
