# 📚 KIRO DOCUMENTATION INDEX - POSFELIX

> **Baca file ini terlebih dahulu saat memulai sesi baru setelah project dipindahkan.**

---

## 🚀 QUICK START

Untuk Kiro AI, baca file-file ini secara berurutan:

1. **[KIRO_PROJECT_MEMORY.md](./KIRO_PROJECT_MEMORY.md)** - Konteks utama project
2. **[KIRO_IMPLEMENTATION_STATUS.md](./KIRO_IMPLEMENTATION_STATUS.md)** - Status & checklist
3. **[KIRO_CODE_REFERENCE.md](./KIRO_CODE_REFERENCE.md)** - Pattern & snippets
4. **[KIRO_DATA_MODELS.md](./KIRO_DATA_MODELS.md)** - Database & entities

---

## 📋 PROJECT SUMMARY

| Item             | Value                              |
| ---------------- | ---------------------------------- |
| **Nama Project** | PosFELIX (MotoParts POS)           |
| **Framework**    | Flutter (Dart)                     |
| **Status**       | Frontend Complete, Backend Pending |
| **Target**       | Mobile, Web, Desktop               |

### Fitur Utama

- 🛒 POS dengan 3 tier harga (Umum/Bengkel/Grossir)
- 📦 Inventory management
- 📊 Dashboard financial cockpit
- 💰 Expense tracking
- 📋 Tax center & laporan (PPh 0.5%)

### User Roles

- **Admin:** Full access (Dashboard, Inventory, Transaction, Expense, Tax)
- **Kasir:** Limited access (Inventory, Transaction only)

---

## 📁 DOCUMENTATION FILES

### Kiro Memory Files (`.kiro/`)

| File                            | Description                                   |
| ------------------------------- | --------------------------------------------- |
| `KIRO_PROJECT_MEMORY.md`        | Overview, architecture, design system, routes |
| `KIRO_CODE_REFERENCE.md`        | Widget patterns, screen patterns, utilities   |
| `KIRO_DATA_MODELS.md`           | Database schema, entities, API endpoints      |
| `KIRO_IMPLEMENTATION_STATUS.md` | Progress tracking, checklist, known issues    |

### Specs (`.kiro/specs/pos-keuangan-pajak/`)

| File                           | Description                                       |
| ------------------------------ | ------------------------------------------------- |
| `requirements.md`              | 11 requirements dengan acceptance criteria        |
| `design.md`                    | Architecture, data models, correctness properties |
| `implementation-plan-kasir.md` | Task breakdown dengan estimasi waktu              |
| `project-structure.md`         | Folder structure & design patterns                |
| `layout-analysis.md`           | UI mockup analysis                                |
| `ui-ux-prompt.md`              | Responsive design guidelines                      |

### Developer Docs (`docs/developer/`)

| File                 | Description                    |
| -------------------- | ------------------------------ |
| `architecture.md`    | Clean architecture explanation |
| `setup-guide.md`     | Installation & build commands  |
| `components.md`      | Widget documentation           |
| `api-integration.md` | Planned API endpoints          |

---

## 🎯 CURRENT STATUS

### ✅ Completed

- Project setup & dependencies
- Theme & design system
- Routing (GoRouter)
- All UI screens (9 screens)
- All common widgets (8 widgets)
- Mock data implementation

### 🔜 Next Steps

1. Setup Supabase backend
2. Create Freezed data models
3. Implement repositories
4. Connect real data to UI
5. Add offline support

---

## 💻 QUICK COMMANDS

```bash
# Run app
flutter run

# Build APK
flutter build apk --release

# Generate code (Freezed)
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📝 NOTES FOR KIRO

Saat melanjutkan development:

1. **Selalu baca `KIRO_PROJECT_MEMORY.md`** untuk konteks lengkap
2. **Cek `KIRO_IMPLEMENTATION_STATUS.md`** untuk status terkini
3. **Gunakan patterns dari `KIRO_CODE_REFERENCE.md`** untuk konsistensi
4. **Ikuti schema dari `KIRO_DATA_MODELS.md`** untuk backend integration

---

_Created: December 14, 2025_
_Project: PosFELIX - POS + Keuangan & Pajak_
