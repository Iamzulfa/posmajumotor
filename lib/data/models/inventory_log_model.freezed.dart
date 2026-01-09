// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InventoryLogModel _$InventoryLogModelFromJson(Map<String, dynamic> json) {
  return _InventoryLogModel.fromJson(json);
}

/// @nodoc
mixin _$InventoryLogModel {
  String get id => throw _privateConstructorUsedError;
  String get productId => throw _privateConstructorUsedError; // Change info
  String get type => throw _privateConstructorUsedError; // IN, OUT, ADJUSTMENT
  int get quantity => throw _privateConstructorUsedError;
  int get stockBefore => throw _privateConstructorUsedError;
  int get stockAfter => throw _privateConstructorUsedError; // Reference
  String? get referenceType => throw _privateConstructorUsedError;
  String? get referenceId => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError; // Metadata
  String? get createdBy => throw _privateConstructorUsedError;
  DateTime? get createdAt =>
      throw _privateConstructorUsedError; // Relations (optional)
  ProductModel? get product => throw _privateConstructorUsedError;
  UserModel? get creator => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $InventoryLogModelCopyWith<InventoryLogModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryLogModelCopyWith<$Res> {
  factory $InventoryLogModelCopyWith(
          InventoryLogModel value, $Res Function(InventoryLogModel) then) =
      _$InventoryLogModelCopyWithImpl<$Res, InventoryLogModel>;
  @useResult
  $Res call(
      {String id,
      String productId,
      String type,
      int quantity,
      int stockBefore,
      int stockAfter,
      String? referenceType,
      String? referenceId,
      String? reason,
      String? createdBy,
      DateTime? createdAt,
      ProductModel? product,
      UserModel? creator});

  $ProductModelCopyWith<$Res>? get product;
  $UserModelCopyWith<$Res>? get creator;
}

/// @nodoc
class _$InventoryLogModelCopyWithImpl<$Res, $Val extends InventoryLogModel>
    implements $InventoryLogModelCopyWith<$Res> {
  _$InventoryLogModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? type = null,
    Object? quantity = null,
    Object? stockBefore = null,
    Object? stockAfter = null,
    Object? referenceType = freezed,
    Object? referenceId = freezed,
    Object? reason = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? product = freezed,
    Object? creator = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      stockBefore: null == stockBefore
          ? _value.stockBefore
          : stockBefore // ignore: cast_nullable_to_non_nullable
              as int,
      stockAfter: null == stockAfter
          ? _value.stockAfter
          : stockAfter // ignore: cast_nullable_to_non_nullable
              as int,
      referenceType: freezed == referenceType
          ? _value.referenceType
          : referenceType // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      product: freezed == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductModel?,
      creator: freezed == creator
          ? _value.creator
          : creator // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ProductModelCopyWith<$Res>? get product {
    if (_value.product == null) {
      return null;
    }

    return $ProductModelCopyWith<$Res>(_value.product!, (value) {
      return _then(_value.copyWith(product: value) as $Val);
    });
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
abstract class _$$InventoryLogModelImplCopyWith<$Res>
    implements $InventoryLogModelCopyWith<$Res> {
  factory _$$InventoryLogModelImplCopyWith(_$InventoryLogModelImpl value,
          $Res Function(_$InventoryLogModelImpl) then) =
      __$$InventoryLogModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String productId,
      String type,
      int quantity,
      int stockBefore,
      int stockAfter,
      String? referenceType,
      String? referenceId,
      String? reason,
      String? createdBy,
      DateTime? createdAt,
      ProductModel? product,
      UserModel? creator});

  @override
  $ProductModelCopyWith<$Res>? get product;
  @override
  $UserModelCopyWith<$Res>? get creator;
}

/// @nodoc
class __$$InventoryLogModelImplCopyWithImpl<$Res>
    extends _$InventoryLogModelCopyWithImpl<$Res, _$InventoryLogModelImpl>
    implements _$$InventoryLogModelImplCopyWith<$Res> {
  __$$InventoryLogModelImplCopyWithImpl(_$InventoryLogModelImpl _value,
      $Res Function(_$InventoryLogModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productId = null,
    Object? type = null,
    Object? quantity = null,
    Object? stockBefore = null,
    Object? stockAfter = null,
    Object? referenceType = freezed,
    Object? referenceId = freezed,
    Object? reason = freezed,
    Object? createdBy = freezed,
    Object? createdAt = freezed,
    Object? product = freezed,
    Object? creator = freezed,
  }) {
    return _then(_$InventoryLogModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      stockBefore: null == stockBefore
          ? _value.stockBefore
          : stockBefore // ignore: cast_nullable_to_non_nullable
              as int,
      stockAfter: null == stockAfter
          ? _value.stockAfter
          : stockAfter // ignore: cast_nullable_to_non_nullable
              as int,
      referenceType: freezed == referenceType
          ? _value.referenceType
          : referenceType // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      product: freezed == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductModel?,
      creator: freezed == creator
          ? _value.creator
          : creator // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryLogModelImpl extends _InventoryLogModel {
  const _$InventoryLogModelImpl(
      {required this.id,
      required this.productId,
      required this.type,
      required this.quantity,
      required this.stockBefore,
      required this.stockAfter,
      this.referenceType,
      this.referenceId,
      this.reason,
      this.createdBy,
      this.createdAt,
      this.product,
      this.creator})
      : super._();

  factory _$InventoryLogModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryLogModelImplFromJson(json);

  @override
  final String id;
  @override
  final String productId;
// Change info
  @override
  final String type;
// IN, OUT, ADJUSTMENT
  @override
  final int quantity;
  @override
  final int stockBefore;
  @override
  final int stockAfter;
// Reference
  @override
  final String? referenceType;
  @override
  final String? referenceId;
  @override
  final String? reason;
// Metadata
  @override
  final String? createdBy;
  @override
  final DateTime? createdAt;
// Relations (optional)
  @override
  final ProductModel? product;
  @override
  final UserModel? creator;

  @override
  String toString() {
    return 'InventoryLogModel(id: $id, productId: $productId, type: $type, quantity: $quantity, stockBefore: $stockBefore, stockAfter: $stockAfter, referenceType: $referenceType, referenceId: $referenceId, reason: $reason, createdBy: $createdBy, createdAt: $createdAt, product: $product, creator: $creator)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryLogModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.stockBefore, stockBefore) ||
                other.stockBefore == stockBefore) &&
            (identical(other.stockAfter, stockAfter) ||
                other.stockAfter == stockAfter) &&
            (identical(other.referenceType, referenceType) ||
                other.referenceType == referenceType) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.product, product) || other.product == product) &&
            (identical(other.creator, creator) || other.creator == creator));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      productId,
      type,
      quantity,
      stockBefore,
      stockAfter,
      referenceType,
      referenceId,
      reason,
      createdBy,
      createdAt,
      product,
      creator);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryLogModelImplCopyWith<_$InventoryLogModelImpl> get copyWith =>
      __$$InventoryLogModelImplCopyWithImpl<_$InventoryLogModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryLogModelImplToJson(
      this,
    );
  }
}

abstract class _InventoryLogModel extends InventoryLogModel {
  const factory _InventoryLogModel(
      {required final String id,
      required final String productId,
      required final String type,
      required final int quantity,
      required final int stockBefore,
      required final int stockAfter,
      final String? referenceType,
      final String? referenceId,
      final String? reason,
      final String? createdBy,
      final DateTime? createdAt,
      final ProductModel? product,
      final UserModel? creator}) = _$InventoryLogModelImpl;
  const _InventoryLogModel._() : super._();

  factory _InventoryLogModel.fromJson(Map<String, dynamic> json) =
      _$InventoryLogModelImpl.fromJson;

  @override
  String get id;
  @override
  String get productId;
  @override // Change info
  String get type;
  @override // IN, OUT, ADJUSTMENT
  int get quantity;
  @override
  int get stockBefore;
  @override
  int get stockAfter;
  @override // Reference
  String? get referenceType;
  @override
  String? get referenceId;
  @override
  String? get reason;
  @override // Metadata
  String? get createdBy;
  @override
  DateTime? get createdAt;
  @override // Relations (optional)
  ProductModel? get product;
  @override
  UserModel? get creator;
  @override
  @JsonKey(ignore: true)
  _$$InventoryLogModelImplCopyWith<_$InventoryLogModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
