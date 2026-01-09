// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryLogModelImpl _$$InventoryLogModelImplFromJson(
        Map<String, dynamic> json) =>
    _$InventoryLogModelImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toInt(),
      stockBefore: (json['stockBefore'] as num).toInt(),
      stockAfter: (json['stockAfter'] as num).toInt(),
      referenceType: json['referenceType'] as String?,
      referenceId: json['referenceId'] as String?,
      reason: json['reason'] as String?,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      product: json['product'] == null
          ? null
          : ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      creator: json['creator'] == null
          ? null
          : UserModel.fromJson(json['creator'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$InventoryLogModelImplToJson(
        _$InventoryLogModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'type': instance.type,
      'quantity': instance.quantity,
      'stockBefore': instance.stockBefore,
      'stockAfter': instance.stockAfter,
      'referenceType': instance.referenceType,
      'referenceId': instance.referenceId,
      'reason': instance.reason,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt?.toIso8601String(),
      'product': instance.product,
      'creator': instance.creator,
    };
