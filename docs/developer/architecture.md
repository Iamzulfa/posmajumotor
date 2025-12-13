# Architecture Documentation

## Clean Architecture

```
┌─────────────────────────────────────────┐
│           PRESENTATION                   │
│  ┌─────────────────────────────────┐    │
│  │  Screens  │  Widgets  │  State  │    │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│              DOMAIN                      │
│  ┌─────────────────────────────────┐    │
│  │  Entities  │  UseCases  │  Repos │   │
│  └─────────────────────────────────┘    │
├─────────────────────────────────────────┤
│               DATA                       │
│  ┌─────────────────────────────────┐    │
│  │  Models  │  DataSources  │  Impl │   │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

## Folder Structure Detail

### Config Layer

```
config/
├── constants/
│   └── app_constants.dart    # API URLs, keys, limits
├── routes/
│   ├── app_routes.dart       # Route paths
│   └── route_generator.dart  # GoRouter config
└── theme/
    ├── app_colors.dart       # Color palette
    ├── app_spacing.dart      # Spacing constants
    ├── app_typography.dart   # Text styles
    └── app_theme.dart        # ThemeData
```

### Core Layer

```
core/
├── errors/
│   ├── exceptions.dart       # Custom exceptions
│   └── failures.dart         # Failure classes
└── utils/
    ├── validators.dart       # Input validation
    ├── extensions.dart       # Dart extensions
    └── logger.dart           # Logging utility
```

### Presentation Layer

```
presentation/
├── screens/
│   ├── admin/
│   │   ├── dashboard/        # Financial overview
│   │   ├── expense/          # Expense management
│   │   └── tax/              # Tax center
│   ├── auth/
│   │   └── login_screen.dart
│   └── kasir/
│       ├── inventory/        # Product management
│       └── transaction/      # Sales transaction
└── widgets/
    └── common/
        ├── app_header.dart
        ├── custom_button.dart
        ├── pill_selector.dart
        └── sync_status_widget.dart
```

## Navigation Flow

```
                    ┌─────────┐
                    │  Login  │
                    └────┬────┘
                         │
           ┌─────────────┴─────────────┐
           │                           │
     ┌─────▼─────┐               ┌─────▼─────┐
     │   Admin   │               │   Kasir   │
     └─────┬─────┘               └─────┬─────┘
           │                           │
    ┌──────┼──────┐              ┌─────┴─────┐
    │      │      │              │           │
┌───▼──┐ ┌─▼─┐ ┌──▼──┐      ┌───▼───┐  ┌────▼────┐
│Dash  │ │Inv│ │Trans│      │  Inv  │  │  Trans  │
└──────┘ └───┘ └─────┘      └───────┘  └─────────┘
    │
┌───┴───┐
│Expense│
│  Tax  │
└───────┘
```

## State Management

Menggunakan Riverpod untuk state management:

```dart
// Provider definition
final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>(
  (ref) => ProductsNotifier(),
);

// Usage in widget
class ProductList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    return ListView.builder(...);
  }
}
```

## Data Flow

```
User Action → Widget → Provider → Repository → DataSource
                                      ↓
User ← Widget ← Provider ← Repository ← Response
```

## Error Handling

```dart
// Exception types
class ServerException implements Exception {}
class CacheException implements Exception {}
class NetworkException implements Exception {}

// Failure types
abstract class Failure {}
class ServerFailure extends Failure {}
class CacheFailure extends Failure {}
class NetworkFailure extends Failure {}
```
