# 📋 REMAINING ISSUES - NEXT PHASES

> **Issues to be implemented by partner team**  
> **Last Updated:** 16 Desember 2025

---

## ⚙️ PHASE 5B: SETTINGS CONFIGURATION

**Priority:** 2 | **Effort:** 1 hari | **Impact:** Medium (Flexibility)

### Issue #1: Add Settings Table to Supabase

**Description:** Create settings table to store application configuration

**Tasks:**

- Create `settings` table with columns:
  - `id` (UUID, primary key)
  - `key` (text, unique) - e.g., "pph_final_rate"
  - `value` (text) - e.g., "0.5"
  - `description` (text) - e.g., "PPh Final Rate (%)"
  - `data_type` (text) - e.g., "decimal", "integer", "boolean"
  - `created_at` (timestamp)
  - `updated_at` (timestamp)
- Add indexes on `key` for fast lookup
- Insert default settings:
  - `pph_final_rate` = 0.5 (default PPh final rate)
  - Add other default settings as needed
- Add RLS policies for settings access

**Files:** `supabase/add_settings_table.sql`

**Acceptance Criteria:**

- Settings table created successfully
- Default values inserted
- RLS policies configured
- Can query settings by key

---

### Issue #2: Create Settings Provider

**Description:** Create Riverpod provider for settings management

**Tasks:**

- Create `lib/domain/repositories/settings_repository.dart` (interface)
- Create `lib/data/repositories/settings_repository_impl.dart` (implementation)
  - `getSetting(key)` - Get single setting
  - `getAllSettings()` - Get all settings
  - `updateSetting(key, value)` - Update setting
  - `getSettingAsDouble(key)` - Get setting as double
  - `getSettingAsInt(key)` - Get setting as int
  - `getSettingAsBoolean(key)` - Get setting as boolean
- Create `lib/presentation/providers/settings_provider.dart`
  - `settingsProvider` - FutureProvider for all settings
  - `pphFinalRateProvider` - FutureProvider for PPh final rate
  - `updateSettingProvider` - StateNotifier for updating settings
- Register in `lib/injection_container.dart`

**Files:**

- `lib/domain/repositories/settings_repository.dart`
- `lib/data/repositories/settings_repository_impl.dart`
- `lib/presentation/providers/settings_provider.dart`

**Acceptance Criteria:**

- All methods implemented
- Settings cached properly
- Type-safe getters for different data types
- Zero compilation errors

---

### Issue #3: Create Settings UI

**Description:** Create UI to manage PPh final rate setting

**Tasks:**

- Create `lib/presentation/screens/admin/settings/settings_screen.dart`
  - Display current PPh final rate
  - Input field to change PPh final rate
  - Save button with validation
  - Success/error messages
  - Loading state during save
- Add Settings screen to Admin navigation
- Responsive design (use responsive utilities)
- Methods:
  - `_buildPphFinalRateCard()` - Display current rate
  - `_buildPphFinalRateForm()` - Form to edit rate
  - `_buildSaveButton()` - Save button with loading state

**Features:**

- Validate PPh rate (0-100%)
- Show current value
- Real-time update after save
- Error handling with user feedback
- Responsive layout for all devices

**Files:**

- `lib/presentation/screens/admin/settings/settings_screen.dart`
- Update `lib/presentation/screens/admin/admin_main_screen.dart` to add Settings screen

**Acceptance Criteria:**

- Settings screen displays correctly
- Can update PPh final rate
- Validation works (0-100%)
- Changes persist in Supabase
- Responsive on all devices
- Zero compilation errors

---

## 🔄 PHASE 5C: POWERSYNC MIGRATION (Optional)

**Priority:** 3 | **Effort:** 3-5 hari | **Impact:** High (Reliability)

### Issue #4: Evaluate PowerSync for Project

**Description:** Evaluate PowerSync as alternative to Hive for offline sync

**Tasks:**

- Research PowerSync capabilities:
  - Offline-first architecture
  - Automatic sync when online
  - Conflict resolution
  - Performance characteristics
  - Cost & licensing
- Compare with current Hive implementation:
  - Pros/cons of each
  - Migration effort
  - Performance impact
  - Reliability improvements
- Create evaluation report with recommendation

**Decision Points:**

- If PowerSync is suitable: proceed with migration (Issue #5)
- If Hive is better: keep current implementation (no further action)

**Files:** `.kiro/POWERSYNC_EVALUATION.md`

**Acceptance Criteria:**

- Evaluation report completed
- Clear recommendation provided
- Pros/cons documented
- Decision made by team

---

### Issue #5: Migrate from Hive to PowerSync (If Approved)

**Description:** Migrate offline sync from Hive to PowerSync

**Tasks (Only if Issue #4 recommends PowerSync):**

- Add PowerSync dependencies to `pubspec.yaml`
- Create PowerSync configuration
- Migrate offline queue from Hive to PowerSync
- Update repositories to use PowerSync
- Update providers for PowerSync integration
- Test offline sync with PowerSync
- Remove Hive dependencies (if no longer needed)

**Files:**

- `pubspec.yaml` - Add PowerSync dependencies
- `lib/core/services/powersync_manager.dart` - PowerSync setup
- Update repository implementations
- Update provider implementations

**Acceptance Criteria:**

- PowerSync integrated successfully
- Offline sync working with PowerSync
- All tests passing
- Performance acceptable
- No data loss during migration

---

## ✅ PHASE 5D: TESTING & POLISH (Ongoing)

**Effort:** Sambil develop | **Impact:** High (Quality)

### Issue #6: Unit Tests for Critical Logic

**Description:** Create unit tests for critical business logic

**Tasks:**

- Test tax calculation logic
- Test profit/loss calculations
- Test tier breakdown calculations
- Test settings repository
- Test offline sync logic
- Aim for 80%+ code coverage on critical paths

**Files:** `test/` directory

**Acceptance Criteria:**

- All critical logic tested
- Tests passing
- 80%+ coverage on critical paths

---

### Issue #7: Widget Tests for Screens

**Description:** Create widget tests for main screens

**Tasks:**

- Test Dashboard screen layout
- Test Transaction screen layout
- Test Inventory screen layout
- Test Settings screen layout
- Test responsive layouts on different sizes

**Files:** `test/presentation/screens/` directory

**Acceptance Criteria:**

- All main screens tested
- Tests passing
- No layout issues detected

---

### Issue #8: Manual Testing on 3 Devices

**Description:** Manual testing on 3 different device sizes

**Tasks:**

- Test on small phone (< 360px)
- Test on regular phone (360-600px)
- Test on tablet (600-1000px)
- Verify all features work correctly
- Check responsive layouts
- Verify no crashes or errors

**Test Scenarios:**

- Login flow
- Product management
- Transaction creation
- Dashboard display
- Tax reports
- Settings management
- Offline mode (if applicable)

**Acceptance Criteria:**

- All features working on all devices
- No crashes or errors
- Responsive layouts correct
- User experience satisfactory

---

## 📊 SUMMARY

| Phase | Issue                | Priority | Effort    | Status      |
| ----- | -------------------- | -------- | --------- | ----------- |
| 5B    | Settings Table       | 2        | 2-3 hours | Not Started |
| 5B    | Settings Provider    | 2        | 2-3 hours | Not Started |
| 5B    | Settings UI          | 2        | 2-3 hours | Not Started |
| 5C    | PowerSync Evaluation | 3        | 4-6 hours | Not Started |
| 5C    | PowerSync Migration  | 3        | 3-5 days  | Conditional |
| 5D    | Unit Tests           | -        | Ongoing   | Not Started |
| 5D    | Widget Tests         | -        | Ongoing   | Not Started |
| 5D    | Manual Testing       | -        | 4-6 hours | Not Started |

---

## 🎯 IMPLEMENTATION ROADMAP

### Week 1: Phase 5B (Settings Configuration)

- Day 1: Issues #1-3 (Settings table, provider, UI)
- Estimated: 6-9 hours
- Blocker: None

### Week 2: Phase 5C (PowerSync - Optional)

- Days 1-2: Issue #4 (Evaluation)
- Days 3-5: Issue #5 (Migration, if approved)
- Estimated: 3-5 days (if approved)
- Blocker: Evaluation decision

### Ongoing: Phase 5D (Testing & Polish)

- Issues #6-8 run in parallel with development
- Unit tests: 2-3 hours
- Widget tests: 2-3 hours
- Manual testing: 4-6 hours
- Total: 8-12 hours

---

## 📝 NOTES FOR PARTNER TEAM

**Phase 5B (Settings):**

- Follow existing patterns from other repositories
- Use responsive utilities for Settings UI
- Test settings persistence in Supabase
- Ensure type-safe setting getters

**Phase 5C (PowerSync):**

- Only proceed if evaluation recommends it
- Thorough testing required before migration
- Backup current Hive implementation
- Document migration process

**Phase 5D (Testing):**

- Test as you develop (don't leave for end)
- Focus on critical business logic first
- Manual testing on real devices is important
- Document any issues found

**General:**

- Update PROSEDUR_LAPORAN_HARIAN.md with progress
- Create pull requests with clear descriptions
- Ensure zero compilation errors before submitting
- Follow existing code style and patterns

---

**Created:** 16 Desember 2025  
**Status:** Ready for Implementation
