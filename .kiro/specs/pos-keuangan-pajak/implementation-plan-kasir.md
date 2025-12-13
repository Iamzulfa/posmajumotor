# Implementation Plan - Admin & Kasir Roles

## Phase Overview

**Phase 1: Foundation & Setup** (Week 1)

- Project setup & dependency injection
- Theme & design system
- Authentication flow
- Base widgets & utilities

**Phase 2: Core Features - Kasir** (Week 2)

- Product management (full CRUD for kasir)
- Shopping cart functionality
- Transaction processing
- Inventory management

**Phase 3: Core Features - Admin** (Week 3)

- Dashboard financial cockpit
- Expense manager
- Tax center & laporan
- Settings & user management

**Phase 4: Polish & Testing** (Week 4)

- Error handling & validation
- Offline support
- Unit & widget tests
- Performance optimization

---

## Phase 1: Foundation & Setup

### Task 1.1: Project Setup & Dependencies

**Objective:** Initialize Flutter project with required packages

**Subtasks:**

1. Create Flutter project structure
2. Add dependencies to pubspec.yaml:
   - `riverpod` / `provider` (state management)
   - `get_it` (dependency injection)
   - `dio` (HTTP client)
   - `hive` (local storage)
   - `intl` (internationalization)
   - `freezed_annotation` (code generation)
   - `json_serializable` (JSON serialization)
   - `go_router` (routing)

**Deliverables:**

- pubspec.yaml with all dependencies
- build_runner configuration
- .env file for API endpoints

**Estimated Time:** 2 hours

---

### Task 1.2: Theme & Design System

**Objective:** Create consistent design system

**Subtasks:**

1. Create `app_colors.dart` with color constants
2. Create `app_typography.dart` with text styles
3. Create `app_spacing.dart` with spacing constants
4. Create `app_theme.dart` with ThemeData
5. Create `app_constants.dart` with app-wide constants

**Deliverables:**

- Color palette (primary, secondary, success, error, etc)
- Typography scale (heading, body, caption)
- Spacing system (8px, 16px, 24px, 32px)
- Theme configuration

**Estimated Time:** 3 hours

---

### Task 1.3: Routing Setup

**Objective:** Configure app navigation

**Subtasks:**

1. Define route names in `app_routes.dart`
2. Create route generator in `route_generator.dart`
3. Setup GoRouter configuration
4. Create route guards for authentication

**Routes to define:**

- `/splash` - Splash screen
- `/login` - Login screen
- `/kasir` - Kasir main screen
- `/kasir/transaction` - Transaction screen
- `/kasir/inventory` - Inventory screen
- `/admin` - Admin main screen (for later)

**Deliverables:**

- Route definitions
- Route generator
- Navigation guards

**Estimated Time:** 2 hours

---

### Task 1.4: Dependency Injection Setup

**Objective:** Configure GetIt for dependency injection

**Subtasks:**

1. Create `injection_container.dart`
2. Register data sources
3. Register repositories
4. Register usecases
5. Register providers

**Deliverables:**

- Centralized DI configuration
- Service locator setup
- Easy to extend for new dependencies

**Estimated Time:** 2 hours

---

### Task 1.5: Base Widgets & Utilities

**Objective:** Create reusable widgets and utilities

**Subtasks:**

1. Create `custom_button.dart` (primary, secondary variants)
2. Create `app_bar_widget.dart` (custom app bar)
3. Create `bottom_nav_widget.dart` (bottom navigation)
4. Create `loading_widget.dart` (loading indicator)
5. Create `error_widget.dart` (error display)
6. Create `empty_state_widget.dart` (empty state)
7. Create `validators.dart` (input validation)
8. Create `extensions.dart` (Dart extensions)
9. Create `logger.dart` (logging utility)

**Deliverables:**

- Reusable widget library
- Utility functions
- Consistent UI components

**Estimated Time:** 4 hours

---

### Task 1.6: Authentication Flow

**Objective:** Implement login & authentication

**Subtasks:**

1. Create `user_entity.dart` (domain)
2. Create `user_model.dart` (data)
3. Create `auth_repository.dart` interface (domain)
4. Create `auth_repository_impl.dart` (data)
5. Create `login_usecase.dart` (domain)
6. Create `logout_usecase.dart` (domain)
7. Create `auth_provider.dart` (presentation)
8. Create `login_screen.dart` (presentation)
9. Create `login_controller.dart` (presentation)

**Deliverables:**

- Complete authentication flow
- Login screen UI
- Auth state management
- Token storage

**Estimated Time:** 6 hours

---

## Phase 2: Core Features

### Task 2.1: Product Entity & Models

**Objective:** Define product data structures

**Subtasks:**

1. Create `product_entity.dart` (domain)
2. Create `product_model.dart` (data)
3. Create `product_mapper.dart` (conversion)
4. Create `payment_method.dart` (enum)

**Deliverables:**

- Product entity with all fields
- Product model with JSON serialization
- Mapper for entity ↔ model conversion

**Estimated Time:** 2 hours

---

### Task 2.2: Product Repository & Datasources

**Objective:** Implement product data access

**Subtasks:**

1. Create `remote_datasource.dart` interface
2. Create `remote_datasource_impl.dart`
3. Create `local_datasource.dart` interface
4. Create `local_datasource_impl.dart`
5. Create `product_repository.dart` interface (domain)
6. Create `product_repository_impl.dart` (data)

**Deliverables:**

- Remote API integration for products
- Local caching with Hive
- Repository pattern implementation

**Estimated Time:** 4 hours

---

### Task 2.3: Product Usecases

**Objective:** Create product business logic

**Subtasks:**

1. Create `get_all_products_usecase.dart`
2. Create `search_products_usecase.dart`
3. Create `get_product_by_id_usecase.dart`
4. Create `get_products_by_tier_usecase.dart`

**Deliverables:**

- Usecases for product operations
- Business logic encapsulation
- Easy to test

**Estimated Time:** 2 hours

---

### Task 2.4: Product Widgets

**Objective:** Create product UI components

**Subtasks:**

1. Create `product_card.dart` (product display)
2. Create `product_list.dart` (product list)
3. Create `product_search_bar.dart` (search)
4. Create `tier_selector.dart` (tier selection)

**Deliverables:**

- Reusable product widgets
- Responsive design
- Interactive components

**Estimated Time:** 3 hours

---

### Task 2.5: Product Provider & Screen

**Objective:** Implement product state management & UI

**Subtasks:**

1. Create `product_provider.dart` (state management)
2. Create `inventory_screen.dart` (UI)
3. Create `inventory_controller.dart` (logic)
4. Create `inventory_state.dart` (state class)

**Deliverables:**

- Product list screen
- Search & filter functionality
- Real-time state updates

**Estimated Time:** 4 hours

---

### Task 2.6: Cart Entity & Models

**Objective:** Define shopping cart data structures

**Subtasks:**

1. Create `cart_item_entity.dart` (domain)
2. Create `cart_item_model.dart` (data)
3. Create `cart_mapper.dart` (conversion)

**Deliverables:**

- Cart item entity
- Cart item model
- Mapper for conversion

**Estimated Time:** 1 hour

---

### Task 2.7: Cart Usecases

**Objective:** Create cart business logic

**Subtasks:**

1. Create `add_to_cart_usecase.dart`
2. Create `remove_from_cart_usecase.dart`
3. Create `update_cart_quantity_usecase.dart`
4. Create `clear_cart_usecase.dart`
5. Create `calculate_cart_total_usecase.dart`

**Deliverables:**

- Usecases for cart operations
- Business logic for cart management
- Validation logic

**Estimated Time:** 2 hours

---

### Task 2.8: Cart Widgets

**Objective:** Create cart UI components

**Subtasks:**

1. Create `cart_item_card.dart` (cart item display)
2. Create `quantity_selector.dart` (quantity control)
3. Create `cart_summary.dart` (cart summary)
4. Create `payment_method_selector.dart` (payment selection)

**Deliverables:**

- Reusable cart widgets
- Quantity controls
- Summary display

**Estimated Time:** 3 hours

---

### Task 2.9: Cart Provider

**Objective:** Implement cart state management

**Subtasks:**

1. Create `cart_provider.dart` (state management)
2. Implement cart state notifier
3. Handle cart operations
4. Persist cart to local storage

**Deliverables:**

- Cart state management
- Reactive updates
- Local persistence

**Estimated Time:** 3 hours

---

### Task 2.10: Transaction Entity & Models

**Objective:** Define transaction data structures

**Subtasks:**

1. Create `transaction_entity.dart` (domain)
2. Create `transaction_model.dart` (data)
3. Create `transaction_mapper.dart` (conversion)

**Deliverables:**

- Transaction entity with all fields
- Transaction model with JSON serialization
- Mapper for conversion

**Estimated Time:** 2 hours

---

### Task 2.11: Transaction Repository & Datasources

**Objective:** Implement transaction data access

**Subtasks:**

1. Create `transaction_repository.dart` interface (domain)
2. Create `transaction_repository_impl.dart` (data)
3. Implement remote datasource for transactions
4. Implement local datasource for transactions

**Deliverables:**

- Transaction data access layer
- Remote API integration
- Local caching

**Estimated Time:** 3 hours

---

### Task 2.12: Transaction Usecases

**Objective:** Create transaction business logic

**Subtasks:**

1. Create `create_transaction_usecase.dart`
2. Create `get_transaction_history_usecase.dart`
3. Create `cancel_transaction_usecase.dart`
4. Create `calculate_transaction_total_usecase.dart`

**Deliverables:**

- Usecases for transaction operations
- Business logic for transaction processing
- Validation logic

**Estimated Time:** 3 hours

---

### Task 2.13: Transaction Screen & Controller

**Objective:** Implement transaction UI & logic

**Subtasks:**

1. Create `transaction_screen.dart` (UI)
2. Create `transaction_controller.dart` (logic)
3. Create `transaction_state.dart` (state class)
4. Implement tier selection
5. Implement product search & selection
6. Implement cart display
7. Implement payment method selection
8. Implement transaction completion

**Deliverables:**

- Complete transaction screen
- Multi-step transaction flow
- Real-time calculations
- State management

**Estimated Time:** 6 hours

---

### Task 2.14: Kasir Main Screen

**Objective:** Create main navigation for kasir

**Subtasks:**

1. Create `kasir_main_screen.dart`
2. Implement bottom navigation
3. Route between transaction & inventory screens
4. Display sync status
5. Handle logout

**Deliverables:**

- Main kasir screen
- Navigation between screens
- Status indicators

**Estimated Time:** 2 hours

---

## Phase 3: Polish & Testing

### Task 3.1: Error Handling & Validation

**Objective:** Implement comprehensive error handling

**Subtasks:**

1. Create exception classes
2. Create failure classes
3. Implement input validation
4. Add error messages
5. Display error UI

**Deliverables:**

- Centralized error handling
- User-friendly error messages
- Validation logic

**Estimated Time:** 3 hours

---

### Task 3.2: Offline Support

**Objective:** Implement offline-first functionality

**Subtasks:**

1. Implement local caching for products
2. Implement local transaction storage
3. Implement sync logic
4. Add sync status indicator
5. Handle sync conflicts

**Deliverables:**

- Offline product browsing
- Offline transaction creation
- Automatic sync when online
- Conflict resolution

**Estimated Time:** 4 hours

---

### Task 3.3: Unit Tests

**Objective:** Write unit tests for business logic

**Subtasks:**

1. Test usecases
2. Test repositories
3. Test providers
4. Test validators
5. Achieve 80%+ code coverage

**Deliverables:**

- Comprehensive unit tests
- High code coverage
- Documented test cases

**Estimated Time:** 6 hours

---

### Task 3.4: Widget Tests

**Objective:** Write widget tests for UI

**Subtasks:**

1. Test screens
2. Test widgets
3. Test interactions
4. Test responsive design
5. Test error states

**Deliverables:**

- Widget tests for critical screens
- UI interaction tests
- Responsive design tests

**Estimated Time:** 4 hours

---

### Task 3.5: Performance Optimization

**Objective:** Optimize app performance

**Subtasks:**

1. Profile app performance
2. Optimize list rendering
3. Optimize image loading
4. Optimize state management
5. Reduce build times

**Deliverables:**

- Optimized app performance
- Smooth animations
- Fast load times

**Estimated Time:** 3 hours

---

### Task 3.6: Documentation & Cleanup

**Objective:** Document code & clean up

**Subtasks:**

1. Add code comments
2. Create README
3. Document API integration
4. Document state management
5. Clean up unused code

**Deliverables:**

- Well-documented codebase
- README with setup instructions
- Architecture documentation

**Estimated Time:** 2 hours

---

---

## Phase 3: Core Features - Admin

### Task 3.1: Dashboard Screen

**Objective:** Implement financial cockpit for admin

**Subtasks:**

1. Create dashboard provider
2. Create dashboard screen
3. Implement real-time profit calculation
4. Implement pajak berjalan indicator
5. Implement trend grafik (7 hari)
6. Implement breakdown per buyer tier
7. Add refresh functionality

**Deliverables:**

- Complete dashboard screen
- Real-time data updates
- Responsive design

**Estimated Time:** 5 hours

---

### Task 3.2: Expense Manager

**Objective:** Implement expense tracking

**Subtasks:**

1. Create expense entity & models
2. Create expense repository & datasources
3. Create expense usecases
4. Create expense widgets
5. Create expense provider
6. Create expense screen
7. Implement add/edit/delete expense
8. Implement expense history & filtering

**Deliverables:**

- Complete expense manager
- Daily expense tracking
- Category breakdown

**Estimated Time:** 5 hours

---

### Task 3.3: Tax Center & Laporan

**Objective:** Implement financial reports & tax calculation

**Subtasks:**

1. Create laporan entity & models
2. Create laporan repository & datasources
3. Create laporan usecases
4. Create laporan widgets
5. Create tax center screen
6. Implement laporan laba rugi
7. Implement PPh final calculator
8. Implement export PDF functionality
9. Integrate with n8n webhook

**Deliverables:**

- Complete tax center
- Financial reports
- PDF export
- n8n integration

**Estimated Time:** 6 hours

---

### Task 3.4: Settings & User Management

**Objective:** Implement admin settings

**Subtasks:**

1. Create settings screen
2. Implement store settings
3. Implement user management (add/edit/delete)
4. Implement diskon management
5. Implement promo management
6. Implement sync status display
7. Add logout functionality

**Deliverables:**

- Complete settings screen
- User management
- Diskon & promo management

**Estimated Time:** 4 hours

---

### Task 3.5: Admin Main Screen

**Objective:** Create main navigation for admin

**Subtasks:**

1. Create admin_main_screen.dart
2. Implement bottom navigation (Dashboard/Inventory/Transaksi/Keuangan/Laporan/Settings)
3. Route between screens
4. Display sync status
5. Handle logout

**Deliverables:**

- Main admin screen
- Navigation between screens
- Status indicators

**Estimated Time:** 2 hours

---

## Phase 4: Polish & Testing

### Task 4.1: Error Handling & Validation

**Objective:** Implement comprehensive error handling

**Subtasks:**

1. Create exception classes
2. Create failure classes
3. Implement input validation
4. Add error messages
5. Display error UI

**Deliverables:**

- Centralized error handling
- User-friendly error messages
- Validation logic

**Estimated Time:** 3 hours

---

### Task 4.2: Offline Support

**Objective:** Implement offline-first functionality

**Subtasks:**

1. Implement local caching for products
2. Implement local transaction storage
3. Implement local expense storage
4. Implement sync logic
5. Add sync status indicator
6. Handle sync conflicts

**Deliverables:**

- Offline product browsing
- Offline transaction creation
- Offline expense tracking
- Automatic sync when online
- Conflict resolution

**Estimated Time:** 5 hours

---

### Task 4.3: Unit Tests

**Objective:** Write unit tests for business logic

**Subtasks:**

1. Test usecases
2. Test repositories
3. Test providers
4. Test validators
5. Achieve 80%+ code coverage

**Deliverables:**

- Comprehensive unit tests
- High code coverage
- Documented test cases

**Estimated Time:** 8 hours

---

### Task 4.4: Widget Tests

**Objective:** Write widget tests for UI

**Subtasks:**

1. Test screens
2. Test widgets
3. Test interactions
4. Test responsive design
5. Test error states

**Deliverables:**

- Widget tests for critical screens
- UI interaction tests
- Responsive design tests

**Estimated Time:** 6 hours

---

### Task 4.5: Performance Optimization

**Objective:** Optimize app performance

**Subtasks:**

1. Profile app performance
2. Optimize list rendering
3. Optimize image loading
4. Optimize state management
5. Reduce build times

**Deliverables:**

- Optimized app performance
- Smooth animations
- Fast load times

**Estimated Time:** 4 hours

---

### Task 4.6: Documentation & Cleanup

**Objective:** Document code & clean up

**Subtasks:**

1. Add code comments
2. Create README
3. Document API integration
4. Document state management
5. Clean up unused code

**Deliverables:**

- Well-documented codebase
- README with setup instructions
- Architecture documentation

**Estimated Time:** 3 hours

---

## Summary

**Total Estimated Time:** 110-120 hours

**Phase 1 (Foundation):** 19 hours
**Phase 2 (Core Features - Kasir):** 40-45 hours
**Phase 3 (Core Features - Admin):** 17 hours
**Phase 4 (Polish & Testing):** 29 hours

**Recommended Timeline:**

- Week 1: Phase 1 (Foundation)
- Week 2: Phase 2 (Core Features - Kasir)
- Week 3: Phase 3 (Core Features - Admin)
- Week 4: Phase 4 (Polish & Testing)

**Development Approach:**

- Start with Phase 1 to establish foundation
- Implement kasir features first (Phase 2)
- Then implement admin features (Phase 3)
- Test & optimize in Phase 4
- Use TDD (Test-Driven Development) where possible
- Regular code reviews & refactoring
