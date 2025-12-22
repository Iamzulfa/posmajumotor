import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_model.dart';
import 'user_model.dart';

part 'inventory_log_model.freezed.dart';
part 'inventory_log_model.g.dart';

@freezed
class InventoryLogModel with _$InventoryLogModel {
  const InventoryLogModel._();

  const factory InventoryLogModel({
    required String id,
    required String productId,

    // Change info
    required String type, // IN, OUT, ADJUSTMENT
    required int quantity,
    required int stockBefore,
    required int stockAfter,

    // Reference
    String? referenceType,
    String? referenceId,
    String? reason,

    // Metadata
    String? createdBy,
    DateTime? createdAt,

    // Relations (optional)
    ProductModel? product,
    UserModel? creator,
  }) = _InventoryLogModel;

  factory InventoryLogModel.fromJson(Map<String, dynamic> json) =>
      _$InventoryLogModelFromJson(json);

  /// Check if this is stock in
  bool get isStockIn => type == 'IN';

  /// Check if this is stock out
  bool get isStockOut => type == 'OUT';

  /// Check if this is adjustment
  bool get isAdjustment => type == 'ADJUSTMENT';

  /// Get formatted date time
  String get formattedDateTime {
    if (createdAt == null) return '-';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year} '
        '${createdAt!.hour.toString().padLeft(2, '0')}:${createdAt!.minute.toString().padLeft(2, '0')}';
  }
}

/// Inventory log types
enum InventoryLogType {
  @JsonValue('IN')
  stockIn,
  @JsonValue('OUT')
  stockOut,
  @JsonValue('ADJUSTMENT')
  adjustment,
}

/// Reference types for inventory logs
enum InventoryReferenceType {
  @JsonValue('PURCHASE')
  purchase,
  @JsonValue('SALE')
  sale,
  @JsonValue('ADJUSTMENT')
  adjustment,
  @JsonValue('OPNAME')
  opname,
  @JsonValue('RETURN')
  returnItem,
}
