// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TransactionItemModel _$TransactionItemModelFromJson(Map<String, dynamic> json) {
  return _TransactionItemModel.fromJson(json);
}

/// @nodoc
mixin _$TransactionItemModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_id')
  String get transactionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_id')
  String get productId =>
      throw _privateConstructorUsedError; // Snapshot data (untuk historical accuracy)
  @JsonKey(name: 'product_name')
  String get productName => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_sku')
  String? get productSku =>
      throw _privateConstructorUsedError; // Quantity & Pricing
  int get quantity => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_price')
  int get unitPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'unit_hpp')
  int get unitHpp => throw _privateConstructorUsedError;
  int get subtotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt =>
      throw _privateConstructorUsedError; // Relations (optional)
  @JsonKey(name: 'products')
  ProductModel? get product => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransactionItemModelCopyWith<TransactionItemModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionItemModelCopyWith<$Res> {
  factory $TransactionItemModelCopyWith(TransactionItemModel value,
          $Res Function(TransactionItemModel) then) =
      _$TransactionItemModelCopyWithImpl<$Res, TransactionItemModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'transaction_id') String transactionId,
      @JsonKey(name: 'product_id') String productId,
      @JsonKey(name: 'product_name') String productName,
      @JsonKey(name: 'product_sku') String? productSku,
      int quantity,
      @JsonKey(name: 'unit_price') int unitPrice,
      @JsonKey(name: 'unit_hpp') int unitHpp,
      int subtotal,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'products') ProductModel? product});

  $ProductModelCopyWith<$Res>? get product;
}

/// @nodoc
class _$TransactionItemModelCopyWithImpl<$Res,
        $Val extends TransactionItemModel>
    implements $TransactionItemModelCopyWith<$Res> {
  _$TransactionItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionId = null,
    Object? productId = null,
    Object? productName = null,
    Object? productSku = freezed,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? unitHpp = null,
    Object? subtotal = null,
    Object? createdAt = freezed,
    Object? product = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      productSku: freezed == productSku
          ? _value.productSku
          : productSku // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as int,
      unitHpp: null == unitHpp
          ? _value.unitHpp
          : unitHpp // ignore: cast_nullable_to_non_nullable
              as int,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      product: freezed == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductModel?,
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
}

/// @nodoc
abstract class _$$TransactionItemModelImplCopyWith<$Res>
    implements $TransactionItemModelCopyWith<$Res> {
  factory _$$TransactionItemModelImplCopyWith(_$TransactionItemModelImpl value,
          $Res Function(_$TransactionItemModelImpl) then) =
      __$$TransactionItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'transaction_id') String transactionId,
      @JsonKey(name: 'product_id') String productId,
      @JsonKey(name: 'product_name') String productName,
      @JsonKey(name: 'product_sku') String? productSku,
      int quantity,
      @JsonKey(name: 'unit_price') int unitPrice,
      @JsonKey(name: 'unit_hpp') int unitHpp,
      int subtotal,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'products') ProductModel? product});

  @override
  $ProductModelCopyWith<$Res>? get product;
}

/// @nodoc
class __$$TransactionItemModelImplCopyWithImpl<$Res>
    extends _$TransactionItemModelCopyWithImpl<$Res, _$TransactionItemModelImpl>
    implements _$$TransactionItemModelImplCopyWith<$Res> {
  __$$TransactionItemModelImplCopyWithImpl(_$TransactionItemModelImpl _value,
      $Res Function(_$TransactionItemModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionId = null,
    Object? productId = null,
    Object? productName = null,
    Object? productSku = freezed,
    Object? quantity = null,
    Object? unitPrice = null,
    Object? unitHpp = null,
    Object? subtotal = null,
    Object? createdAt = freezed,
    Object? product = freezed,
  }) {
    return _then(_$TransactionItemModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      transactionId: null == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String,
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      productName: null == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String,
      productSku: freezed == productSku
          ? _value.productSku
          : productSku // ignore: cast_nullable_to_non_nullable
              as String?,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as int,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as int,
      unitHpp: null == unitHpp
          ? _value.unitHpp
          : unitHpp // ignore: cast_nullable_to_non_nullable
              as int,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      product: freezed == product
          ? _value.product
          : product // ignore: cast_nullable_to_non_nullable
              as ProductModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionItemModelImpl extends _TransactionItemModel {
  const _$TransactionItemModelImpl(
      {required this.id,
      @JsonKey(name: 'transaction_id') required this.transactionId,
      @JsonKey(name: 'product_id') required this.productId,
      @JsonKey(name: 'product_name') required this.productName,
      @JsonKey(name: 'product_sku') this.productSku,
      required this.quantity,
      @JsonKey(name: 'unit_price') required this.unitPrice,
      @JsonKey(name: 'unit_hpp') required this.unitHpp,
      required this.subtotal,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'products') this.product})
      : super._();

  factory _$TransactionItemModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionItemModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'transaction_id')
  final String transactionId;
  @override
  @JsonKey(name: 'product_id')
  final String productId;
// Snapshot data (untuk historical accuracy)
  @override
  @JsonKey(name: 'product_name')
  final String productName;
  @override
  @JsonKey(name: 'product_sku')
  final String? productSku;
// Quantity & Pricing
  @override
  final int quantity;
  @override
  @JsonKey(name: 'unit_price')
  final int unitPrice;
  @override
  @JsonKey(name: 'unit_hpp')
  final int unitHpp;
  @override
  final int subtotal;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
// Relations (optional)
  @override
  @JsonKey(name: 'products')
  final ProductModel? product;

  @override
  String toString() {
    return 'TransactionItemModel(id: $id, transactionId: $transactionId, productId: $productId, productName: $productName, productSku: $productSku, quantity: $quantity, unitPrice: $unitPrice, unitHpp: $unitHpp, subtotal: $subtotal, createdAt: $createdAt, product: $product)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionItemModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.productSku, productSku) ||
                other.productSku == productSku) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.unitHpp, unitHpp) || other.unitHpp == unitHpp) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.product, product) || other.product == product));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      transactionId,
      productId,
      productName,
      productSku,
      quantity,
      unitPrice,
      unitHpp,
      subtotal,
      createdAt,
      product);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionItemModelImplCopyWith<_$TransactionItemModelImpl>
      get copyWith =>
          __$$TransactionItemModelImplCopyWithImpl<_$TransactionItemModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionItemModelImplToJson(
      this,
    );
  }
}

abstract class _TransactionItemModel extends TransactionItemModel {
  const factory _TransactionItemModel(
          {required final String id,
          @JsonKey(name: 'transaction_id') required final String transactionId,
          @JsonKey(name: 'product_id') required final String productId,
          @JsonKey(name: 'product_name') required final String productName,
          @JsonKey(name: 'product_sku') final String? productSku,
          required final int quantity,
          @JsonKey(name: 'unit_price') required final int unitPrice,
          @JsonKey(name: 'unit_hpp') required final int unitHpp,
          required final int subtotal,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'products') final ProductModel? product}) =
      _$TransactionItemModelImpl;
  const _TransactionItemModel._() : super._();

  factory _TransactionItemModel.fromJson(Map<String, dynamic> json) =
      _$TransactionItemModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'transaction_id')
  String get transactionId;
  @override
  @JsonKey(name: 'product_id')
  String get productId;
  @override // Snapshot data (untuk historical accuracy)
  @JsonKey(name: 'product_name')
  String get productName;
  @override
  @JsonKey(name: 'product_sku')
  String? get productSku;
  @override // Quantity & Pricing
  int get quantity;
  @override
  @JsonKey(name: 'unit_price')
  int get unitPrice;
  @override
  @JsonKey(name: 'unit_hpp')
  int get unitHpp;
  @override
  int get subtotal;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override // Relations (optional)
  @JsonKey(name: 'products')
  ProductModel? get product;
  @override
  @JsonKey(ignore: true)
  _$$TransactionItemModelImplCopyWith<_$TransactionItemModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
