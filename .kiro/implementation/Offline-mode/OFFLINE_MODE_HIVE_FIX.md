# Offline Mode - Hive Serialization Fix

**Date**: December 28, 2025  
**Issue**: Hive adapter error when caching DashboardData objects  
**Status**: ✅ FIXED

## Problem

The `CacheSeeder` was attempting to cache complex Dart objects (`DashboardData`, `ProfitIndicator`, `TaxIndicator`) directly to Hive:

```
HiveError: Cannot write, unknown type: DashboardData. Did you forget to register an adapter?
```

This occurred because:

1. Hive requires registered adapters for custom types
2. Creating adapters for all data models is complex and error-prone
3. Hive natively supports Maps, which is simpler and more flexible

## Solution

Changed `CacheSeeder` to store data as Maps instead of complex objects:

### Before

```dart
final realDashboardData = DashboardData(...);
await offlineService.cacheData(cacheKey, realDashboardData); // ❌ Fails
```

### After

```dart
await offlineService.cacheData(cacheKey, {
  'totalTransactions': count,
  'totalOmset': totalOmset,
  'totalProfit': totalProfit,
  'totalExpenses': totalExpenses,
  'averageTransaction': average,
  'tierBreakdown': tierBreakdown,
  'paymentMethodBreakdown': paymentMethodBreakdown,
}); // ✅ Works - Hive natively supports Maps
```

## Implementation Details

### Files Modified

1. **`lib/core/services/cache_seeder.dart`**
   - Removed object instantiation (DashboardData, ProfitIndicator, TaxIndicator)
   - Changed all cache writes to use Maps
   - Removed unused imports from `dashboard_repository.dart`
   - Simplified mock data seeding to use Maps directly

### How It Works

**Caching Flow**:

```
CacheSeeder → Stores as Map → Hive (native support) → OfflineService
```

**Retrieval Flow**:

```
OfflineService → Returns Map → DashboardRepository converts to object
```

The `DashboardRepositoryImpl._fetchInitialDashboardData()` already handles Map-to-object conversion:

```dart
if (cached is Map) {
  return DashboardData(
    totalTransactions: (cached['totalTransactions'] as num?)?.toInt() ?? 0,
    totalOmset: (cached['totalOmset'] as num?)?.toInt() ?? 0,
    // ... other fields
  );
}
```

## Benefits

1. **No Adapter Registration Needed**: Maps are natively supported by Hive
2. **Simpler Architecture**: No need to maintain Hive adapters for data models
3. **More Flexible**: Easy to add/remove fields without adapter changes
4. **Type-Safe Conversion**: Repository handles safe type conversion with null coalescing
5. **Consistent Pattern**: All cached data uses the same Map-based approach

## Testing

To verify the fix works:

1. **Online Mode**: App fetches real data from Supabase and caches it as Maps
2. **Offline Mode**: App uses cached Maps to display data
3. **Fallback**: If no cache exists, mock data is seeded as Maps

### Test Scenarios

```
Scenario 1: Online → Offline
- Start app online
- Real data fetched and cached as Maps
- Disable WiFi
- Cached data displays correctly

Scenario 2: Offline → Online
- Start app offline
- Mock data seeded as Maps
- Enable WiFi
- Real data fetches and updates cache

Scenario 3: Offline from Start
- Start app offline
- Mock data seeded immediately
- Dashboard displays mock data
- No errors in logs
```

## Cache Keys

The following cache keys are used:

- `dashboard_data_YYYY-MM-DDTHH:MM:SS.000Z` - Daily dashboard data
- `profit_indicator` - Year-to-date profit data
- `tax_indicator_M_YYYY` - Monthly tax data (e.g., `tax_indicator_12_2025`)

## Error Handling

If caching fails:

1. Error is logged but doesn't crash the app
2. Offline fallback still works with existing cache
3. If no cache exists, empty data is returned gracefully

## Related Files

- `lib/core/services/offline_service.dart` - Hive box management
- `lib/data/repositories/dashboard_repository_impl.dart` - Map-to-object conversion
- `lib/data/repositories/expense_repository_impl.dart` - Offline fallback
- `lib/data/repositories/transaction_repository_impl.dart` - Offline fallback

## Status

✅ **COMPLETE** - All compilation errors resolved, offline mode ready for testing
