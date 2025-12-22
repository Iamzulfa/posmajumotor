# POS Felix - Point of Sale System

A modern, responsive Point of Sale (POS) system built with Flutter and Supabase, designed for small to medium businesses.

## ✨ Features

### 🛍️ Sales Management
- **Modern Transaction Interface** - Full-screen sliding cart with Tokopedia-style UX
- **Real-time Inventory** - Live stock updates and availability checking
- **Multi-tier Pricing** - Support for different customer tiers (Umum, Bengkel, Grossir)
- **Payment Methods** - Cash, Transfer, and QRIS support

### 📦 Inventory Management
- **Complete CRUD Operations** - Add, edit, delete products with real-time updates
- **Category & Brand Management** - Create and manage product categories and brands on-demand
- **Stock Tracking** - Real-time stock monitoring with low stock alerts
- **Smart Selection Modal** - Choose between adding products, categories, or brands

### 💰 Financial Management
- **Tax Center** - Automated tax calculations (0.5% of omset)
- **Expense Tracking** - Record and categorize business expenses
- **Profit/Loss Reports** - Detailed financial reporting by tier and period
- **Real-time Dashboard** - Live financial metrics and KPIs

### 🎨 User Experience
- **Auto-Responsive Design** - Professional scaling using `(widget_size / 360) * device_width` formula
- **User-Friendly Error Messages** - Clear, actionable error messages in Indonesian
- **Modern UI/UX** - Professional design matching modern e-commerce apps
- **Smooth Animations** - 300ms animations for professional feel

### 🔐 User Management
- **Role-Based Access** - Admin and Kasir roles with appropriate permissions
- **Secure Authentication** - Supabase-powered authentication system
- **Demo Mode** - Offline demo functionality for testing

## 🏗️ Technical Architecture

### Frontend
- **Flutter** - Cross-platform mobile development
- **Riverpod** - State management with real-time updates
- **Freezed** - Immutable data classes with JSON serialization
- **Auto-Responsive System** - Custom responsive design system

### Backend
- **Supabase** - Backend-as-a-Service with real-time capabilities
- **PostgreSQL** - Robust database with proper relationships
- **Real-time Subscriptions** - Live data updates across all screens

### Code Quality
- **Clean Architecture** - Separation of concerns with repository pattern
- **Error Handling** - Comprehensive error management system
- **Field Mapping** - Proper database-to-model mapping with `@JsonKey`
- **Responsive Design** - Mathematical scaling for all screen sizes

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.10.0 or higher)
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/pos-felix.git
   cd pos-felix
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Configure Supabase (Optional)**
   - Create a Supabase project
   - Update `lib/config/constants/supabase_config.dart`
   - Run database migrations from `supabase/` folder

5. **Run the app**
   ```bash
   flutter run
   ```

### Demo Mode
The app includes a demo mode that works without Supabase configuration. Simply run the app and use the demo credentials provided on the login screen.

## 📱 Screenshots

### Sales Interface
- Modern transaction screen with product browsing
- Full-screen sliding cart with smooth animations
- Real-time stock updates and pricing

### Inventory Management
- Complete product management with categories and brands
- Smart selection modal for adding different item types
- Real-time updates across all screens

### Financial Dashboard
- Tax calculations and payment tracking
- Expense management with categorization
- Profit/loss reports with tier breakdown

## 🔧 Development

### Project Structure
```
lib/
├── config/           # App configuration and constants
├── core/            # Core utilities (responsive, error handling)
├── data/            # Data layer (models, repositories)
├── domain/          # Domain layer (interfaces, entities)
├── presentation/    # UI layer (screens, widgets, providers)
└── injection_container.dart
```

### Key Systems

#### Responsive Design
```dart
// Automatic responsive scaling
final width = ResponsiveUtils.getResponsiveWidth(context, 100);
final fontSize = ResponsiveUtils.getResponsiveFontSize(context, phoneSize: 14);
```

#### Error Handling
```dart
// User-friendly error messages
final userError = ErrorHandler.getErrorMessage(technicalError);
UserFriendlySnackBar.showError(context, userError);
```

#### Database Integration
```dart
// Proper field mapping
@JsonKey(name: 'created_at') DateTime? createdAt,
@JsonKey(name: 'is_active') @Default(true) bool isActive,
```

### Development Guidelines
- Follow the patterns in `documents/guides/DEVELOPMENT_GUIDE.md`
- Use responsive utilities for all UI elements
- Implement proper error handling with user-friendly messages
- Ensure proper field mapping for all models
- Test on multiple screen sizes

## 📊 Current Status

### ✅ Completed Features
- [x] Complete sales transaction system
- [x] Full inventory management (products, categories, brands)
- [x] Financial tracking (tax, expenses, reports)
- [x] User authentication and role management
- [x] Auto-responsive design system
- [x] User-friendly error handling
- [x] Real-time data synchronization
- [x] Modern UI/UX with smooth animations

### 🔄 Recent Updates (December 22, 2025)
- Fixed all field mapping issues across models
- Implemented auto-responsive design system
- Added full-screen sliding cart interface
- Created category and brand management system
- Enhanced error handling with Indonesian messages
- Resolved all build warnings and errors

## 🔮 Future Development

### Planned Features
- [ ] **Advanced Reports** - More detailed analytics and insights
- [ ] **Multi-store Support** - Manage multiple store locations
- [ ] **Payment Integrations** - Direct payment gateway connections
- [ ] **Offline Mode** - Enhanced offline capabilities
- [ ] **Web Dashboard** - Web-based admin panel
- [ ] **iOS Version** - Native iOS application
- [ ] **API Integration** - REST API for third-party systems
- [ ] **Business Intelligence** - Advanced analytics and forecasting

### Technical Improvements
- [ ] **Unit Testing** - Comprehensive test coverage
- [ ] **CI/CD Pipeline** - Automated testing and deployment
- [ ] **Performance Optimization** - Further performance enhancements
- [ ] **Security Hardening** - Enhanced security measures
- [ ] **Accessibility** - Improved accessibility features
- [ ] **Internationalization** - Multi-language support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Follow the development guidelines in `documents/guides/`
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### Development Standards
- Use the responsive design system for all UI elements
- Implement proper error handling with user-friendly messages
- Follow the established architecture patterns
- Add proper documentation for new features
- Test on multiple screen sizes and devices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase team for the excellent backend service
- Riverpod for state management
- Freezed for data classes
- All contributors and testers

## 📞 Support

For support, questions, or feature requests:
- Create an issue on GitHub
- Check the development guides in `documents/guides/`
- Review the daily development reports in `documents/development-logs/`

---

**POS Felix** - Modern, responsive, and user-friendly POS system for the digital age.

Built with ❤️ using Flutter and Supabase.