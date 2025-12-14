// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryLogModelImpl _$$InventoryLogModelImplFromJson(
        Map<String, dynamic> json) =>
    _$InventoryLogModelImpl(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toInt(),
      stockBefore: (json['stock_before'] as num).toInt(),
      stockAfter: (json['stock_after'] as num).toInt(),
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      reason: json['reason'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      product: json['products'] == null
          ? null
          : ProductModel.fromJson(json['products'] as Map<String, dynamic>),
      creator: json['users'] == null
          ? null
          : UserModel.fromJson(json['users'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$InventoryLogModelImplToJson(
        _$InventoryLogModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'type': instance.type,
      'quantity': instance.quantity,
      'stock_before': instance.stockBefore,
      'stock_after': instance.stockAfter,
      'reference_type': instance.referenceType,
      'reference_id': instance.referenceId,
      'reason': instance.reason,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt?.toIso8601String(),
      'products': instance.product,
      'users': instance.creator,
    };
