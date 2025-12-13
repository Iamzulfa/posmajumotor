# Project Scope

## In Scope ✅

### Phase 1: Frontend (Current)

- Login dengan role-based access
- Dashboard keuangan (Admin)
- Manajemen inventory
- Transaksi penjualan multi-tier
- Input pengeluaran
- Tax center dengan kalkulator pajak
- UI/UX sesuai mockup

### Phase 2: Backend (Next)

- Database Supabase
- REST API integration
- Real-time sync
- Data persistence

### Phase 3: Automation (Planned)

- n8n workflow setup
- PDF report generation
- WhatsApp notifications

## Out of Scope ❌

| Item                            | Alasan                         |
| ------------------------------- | ------------------------------ |
| Multi-store                     | Fokus single store dulu        |
| Barcode scanner                 | Tidak semua produk ada barcode |
| E-commerce integration          | Fokus offline POS              |
| Payroll system                  | Diluar scope POS               |
| Accounting software integration | Phase selanjutnya              |
| Loyalty program                 | Future enhancement             |
| Integrasi DJP Online            | Kompleksitas tinggi            |

## Deliverables

### Documentation

- [x] Requirements document
- [x] Design document
- [x] UI/UX mockups
- [x] Developer documentation
- [x] User guide

### Application

- [x] Login screen
- [x] Admin dashboard
- [x] Inventory management
- [x] Transaction screen
- [x] Expense management
- [x] Tax center
- [ ] Backend integration
- [ ] PDF export
- [ ] Notifications

## Assumptions

1. User memiliki smartphone Android/iOS
2. Koneksi internet tersedia (untuk sync)
3. Data produk akan di-input manual
4. Satu device per user (tidak sharing)

## Dependencies

| Dependency       | Status    |
| ---------------- | --------- |
| Flutter SDK      | ✅ Ready  |
| Supabase Account | 📋 Needed |
| n8n Server       | 📋 Needed |
| Domain/Hosting   | 📋 Needed |

## Risks

| Risk                  | Impact               | Mitigation                 |
| --------------------- | -------------------- | -------------------------- |
| Internet tidak stabil | Data tidak sync      | Offline-first architecture |
| User tidak tech-savvy | Adoption rendah      | UI sederhana, training     |
| Data loss             | Kehilangan transaksi | Auto-backup ke cloud       |
