# Setup Guide

## System Requirements

| Requirement | Minimum                                 | Recommended |
| ----------- | --------------------------------------- | ----------- |
| RAM         | 8 GB                                    | 16 GB       |
| Storage     | 10 GB                                   | 20 GB       |
| OS          | Windows 10 / macOS 10.15 / Ubuntu 18.04 | Latest      |

## Installation Steps

### 1. Install Flutter

**Windows:**

```powershell
# Download Flutter SDK from flutter.dev
# Extract to C:\flutter
# Add to PATH: C:\flutter\bin
```

**macOS:**

```bash
brew install flutter
```

**Linux:**

```bash
sudo snap install flutter --classic
```

### 2. Verify Installation

```bash
flutter doctor
```

Pastikan semua checklist hijau (✓).

### 3. Clone & Setup Project

```bash
git clone <repo-url>
cd posfelix
flutter pub get
```

### 4. Run Application

```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d <device_id>
```

## IDE Setup

### VS Code Extensions

- Flutter
- Dart
- Flutter Widget Snippets
- Error Lens

### Android Studio Plugins

- Flutter
- Dart

## Project Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9 # State management
  go_router: ^13.0.0 # Navigation
  get_it: ^7.6.4 # Dependency injection
  hive: ^2.2.3 # Local storage
  dio: ^5.4.0 # HTTP client
  intl: ^0.19.0 # Internationalization
```

## Build Commands

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

## Troubleshooting

### Hot Reload Issues

```bash
# Full restart
flutter run
# Press 'R' (capital) for hot restart
```

### Dependency Conflicts

```bash
flutter clean
flutter pub get
```

### Build Errors

```bash
flutter clean
rm -rf build/
flutter pub get
flutter run
```
