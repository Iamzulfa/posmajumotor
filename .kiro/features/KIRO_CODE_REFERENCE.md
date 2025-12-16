# 🔧 KIRO CODE REFERENCE - POSFELIX

> **File ini berisi referensi kode dan pattern yang digunakan dalam project.**

---

## 📦 WIDGET PATTERNS

### 1. AppHeader Pattern

```dart
// Usage
const AppHeader(
  title: 'Screen Title',
  syncStatus: SyncStatus.online,
  lastSyncTime: '2 min ago',
  showLogout: true,
)

// Props
- title: String (required)
- syncStatus: SyncStatus (online/offline/syncing)
- lastSyncTime: String? (optional)
- onLogout: VoidCallback? (optional, default: go to login)
- showLogout: bool (default: true)
```

### 2. CustomButton Pattern

```dart
// Primary button
CustomButton(
  text: 'Submit',
  icon: Icons.check,
  onPressed: () {},
)

// Secondary button
CustomButton(
  text: 'Cancel',
  variant: ButtonVariant.secondary,
  onPressed: () {},
)

// Loading state
CustomButton(
  text: 'Loading',
  isLoading: true,
  onPressed: null,
)

// Variants: primary, secondary, outline, text
```

### 3. PillSelector Pattern

```dart
PillSelector<String>(
  label: 'Tier Pembeli',
  items: const ['UMUM', 'BENGKEL', 'GROSSIR'],
  selectedItem: _selectedTier,
  itemLabel: (item) {
    switch (item) {
      case 'UMUM': return 'Orang Umum';
      case 'BENGKEL': return 'Bengkel';
      case 'GROSSIR': return 'Grossir';
      default: return item;
    }
  },
  onSelected: (item) => setState(() => _selectedTier = item),
)
```

### 4. Product Card Pattern (Inventory)

```dart
Container(
  margin: const EdgeInsets.only(bottom: AppSpacing.md),
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    border: Border.all(color: AppColors.border),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Product name
      Text(product['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      // Category | Brand
      Text('${product['category']} | ${product['brand']}', style: TextStyle(color: AppColors.textGray)),
      // Stock & Margin row
      Row(children: [
        Icon(Icons.check_circle, size: 16, color: stockColor),
        Text('Stok: ${product['stock']}'),
        Text('Margin: ${product['margin']}%', style: TextStyle(color: marginColor)),
      ]),
      // HPP & Price
      Text('HPP: Rp ${hpp}  |  Jual: Rp ${price}'),
      // Actions
      Row(children: [
        TextButton.icon(icon: Icon(Icons.edit), label: Text('Edit')),
        IconButton(icon: Icon(Icons.delete_outline), color: AppColors.error),
      ]),
    ],
  ),
)
```

### 5. Cart Item Pattern (Transaction)

```dart
Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    border: Border.all(color: AppColors.border),
  ),
  child: Column(
    children: [
      // Header: Name + Remove button
      Row(children: [
        Expanded(child: Text(item['name'])),
        IconButton(icon: Icon(Icons.close), color: AppColors.error),
      ]),
      // Price info
      Text('Rp ${price} x ${quantity}'),
      // Quantity controls + Subtotal
      Row(children: [
        // Minus button
        InkWell(child: Container(child: Icon(Icons.remove))),
        // Quantity
        Text('${quantity}'),
        // Plus button
        InkWell(child: Container(child: Icon(Icons.add))),
        // Subtotal
        Text('Rp ${subtotal}'),
      ]),
    ],
  ),
)
```

### 6. Summary Card Pattern

```dart
Container(
  padding: const EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    border: Border.all(color: AppColors.border),
  ),
  child: Column(
    children: [
      _buildSummaryRow('Subtotal', subtotal),
      _buildSummaryRow('Diskon', discount),
      const Divider(),
      _buildSummaryRow('Total', total, isTotal: true),
    ],
  ),
)

Widget _buildSummaryRow(String label, int amount, {bool isTotal = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(
        fontSize: isTotal ? 16 : 14,
        fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
      )),
      Text('Rp ${_formatNumber(amount)}', style: TextStyle(
        fontSize: isTotal ? 18 : 14,
        fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
        color: isTotal ? AppColors.primary : AppColors.textDark,
      )),
    ],
  );
}
```

---

## 🎯 SCREEN PATTERNS

### 1. Basic Screen Structure

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Screen Title', syncStatus: SyncStatus.online),
            // Content
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
```

### 2. Tab Screen Pattern

```dart
class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Tab Screen'),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildTab1(), _buildTab2()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textGray,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [Tab(text: 'Tab 1'), Tab(text: 'Tab 2')],
      ),
    );
  }
}
```

### 3. Main Screen with Bottom Navigation

```dart
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    Screen1(),
    Screen2(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.settings_outlined, Icons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isActive ? activeIcon : icon, color: isActive ? AppColors.primary : AppColors.textLight),
              const SizedBox(height: AppSpacing.xs),
              Text(label, style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textLight,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🔢 UTILITY FUNCTIONS

### Number Formatting

```dart
String _formatNumber(int number) {
  return number.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  );
}

// Usage: _formatNumber(1500000) → "1.500.000"
```

### Currency Extension

```dart
extension IntExtensions on int {
  String toCurrency() {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(this);
  }
}

// Usage: 1500000.toCurrency() → "Rp 1.500.000"
```

### Date Formatting

```dart
extension DateTimeExtensions on DateTime {
  String toFormattedDate() {
    final formatter = DateFormat('dd/MM/yyyy', 'id_ID');
    return formatter.format(this);
  }

  String toFormattedTime() {
    final formatter = DateFormat('HH:mm:ss', 'id_ID');
    return formatter.format(this);
  }

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}
```

### Greeting by Time

```dart
String _getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Selamat Pagi';
  if (hour < 17) return 'Selamat Siang';
  return 'Selamat Malam';
}
```

---

## 🎨 COLOR HELPERS

### Margin Color

```dart
Color _getMarginColor(int margin) {
  if (margin >= 30) return AppColors.success;
  if (margin >= 20) return AppColors.warning;
  return AppColors.error;
}
```

### Stock Color

```dart
Color _getStockColor(int stock) {
  if (stock > 5) return AppColors.success;
  return AppColors.warning;
}
```

### Category Color (Expense)

```dart
Color _getCategoryColor(String category) {
  switch (category) {
    case 'LISTRIK': return Colors.orange;
    case 'GAJI': return Colors.blue;
    case 'PLASTIK': return Colors.purple;
    case 'MAKAN_SIANG': return Colors.green;
    default: return AppColors.textGray;
  }
}
```

### Category Icon (Expense)

```dart
IconData _getCategoryIcon(String category) {
  switch (category) {
    case 'LISTRIK': return Icons.bolt;
    case 'GAJI': return Icons.people;
    case 'PLASTIK': return Icons.shopping_bag;
    case 'MAKAN_SIANG': return Icons.restaurant;
    default: return Icons.receipt;
  }
}
```

---

## 📊 CHART PATTERN (Custom Painter)

```dart
class _TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final omsetPaint = Paint()
      ..color = AppColors.info
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final profitPaint = Paint()
      ..color = AppColors.success
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Data points (0.0 - 1.0 normalized)
    final omsetPoints = [0.5, 0.65, 0.55, 0.75, 0.6, 0.85, 0.7];
    final profitPoints = [0.25, 0.32, 0.28, 0.38, 0.3, 0.42, 0.35];

    final omsetPath = Path();
    final profitPath = Path();

    for (int i = 0; i < omsetPoints.length; i++) {
      final x = (size.width / (omsetPoints.length - 1)) * i;
      final omsetY = size.height - (size.height * omsetPoints[i]);
      final profitY = size.height - (size.height * profitPoints[i]);

      if (i == 0) {
        omsetPath.moveTo(x, omsetY);
        profitPath.moveTo(x, profitY);
      } else {
        omsetPath.lineTo(x, omsetY);
        profitPath.lineTo(x, profitY);
      }

      // Draw dots
      canvas.drawCircle(Offset(x, omsetY), 4, Paint()..color = AppColors.info);
      canvas.drawCircle(Offset(x, profitY), 4, Paint()..color = AppColors.success);
    }

    canvas.drawPath(omsetPath, omsetPaint);
    canvas.drawPath(profitPath, profitPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Usage
SizedBox(
  height: 180,
  child: CustomPaint(
    size: const Size(double.infinity, 180),
    painter: _TrendChartPainter(),
  ),
)
```

---

## 📝 MODAL/DIALOG PATTERNS

### Bottom Sheet Modal

```dart
void _showAddModal() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 80,
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Modal Title', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.lg),
            // Form fields
            const SizedBox(height: AppSpacing.lg),
            CustomButton(text: 'Simpan', onPressed: () => Navigator.pop(context)),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    ),
  );
}
```

### SnackBar

```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Action completed!')),
);
```

---

## 🔐 VALIDATION PATTERNS

```dart
class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) return 'Harga tidak boleh kosong';
    final price = int.tryParse(value);
    if (price == null || price <= 0) return 'Harga harus berupa angka positif';
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) return '$fieldName tidak boleh kosong';
    return null;
  }
}
```

---

## 🚀 NAVIGATION PATTERNS

### GoRouter Navigation

```dart
// Navigate to route
context.go(AppRoutes.login);

// Navigate with replacement
context.go(AppRoutes.kasirMain);

// Pop current route
context.pop();
```

### Route Guard (Planned)

```dart
redirect: (context, state) {
  final isLoggedIn = ref.read(authProvider).isLoggedIn;
  final isLoginRoute = state.matchedLocation == AppRoutes.login;

  if (!isLoggedIn && !isLoginRoute) return AppRoutes.login;
  if (isLoggedIn && isLoginRoute) return AppRoutes.kasirMain;
  return null;
}
```

---

## 📱 RESPONSIVE PATTERNS

### MediaQuery Usage

```dart
final screenWidth = MediaQuery.of(context).size.width;
final isMobile = screenWidth < 600;
final isTablet = screenWidth >= 600 && screenWidth < 1200;
final isDesktop = screenWidth >= 1200;
```

### LayoutBuilder Usage

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    } else {
      return TabletLayout();
    }
  },
)
```

---

_Last Updated: December 14, 2025_
