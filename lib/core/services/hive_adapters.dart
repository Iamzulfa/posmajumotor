import 'package:hive_flutter/hive_flutter.dart';
import 'package:posfelix/core/utils/logger.dart';

// Hive Box Names
class HiveBoxes {
  static const String productsCache = 'products_cache';
  static const String transactionsQueue = 'transactions_queue';
  static const String cacheMetadata = 'cache_metadata';
  static const String expensesCache = 'expenses_cache';
}

// Hive Type IDs
class HiveTypeIds {
  static const int cacheMetadata = 10;
  static const int queuedTransaction = 11;
  static const int cachedProduct = 12;
  static const int cachedExpense = 13;
}

/// Register all Hive type adapters
Future<void> registerHiveAdapters() async {
  try {
    // Register CacheMetadata adapter
    if (!Hive.isAdapterRegistered(HiveTypeIds.cacheMetadata)) {
      Hive.registerAdapter(CacheMetadataAdapter());
    }

    // Register QueuedTransaction adapter
    if (!Hive.isAdapterRegistered(HiveTypeIds.queuedTransaction)) {
      Hive.registerAdapter(QueuedTransactionAdapter());
    }

    AppLogger.info('Hive adapters registered successfully');
  } catch (e) {
    AppLogger.error('Error registering Hive adapters', e);
  }
}

/// Open all required Hive boxes
Future<void> openHiveBoxes() async {
  try {
    // Open cache metadata box
    await Hive.openBox<CacheMetadata>(HiveBoxes.cacheMetadata);

    // Open products cache box (stores as JSON strings for flexibility)
    await Hive.openBox<String>(HiveBoxes.productsCache);

    // Open transactions queue box
    await Hive.openBox<QueuedTransaction>(HiveBoxes.transactionsQueue);

    // Open expenses cache box
    await Hive.openBox<String>(HiveBoxes.expensesCache);

    AppLogger.info('Hive boxes opened successfully');
  } catch (e) {
    AppLogger.error('Error opening Hive boxes', e);
  }
}

/// Close all Hive boxes
Future<void> closeHiveBoxes() async {
  await Hive.close();
}

// ============================================
// HIVE MODELS
// ============================================

/// Cache metadata for tracking cache validity
@HiveType(typeId: HiveTypeIds.cacheMetadata)
class CacheMetadata extends HiveObject {
  @HiveField(0)
  final String cacheKey;

  @HiveField(1)
  final DateTime cachedAt;

  @HiveField(2)
  final int itemCount;

  CacheMetadata({
    required this.cacheKey,
    required this.cachedAt,
    required this.itemCount,
  });

  /// Check if cache is still valid
  bool isValid(Duration maxAge) {
    return DateTime.now().difference(cachedAt) < maxAge;
  }
}

/// Queued transaction for offline sync
@HiveType(typeId: HiveTypeIds.queuedTransaction)
class QueuedTransaction extends HiveObject {
  @HiveField(0)
  final String localId;

  @HiveField(1)
  final String transactionJson; // Store as JSON string

  @HiveField(2)
  final DateTime queuedAt;

  @HiveField(3)
  int retryCount;

  @HiveField(4)
  String? lastError;

  QueuedTransaction({
    required this.localId,
    required this.transactionJson,
    required this.queuedAt,
    this.retryCount = 0,
    this.lastError,
  });

  /// Increment retry count
  void incrementRetry(String? error) {
    retryCount++;
    lastError = error;
  }
}

// ============================================
// HIVE ADAPTERS
// ============================================

class CacheMetadataAdapter extends TypeAdapter<CacheMetadata> {
  @override
  final int typeId = HiveTypeIds.cacheMetadata;

  @override
  CacheMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CacheMetadata(
      cacheKey: fields[0] as String,
      cachedAt: fields[1] as DateTime,
      itemCount: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CacheMetadata obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.cacheKey)
      ..writeByte(1)
      ..write(obj.cachedAt)
      ..writeByte(2)
      ..write(obj.itemCount);
  }
}

class QueuedTransactionAdapter extends TypeAdapter<QueuedTransaction> {
  @override
  final int typeId = HiveTypeIds.queuedTransaction;

  @override
  QueuedTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueuedTransaction(
      localId: fields[0] as String,
      transactionJson: fields[1] as String,
      queuedAt: fields[2] as DateTime,
      retryCount: fields[3] as int? ?? 0,
      lastError: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QueuedTransaction obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.transactionJson)
      ..writeByte(2)
      ..write(obj.queuedAt)
      ..writeByte(3)
      ..write(obj.retryCount)
      ..writeByte(4)
      ..write(obj.lastError);
  }
}
