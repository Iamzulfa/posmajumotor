// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tax_payment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TaxPaymentModel _$TaxPaymentModelFromJson(Map<String, dynamic> json) {
  return _TaxPaymentModel.fromJson(json);
}

/// @nodoc
mixin _$TaxPaymentModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'period_month')
  int get periodMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'period_year')
  int get periodYear => throw _privateConstructorUsedError; // Amounts
  @JsonKey(name: 'total_omset')
  int get totalOmset => throw _privateConstructorUsedError;
  @JsonKey(name: 'tax_amount')
  int get taxAmount => throw _privateConstructorUsedError; // Payment info
  @JsonKey(name: 'is_paid')
  bool get isPaid => throw _privateConstructorUsedError;
  @JsonKey(name: 'paid_at')
  DateTime? get paidAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_proof')
  String? get paymentProof => throw _privateConstructorUsedError; // Metadata
  @JsonKey(name: 'created_by')
  String? get createdBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Relations (optional)
  @JsonKey(name: 'users')
  UserModel? get creator => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TaxPaymentModelCopyWith<TaxPaymentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaxPaymentModelCopyWith<$Res> {
  factory $TaxPaymentModelCopyWith(
          TaxPaymentModel value, $Res Function(TaxPaymentModel) then) =
      _$TaxPaymentModelCopyWithImpl<$Res, TaxPaymentModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'period_month') int periodMonth,
      @JsonKey(name: 'period_year') int periodYear,
      @JsonKey(name: 'total_omset') int totalOmset,
      @JsonKey(name: 'tax_amount') int taxAmount,
      @JsonKey(name: 'is_paid') bool isPaid,
      @JsonKey(name: 'paid_at') DateTime? paidAt,
      @JsonKey(name: 'payment_proof') String? paymentProof,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'users') UserModel? creator});

  $UserModelCopyWith<$Res>? get creator;
}

/// @nodoc
class _$TaxPaymentModelCopyWithImpl<$Res, $Val extends TaxPaymentModel>
    implements $TaxPaymentModelCopyWith<$Res> {
  _$TaxPaymentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? periodMonth = null,
    Object? periodYear = null,
    Object? totalOmset = null,
    Object? taxAmount = null,
    Object? isPaid = null,
    Object? paidAt = freezed,
    Object? paymentProof = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? creator = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      periodMonth: null == periodMonth
          ? _value.periodMonth
          : periodMonth // ignore: cast_nullable_to_non_nullable
              as int,
      periodYear: null == periodYear
          ? _value.periodYear
          : periodYear // ignore: cast_nullable_to_non_nullable
              as int,
      totalOmset: null == totalOmset
          ? _value.totalOmset
          : totalOmset // ignore: cast_nullable_to_non_nullable
              as int,
      taxAmount: null == taxAmount
          ? _value.taxAmount
          : taxAmount // ignore: cast_nullable_to_non_nullable
              as int,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      paidAt: freezed == paidAt
          ? _value.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentProof: freezed == paymentProof
          ? _value.paymentProof
          : paymentProof // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creator: freezed == creator
          ? _value.creator
          : creator // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get creator {
    if (_value.creator == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.creator!, (value) {
      return _then(_value.copyWith(creator: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TaxPaymentModelImplCopyWith<$Res>
    implements $TaxPaymentModelCopyWith<$Res> {
  factory _$$TaxPaymentModelImplCopyWith(_$TaxPaymentModelImpl value,
          $Res Function(_$TaxPaymentModelImpl) then) =
      __$$TaxPaymentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'period_month') int periodMonth,
      @JsonKey(name: 'period_year') int periodYear,
      @JsonKey(name: 'total_omset') int totalOmset,
      @JsonKey(name: 'tax_amount') int taxAmount,
      @JsonKey(name: 'is_paid') bool isPaid,
      @JsonKey(name: 'paid_at') DateTime? paidAt,
      @JsonKey(name: 'payment_proof') String? paymentProof,
      @JsonKey(name: 'created_by') String? createdBy,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'users') UserModel? creator});

  @override
  $UserModelCopyWith<$Res>? get creator;
}

/// @nodoc
class __$$TaxPaymentModelImplCopyWithImpl<$Res>
    extends _$TaxPaymentModelCopyWithImpl<$Res, _$TaxPaymentModelImpl>
    implements _$$TaxPaymentModelImplCopyWith<$Res> {
  __$$TaxPaymentModelImplCopyWithImpl(
      _$TaxPaymentModelImpl _value, $Res Function(_$TaxPaymentModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? periodMonth = null,
    Object? periodYear = null,
    Object? totalOmset = null,
    Object? taxAmount = null,
    Object? isPaid = null,
    Object? paidAt = freezed,
    Object? paymentProof = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? creator = freezed,
  }) {
    return _then(_$TaxPaymentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      periodMonth: null == periodMonth
          ? _value.periodMonth
          : periodMonth // ignore: cast_nullable_to_non_nullable
              as int,
      periodYear: null == periodYear
          ? _value.periodYear
          : periodYear // ignore: cast_nullable_to_non_nullable
              as int,
      totalOmset: null == totalOmset
          ? _value.totalOmset
          : totalOmset // ignore: cast_nullable_to_non_nullable
              as int,
      taxAmount: null == taxAmount
          ? _value.taxAmount
          : taxAmount // ignore: cast_nullable_to_non_nullable
              as int,
      isPaid: null == isPaid
          ? _value.isPaid
          : isPaid // ignore: cast_nullable_to_non_nullable
              as bool,
      paidAt: freezed == paidAt
          ? _value.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentProof: freezed == paymentProof
          ? _value.paymentProof
          : paymentProof // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creator: freezed == creator
          ? _value.creator
          : creator // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TaxPaymentModelImpl extends _TaxPaymentModel {
  const _$TaxPaymentModelImpl(
      {required this.id,
      @JsonKey(name: 'period_month') required this.periodMonth,
      @JsonKey(name: 'period_year') required this.periodYear,
      @JsonKey(name: 'total_omset') this.totalOmset = 0,
      @JsonKey(name: 'tax_amount') this.taxAmount = 0,
      @JsonKey(name: 'is_paid') this.isPaid = false,
      @JsonKey(name: 'paid_at') this.paidAt,
      @JsonKey(name: 'payment_proof') this.paymentProof,
      @JsonKey(name: 'created_by') this.createdBy,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'users') this.creator})
      : super._();

  factory _$TaxPaymentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TaxPaymentModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'period_month')
  final int periodMonth;
  @override
  @JsonKey(name: 'period_year')
  final int periodYear;
// Amounts
  @override
  @JsonKey(name: 'total_omset')
  final int totalOmset;
  @override
  @JsonKey(name: 'tax_amount')
  final int taxAmount;
// Payment info
  @override
  @JsonKey(name: 'is_paid')
  final bool isPaid;
  @override
  @JsonKey(name: 'paid_at')
  final DateTime? paidAt;
  @override
  @JsonKey(name: 'payment_proof')
  final String? paymentProof;
// Metadata
  @override
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
// Relations (optional)
  @override
  @JsonKey(name: 'users')
  final UserModel? creator;

  @override
  String toString() {
    return 'TaxPaymentModel(id: $id, periodMonth: $periodMonth, periodYear: $periodYear, totalOmset: $totalOmset, taxAmount: $taxAmount, isPaid: $isPaid, paidAt: $paidAt, paymentProof: $paymentProof, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, creator: $creator)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaxPaymentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.periodMonth, periodMonth) ||
                other.periodMonth == periodMonth) &&
            (identical(other.periodYear, periodYear) ||
                other.periodYear == periodYear) &&
            (identical(other.totalOmset, totalOmset) ||
                other.totalOmset == totalOmset) &&
            (identical(other.taxAmount, taxAmount) ||
                other.taxAmount == taxAmount) &&
            (identical(other.isPaid, isPaid) || other.isPaid == isPaid) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.paymentProof, paymentProof) ||
                other.paymentProof == paymentProof) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.creator, creator) || other.creator == creator));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      periodMonth,
      periodYear,
      totalOmset,
      taxAmount,
      isPaid,
      paidAt,
      paymentProof,
      createdBy,
      createdAt,
      updatedAt,
      creator);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TaxPaymentModelImplCopyWith<_$TaxPaymentModelImpl> get copyWith =>
      __$$TaxPaymentModelImplCopyWithImpl<_$TaxPaymentModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TaxPaymentModelImplToJson(
      this,
    );
  }
}

abstract class _TaxPaymentModel extends TaxPaymentModel {
  const factory _TaxPaymentModel(
          {required final String id,
          @JsonKey(name: 'period_month') required final int periodMonth,
          @JsonKey(name: 'period_year') required final int periodYear,
          @JsonKey(name: 'total_omset') final int totalOmset,
          @JsonKey(name: 'tax_amount') final int taxAmount,
          @JsonKey(name: 'is_paid') final bool isPaid,
          @JsonKey(name: 'paid_at') final DateTime? paidAt,
          @JsonKey(name: 'payment_proof') final String? paymentProof,
          @JsonKey(name: 'created_by') final String? createdBy,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt,
          @JsonKey(name: 'users') final UserModel? creator}) =
      _$TaxPaymentModelImpl;
  const _TaxPaymentModel._() : super._();

  factory _TaxPaymentModel.fromJson(Map<String, dynamic> json) =
      _$TaxPaymentModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'period_month')
  int get periodMonth;
  @override
  @JsonKey(name: 'period_year')
  int get periodYear;
  @override // Amounts
  @JsonKey(name: 'total_omset')
  int get totalOmset;
  @override
  @JsonKey(name: 'tax_amount')
  int get taxAmount;
  @override // Payment info
  @JsonKey(name: 'is_paid')
  bool get isPaid;
  @override
  @JsonKey(name: 'paid_at')
  DateTime? get paidAt;
  @override
  @JsonKey(name: 'payment_proof')
  String? get paymentProof;
  @override // Metadata
  @JsonKey(name: 'created_by')
  String? get createdBy;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override // Relations (optional)
  @JsonKey(name: 'users')
  UserModel? get creator;
  @override
  @JsonKey(ignore: true)
  _$$TaxPaymentModelImplCopyWith<_$TaxPaymentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
