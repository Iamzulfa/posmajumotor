// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_repository.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DashboardDataAdapter extends TypeAdapter<DashboardData> {
  @override
  final int typeId = 20;

  @override
  DashboardData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DashboardData(
      totalTransactions: fields[0] as int,
      totalOmset: fields[1] as int,
      totalProfit: fields[2] as int,
      totalExpenses: fields[3] as int,
      averageTransaction: fields[4] as int,
      tierBreakdown: (fields[5] as Map).cast<String, int>(),
      paymentMethodBreakdown: (fields[6] as Map).cast<String, int>(),
      recentTransactions: (fields[7] as List?)?.cast<TransactionModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, DashboardData obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.totalTransactions)
      ..writeByte(1)
      ..write(obj.totalOmset)
      ..writeByte(2)
      ..write(obj.totalProfit)
      ..writeByte(3)
      ..write(obj.totalExpenses)
      ..writeByte(4)
      ..write(obj.averageTransaction)
      ..writeByte(5)
      ..write(obj.tierBreakdown)
      ..writeByte(6)
      ..write(obj.paymentMethodBreakdown)
      ..writeByte(7)
      ..write(obj.recentTransactions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProfitIndicatorAdapter extends TypeAdapter<ProfitIndicator> {
  @override
  final int typeId = 21;

  @override
  ProfitIndicator read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfitIndicator(
      grossProfit: fields[0] as int,
      netProfit: fields[1] as int,
      profitMargin: fields[2] as double,
      totalOmset: fields[3] as int,
      totalHpp: fields[4] as int,
      totalExpenses: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProfitIndicator obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.grossProfit)
      ..writeByte(1)
      ..write(obj.netProfit)
      ..writeByte(2)
      ..write(obj.profitMargin)
      ..writeByte(3)
      ..write(obj.totalOmset)
      ..writeByte(4)
      ..write(obj.totalHpp)
      ..writeByte(5)
      ..write(obj.totalExpenses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfitIndicatorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaxIndicatorAdapter extends TypeAdapter<TaxIndicator> {
  @override
  final int typeId = 22;

  @override
  TaxIndicator read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaxIndicator(
      month: fields[0] as int,
      year: fields[1] as int,
      totalOmset: fields[2] as int,
      taxAmount: fields[3] as int,
      isPaid: fields[4] as bool,
      paidAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaxIndicator obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.month)
      ..writeByte(1)
      ..write(obj.year)
      ..writeByte(2)
      ..write(obj.totalOmset)
      ..writeByte(3)
      ..write(obj.taxAmount)
      ..writeByte(4)
      ..write(obj.isPaid)
      ..writeByte(5)
      ..write(obj.paidAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaxIndicatorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
