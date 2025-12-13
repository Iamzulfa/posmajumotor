# Layout Analysis & Project Structure

## Mockup Analysis

### Screen 1: Login Screen

**Layout Structure:**

```
┌─────────────────────────────────────┐
│ [Logo/Branding - M]                 │
│ MotoParts POS                       │
│ Kelola toko suku cadang Anda        │
├─────────────────────────────────────┤
│ Email                               │
│ [email@example.com]                 │
├─────────────────────────────────────┤
│ Password                            │
│ [••••••••] [👁️]                     │
├─────────────────────────────────────┤
│ ☐ Ingat saya                        │
├─────────────────────────────────────┤
│ [Masuk Button]                      │
├─────────────────────────────────────┤
│ Lupa Password?                      │
├─────────────────────────────────────┤
│ Demo Credentials:                   │
│ Admin: admin@toko.com / admin123    │
│ Kasir: kasir@toko.com / kasir123    │
└─────────────────────────────────────┘
```

**Key Components:**

- Logo container (centered)
- Title & subtitle
- Email input field
- Password input field (with visibility toggle)
- Remember me checkbox
- Login button (full width, teal color)
- Forgot password link
- Demo credentials info box

**Responsive Behavior:**

- Single column layout
- Full-width inputs
- Centered content
- Scrollable if needed

---

### Screen 2: Transaction (Transaksi Penjualan) - Kasir Role

**Layout Structure (3 states shown):**

#### State 1: Product Selection

```
┌─────────────────────────────────────┐
│ Transaksi Penjualan          [→]    │ ← Header
│ 🟢 Online • Last sync: 2 min ago    │ ← Status bar
├─────────────────────────────────────┤
│ Tier Pembeli                        │
│ [Orang Umum] [Bengkel] [Grossir]   │ ← Tier selector (pills)
├─────────────────────────────────────┤
│ Produk Tersedia                     │
│ [🔍 Cari produk...]                 │ ← Search bar
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Ban Michelin 90/90 Ring 14      │ │
│ │ Stok: 15 | Rp 450.000           │ │
│ │                          [+]    │ │ ← Add button
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Oli Shell Helix 1L              │ │
│ │ Stok: 32 | Rp 85.000            │ │
│ │                          [+]    │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Rantai Motor 415H               │ │
│ │ Stok: 5 | Rp 210.000            │ │
│ │                          [+]    │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Gearset Supra X 125             │ │
│ │ Stok: 8 | Rp 530.000            │ │
│ │                          [+]    │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ [Inventory] [Transaksi]             │ ← Bottom nav
└─────────────────────────────────────┘
```

#### State 2: Cart View (Multiple Items)

```
┌─────────────────────────────────────┐
│ Transaksi Penjualan          [→]    │
│ 🟢 Online • Last sync: 2 min ago    │
├─────────────────────────────────────┤
│ 🛒 Keranjang (2)                    │ ← Cart header
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Aki Kering 5A                   │ │
│ │ Rp 380.000 x 3                  │ │
│ │ [−] 3 [+]        Rp 1.140.000   │ │
│ │                          [✕]    │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Gearset Supra X 125             │ │
│ │ Rp 530.000 x 1                  │ │
│ │ [−] 1 [+]        Rp 530.000     │ │
│ │                          [✕]    │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Subtotal          Rp 1.670.000      │
│ Diskon                    Rp 0      │
│ Total             Rp 1.670.000      │ ← Summary (teal highlight)
├─────────────────────────────────────┤
│ Metode Pembayaran                   │
│ [Cash] [Transfer] [Qris]            │ ← Payment method pills
├─────────────────────────────────────┤
│ Catatan (Opsional)                  │
│ [Tambahkan catatan...]              │ ← Notes input
├─────────────────────────────────────┤
│ [Batal]        [✓ Selesaikan]       │ ← Action buttons
├─────────────────────────────────────┤
│ [Inventory] [Transaksi]             │
└─────────────────────────────────────┘
```

**Key Components:**

- Header with title & sync status
- Tier selector (pill buttons - Orang Umum/Bengkel/Grossir)
- Product search bar
- Product list (scrollable):
  - Product name
  - Stock info
  - Price
  - Add button
- Cart section:
  - Cart header with item count
  - Cart items (scrollable):
    - Product name
    - Price per unit & quantity
    - Quantity controls (−/+)
    - Subtotal
    - Remove button (✕)
- Summary section:
  - Subtotal
  - Discount
  - Total (highlighted in teal)
- Payment method selector (pills)
- Notes input field
- Action buttons (Cancel/Complete)
- Bottom navigation (Inventory/Transaksi)

**Responsive Behavior:**

- Single column layout
- Scrollable product list & cart
- Full-width buttons
- Stacked layout for mobile

---

### Screen 3: Inventory Screen - Kasir Role (Read-only)

**Layout Structure:**

```
┌─────────────────────────────────────┐
│ Inventory                    [→]    │
│ 🟢 Online • Last sync: 2 min ago    │
├─────────────────────────────────────┤
│ [🔍 Cari produk...]  [Semua ▼]      │ ← Search & filter
├─────────────────────────────────────┤
│ Hasil: 8 produk                     │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ Ban Michelin 90/90 Ring 14      │ │
│ │ Ban | Michelin                  │ │
│ │ ✓ Stok: 15    Margin: 35%       │ │
│ │ HPP: Rp 300.000  Jual: Rp 450K  │ │
│ │ [Edit]                    [🗑️]  │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Oli Shell Helix 1L              │ │
│ │ Oli | Shell                     │ │
│ │ ✓ Stok: 32    Margin: 28%       │ │
│ │ HPP: Rp 65.000   Jual: Rp 85K   │ │
│ │ [Edit]                    [🗑️]  │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ Rantai Motor 415H               │ │
│ │ Rantai | DID                    │ │
│ │ ✓ Stok: 5     Margin: 40%       │ │
│ │ HPP: Rp 150.000  Jual: Rp 210K  │ │
│ │ [Edit]                    [🗑️]  │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ [Inventory] [Transaksi]             │
│                              [+]    │ ← FAB (Floating Action Button)
└─────────────────────────────────────┘
```

**Key Components:**

- Header with title & sync status
- Search bar & filter dropdown
- Result count
- Product cards (scrollable):
  - Product name
  - Category | Brand
  - Stock status (with checkmark)
  - Margin % (green)
  - HPP & selling price
  - Edit button
  - Delete button (trash icon)
- Bottom navigation
- FAB (+ button) for adding product

**Responsive Behavior:**

- Single column layout
- Full-width product cards
- Scrollable list
- FAB positioned at bottom-right

---

## Layout Patterns Identified

### 1. **Header Pattern**

- Title (left-aligned)
- Action icon (right-aligned, e.g., →)
- Status bar (Online/Offline, Last sync)

### 2. **Tier/Filter Selector Pattern**

- Horizontal scrollable pill buttons
- Active state: teal background, white text
- Inactive state: light gray background, gray text

### 3. **Product List Pattern**

- Vertical scrollable list
- Card-based layout
- Consistent spacing & padding
- Add/Edit/Delete actions

### 4. **Cart Item Pattern**

- Product info (name, price, quantity)
- Quantity controls (−/+)
- Remove button
- Subtotal display

### 5. **Summary Section Pattern**

- Subtotal, Discount, Total
- Total highlighted in teal
- Clear visual hierarchy

### 6. **Payment Method Pattern**

- Horizontal pill buttons
- Active state: teal
- Inactive state: light gray

### 7. **Action Buttons Pattern**

- Full-width buttons
- Primary (teal): main action
- Secondary (light gray): cancel/secondary action
- Stacked vertically on mobile

### 8. **Bottom Navigation Pattern**

- 2 items (Inventory, Transaksi)
- Active state: teal icon & text
- Inactive state: gray icon & text
- Fixed at bottom

### 9. **FAB (Floating Action Button) Pattern**

- Circular button
- Teal background
- Positioned at bottom-right
- Icon: + (add)

---

## Color Scheme

- **Primary (Teal):** #1DB584 or similar
- **Secondary (Light Gray):** #F0F0F0 or #E8E8E8
- **Text (Dark):** #1F2937 or #000000
- **Text (Light):** #9CA3AF or #999999
- **Success (Green):** #10B981
- **Background:** #FFFFFF or #FAFAFA

---

## Typography

- **Heading 1:** 24px, Bold (Screen titles)
- **Heading 2:** 18px, Semi-bold (Section titles)
- **Body:** 16px, Regular (Main text)
- **Small:** 14px, Regular (Secondary text)
- **Caption:** 12px, Regular (Helper text)

---

## Spacing & Padding

- **Container padding:** 16px
- **Card padding:** 16px
- **Item spacing:** 12px
- **Section spacing:** 16px
- **Button height:** 48px
- **Input height:** 48px
