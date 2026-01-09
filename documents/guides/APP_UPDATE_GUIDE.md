# Panduan Update Aplikasi POS Felix

## 📱 **Cara Update Aplikasi Release**

### **Scenario 1: Update untuk Testing/Internal**

#### **Step 1: Update Version Number**
```yaml
# pubspec.yaml
version: 1.0.1+2  # Format: major.minor.patch+buildNumber
```

**Version Numbering:**
- **Major (1.x.x)**: Breaking changes, major features
- **Minor (x.1.x)**: New features, non-breaking changes  
- **Patch (x.x.1)**: Bug fixes, small improvements
- **Build (+2)**: Internal build number (increment setiap build)

#### **Step 2: Build Release APK**
```bash
# Manual commands
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release

# Or use script
scripts/build_release.bat
```

#### **Step 3: Install Update**
```bash
# Uninstall old version first (untuk testing)
adb uninstall com.example.posfelix

# Install new version
adb install build/app/outputs/flutter-apk/app-release.apk

# Or install over existing (if same signing key)
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### **Scenario 2: Update untuk Production/Distribution**

#### **Step 1: Prepare Release**
1. **Update version** di `pubspec.yaml`
2. **Test thoroughly** di berbagai device
3. **Update changelog** dan documentation
4. **Create release notes**

#### **Step 2: Build Signed Release**
```bash
# Build signed APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

#### **Step 3: Distribution Options**

##### **Option A: Direct APK Distribution**
- Share `app-release.apk` file
- Users install manually (enable "Unknown Sources")
- Good for: Internal testing, small user base

##### **Option B: Google Play Store**
- Upload `app-release.aab` to Play Console
- Google handles distribution and updates
- Good for: Public release, automatic updates

##### **Option C: Firebase App Distribution**
- Upload APK to Firebase
- Send download links to testers
- Good for: Beta testing, controlled distribution

### **Scenario 3: Over-the-Air (OTA) Updates**

#### **Setup Code Push (Advanced)**
```dart
// For future implementation
// Using packages like:
// - code_push
// - firebase_remote_config
// - in_app_update (Play Store only)
```

## 🔧 **Update Process Checklist**

### **Pre-Update:**
- [ ] Test all new features thoroughly
- [ ] Check for breaking changes
- [ ] Update version number
- [ ] Update changelog
- [ ] Backup current working version

### **Build Process:**
- [ ] `flutter clean`
- [ ] `flutter pub get`  
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] `flutter build apk --release`
- [ ] Test APK on different devices
- [ ] Verify all features work

### **Post-Update:**
- [ ] Document changes made
- [ ] Update user documentation
- [ ] Notify users about update
- [ ] Monitor for issues
- [ ] Prepare hotfix if needed

## 📋 **Version History Tracking**

### **Current Versions:**
- **v1.0.0+1** - Initial release
- **v1.0.1+2** - Syncing issue fixes, network improvements

### **Changelog Template:**
```markdown
## v1.0.1+2 - December 22, 2025

### 🐛 Bug Fixes
- Fixed infinite loading/syncing issues
- Improved network error handling
- Enhanced timeout management

### ✨ New Features
- Network-aware UI components
- Connection status monitoring
- Automatic retry functionality

### 🔧 Technical Improvements
- Added NetworkService with timeout handling
- Enhanced error messages in Indonesian
- Improved stream provider reliability
```

## 🚀 **Deployment Strategies**

### **Strategy 1: Gradual Rollout**
1. **Internal Testing** (v1.0.1-alpha)
2. **Beta Testing** (v1.0.1-beta) 
3. **Limited Release** (v1.0.1-rc)
4. **Full Release** (v1.0.1)

### **Strategy 2: Feature Flags**
```dart
// Enable/disable features remotely
class FeatureFlags {
  static bool get newSyncingLogic => true;
  static bool get enhancedErrorHandling => true;
}
```

### **Strategy 3: A/B Testing**
- Test new features with subset of users
- Compare performance metrics
- Roll out based on results

## 🔒 **Security Considerations**

### **APK Signing:**
- Use same signing key for updates
- Store keystore securely
- Never share signing credentials

### **Version Verification:**
```dart
// Add version check in app
class AppVersion {
  static const String current = '1.0.1';
  static const int buildNumber = 2;
  
  static bool isUpdateRequired(String serverVersion) {
    // Compare versions and force update if needed
  }
}
```

## 📱 **User Communication**

### **Update Notification Template:**
```
🎉 POS Felix Update v1.0.1 Tersedia!

✨ Yang Baru:
- Perbaikan masalah loading lambat
- Pesan error yang lebih jelas
- Koneksi internet lebih stabil

📥 Cara Update:
1. Download APK terbaru
2. Install (izinkan "Unknown Sources")
3. Buka aplikasi

💡 Catatan: Data Anda akan tetap aman
```

### **In-App Update Dialog:**
```dart
// Future implementation
showDialog(
  context: context,
  builder: (context) => UpdateDialog(
    currentVersion: '1.0.0',
    latestVersion: '1.0.1',
    features: [
      'Perbaikan syncing issue',
      'Network error handling',
      'Improved user experience',
    ],
    isRequired: false,
  ),
);
```

## 🛠️ **Troubleshooting Updates**

### **Common Issues:**

#### **"App not installed" Error**
- **Cause**: Different signing key
- **Solution**: Uninstall old version first

#### **"Parse Error" on Install**
- **Cause**: Corrupted APK or incompatible architecture
- **Solution**: Re-download APK, check device compatibility

#### **Data Loss After Update**
- **Cause**: Database schema changes
- **Solution**: Implement migration logic

#### **Features Not Working**
- **Cause**: Cache issues, incomplete update
- **Solution**: Clear app data, reinstall

### **Recovery Steps:**
1. **Backup user data** before major updates
2. **Keep previous APK** for rollback
3. **Test update process** on development devices
4. **Have rollback plan** ready

## 📊 **Update Metrics to Track**

### **Technical Metrics:**
- Update success rate
- Installation time
- Crash rate after update
- Performance improvements

### **User Metrics:**
- Update adoption rate
- User feedback/ratings
- Support ticket volume
- Feature usage statistics

## 🎯 **Best Practices**

### **Development:**
- **Semantic versioning** for clear communication
- **Automated testing** before release
- **Staged rollouts** for risk mitigation
- **Feature toggles** for quick fixes

### **Communication:**
- **Clear release notes** in user language
- **Multiple communication channels**
- **Advance notice** for major updates
- **Support availability** during rollout

### **Monitoring:**
- **Real-time crash reporting**
- **Performance monitoring**
- **User feedback collection**
- **Rollback triggers** defined

---

**Remember**: Always test updates thoroughly before releasing to users! 🧪✅