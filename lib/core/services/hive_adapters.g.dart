// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CacheMetadataAdapter extends TypeAdapter<CacheMetadata> {
  @override
  final int typeId = 10;

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

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QueuedTransactionAdapter extends TypeAdapter<QueuedTransaction> {
  @override
  final int typeId = 11;

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
      retryCount: fields[3] as int,
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

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueuedTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
