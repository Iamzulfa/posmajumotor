# POS Felix Development Guide

## 🏗️ Architecture Overview

### Project Structure
```
lib/
├── config/           # Configuration files
├── core/            # Core utilities and services
├── data/            # Data layer (models, repositories)
├── domain/          # Domain layer (interfaces)
├── presentation/    # UI layer (screens, widgets, providers)
└── injection_container.dart
```

### Key Systems

#### 1. Responsive System
- **Location**: `lib/core/utils/auto_responsive.dart`
- **Usage**: `ResponsiveUtils.getResponsiveWidth(context, 100)`
- **Formula**: `(widget_size / 360) * device_width`

#### 2. Error Handling
- **Location**: `lib/core/utils/error_handler.dart`
- **Usage**: `ErrorHandler.getErrorMessage(error)`
- **Features**: User-friendly Indonesian messages

#### 3. State Management
- **Pattern**: Riverpod with StateNotifier
- **Providers**: Located in `lib/presentation/providers/`
- **Real-time**: Stream providers for live updates

## 🔧 Development Workflow

### 1. Adding New Features
1. Create domain interface in `lib/domain/`
2. Implement in `lib/data/repositories/`
3. Create/update models with proper `@JsonKey` mapping
4. Add provider in `lib/presentation/providers/`
5. Build UI in `lib/presentation/screens/`
6. Use responsive utilities for scaling

### 2. Database Integration
- Always use `@JsonKey` for field mapping
- Database: snake_case (created_at)
- Dart: camelCase (createdAt)
- Example: `@JsonKey(name: 'created_at') DateTime? createdAt`

### 3. Error Handling
- Use `ErrorHandler.getErrorMessage(e)` in providers
- Display with `UserFriendlySnackBar.showError()`
- Create user-friendly messages in Indonesian

## 📱 UI Development

### Responsive Design
```dart
// Width scaling
final width = ResponsiveUtils.getResponsiveWidth(context, 100);

// Font scaling
final fontSize = ResponsiveUtils.getResponsiveFontSize(
  context,
  phoneSize: 14,
  tabletSize: 16,
  desktopSize: 18,
);

// Padding scaling
final padding = ResponsiveUtils.getResponsivePadding(context);
```

### Error Display
```dart
// Full error widget
ErrorMessageWidget(
  message: 'User-friendly error message',
  onRetry: () => _retry(),
)

// Inline error
InlineErrorWidget(message: 'Validation error')

// Snackbar
UserFriendlySnackBar.showError(context, 'Error message');
```

## 🗄️ Database Schema

### Field Naming Convention
- Database: snake_case
- Dart Models: camelCase
- Always use `@JsonKey` for mapping

### Example Model
```dart
@freezed
class ExampleModel with _$ExampleModel {
  const factory ExampleModel({
    required String id,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _ExampleModel;

  factory ExampleModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleModelFromJson(json);
}
```

## 🔄 State Management Patterns

### Provider Structure
```dart
// State class
class ExampleState {
  final List<ExampleModel> items;
  final bool isLoading;
  final String? error;
  
  const ExampleState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });
}

// Notifier class
class ExampleNotifier extends StateNotifier<ExampleState> {
  ExampleNotifier(this._repository) : super(const ExampleState());
  
  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repository.getItems();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      final userFriendlyError = ErrorHandler.getErrorMessage(e);
      state = state.copyWith(isLoading: false, error: userFriendlyError);
    }
  }
}

// Provider
final exampleProvider = StateNotifierProvider<ExampleNotifier, ExampleState>((ref) {
  return ExampleNotifier(getIt<ExampleRepository>());
});
```

## 🧪 Testing Guidelines

### Manual Testing Checklist
- [ ] All CRUD operations work
- [ ] Error messages are user-friendly
- [ ] Responsive design scales properly
- [ ] Real-time updates function
- [ ] Navigation flows are intuitive

### Error Testing
- [ ] Network disconnection
- [ ] Invalid data input
- [ ] Database constraints
- [ ] Authentication failures
- [ ] Permission errors

## 🚀 Deployment

### Build Process
1. Run `flutter clean`
2. Run `flutter pub get`
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Run `flutter build apk --release`

### Pre-deployment Checklist
- [ ] All tests pass
- [ ] No build warnings/errors
- [ ] Error handling tested
- [ ] Responsive design verified
- [ ] Performance optimized

## 📋 Code Standards

### Naming Conventions
- Classes: PascalCase
- Variables/Functions: camelCase
- Files: snake_case
- Constants: UPPER_SNAKE_CASE

### Documentation
- Document all public APIs
- Use meaningful variable names
- Add comments for complex logic
- Update README for major changes

### Error Handling
- Always use ErrorHandler utility
- Provide actionable error messages
- Log errors for debugging
- Handle edge cases gracefully

## 🔮 Future Development Areas

### Potential Enhancements
1. **Offline Mode**: Enhanced offline capabilities
2. **Reports**: Advanced reporting features
3. **Multi-store**: Support for multiple store locations
4. **Integrations**: Payment gateway integrations
5. **Analytics**: Business intelligence features
6. **Mobile**: iOS version development
7. **Web**: Web version for admin panel
8. **API**: REST API for third-party integrations

### Technical Improvements
1. **Testing**: Unit and integration tests
2. **CI/CD**: Automated deployment pipeline
3. **Monitoring**: Error tracking and analytics
4. **Performance**: Further optimizations
5. **Security**: Enhanced security measures
6. **Accessibility**: Improved accessibility features

## 📞 Support & Maintenance

### Common Issues
1. **Field Mapping**: Always check `@JsonKey` annotations
2. **Responsive Issues**: Use ResponsiveUtils consistently
3. **Error Messages**: Use ErrorHandler for user-friendly messages
4. **State Updates**: Ensure proper provider invalidation

### Debugging Tips
1. Check terminal logs for detailed errors
2. Use AppLogger for debugging information
3. Verify database field names match model annotations
4. Test responsive design on different screen sizes

---

This guide provides the foundation for continued development of POS Felix. Follow these patterns and conventions to maintain code quality and user experience standards.