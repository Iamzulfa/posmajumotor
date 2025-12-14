// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionModelImpl _$$TransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TransactionModelImpl(
      id: json['id'] as String,
      transactionNumber: json['transaction_number'] as String,
      tier: json['tier'] as String,
      customerName: json['customer_name'] as String?,
      subtotal: (json['subtotal'] as num?)?.toInt() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalHpp: (json['total_hpp'] as num?)?.toInt() ?? 0,
      profit: (json['profit'] as num?)?.toInt() ?? 0,
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String? ?? 'COMPLETED',
      notes: json['notes'] as String?,
      cashierId: json['cashier_id'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      items: (json['transaction_items'] as List<dynamic>?)
          ?.map((e) => TransactionItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      cashier: json['users'] == null
          ? null
          : UserModel.fromJson(json['users'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TransactionModelImplToJson(
        _$TransactionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transaction_number': instance.transactionNumber,
      'tier': instance.tier,
      'customer_name': instance.customerName,
      'subtotal': instance.subtotal,
      'discount_amount': instance.discountAmount,
      'total': instance.total,
      'total_hpp': instance.totalHpp,
      'profit': instance.profit,
      'payment_method': instance.paymentMethod,
      'payment_status': instance.paymentStatus,
      'notes': instance.notes,
      'cashier_id': instance.cashierId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'transaction_items': instance.items,
      'users': instance.cashier,
    };
