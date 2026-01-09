# ⚙️ SETTINGS & CONFIGURATION DATABASE PLAN

> **Priority:** Phase 5B - Medium Priority  
> **Effort:** 1-2 days  
> **Impact:** Medium (Business Flexibility)  
> **Status:** Planning

---

## 🎯 OBJECTIVES

1. Move hardcoded PPh final (0.5%) to database
2. Create flexible settings system for future configurations
3. Allow admin to manage settings via UI
4. Prevent data loss when updating nominal values
5. Support multiple configuration types

---

## 📊 CURRENT STATE

### Hardcoded PPh Final

```dart
// Current (Hardcoded)
const double PPH_FINAL_RATE = 0.005; // 0.5%

// Usage
double pphAmount = totalOmset * PPH_FINAL_RATE;
```

### Problems

- ❌ Cannot change without code update
- ❌ No audit trail
- ❌ No version history
- ❌ Not flexible for future changes
- ❌ Hard to manage multiple stores

---

## 🛠️ SOLUTION ARCHITECTURE

### 1. Database Schema

**File:** `supabase/add_settings_table.sql`

```sql
-- Create settings table
CREATE TABLE IF NOT EXISTS settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key VARCHAR(255) NOT NULL UNIQUE,
  value TEXT NOT NULL,
  type VARCHAR(50) NOT NULL, -- 'decimal', 'integer', 'string', 'boolean'
  description TEXT,
  category VARCHAR(100), -- 'tax', 'business', 'system'
  is_editable BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id)
);

-- Create settings audit log
CREATE TABLE IF NOT EXISTS settings_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  setting_id UUID REFERENCES settings(id) ON DELETE CASCADE,
  old_value TEXT,
  new_value TEXT,
  changed_by UUID REFERENCES auth.users(id),
  changed_at TIMESTAMP DEFAULT NOW()
);

-- Create index
CREATE INDEX idx_settings_key ON settings(key);
CREATE INDEX idx_settings_category ON settings(category);

-- Insert default settings
INSERT INTO settings (key, value, type, description, category, is_editable)
VALUES
  ('pph_final_rate', '0.005', 'decimal', 'PPh Final Rate (0.5%)', 'tax', true),
  ('business_name', 'Toko Otomotif', 'string', 'Business Name', 'business', true),
  ('business_address', '', 'string', 'Business Address', 'business', true),
  ('business_phone', '', 'string', 'Business Phone', 'business', true),
  ('currency_symbol', 'Rp', 'string', 'Currency Symbol', 'system', false),
  ('decimal_places', '0', 'integer', 'Decimal Places for Currency', 'system', false)
ON CONFLICT (key) DO NOTHING;

-- Auto-update timestamp
CREATE OR REPLACE FUNCTION update_settings_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER settings_timestamp
BEFORE UPDATE ON settings
FOR EACH ROW
EXECUTE FUNCTION update_settings_timestamp();
```

### 2. Settings Model

**File:** `lib/data/models/settings_model.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
class SettingsModel with _$SettingsModel {
  const factory SettingsModel({
    required String id,
    required String key,
    required String value,
    required String type, // 'decimal', 'integer', 'string', 'boolean'
    String? description,
    String? category,
    @Default(true) bool isEditable,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? createdBy,
    String? updatedBy,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);

  // Helper methods
  double? asDouble() {
    if (type != 'decimal') return null;
    return double.tryParse(value);
  }

  int? asInt() {
    if (type != 'integer') return null;
    return int.tryParse(value);
  }

  String asString() => value;

  bool asBool() {
    if (type != 'boolean') return false;
    return value.toLowerCase() == 'true';
  }
}

@freezed
class SettingsAuditLogModel with _$SettingsAuditLogModel {
  const factory SettingsAuditLogModel({
    required String id,
    required String settingId,
    String? oldValue,
    required String newValue,
    String? changedBy,
    required DateTime changedAt,
  }) = _SettingsAuditLogModel;

  factory SettingsAuditLogModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsAuditLogModelFromJson(json);
}
```

### 3. Settings Repository

**File:** `lib/domain/repositories/settings_repository.dart`

```dart
abstract class SettingsRepository {
  // Get single setting
  Future<SettingsModel?> getSetting(String key);

  // Get all settings
  Future<List<SettingsModel>> getAllSettings();

  // Get settings by category
  Future<List<SettingsModel>> getSettingsByCategory(String category);

  // Update setting
  Future<void> updateSetting(String key, String value);

  // Get audit log
  Future<List<SettingsAuditLogModel>> getAuditLog(String settingId);

  // Stream for real-time updates
  Stream<SettingsModel> watchSetting(String key);
  Stream<List<SettingsModel>> watchAllSettings();
}
```

### 4. Settings Repository Implementation

**File:** `lib/data/repositories/settings_repository_impl.dart`

```dart
class SettingsRepositoryImpl implements SettingsRepository {
  final SupabaseClient supabase;

  SettingsRepositoryImpl({required this.supabase});

  @override
  Future<SettingsModel?> getSetting(String key) async {
    try {
      final response = await supabase
          .from('settings')
          .select()
          .eq('key', key)
          .maybeSingle();

      if (response == null) return null;
      return SettingsModel.fromJson(response);
    } catch (e) {
      print('Error getting setting: $e');
      return null;
    }
  }

  @override
  Future<List<SettingsModel>> getAllSettings() async {
    try {
      final response = await supabase
          .from('settings')
          .select()
          .order('category');

      return (response as List)
          .map((e) => SettingsModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error getting all settings: $e');
      return [];
    }
  }

  @override
  Future<List<SettingsModel>> getSettingsByCategory(String category) async {
    try {
      final response = await supabase
          .from('settings')
          .select()
          .eq('category', category)
          .order('key');

      return (response as List)
          .map((e) => SettingsModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error getting settings by category: $e');
      return [];
    }
  }

  @override
  Future<void> updateSetting(String key, String value) async {
    try {
      // Get current value for audit log
      final current = await getSetting(key);

      // Update setting
      await supabase
          .from('settings')
          .update({'value': value})
          .eq('key', key);

      // Log to audit table
      if (current != null) {
        await supabase.from('settings_audit_log').insert({
          'setting_id': current.id,
          'old_value': current.value,
          'new_value': value,
          'changed_by': supabase.auth.currentUser?.id,
          'changed_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error updating setting: $e');
      rethrow;
    }
  }

  @override
  Future<List<SettingsAuditLogModel>> getAuditLog(String settingId) async {
    try {
      final response = await supabase
          .from('settings_audit_log')
          .select()
          .eq('setting_id', settingId)
          .order('changed_at', ascending: false);

      return (response as List)
          .map((e) => SettingsAuditLogModel.fromJson(e))
          .toList();
    } catch (e) {
      print('Error getting audit log: $e');
      return [];
    }
  }

  @override
  Stream<SettingsModel> watchSetting(String key) {
    return supabase
        .from('settings')
        .stream(primaryKey: ['id'])
        .eq('key', key)
        .map((list) {
          if (list.isEmpty) throw Exception('Setting not found');
          return SettingsModel.fromJson(list.first);
        });
  }

  @override
  Stream<List<SettingsModel>> watchAllSettings() {
    return supabase
        .from('settings')
        .stream(primaryKey: ['id'])
        .map((list) => list.map((e) => SettingsModel.fromJson(e)).toList());
  }
}
```

### 5. Settings Provider

**File:** `lib/presentation/providers/settings_provider.dart`

```dart
final settingsRepositoryProvider = Provider((ref) {
  return SettingsRepositoryImpl(supabase: Supabase.instance.client);
});

// Get single setting
final settingProvider = FutureProvider.family<SettingsModel?, String>((ref, key) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getSetting(key);
});

// Watch single setting (real-time)
final watchSettingProvider = StreamProvider.family<SettingsModel, String>((ref, key) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchSetting(key);
});

// Get all settings
final allSettingsProvider = FutureProvider((ref) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getAllSettings();
});

// Watch all settings (real-time)
final watchAllSettingsProvider = StreamProvider((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchAllSettings();
});

// Get settings by category
final settingsByCategoryProvider = FutureProvider.family<List<SettingsModel>, String>((ref, category) async {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.getSettingsByCategory(category);
});

// PPh Final Rate (convenience provider)
final pphFinalRateProvider = FutureProvider((ref) async {
  final setting = await ref.watch(settingProvider('pph_final_rate').future);
  return setting?.asDouble() ?? 0.005; // Default 0.5%
});

// Watch PPh Final Rate (real-time)
final watchPphFinalRateProvider = StreamProvider((ref) {
  return ref.watch(watchSettingProvider('pph_final_rate')).map((setting) {
    return setting.asDouble() ?? 0.005;
  });
});
```

### 6. Settings Usage in Tax Calculation

**File:** `lib/data/repositories/tax_repository_impl.dart` (Updated)

```dart
// Before (Hardcoded)
double calculatePphFinal(double omset) {
  const pphRate = 0.005; // Hardcoded!
  return omset * pphRate;
}

// After (From Database)
Future<double> calculatePphFinal(double omset) async {
  final setting = await settingsRepository.getSetting('pph_final_rate');
  final pphRate = setting?.asDouble() ?? 0.005;
  return omset * pphRate;
}

// Or with Provider (in UI)
final pphAmount = (await ref.watch(pphFinalRateProvider.future)) * omset;
```

### 7. Settings Management UI

**File:** `lib/presentation/screens/admin/settings/settings_screen.dart`

```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(watchAllSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: settings.when(
        data: (settingsList) {
          // Group by category
          final grouped = <String, List<SettingsModel>>{};
          for (final setting in settingsList) {
            final category = setting.category ?? 'Other';
            grouped.putIfAbsent(category, () => []).add(setting);
          }

          return ListView(
            children: grouped.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key),
                children: entry.value.map((setting) {
                  return SettingTile(setting: setting);
                }).toList(),
              );
            }).toList(),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class SettingTile extends ConsumerWidget {
  final SettingsModel setting;

  const SettingTile({required this.setting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!setting.isEditable) {
      return ListTile(
        title: Text(setting.key),
        subtitle: Text(setting.value),
        enabled: false,
      );
    }

    return ListTile(
      title: Text(setting.key),
      subtitle: Text(setting.description ?? ''),
      trailing: _buildEditWidget(context, ref),
      onTap: () => _showEditDialog(context, ref),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: setting.value);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${setting.key}'),
        content: TextField(
          controller: controller,
          keyboardType: _getKeyboardType(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(settingsRepositoryProvider);
              await repo.updateSetting(setting.key, controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Setting updated')),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  TextInputType _getKeyboardType() {
    switch (setting.type) {
      case 'decimal':
        return TextInputType.numberWithOptions(decimal: true);
      case 'integer':
        return TextInputType.number;
      default:
        return TextInputType.text;
    }
  }

  Widget _buildEditWidget(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showEditDialog(context, ref),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          setting.value,
          style: TextStyle(color: Colors.blue),
        ),
      ),
    );
  }
}
```

---

## 📋 IMPLEMENTATION CHECKLIST

### Phase 1: Database Setup (Day 1)

- [ ] Create settings table
- [ ] Create settings_audit_log table
- [ ] Create indexes
- [ ] Insert default settings
- [ ] Create auto-update trigger

### Phase 2: Models & Repository (Day 1)

- [ ] Create SettingsModel
- [ ] Create SettingsAuditLogModel
- [ ] Create SettingsRepository interface
- [ ] Create SettingsRepositoryImpl
- [ ] Add to dependency injection

### Phase 3: Providers (Day 1)

- [ ] Create settings providers
- [ ] Create convenience providers (pphFinalRate)
- [ ] Add to providers.dart

### Phase 4: UI Implementation (Day 2)

- [ ] Create SettingsScreen
- [ ] Create SettingTile widget
- [ ] Add edit dialog
- [ ] Add to admin navigation

### Phase 5: Update Tax Calculation (Day 2)

- [ ] Update TaxRepository to use settings
- [ ] Update tax calculation logic
- [ ] Remove hardcoded values
- [ ] Test with different PPh rates

### Phase 6: Testing & Documentation (Day 2)

- [ ] Test settings CRUD
- [ ] Test audit log
- [ ] Test real-time updates
- [ ] Update documentation

---

## 🔧 MIGRATION STEPS

### Step 1: Run SQL Migration

```sql
-- Execute in Supabase SQL Editor
-- Run: supabase/add_settings_table.sql
```

### Step 2: Generate Models

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 3: Update Tax Calculation

```dart
// Before
double pphAmount = omset * 0.005;

// After
final pphRate = await ref.watch(pphFinalRateProvider.future);
double pphAmount = omset * pphRate;
```

### Step 4: Add Settings Screen to Navigation

```dart
// admin_main_screen.dart
NavigationRailDestination(
  icon: Icon(Icons.settings),
  label: Text('Settings'),
),
```

---

## 📊 SETTINGS CATEGORIES

### Tax Settings

- `pph_final_rate` - PPh Final Rate (default: 0.005)
- `pph_payment_day` - PPh Payment Day (future)
- `tax_calculation_method` - Tax Method (future)

### Business Settings

- `business_name` - Business Name
- `business_address` - Business Address
- `business_phone` - Business Phone
- `business_email` - Business Email (future)

### System Settings

- `currency_symbol` - Currency Symbol (Rp)
- `decimal_places` - Decimal Places (0)
- `date_format` - Date Format (future)
- `time_format` - Time Format (future)

---

## 🚀 FUTURE ENHANCEMENTS

1. **Multi-Store Support**

   - Add store_id to settings
   - Different settings per store

2. **Settings Versioning**

   - Track all changes
   - Rollback capability

3. **Settings Validation**

   - Min/max values
   - Regex patterns
   - Custom validators

4. **Settings Permissions**

   - Role-based access
   - Who can edit what

5. **Settings Export/Import**
   - Backup settings
   - Migrate between stores

---

## 📝 SUMMARY

**Benefits:**

- ✅ No hardcoding
- ✅ Flexible & scalable
- ✅ Audit trail
- ✅ Easy to update
- ✅ Future-proof

**Implementation:**

- 1-2 days effort
- Medium complexity
- High business value

---

_Plan created: 16 Desember 2025_  
_Status: Ready for Implementation_
