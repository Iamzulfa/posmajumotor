# UI Components Documentation

## Common Widgets

### 1. AppHeader

Header konsisten untuk semua screen.

```dart
const AppHeader(
  title: 'Screen Title',
  syncStatus: SyncStatus.online,
  lastSyncTime: '2 min ago',
)
```

**Props:**
| Prop | Type | Description |
|------|------|-------------|
| title | String | Judul screen |
| syncStatus | SyncStatus | online/offline/syncing |
| lastSyncTime | String | Waktu sync terakhir |

### 2. CustomButton

Button dengan variant primary/secondary.

```dart
CustomButton(
  text: 'Submit',
  icon: Icons.check,
  variant: ButtonVariant.primary,
  onPressed: () {},
)
```

**Props:**
| Prop | Type | Description |
|------|------|-------------|
| text | String | Label button |
| icon | IconData? | Optional icon |
| variant | ButtonVariant | primary/secondary |
| onPressed | VoidCallback | Callback function |

### 3. PillSelector

Horizontal pill buttons untuk selection.

```dart
PillSelector<String>(
  label: 'Tier Pembeli',
  items: ['UMUM', 'BENGKEL', 'GROSSIR'],
  selectedItem: _selectedTier,
  itemLabel: (item) => item,
  onSelected: (item) => setState(() => _selectedTier = item),
)
```

**Props:**
| Prop | Type | Description |
|------|------|-------------|
| label | String | Section label |
| items | List<T> | List of options |
| selectedItem | T | Currently selected |
| itemLabel | Function | Label formatter |
| onSelected | Function | Selection callback |

### 4. SyncStatusWidget

Indicator untuk status sinkronisasi.

```dart
const SyncStatusWidget(
  status: SyncStatus.online,
  lastSyncTime: '2 min ago',
)
```

**Status Types:**

- `SyncStatus.online` - Green dot
- `SyncStatus.offline` - Red dot
- `SyncStatus.syncing` - Yellow dot with animation

## Screen Components

### Product Card (Inventory)

```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey[200]!),
  ),
  child: Column(
    children: [
      // Product name
      // Category | Brand
      // Stock & Margin
      // HPP & Price
      // Edit & Delete buttons
    ],
  ),
)
```

### Cart Item (Transaction)

```dart
Container(
  child: Column(
    children: [
      // Product name + remove button
      // Price x quantity
      // Quantity controls (- / + )
      // Subtotal
    ],
  ),
)
```

### Expense Card

```dart
Container(
  child: Row(
    children: [
      // Category icon
      // Category name + notes
      // Amount + time
    ],
  ),
)
```

### Tier Breakdown (Expandable)

```dart
InkWell(
  onTap: () => toggleExpand(),
  child: Column(
    children: [
      // Tier name + transaction count + amount
      if (isExpanded) ...[
        // Omset
        // HPP
        // Profit
        // Margin badge
      ],
    ],
  ),
)
```

## Color Usage

```dart
// Primary actions
AppColors.primary      // #1DB584

// Status colors
AppColors.success      // #10B981 - positive values
AppColors.warning      // #F59E0B - pending/caution
AppColors.error        // #EF4444 - negative/delete

// Text colors
AppColors.textDark     // Primary text
AppColors.textGray     // Secondary text
AppColors.textLight    // Tertiary text

// Background
AppColors.background      // White
AppColors.backgroundLight // Light gray
AppColors.secondary       // Pill inactive
```

## Spacing Guidelines

```dart
AppSpacing.xs   // 4.0  - Tight spacing
AppSpacing.sm   // 8.0  - Small gaps
AppSpacing.md   // 16.0 - Standard padding
AppSpacing.lg   // 24.0 - Section spacing
AppSpacing.xl   // 32.0 - Large gaps
```

## Typography

```dart
// Headings
fontSize: 24, fontWeight: FontWeight.bold    // Screen title
fontSize: 18, fontWeight: FontWeight.bold    // Section title
fontSize: 16, fontWeight: FontWeight.w600    // Card title

// Body
fontSize: 16, fontWeight: FontWeight.normal  // Primary text
fontSize: 14, fontWeight: FontWeight.normal  // Secondary text
fontSize: 12, fontWeight: FontWeight.normal  // Caption
```
