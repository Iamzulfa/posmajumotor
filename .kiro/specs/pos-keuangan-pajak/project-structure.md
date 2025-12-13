# Project Structure - Modular & Clean Code

## Folder Architecture

```
lib/
├── main.dart                          # App entry point
├── config/
│   ├── theme/
│   │   ├── app_colors.dart           # Color constants
│   │   ├── app_typography.dart       # Typography styles
│   │   ├── app_spacing.dart          # Spacing constants
│   │   └── app_theme.dart            # Theme configuration
│   ├── routes/
│   │   ├── app_routes.dart           # Route definitions
│   │   └── route_generator.dart      # Route generation logic
│   └── constants/
│       ├── app_constants.dart        # App-wide constants
│       └── api_constants.dart        # API endpoints
│
├── core/
│   ├── errors/
│   │   ├── exceptions.dart           # Custom exceptions
│   │   └── failures.dart             # Failure classes
│   ├── usecases/
│   │   └── usecase.dart              # Base usecase class
│   ├── utils/
│   │   ├── logger.dart               # Logging utility
│   │   ├── validators.dart           # Input validators
│   │   └── extensions.dart           # Dart extensions
│   └── network/
│       ├── api_client.dart           # HTTP client wrapper
│       └── interceptors.dart         # Request/response interceptors
│
├── data/
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── local_datasource.dart # Local storage interface
│   │   │   └── local_datasource_impl.dart
│   │   └── remote/
│   │       ├── remote_datasource.dart # Remote API interface
│   │       └── remote_datasource_impl.dart
│   ├── models/
│   │   ├── product_model.dart
│   │   ├── transaction_model.dart
│   │   ├── cart_item_model.dart
│   │   └── user_model.dart
│   ├── repositories/
│   │   ├── product_repository.dart   # Interface
│   │   ├── product_repository_impl.dart
│   │   ├── transaction_repository.dart
│   │   ├── transaction_repository_impl.dart
│   │   ├── auth_repository.dart
│   │   └── auth_repository_impl.dart
│   └── mappers/
│       ├── product_mapper.dart       # Entity ↔ Model conversion
│       ├── transaction_mapper.dart
│       └── user_mapper.dart
│
├── domain/
│   ├── entities/
│   │   ├── product_entity.dart
│   │   ├── transaction_entity.dart
│   │   ├── cart_item_entity.dart
│   │   ├── user_entity.dart
│   │   └── payment_method.dart
│   ├── repositories/
│   │   ├── product_repository.dart   # Abstract interface
│   │   ├── transaction_repository.dart
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── product/
│       │   ├── get_all_products_usecase.dart
│       │   ├── search_products_usecase.dart
│       │   └── get_product_by_id_usecase.dart
│       ├── transaction/
│       │   ├── create_transaction_usecase.dart
│       │   ├── get_transaction_history_usecase.dart
│       │   └── cancel_transaction_usecase.dart
│       ├── cart/
│       │   ├── add_to_cart_usecase.dart
│       │   ├── remove_from_cart_usecase.dart
│       │   ├── update_cart_quantity_usecase.dart
│       │   └── clear_cart_usecase.dart
│       └── auth/
│           ├── login_usecase.dart
│           ├── logout_usecase.dart
│           └── get_current_user_usecase.dart
│
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart        # Authentication state
│   │   ├── product_provider.dart     # Product list state
│   │   ├── cart_provider.dart        # Shopping cart state
│   │   ├── transaction_provider.dart # Transaction state
│   │   └── ui_provider.dart          # UI state (loading, etc)
│   │
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── app_bar_widget.dart
│   │   │   ├── bottom_nav_widget.dart
│   │   │   ├── loading_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   ├── empty_state_widget.dart
│   │   │   └── custom_button.dart
│   │   ├── product/
│   │   │   ├── product_card.dart
│   │   │   ├── product_list.dart
│   │   │   └── product_search_bar.dart
│   │   ├── cart/
│   │   │   ├── cart_item_card.dart
│   │   │   ├── cart_summary.dart
│   │   │   └── quantity_selector.dart
│   │   ├── transaction/
│   │   │   ├── tier_selector.dart
│   │   │   ├── payment_method_selector.dart
│   │   │   └── transaction_summary.dart
│   │   └── auth/
│   │       ├── email_input_field.dart
│   │       ├── password_input_field.dart
│   │       └── remember_me_checkbox.dart
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── login_controller.dart
│   │   ├── kasir/
│   │   │   ├── transaction/
│   │   │   │   ├── transaction_screen.dart
│   │   │   │   ├── transaction_controller.dart
│   │   │   │   └── transaction_state.dart
│   │   │   ├── inventory/
│   │   │   │   ├── inventory_screen.dart
│   │   │   │   ├── inventory_controller.dart
│   │   │   │   └── inventory_state.dart
│   │   │   └── kasir_main_screen.dart
│   │   └── admin/
│   │       ├── dashboard/
│   │       │   ├── dashboard_screen.dart
│   │       │   └── dashboard_controller.dart
│   │       ├── inventory_management/
│   │       │   ├── inventory_management_screen.dart
│   │       │   └── inventory_management_controller.dart
│   │       └── admin_main_screen.dart
│   │
│   └── pages/
│       └── splash_screen.dart
│
└── injection_container.dart           # Dependency injection setup

```

---

## Design Patterns Used

### 1. **Clean Architecture**

- **Presentation Layer:** UI & state management
- **Domain Layer:** Business logic & entities
- **Data Layer:** Data sources & repositories

### 2. **Repository Pattern**

- Abstract interfaces in domain layer
- Concrete implementations in data layer
- Decouples business logic from data sources

### 3. **Usecase Pattern**

- Encapsulates business logic
- Single responsibility principle
- Easy to test

### 4. **Provider Pattern (State Management)**

- Riverpod or Provider package
- Reactive state management
- Dependency injection

### 5. **Mapper Pattern**

- Converts between layers (Entity ↔ Model)
- Keeps layers independent
- Centralized conversion logic

### 6. **Singleton Pattern**

- API client, database, shared preferences
- Single instance throughout app lifecycle

### 7. **Factory Pattern**

- Route generation
- Widget creation based on conditions

### 8. **Observer Pattern**

- State management (Provider)
- UI updates on state changes

---

## Naming Conventions

### Files

- `snake_case` for file names
- Suffix for file type: `_screen.dart`, `_widget.dart`, `_provider.dart`, `_usecase.dart`

### Classes

- `PascalCase` for class names
- Suffix for class type: `Screen`, `Widget`, `Provider`, `Usecase`, `Repository`

### Variables & Functions

- `camelCase` for variables and functions
- Prefix for private: `_privateVariable`

### Constants

- `UPPER_SNAKE_CASE` for constants
- Group related constants in classes

---

## Dependency Injection Setup

```dart
// injection_container.dart

// Repositories
final getIt = GetIt.instance;

void setupServiceLocator() {
  // Data sources
  getIt.registerSingleton<LocalDataSource>(
    LocalDataSourceImpl(getIt()),
  );

  getIt.registerSingleton<RemoteDataSource>(
    RemoteDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerSingleton<ProductRepository>(
    ProductRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // Usecases
  getIt.registerSingleton<GetAllProductsUsecase>(
    GetAllProductsUsecase(getIt()),
  );

  // Providers
  getIt.registerSingleton<ProductProvider>(
    ProductProvider(getIt()),
  );
}
```

---

## State Management Strategy

### Using Riverpod

```dart
// Product Provider
final productListProvider = FutureProvider<List<ProductEntity>>((ref) async {
  final usecase = ref.watch(getAllProductsUsecaseProvider);
  return usecase.call();
});

// Cart Provider
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(loginUsecaseProvider));
});
```

---

## Error Handling Strategy

### Exception Hierarchy

```dart
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message);
}

class ServerException extends AppException {
  ServerException(String message) : super(message);
}
```

### Failure Handling

```dart
abstract class Failure {
  final String message;
  Failure(this.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}
```

---

## Testing Strategy

```
test/
├── unit/
│   ├── domain/
│   │   └── usecases/
│   │       ├── get_all_products_usecase_test.dart
│   │       └── create_transaction_usecase_test.dart
│   ├── data/
│   │   ├── repositories/
│   │   │   └── product_repository_test.dart
│   │   └── models/
│   │       └── product_model_test.dart
│   └── presentation/
│       └── providers/
│           ├── product_provider_test.dart
│           └── cart_provider_test.dart
│
├── widget/
│   ├── screens/
│   │   ├── transaction_screen_test.dart
│   │   └── inventory_screen_test.dart
│   └── widgets/
│       ├── product_card_test.dart
│       └── cart_item_card_test.dart
│
└── integration/
    ├── transaction_flow_test.dart
    └── auth_flow_test.dart
```

---

## Key Principles

1. **Single Responsibility:** Each class has one reason to change
2. **Open/Closed:** Open for extension, closed for modification
3. **Liskov Substitution:** Subtypes must be substitutable
4. **Interface Segregation:** Clients depend on specific interfaces
5. **Dependency Inversion:** Depend on abstractions, not concretions
6. **DRY (Don't Repeat Yourself):** Avoid code duplication
7. **KISS (Keep It Simple, Stupid):** Simplicity over complexity
8. **YAGNI (You Aren't Gonna Need It):** Don't add unnecessary features

---

## Development Workflow

1. **Define Entity** (domain/entities/)
2. **Create Repository Interface** (domain/repositories/)
3. **Create Usecase** (domain/usecases/)
4. **Create Model** (data/models/)
5. **Create Datasource** (data/datasources/)
6. **Implement Repository** (data/repositories/)
7. **Create Provider** (presentation/providers/)
8. **Create Widgets** (presentation/widgets/)
9. **Create Screen** (presentation/screens/)
10. **Write Tests** (test/)
