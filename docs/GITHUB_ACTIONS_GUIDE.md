# Panduan GitHub Actions untuk Build Desktop

## Apa itu GitHub Actions?

GitHub Actions adalah fitur CI/CD gratis dari GitHub yang memungkinkan kamu menjalankan script otomatis di server GitHub. Untuk PosFELIX, kita gunakan untuk build aplikasi desktop tanpa perlu install toolchain di laptop.

## ⚠️ PENTING: Setup Secrets Dulu!

Sebelum build, kamu HARUS setup GitHub Secrets untuk credentials Supabase:

### Cara Setup Secrets:

1. Buka repository di GitHub
2. Klik **Settings** (tab paling kanan)
3. Di sidebar kiri, klik **Secrets and variables** → **Actions**
4. Klik **New repository secret**
5. Tambahkan 2 secrets:

| Name                | Value                                     |
| ------------------- | ----------------------------------------- |
| `SUPABASE_URL`      | `https://your-project.supabase.co`        |
| `SUPABASE_ANON_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |

```
┌─────────────────────────────────────────────────────────────┐
│ Settings > Secrets and variables > Actions                  │
│                                                             │
│ Repository secrets                                          │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ SUPABASE_URL         Updated 2 days ago    [Update]    │ │
│ │ SUPABASE_ANON_KEY    Updated 2 days ago    [Update]    │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ [New repository secret]                                     │
└─────────────────────────────────────────────────────────────┘
```

**Kenapa perlu secrets?**

- Credentials tidak boleh di-commit ke Git (security risk!)
- GitHub Secrets terenkripsi dan aman
- Hanya bisa diakses saat workflow jalan

---

## Cara Pakai (Step by Step)

### 1. Push Code ke GitHub

```bash
git add .
git commit -m "Add GitHub Actions for desktop build"
git push origin main
```

### 2. Buka Repository di GitHub

Buka browser, pergi ke: `https://github.com/USERNAME/posfelix`

### 3. Klik Tab "Actions"

```
┌─────────────────────────────────────────────────────────────┐
│  < > Code   ○ Issues   ⑂ Pull requests   ▶ Actions   ...   │
│                                            ^^^^^^^^         │
│                                            KLIK INI         │
└─────────────────────────────────────────────────────────────┘
```

### 4. Pilih Workflow "Build Desktop"

Di sidebar kiri, klik "Build Desktop"

```
┌──────────────────┬──────────────────────────────────────────┐
│ All workflows    │                                          │
│                  │  Build Desktop                           │
│ ▶ Build Desktop  │  ─────────────────────────────────────   │
│   ^^^^^^^^^^^^   │  This workflow has a workflow_dispatch   │
│   KLIK INI       │  event trigger.                          │
│                  │                                          │
│                  │  [Run workflow ▼]  ← KLIK INI            │
│                  │                                          │
└──────────────────┴──────────────────────────────────────────┘
```

### 5. Klik "Run workflow"

Akan muncul dropdown:

```
┌─────────────────────────────────┐
│ Use workflow from               │
│ Branch: main              ▼     │
│                                 │
│ Platform to build               │
│ ┌─────────────────────────┐     │
│ │ windows               ▼ │     │  ← Pilih platform
│ └─────────────────────────┘     │
│   - windows                     │
│   - linux                       │
│   - macos                       │
│   - all (build semua)           │
│                                 │
│ [Run workflow]  ← KLIK          │
└─────────────────────────────────┘
```

### 6. Tunggu Build Selesai

- Windows: ~8-12 menit
- Linux: ~5-8 menit
- macOS: ~10-15 menit
- All: ~15-20 menit (parallel)

Kamu bisa lihat progress dengan klik workflow run yang sedang jalan.

### 7. Download Hasil Build

Setelah selesai (centang hijau ✓):

```
┌─────────────────────────────────────────────────────────────┐
│ ✓ Build Desktop #1                                          │
│   main · 5 minutes ago                                      │
│                                                             │
│ ─────────────────────────────────────────────────────────── │
│                                                             │
│ Artifacts                                                   │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 📦 PosFELIX-Windows    45.2 MB    [Download]           │ │
│ │ 📦 PosFELIX-Linux      38.1 MB    [Download]           │ │
│ │ 📦 PosFELIX-macOS      52.3 MB    [Download]           │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                                             │
│ Klik [Download] untuk download file ZIP                     │
└─────────────────────────────────────────────────────────────┘
```

### 8. Extract dan Jalankan

**Windows:**

- Extract ZIP
- Jalankan `posfelix.exe`

**Linux:**

- Extract ZIP
- `chmod +x posfelix`
- `./posfelix`

**macOS:**

- Extract ZIP
- Double-click `PosFELIX.app`

---

## FAQ

### Q: Apakah gratis?

**A:** Ya! GitHub memberikan 2000 menit/bulan untuk repository public, 500 menit untuk private.

### Q: Berapa lama artifact disimpan?

**A:** 30 hari (bisa diubah di workflow file).

### Q: Bisa build otomatis setiap push?

**A:** Bisa! Ubah bagian `on:` di workflow file:

```yaml
on:
  push:
    branches: [main]
```

### Q: Build gagal, kenapa?

**A:** Klik workflow run yang gagal, lalu klik job yang error untuk lihat log detail.

---

## Troubleshooting

### Error: "flutter pub get failed"

- Cek `pubspec.yaml` tidak ada error
- Pastikan semua dependencies compatible

### Error: "Windows build failed"

- Cek folder `windows/` ada dan tidak corrupt
- Coba regenerate: `flutter create --platforms=windows .`

### Error: "Permission denied" (Linux/macOS)

- Normal untuk artifact, akan fix saat extract

---

## Tips

1. **Build Windows saja** jika klien pakai Windows (hemat waktu)
2. **Gunakan cache** - sudah diaktifkan di workflow
3. **Jangan build setiap commit** - gunakan manual trigger untuk hemat quota
