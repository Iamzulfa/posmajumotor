// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) {
  return _ProductModel.fromJson(json);
}

/// @nodoc
mixin _$ProductModel {
  String get id => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  String? get barcode => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_id')
  String? get categoryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'brand_id')
  String? get brandId => throw _privateConstructorUsedError; // Stock
  int get stock => throw _privateConstructorUsedError;
  @JsonKey(name: 'min_stock')
  int get minStock =>
      throw _privateConstructorUsedError; // Pricing (dalam Rupiah)
  int get hpp => throw _privateConstructorUsedError;
  @JsonKey(name: 'harga_umum')
  int get hargaUmum => throw _privateConstructorUsedError;
  @JsonKey(name: 'harga_bengkel')
  int get hargaBengkel => throw _privateConstructorUsedError;
  @JsonKey(name: 'harga_grossir')
  int get hargaGrossir => throw _privateConstructorUsedError; // Metadata
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Relations (optional, for joined queries)
  CategoryModel? get category => throw _privateConstructorUsedError;
  BrandModel? get brand => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProductModelCopyWith<ProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductModelCopyWith<$Res> {
  factory $ProductModelCopyWith(
          ProductModel value, $Res Function(ProductModel) then) =
      _$ProductModelCopyWithImpl<$Res, ProductModel>;
  @useResult
  $Res call(
      {String id,
      String? sku,
      String? barcode,
      String name,
      String? description,
      @JsonKey(name: 'category_id') String? categoryId,
      @JsonKey(name: 'brand_id') String? brandId,
      int stock,
      @JsonKey(name: 'min_stock') int minStock,
      int hpp,
      @JsonKey(name: 'harga_umum') int hargaUmum,
      @JsonKey(name: 'harga_bengkel') int hargaBengkel,
      @JsonKey(name: 'harga_grossir') int hargaGrossir,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      CategoryModel? category,
      BrandModel? brand});

  $CategoryModelCopyWith<$Res>? get category;
  $BrandModelCopyWith<$Res>? get brand;
}

/// @nodoc
class _$ProductModelCopyWithImpl<$Res, $Val extends ProductModel>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sku = freezed,
    Object? barcode = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? categoryId = freezed,
    Object? brandId = freezed,
    Object? stock = null,
    Object? minStock = null,
    Object? hpp = null,
    Object? hargaUmum = null,
    Object? hargaBengkel = null,
    Object? hargaGrossir = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? category = freezed,
    Object? brand = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      brandId: freezed == brandId
          ? _value.brandId
          : brandId // ignore: cast_nullable_to_non_nullable
              as String?,
      stock: null == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      minStock: null == minStock
          ? _value.minStock
          : minStock // ignore: cast_nullable_to_non_nullable
              as int,
      hpp: null == hpp
          ? _value.hpp
          : hpp // ignore: cast_nullable_to_non_nullable
              as int,
      hargaUmum: null == hargaUmum
          ? _value.hargaUmum
          : hargaUmum // ignore: cast_nullable_to_non_nullable
              as int,
      hargaBengkel: null == hargaBengkel
          ? _value.hargaBengkel
          : hargaBengkel // ignore: cast_nullable_to_non_nullable
              as int,
      hargaGrossir: null == hargaGrossir
          ? _value.hargaGrossir
          : hargaGrossir // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryModel?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as BrandModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CategoryModelCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $CategoryModelCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $BrandModelCopyWith<$Res>? get brand {
    if (_value.brand == null) {
      return null;
    }

    return $BrandModelCopyWith<$Res>(_value.brand!, (value) {
      return _then(_value.copyWith(brand: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductModelImplCopyWith<$Res>
    implements $ProductModelCopyWith<$Res> {
  factory _$$ProductModelImplCopyWith(
          _$ProductModelImpl value, $Res Function(_$ProductModelImpl) then) =
      __$$ProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? sku,
      String? barcode,
      String name,
      String? description,
      @JsonKey(name: 'category_id') String? categoryId,
      @JsonKey(name: 'brand_id') String? brandId,
      int stock,
      @JsonKey(name: 'min_stock') int minStock,
      int hpp,
      @JsonKey(name: 'harga_umum') int hargaUmum,
      @JsonKey(name: 'harga_bengkel') int hargaBengkel,
      @JsonKey(name: 'harga_grossir') int hargaGrossir,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      CategoryModel? category,
      BrandModel? brand});

  @override
  $CategoryModelCopyWith<$Res>? get category;
  @override
  $BrandModelCopyWith<$Res>? get brand;
}

/// @nodoc
class __$$ProductModelImplCopyWithImpl<$Res>
    extends _$ProductModelCopyWithImpl<$Res, _$ProductModelImpl>
    implements _$$ProductModelImplCopyWith<$Res> {
  __$$ProductModelImplCopyWithImpl(
      _$ProductModelImpl _value, $Res Function(_$ProductModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sku = freezed,
    Object? barcode = freezed,
    Object? name = null,
    Object? description = freezed,
    Object? categoryId = freezed,
    Object? brandId = freezed,
    Object? stock = null,
    Object? minStock = null,
    Object? hpp = null,
    Object? hargaUmum = null,
    Object? hargaBengkel = null,
    Object? hargaGrossir = null,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? category = freezed,
    Object? brand = freezed,
  }) {
    return _then(_$ProductModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      sku: freezed == sku
          ? _value.sku
          : sku // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryId: freezed == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String?,
      brandId: freezed == brandId
          ? _value.brandId
          : brandId // ignore: cast_nullable_to_non_nullable
              as String?,
      stock: null == stock
          ? _value.stock
          : stock // ignore: cast_nullable_to_non_nullable
              as int,
      minStock: null == minStock
          ? _value.minStock
          : minStock // ignore: cast_nullable_to_non_nullable
              as int,
      hpp: null == hpp
          ? _value.hpp
          : hpp // ignore: cast_nullable_to_non_nullable
              as int,
      hargaUmum: null == hargaUmum
          ? _value.hargaUmum
          : hargaUmum // ignore: cast_nullable_to_non_nullable
              as int,
      hargaBengkel: null == hargaBengkel
          ? _value.hargaBengkel
          : hargaBengkel // ignore: cast_nullable_to_non_nullable
              as int,
      hargaGrossir: null == hargaGrossir
          ? _value.hargaGrossir
          : hargaGrossir // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryModel?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as BrandModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductModelImpl extends _ProductModel {
  const _$ProductModelImpl(
      {required this.id,
      this.sku,
      this.barcode,
      required this.name,
      this.description,
      @JsonKey(name: 'category_id') this.categoryId,
      @JsonKey(name: 'brand_id') this.brandId,
      this.stock = 0,
      @JsonKey(name: 'min_stock') this.minStock = 5,
      this.hpp = 0,
      @JsonKey(name: 'harga_umum') this.hargaUmum = 0,
      @JsonKey(name: 'harga_bengkel') this.hargaBengkel = 0,
      @JsonKey(name: 'harga_grossir') this.hargaGrossir = 0,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      this.category,
      this.brand})
      : super._();

  factory _$ProductModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductModelImplFromJson(json);

  @override
  final String id;
  @override
  final String? sku;
  @override
  final String? barcode;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @override
  @JsonKey(name: 'brand_id')
  final String? brandId;
// Stock
  @override
  @JsonKey()
  final int stock;
  @override
  @JsonKey(name: 'min_stock')
  final int minStock;
// Pricing (dalam Rupiah)
  @override
  @JsonKey()
  final int hpp;
  @override
  @JsonKey(name: 'harga_umum')
  final int hargaUmum;
  @override
  @JsonKey(name: 'harga_bengkel')
  final int hargaBengkel;
  @override
  @JsonKey(name: 'harga_grossir')
  final int hargaGrossir;
// Metadata
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
// Relations (optional, for joined queries)
  @override
  final CategoryModel? category;
  @override
  final BrandModel? brand;

  @override
  String toString() {
    return 'ProductModel(id: $id, sku: $sku, barcode: $barcode, name: $name, description: $description, categoryId: $categoryId, brandId: $brandId, stock: $stock, minStock: $minStock, hpp: $hpp, hargaUmum: $hargaUmum, hargaBengkel: $hargaBengkel, hargaGrossir: $hargaGrossir, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, category: $category, brand: $brand)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.brandId, brandId) || other.brandId == brandId) &&
            (identical(other.stock, stock) || other.stock == stock) &&
            (identical(other.minStock, minStock) ||
                other.minStock == minStock) &&
            (identical(other.hpp, hpp) || other.hpp == hpp) &&
            (identical(other.hargaUmum, hargaUmum) ||
                other.hargaUmum == hargaUmum) &&
            (identical(other.hargaBengkel, hargaBengkel) ||
                other.hargaBengkel == hargaBengkel) &&
            (identical(other.hargaGrossir, hargaGrossir) ||
                other.hargaGrossir == hargaGrossir) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.brand, brand) || other.brand == brand));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      sku,
      barcode,
      name,
      description,
      categoryId,
      brandId,
      stock,
      minStock,
      hpp,
      hargaUmum,
      hargaBengkel,
      hargaGrossir,
      isActive,
      createdAt,
      updatedAt,
      category,
      brand);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      __$$ProductModelImplCopyWithImpl<_$ProductModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductModelImplToJson(
      this,
    );
  }
}

abstract class _ProductModel extends ProductModel {
  const factory _ProductModel(
      {required final String id,
      final String? sku,
      final String? barcode,
      required final String name,
      final String? description,
      @JsonKey(name: 'category_id') final String? categoryId,
      @JsonKey(name: 'brand_id') final String? brandId,
      final int stock,
      @JsonKey(name: 'min_stock') final int minStock,
      final int hpp,
      @JsonKey(name: 'harga_umum') final int hargaUmum,
      @JsonKey(name: 'harga_bengkel') final int hargaBengkel,
      @JsonKey(name: 'harga_grossir') final int hargaGrossir,
      @JsonKey(name: 'is_active') final bool isActive,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt,
      final CategoryModel? category,
      final BrandModel? brand}) = _$ProductModelImpl;
  const _ProductModel._() : super._();

  factory _ProductModel.fromJson(Map<String, dynamic> json) =
      _$ProductModelImpl.fromJson;

  @override
  String get id;
  @override
  String? get sku;
  @override
  String? get barcode;
  @override
  String get name;
  @override
  String? get description;
  @override
  @JsonKey(name: 'category_id')
  String? get categoryId;
  @override
  @JsonKey(name: 'brand_id')
  String? get brandId;
  @override // Stock
  int get stock;
  @override
  @JsonKey(name: 'min_stock')
  int get minStock;
  @override // Pricing (dalam Rupiah)
  int get hpp;
  @override
  @JsonKey(name: 'harga_umum')
  int get hargaUmum;
  @override
  @JsonKey(name: 'harga_bengkel')
  int get hargaBengkel;
  @override
  @JsonKey(name: 'harga_grossir')
  int get hargaGrossir;
  @override // Metadata
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override // Relations (optional, for joined queries)
  CategoryModel? get category;
  @override
  BrandModel? get brand;
  @override
  @JsonKey(ignore: true)
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
