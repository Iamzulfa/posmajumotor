// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TaxPaymentModelImpl _$$TaxPaymentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TaxPaymentModelImpl(
      id: json['id'] as String,
      periodMonth: (json['period_month'] as num).toInt(),
      periodYear: (json['period_year'] as num).toInt(),
      totalOmset: (json['total_omset'] as num?)?.toInt() ?? 0,
      taxAmount: (json['tax_amount'] as num?)?.toInt() ?? 0,
      isPaid: json['is_paid'] as bool? ?? false,
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
      paymentProof: json['payment_proof'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      creator: json['users'] == null
          ? null
          : UserModel.fromJson(json['users'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TaxPaymentModelImplToJson(
        _$TaxPaymentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'period_month': instance.periodMonth,
      'period_year': instance.periodYear,
      'total_omset': instance.totalOmset,
      'tax_amount': instance.taxAmount,
      'is_paid': instance.isPaid,
      'paid_at': instance.paidAt?.toIso8601String(),
      'payment_proof': instance.paymentProof,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'users': instance.creator,
    };
