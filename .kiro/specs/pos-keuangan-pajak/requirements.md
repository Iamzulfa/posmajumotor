# Requirements Document: POS + Modul Keuangan & Pajak

## Introduction

Sistem POS terintegrasi untuk toko suku cadang motor dengan fokus pada manajemen inventory kompleks (ratusan/ribuan produk dengan varian), transaksi multi-tier pricing (Umum/Bengkel/Grossir), dan modul keuangan & pajak real-time. Sistem ini memungkinkan owner untuk memonitor kesehatan finansial toko melalui dashboard mobile, mengelola pengeluaran, tracking margin produk, dan menghasilkan laporan pajak otomatis.

## Glossary

- **POS (Point of Sale)**: Sistem transaksi penjualan di toko
- **Inventory**: Daftar produk dan stok yang tersedia
- **Varian Produk**: Variasi dari satu produk (ukuran, warna, merek, tipe)
- **Buyer Tier**: Kategori pembeli (Umum, Bengkel, Grossir)
- **HPP (Harga Pokok Penjualan)**: Harga beli produk dari distributor
- **Margin**: Selisih antara harga jual dan HPP
- **Omset**: Total penjualan (revenue)
- **Profit/Laba**: Omset dikurangi HPP dan pengeluaran
- **Pajak Berjalan**: Estimasi pajak yang harus dibayar (0.5% dari omset)
- **Stock Opname**: Penghitungan stok fisik barang
- **Diskon**: Potongan harga yang ditetapkan admin
- **Refund**: Pengembalian barang dan uang
- **Cashflow**: Arus kas masuk dan keluar
- **Admin/Bos**: Pemilik toko dengan akses penuh
- **Cashier**: Operator kasir dengan akses terbatas
- **n8n**: Platform automation untuk generate PDF dan notifikasi
- **Supabase**: Backend database (PostgreSQL) dengan REST API
- **Flutter**: Framework untuk aplikasi mobile dan web

---

## Requirements

### Requirement 1: Manajemen Inventory & Produk

**User Story:** Sebagai admin, saya ingin mengelola inventory dengan ribuan produk dan varian kompleks, sehingga saya dapat melacak stok dengan akurat dan memudahkan pencarian produk.

#### Acceptance Criteria

1. WHEN admin membuka halaman inventory THEN sistem SHALL menampilkan daftar semua produk dengan kategori, sub-kategori, dan varian
2. WHEN admin menambah produk baru THEN sistem SHALL menerima input: nama produk, kategori, sub-kategori, tipe (imitasi/orisinil), varian (ukuran/warna/merek), HPP, harga jual per tier, dan stok awal
3. WHEN admin menginput produk dari nota distributor THEN sistem SHALL menyimpan data produk ke katalog dan dapat dicari berdasarkan nama, kategori, atau merek
4. WHEN stok produk berkurang karena penjualan THEN sistem SHALL otomatis mengurangi stok di database secara real-time
5. WHEN admin melakukan stock opname manual THEN sistem SHALL memungkinkan adjustment stok dan mencatat waktu serta alasan perubahan
6. WHEN admin mencari produk THEN sistem SHALL menampilkan hasil berdasarkan nama, kategori, merek, atau varian dengan response time kurang dari 1 detik

---

### Requirement 2: Transaksi Penjualan Multi-Tier

**User Story:** Sebagai admin/cashier, saya ingin memproses transaksi penjualan dengan harga berbeda berdasarkan tipe pembeli (Umum/Bengkel/Grossir), sehingga saya dapat mengelola pricing strategy yang kompleks.

#### Acceptance Criteria

1. WHEN cashier membuat transaksi baru THEN sistem SHALL menampilkan form untuk memilih buyer tier (Umum/Bengkel/Grossir) dan produk yang dijual
2. WHEN cashier memilih buyer tier THEN sistem SHALL menampilkan harga jual yang sesuai dengan tier tersebut
3. WHEN cashier menambah produk ke transaksi THEN sistem SHALL menampilkan harga, diskon (jika ada), dan total harga per item
4. WHEN transaksi selesai THEN sistem SHALL mencatat: waktu transaksi (jam:menit:detik), buyer tier, produk, harga, diskon, metode pembayaran (Cash/Transfer/QRIS), dan total pembayaran
5. WHEN pembeli memilih metode pembayaran THEN sistem SHALL menerima salah satu dari: Cash, Transfer ke rekening owner, atau QRIS
6. WHEN transaksi cash THEN sistem SHALL mencatat dengan jelas nominal uang masuk dan kembalian
7. WHEN admin membuat diskon THEN sistem SHALL menyimpan diskon dengan nama, persentase/nominal, dan tanggal berlaku
8. WHEN cashier memproses transaksi THEN sistem SHALL memungkinkan cashier memilih diskon yang sudah dibuat admin (cashier tidak bisa membuat diskon baru)

---

### Requirement 3: Manajemen Pengeluaran & Expense Tracking

**User Story:** Sebagai admin, saya ingin mencatat pengeluaran harian melalui HP, sehingga saya dapat melacak cashflow dan menghitung profit yang akurat.

#### Acceptance Criteria

1. WHEN admin membuka menu pengeluaran THEN sistem SHALL menampilkan tombol "+ Tambah Pengeluaran" dan daftar pengeluaran hari ini
2. WHEN admin menambah pengeluaran THEN sistem SHALL menerima input: kategori (Listrik/Gaji/Plastik/Makan Siang/Lainnya), nominal, catatan, dan waktu
3. WHEN admin menambah pengeluaran THEN sistem SHALL menyimpan pengeluaran dengan timestamp (jam:menit:detik) untuk tracking harian
4. WHEN admin melihat daftar pengeluaran THEN sistem SHALL menampilkan total pengeluaran hari ini dan breakdown per kategori
5. WHEN admin membuka halaman pengeluaran THEN sistem SHALL menampilkan riwayat pengeluaran dengan filter berdasarkan tanggal dan kategori

---

### Requirement 4: Dashboard Financial Cockpit

**User Story:** Sebagai owner, saya ingin melihat kesehatan finansial toko dalam sekali pandang melalui HP, sehingga saya dapat membuat keputusan bisnis dengan cepat.

#### Acceptance Criteria

1. WHEN owner membuka dashboard THEN sistem SHALL menampilkan "Real-time Profit Widget" yang menunjukkan Laba Bersih Hari Ini dengan rumus: (Total Penjualan Hari Ini) - (Total HPP Terjual) - (Pengeluaran Hari Ini)
2. WHEN owner melihat dashboard THEN sistem SHALL menampilkan "Indikator Pajak Berjalan" berupa progress bar atau angka estimasi "Tabungan Pajak Bulan Ini" (0.5% dari omset bulan ini)
3. WHEN owner melihat dashboard THEN sistem SHALL menampilkan "Trend Grafik" line chart yang membandingkan Omset vs Profit 7 hari terakhir
4. WHEN owner membuka dashboard THEN sistem SHALL menampilkan breakdown profit per buyer tier (Umum/Bengkel/Grossir) untuk hari ini
5. WHEN owner membuka dashboard THEN sistem SHALL menampilkan total transaksi hari ini dan rata-rata nilai transaksi
6. WHEN dashboard dimuat THEN sistem SHALL menampilkan data real-time (update otomatis setiap 5 detik atau saat ada transaksi baru)

---

### Requirement 5: Manajemen HPP & Margin

**User Story:** Sebagai admin, saya ingin mengelola HPP dan margin produk, sehingga saya dapat memastikan pricing yang menguntungkan dan menghindari kerugian.

#### Acceptance Criteria

1. WHEN admin membuka halaman produk THEN sistem SHALL menampilkan HPP, harga jual per tier, dan margin (%) untuk setiap produk
2. WHEN admin mengupdate HPP produk THEN sistem SHALL menyimpan perubahan dan menghitung ulang margin otomatis
3. WHEN admin mengupdate harga jual produk THEN sistem SHALL menghitung margin baru dan menampilkan perubahan
4. WHEN admin set harga jual lebih rendah dari HPP THEN sistem SHALL menampilkan alert merah "RUGI!" dan mencegah penyimpanan sampai harga diperbaiki
5. WHEN admin melakukan stock opname THEN sistem SHALL memungkinkan update HPP bersamaan dengan adjustment stok

---

### Requirement 6: Laporan & Perpajakan

**User Story:** Sebagai admin, saya ingin menghasilkan laporan keuangan dan pajak otomatis, sehingga saya dapat memenuhi kewajiban pajak dan membuat keputusan bisnis berdasarkan data.

#### Acceptance Criteria

1. WHEN admin membuka "Tax Center" THEN sistem SHALL menampilkan "Laporan Laba Rugi" dalam format mobile-friendly dengan opsi expand untuk detail
2. WHEN admin membuka laporan THEN sistem SHALL menampilkan: Total Omset, Total HPP, Total Pengeluaran, dan Profit Bersih untuk periode yang dipilih
3. WHEN admin membuka laporan THEN sistem SHALL menampilkan tombol "Export PDF" untuk generate laporan resmi
4. WHEN admin klik "Export PDF" THEN sistem SHALL generate PDF laporan dan mengirimkan ke n8n untuk disimpan/dikirim
5. WHEN admin membuka "Kalkulator PPh Final" THEN sistem SHALL menampilkan form untuk memilih bulan
6. WHEN admin memilih bulan di kalkulator pajak THEN sistem SHALL menampilkan: Total Omset Bulan, Estimasi Pajak (0.5%), dan tombol "Tandai Sudah Bayar"
7. WHEN admin klik "Tandai Sudah Bayar" THEN sistem SHALL mencatat tanggal pembayaran pajak untuk arsip
8. WHEN admin membuka laporan THEN sistem SHALL menampilkan breakdown profit per buyer tier (Umum/Bengkel/Grossir) untuk analisis

---

### Requirement 7: Manajemen Refund & Return

**User Story:** Sebagai cashier/admin, saya ingin memproses refund dengan kategori dan alasan yang jelas, sehingga saya dapat melacak return barang dan menjaga kepuasan pelanggan.

#### Acceptance Criteria

1. WHEN cashier membuka menu refund THEN sistem SHALL menampilkan form untuk memilih transaksi yang akan di-refund
2. WHEN cashier memilih transaksi THEN sistem SHALL menampilkan detail produk, harga, dan metode pembayaran asli
3. WHEN cashier memproses refund THEN sistem SHALL menerima input: kategori refund (Rusak/Tidak Sesuai/Tidak Diperlukan), alasan detail, dan jumlah item yang di-refund
4. WHEN refund diproses THEN sistem SHALL otomatis: mengembalikan stok produk, mencatat refund dengan timestamp, dan mencatat metode pengembalian uang
5. WHEN refund diproses THEN sistem SHALL menampilkan konfirmasi refund dan menyimpan riwayat untuk audit

---

### Requirement 8: Kontrol Akses & User Management

**User Story:** Sebagai admin, saya ingin mengatur akses berbeda untuk admin dan cashier, sehingga saya dapat menjaga keamanan data dan membatasi operasi sesuai role.

#### Acceptance Criteria

1. WHEN admin login THEN sistem SHALL menampilkan akses penuh: inventory, transaksi, pricing, diskon, membership, promo, laporan, pajak, dan settings
2. WHEN cashier login THEN sistem SHALL menampilkan akses penuh ke: inventory (create/read/update/delete), transaksi penjualan (create/read/update/refund), dan pemilihan diskon
3. WHEN cashier mencoba akses fitur admin (dashboard, laporan, pajak, settings) THEN sistem SHALL menampilkan pesan "Akses Ditolak" dan tidak menampilkan fitur tersebut
4. WHEN admin membuka aplikasi THEN sistem SHALL menampilkan dashboard dengan semua data finansial dan operasional
5. WHEN cashier membuka aplikasi THEN sistem SHALL menampilkan halaman transaksi penjualan sebagai default
6. WHEN cashier membuka aplikasi THEN sistem SHALL menampilkan akses ke inventory management (full CRUD) dan transaksi management (full CRUD + refund)

---

### Requirement 9: Integrasi n8n untuk Automation

**User Story:** Sebagai admin, saya ingin mengotomatisasi generate laporan PDF dan notifikasi pajak melalui n8n, sehingga saya dapat menghemat waktu dan tidak lupa membayar pajak.

#### Acceptance Criteria

1. WHEN admin klik "Export PDF" di laporan THEN sistem SHALL mengirim data laporan ke n8n via webhook
2. WHEN n8n menerima data laporan THEN sistem SHALL generate PDF dengan format profesional dan menyimpan file
3. WHEN laporan PDF selesai di-generate THEN sistem SHALL mengirim notifikasi ke admin (push notification atau email)
4. WHEN tanggal pembayaran pajak mendekati THEN sistem SHALL mengirim reminder notifikasi ke admin
5. WHEN admin tandai pajak sudah dibayar THEN sistem SHALL mencatat dan mengirim konfirmasi ke n8n untuk arsip

---

### Requirement 10: Real-time Sync & Offline Support

**User Story:** Sebagai admin/cashier, saya ingin aplikasi dapat bekerja offline dan sync otomatis saat online, sehingga operasional tidak terganggu meski internet putus.

#### Acceptance Criteria

1. WHEN aplikasi offline THEN sistem SHALL menyimpan transaksi ke local SQLite cache
2. WHEN aplikasi kembali online THEN sistem SHALL otomatis sync data ke Supabase via REST API
3. WHEN sync terjadi THEN sistem SHALL menampilkan status "Syncing..." dan "Sync Berhasil" atau error message
4. WHEN ada konflik data saat sync THEN sistem SHALL menggunakan timestamp untuk menentukan data mana yang lebih baru
5. WHEN aplikasi offline THEN sistem SHALL tetap menampilkan data dari cache lokal (inventory, transaksi sebelumnya)

---

### Requirement 11: Laporan Penjualan Harian & Analisis

**User Story:** Sebagai admin, saya ingin melihat laporan penjualan harian dengan breakdown per buyer tier, sehingga saya dapat menganalisis performa dan merencanakan strategi penjualan.

#### Acceptance Criteria

1. WHEN admin membuka "Laporan Harian" THEN sistem SHALL menampilkan: Total Omset Hari Ini, Total Profit, dan breakdown per buyer tier (Umum/Bengkel/Grossir)
2. WHEN admin melihat laporan harian THEN sistem SHALL menampilkan: jumlah transaksi per tier, rata-rata nilai transaksi, dan produk terlaris
3. WHEN admin membuka laporan THEN sistem SHALL menampilkan grafik perbandingan omset vs profit per tier
4. WHEN admin membuka laporan THEN sistem SHALL menampilkan tombol "View Details" untuk melihat transaksi individual
5. WHEN admin membuka laporan THEN sistem SHALL menampilkan data real-time yang update setiap ada transaksi baru
