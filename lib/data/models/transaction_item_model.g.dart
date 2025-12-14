// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionItemModelImpl _$$TransactionItemModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TransactionItemModelImpl(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productSku: json['product_sku'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toInt(),
      unitHpp: (json['unit_hpp'] as num).toInt(),
      subtotal: (json['subtotal'] as num).toInt(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      product: json['products'] == null
          ? null
          : ProductModel.fromJson(json['products'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TransactionItemModelImplToJson(
        _$TransactionItemModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transaction_id': instance.transactionId,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'product_sku': instance.productSku,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'unit_hpp': instance.unitHpp,
      'subtotal': instance.subtotal,
      'created_at': instance.createdAt?.toIso8601String(),
      'products': instance.product,
    };
