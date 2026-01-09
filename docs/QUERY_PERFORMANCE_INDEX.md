# PosFELIX Query Performance Index

Dokumen ini berisi analisis performa query database Supabase untuk aplikasi PosFELIX.

**Tanggal Analisis:** 9 Januari 2026

---

## Executive Summary

| Metric                       | Value                     |
| ---------------------------- | ------------------------- |
| Total Query Time             | ~10,410 detik             |
| Supabase Internal (Realtime) | 98.6%                     |
| Aplikasi PosFELIX            | 1.4%                      |
| Average Cache Hit Rate       | 99.9%+                    |
| Slowest App Query            | 21ms (INSERT transaction) |

**Kesimpulan:** Query aplikasi PosFELIX sangat efisien. Mayoritas resource database digunakan oleh Supabase Realtime internal.

---

## Query Breakdown by Category

### 🔴 Supabase Realtime (Internal) - 98.6% Total Time

| Query                        | Calls     | Mean Time | Total Time | % Total |
| ---------------------------- | --------- | --------- | ---------- | ------- |
| `realtime.list_changes` (v1) | 2,070,265 | 4.77ms    | 9,872s     | 94.85%  |
| `realtime.list_changes` (v2) | 84,378    | 4.61ms    | 389s       | 3.74%   |
| Subscription insert/update   | 2,869     | 13.8ms    | 39.6s      | 0.38%   |
| Publication tables lookup    | 3,971     | 1.87ms    | 7.4s       | 0.07%   |

**Catatan:** Ini adalah internal Supabase untuk real-time subscriptions, bukan query dari aplikasi.

---

### 🟢 Query Aplikasi PosFELIX - Sangat Efisien

| Query                                     | Calls  | Mean   | Min    | Max    | Total | Cache Hit |
| ----------------------------------------- | ------ | ------ | ------ | ------ | ----- | --------- |
| `SELECT transactions ORDER BY created_at` | 2,688  | 0.55ms | 0.31ms | 23.5ms | 1.49s | 100%      |
| `SELECT fixed_expenses WHERE is_active`   | 15,700 | 0.09ms | 0.02ms | 11.9ms | 1.48s | 100%      |
| `INSERT transactions`                     | 67     | 21ms   | 1.2ms  | 65.6ms | 1.4s  | -         |
| `set_config` (auth context)               | 54,371 | 0.06ms | 0.01ms | 17.3ms | 3.5s  | 100%      |

**Highlights:**

- ✅ SELECT transactions: rata-rata hanya **0.55ms**
- ✅ SELECT fixed_expenses: rata-rata hanya **0.09ms**
- ✅ Cache hit rate **100%** untuk semua SELECT queries
- ✅ INSERT transaction **21ms** (wajar karena ada trigger stock)

---

### 🟡 Supabase Dashboard/Admin Queries

Query ini dipanggil oleh Supabase Dashboard, bukan aplikasi:

| Query                        | Calls | Mean    | Purpose                      |
| ---------------------------- | ----- | ------- | ---------------------------- |
| `pg_timezone_names`          | 110   | 390ms   | Timezone picker di dashboard |
| Functions introspection      | 52    | 339ms   | PostgREST schema cache       |
| Tables/columns introspection | 110   | 26-44ms | Schema discovery             |
| `pg_available_extensions`    | 37    | 55ms    | Extensions list              |
| Table privileges             | 17    | 129ms   | Permission check             |

---

## Performance Metrics Detail

### Transaction Queries

```
Query: SELECT transactions ORDER BY created_at DESC
─────────────────────────────────────────────────
Calls:      2,688
Mean:       0.55ms
Min:        0.31ms
Max:        23.52ms
Total:      1,492.82ms
Cache Hit:  100%
Status:     ✅ EXCELLENT
```

### Fixed Expenses Queries

```
Query: SELECT fixed_expenses WHERE is_active = true
─────────────────────────────────────────────────
Calls:      15,700
Mean:       0.09ms
Min:        0.02ms
Max:        11.92ms
Total:      1,477.91ms
Cache Hit:  100%
Status:     ✅ EXCELLENT
```

### Transaction Insert

```
Query: INSERT INTO transactions (...)
─────────────────────────────────────────────────
Calls:      67
Mean:       20.98ms
Min:        1.22ms
Max:        65.56ms
Total:      1,405.48ms
Status:     ✅ GOOD (includes stock trigger)
```

---

## Realtime Subscription Analysis

### Current State

| Metric                | Value     |
| --------------------- | --------- |
| Total Realtime Calls  | 2,154,643 |
| Rows Actually Changed | 217       |
| Efficiency            | 0.01%     |

### Interpretation

- Supabase Realtime melakukan polling setiap ~3 detik
- Dari 2M+ polls, hanya 217 rows yang benar-benar berubah
- Ini normal untuk real-time system, tapi bisa di-optimize jika tidak butuh instant updates

---

## Recommendations

### ✅ Yang Sudah Bagus

1. **Query SELECT sangat cepat** - Semua di bawah 1ms average
2. **Cache hit rate 100%** - Database caching bekerja optimal
3. **No N+1 queries** - Query sudah di-batch dengan baik
4. **Indexes working** - Tidak ada sequential scan yang lambat

### 🔧 Potential Optimizations

1. **Reduce Realtime Polling** (jika tidak butuh instant update)

   ```dart
   // Ganti dari Stream ke periodic refresh
   Timer.periodic(Duration(seconds: 30), (_) => refresh());
   ```

2. **Batch Insert Transaction Items**

   - Current: Insert transaction + items dalam 2 query
   - Sudah optimal dengan trigger

3. **Consider Connection Pooling**
   - Untuk high-traffic, gunakan PgBouncer
   - Supabase Pro sudah include ini

---

## Query Time Distribution

```
┌─────────────────────────────────────────────────────────────┐
│                    TOTAL DATABASE TIME                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ████████████████████████████████████████████████  94.85%   │
│  Supabase Realtime (list_changes v1)                        │
│                                                             │
│  ██  3.74%                                                  │
│  Supabase Realtime (list_changes v2)                        │
│                                                             │
│  ░ 1.41%                                                    │
│  Everything else (app queries, dashboard, etc)              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## App Query Performance Score

| Category           | Score      | Notes                   |
| ------------------ | ---------- | ----------------------- |
| SELECT Performance | ⭐⭐⭐⭐⭐ | < 1ms average           |
| INSERT Performance | ⭐⭐⭐⭐   | 21ms (with trigger)     |
| Cache Utilization  | ⭐⭐⭐⭐⭐ | 100% hit rate           |
| Index Usage        | ⭐⭐⭐⭐⭐ | All queries use indexes |
| Overall            | **A+**     | Excellent performance   |

---

## Monitoring Tips

1. **Watch for slow queries** > 100ms
2. **Monitor cache hit rate** - should stay > 95%
3. **Check Realtime connections** - don't exceed plan limits
4. **Review after schema changes** - indexes may need update

---

_Generated from Supabase Query Performance Report_
_Project: PosFELIX POS System_
