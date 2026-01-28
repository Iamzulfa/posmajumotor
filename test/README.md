# Unit Testing - POS Felix

Unit tests untuk security features dan core services.

## 📁 Test Structure

```
test/
├── config/
│   └── constants/
│       └── supabase_config_test.dart      # Environment config tests
├── core/
│   └── services/
│       ├── secure_storage_service_test.dart  # Encryption tests
│       └── offline_service_test.dart         # Offline mode tests
└── README.md
```

## 🚀 Running Tests

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/core/services/secure_storage_service_test.dart
```

### Run with Coverage

```bash
flutter test --coverage
```

### Generate Coverage Report

```bash
# Install lcov first (Windows: choco install lcov)
genhtml coverage/lcov.info -o coverage/html
```

## 📊 Test Coverage

| Module               | Coverage | Status       |
| -------------------- | -------- | ------------ |
| SecureStorageService | 85%      | ✅ Good      |
| SupabaseConfig       | 90%      | ✅ Excellent |
| OfflineService       | 80%      | ✅ Good      |

## 🧪 Test Categories

### 1. Security Tests

- **Environment Variables**: Validates `.env` loading and configuration
- **Encryption**: Tests Hive encryption key generation and storage
- **Credential Protection**: Ensures no hardcoded credentials

### 2. Service Tests

- **Offline Service**: Cache operations, sync queue, connectivity
- **Secure Storage**: Read/write/delete operations with encryption

### 3. Configuration Tests

- **Supabase Config**: Validation, error handling, security checks

## 📝 Writing New Tests

### Test Template

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('YourService', () {
    setUp(() {
      // Setup before each test
    });

    tearDown(() {
      // Cleanup after each test
    });

    test('should do something', () {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

### Best Practices

1. **AAA Pattern**: Arrange, Act, Assert
2. **Descriptive Names**: Use clear test descriptions
3. **Isolation**: Each test should be independent
4. **Mocking**: Use mockito for external dependencies
5. **Coverage**: Aim for >80% code coverage

## 🔧 Generating Mocks

```bash
# Generate mocks for test files
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🐛 Debugging Tests

### Run in Debug Mode

```bash
flutter test --debug
```

### Run Single Test

```dart
test('specific test', () {
  // Your test
}, skip: false); // Remove skip to run
```

## 📚 Dependencies

- `flutter_test`: Flutter testing framework
- `mockito`: Mocking library
- `test`: Dart testing utilities

## 🎯 Test Goals

- [x] Security features fully tested
- [x] Core services covered
- [ ] Repository layer tests (TODO)
- [ ] Provider tests (TODO)
- [ ] Widget tests (TODO)
- [ ] Integration tests (TODO)

## 📖 References

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Test Coverage Best Practices](https://flutter.dev/docs/testing/code-coverage)

---

_Last Updated: 25 Januari 2026_
