// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) {
  return _TransactionModel.fromJson(json);
}

/// @nodoc
mixin _$TransactionModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'transaction_number')
  String get transactionNumber =>
      throw _privateConstructorUsedError; // Buyer info
  String get tier => throw _privateConstructorUsedError;
  @JsonKey(name: 'customer_name')
  String? get customerName =>
      throw _privateConstructorUsedError; // Amounts (dalam Rupiah)
  int get subtotal => throw _privateConstructorUsedError;
  @JsonKey(name: 'discount_amount')
  int get discountAmount => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_hpp')
  int get totalHpp => throw _privateConstructorUsedError;
  int get profit => throw _privateConstructorUsedError; // Payment
  @JsonKey(name: 'payment_method')
  String get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_status')
  String get paymentStatus => throw _privateConstructorUsedError; // Metadata
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'cashier_id')
  String? get cashierId => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // Relations (optional, for joined queries)
  @JsonKey(name: 'transaction_items')
  List<TransactionItemModel>? get items => throw _privateConstructorUsedError;
  @JsonKey(name: 'users')
  UserModel? get cashier => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransactionModelCopyWith<TransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionModelCopyWith<$Res> {
  factory $TransactionModelCopyWith(
          TransactionModel value, $Res Function(TransactionModel) then) =
      _$TransactionModelCopyWithImpl<$Res, TransactionModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'transaction_number') String transactionNumber,
      String tier,
      @JsonKey(name: 'customer_name') String? customerName,
      int subtotal,
      @JsonKey(name: 'discount_amount') int discountAmount,
      int total,
      @JsonKey(name: 'total_hpp') int totalHpp,
      int profit,
      @JsonKey(name: 'payment_method') String paymentMethod,
      @JsonKey(name: 'payment_status') String paymentStatus,
      String? notes,
      @JsonKey(name: 'cashier_id') String? cashierId,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'transaction_items') List<TransactionItemModel>? items,
      @JsonKey(name: 'users') UserModel? cashier});

  $UserModelCopyWith<$Res>? get cashier;
}

/// @nodoc
class _$TransactionModelCopyWithImpl<$Res, $Val extends TransactionModel>
    implements $TransactionModelCopyWith<$Res> {
  _$TransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionNumber = null,
    Object? tier = null,
    Object? customerName = freezed,
    Object? subtotal = null,
    Object? discountAmount = null,
    Object? total = null,
    Object? totalHpp = null,
    Object? profit = null,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? notes = freezed,
    Object? cashierId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? items = freezed,
    Object? cashier = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      transactionNumber: null == transactionNumber
          ? _value.transactionNumber
          : transactionNumber // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as int,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      totalHpp: null == totalHpp
          ? _value.totalHpp
          : totalHpp // ignore: cast_nullable_to_non_nullable
              as int,
      profit: null == profit
          ? _value.profit
          : profit // ignore: cast_nullable_to_non_nullable
              as int,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      cashierId: freezed == cashierId
          ? _value.cashierId
          : cashierId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      items: freezed == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<TransactionItemModel>?,
      cashier: freezed == cashier
          ? _value.cashier
          : cashier // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get cashier {
    if (_value.cashier == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.cashier!, (value) {
      return _then(_value.copyWith(cashier: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TransactionModelImplCopyWith<$Res>
    implements $TransactionModelCopyWith<$Res> {
  factory _$$TransactionModelImplCopyWith(_$TransactionModelImpl value,
          $Res Function(_$TransactionModelImpl) then) =
      __$$TransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'transaction_number') String transactionNumber,
      String tier,
      @JsonKey(name: 'customer_name') String? customerName,
      int subtotal,
      @JsonKey(name: 'discount_amount') int discountAmount,
      int total,
      @JsonKey(name: 'total_hpp') int totalHpp,
      int profit,
      @JsonKey(name: 'payment_method') String paymentMethod,
      @JsonKey(name: 'payment_status') String paymentStatus,
      String? notes,
      @JsonKey(name: 'cashier_id') String? cashierId,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'transaction_items') List<TransactionItemModel>? items,
      @JsonKey(name: 'users') UserModel? cashier});

  @override
  $UserModelCopyWith<$Res>? get cashier;
}

/// @nodoc
class __$$TransactionModelImplCopyWithImpl<$Res>
    extends _$TransactionModelCopyWithImpl<$Res, _$TransactionModelImpl>
    implements _$$TransactionModelImplCopyWith<$Res> {
  __$$TransactionModelImplCopyWithImpl(_$TransactionModelImpl _value,
      $Res Function(_$TransactionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? transactionNumber = null,
    Object? tier = null,
    Object? customerName = freezed,
    Object? subtotal = null,
    Object? discountAmount = null,
    Object? total = null,
    Object? totalHpp = null,
    Object? profit = null,
    Object? paymentMethod = null,
    Object? paymentStatus = null,
    Object? notes = freezed,
    Object? cashierId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? items = freezed,
    Object? cashier = freezed,
  }) {
    return _then(_$TransactionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      transactionNumber: null == transactionNumber
          ? _value.transactionNumber
          : transactionNumber // ignore: cast_nullable_to_non_nullable
              as String,
      tier: null == tier
          ? _value.tier
          : tier // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: freezed == customerName
          ? _value.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String?,
      subtotal: null == subtotal
          ? _value.subtotal
          : subtotal // ignore: cast_nullable_to_non_nullable
              as int,
      discountAmount: null == discountAmount
          ? _value.discountAmount
          : discountAmount // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      totalHpp: null == totalHpp
          ? _value.totalHpp
          : totalHpp // ignore: cast_nullable_to_non_nullable
              as int,
      profit: null == profit
          ? _value.profit
          : profit // ignore: cast_nullable_to_non_nullable
              as int,
      paymentMethod: null == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String,
      paymentStatus: null == paymentStatus
          ? _value.paymentStatus
          : paymentStatus // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      cashierId: freezed == cashierId
          ? _value.cashierId
          : cashierId // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      items: freezed == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<TransactionItemModel>?,
      cashier: freezed == cashier
          ? _value.cashier
          : cashier // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionModelImpl extends _TransactionModel {
  const _$TransactionModelImpl(
      {required this.id,
      @JsonKey(name: 'transaction_number') required this.transactionNumber,
      required this.tier,
      @JsonKey(name: 'customer_name') this.customerName,
      this.subtotal = 0,
      @JsonKey(name: 'discount_amount') this.discountAmount = 0,
      this.total = 0,
      @JsonKey(name: 'total_hpp') this.totalHpp = 0,
      this.profit = 0,
      @JsonKey(name: 'payment_method') required this.paymentMethod,
      @JsonKey(name: 'payment_status') this.paymentStatus = 'COMPLETED',
      this.notes,
      @JsonKey(name: 'cashier_id') this.cashierId,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'transaction_items')
      final List<TransactionItemModel>? items,
      @JsonKey(name: 'users') this.cashier})
      : _items = items,
        super._();

  factory _$TransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'transaction_number')
  final String transactionNumber;
// Buyer info
  @override
  final String tier;
  @override
  @JsonKey(name: 'customer_name')
  final String? customerName;
// Amounts (dalam Rupiah)
  @override
  @JsonKey()
  final int subtotal;
  @override
  @JsonKey(name: 'discount_amount')
  final int discountAmount;
  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey(name: 'total_hpp')
  final int totalHpp;
  @override
  @JsonKey()
  final int profit;
// Payment
  @override
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @override
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
// Metadata
  @override
  final String? notes;
  @override
  @JsonKey(name: 'cashier_id')
  final String? cashierId;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
// Relations (optional, for joined queries)
  final List<TransactionItemModel>? _items;
// Relations (optional, for joined queries)
  @override
  @JsonKey(name: 'transaction_items')
  List<TransactionItemModel>? get items {
    final value = _items;
    if (value == null) return null;
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'users')
  final UserModel? cashier;

  @override
  String toString() {
    return 'TransactionModel(id: $id, transactionNumber: $transactionNumber, tier: $tier, customerName: $customerName, subtotal: $subtotal, discountAmount: $discountAmount, total: $total, totalHpp: $totalHpp, profit: $profit, paymentMethod: $paymentMethod, paymentStatus: $paymentStatus, notes: $notes, cashierId: $cashierId, createdAt: $createdAt, updatedAt: $updatedAt, items: $items, cashier: $cashier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.transactionNumber, transactionNumber) ||
                other.transactionNumber == transactionNumber) &&
            (identical(other.tier, tier) || other.tier == tier) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.discountAmount, discountAmount) ||
                other.discountAmount == discountAmount) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.totalHpp, totalHpp) ||
                other.totalHpp == totalHpp) &&
            (identical(other.profit, profit) || other.profit == profit) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.paymentStatus, paymentStatus) ||
                other.paymentStatus == paymentStatus) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.cashierId, cashierId) ||
                other.cashierId == cashierId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.cashier, cashier) || other.cashier == cashier));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      transactionNumber,
      tier,
      customerName,
      subtotal,
      discountAmount,
      total,
      totalHpp,
      profit,
      paymentMethod,
      paymentStatus,
      notes,
      cashierId,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_items),
      cashier);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionModelImplCopyWith<_$TransactionModelImpl> get copyWith =>
      __$$TransactionModelImplCopyWithImpl<_$TransactionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionModelImplToJson(
      this,
    );
  }
}

abstract class _TransactionModel extends TransactionModel {
  const factory _TransactionModel(
          {required final String id,
          @JsonKey(name: 'transaction_number')
          required final String transactionNumber,
          required final String tier,
          @JsonKey(name: 'customer_name') final String? customerName,
          final int subtotal,
          @JsonKey(name: 'discount_amount') final int discountAmount,
          final int total,
          @JsonKey(name: 'total_hpp') final int totalHpp,
          final int profit,
          @JsonKey(name: 'payment_method') required final String paymentMethod,
          @JsonKey(name: 'payment_status') final String paymentStatus,
          final String? notes,
          @JsonKey(name: 'cashier_id') final String? cashierId,
          @JsonKey(name: 'created_at') final DateTime? createdAt,
          @JsonKey(name: 'updated_at') final DateTime? updatedAt,
          @JsonKey(name: 'transaction_items')
          final List<TransactionItemModel>? items,
          @JsonKey(name: 'users') final UserModel? cashier}) =
      _$TransactionModelImpl;
  const _TransactionModel._() : super._();

  factory _TransactionModel.fromJson(Map<String, dynamic> json) =
      _$TransactionModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'transaction_number')
  String get transactionNumber;
  @override // Buyer info
  String get tier;
  @override
  @JsonKey(name: 'customer_name')
  String? get customerName;
  @override // Amounts (dalam Rupiah)
  int get subtotal;
  @override
  @JsonKey(name: 'discount_amount')
  int get discountAmount;
  @override
  int get total;
  @override
  @JsonKey(name: 'total_hpp')
  int get totalHpp;
  @override
  int get profit;
  @override // Payment
  @JsonKey(name: 'payment_method')
  String get paymentMethod;
  @override
  @JsonKey(name: 'payment_status')
  String get paymentStatus;
  @override // Metadata
  String? get notes;
  @override
  @JsonKey(name: 'cashier_id')
  String? get cashierId;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;
  @override // Relations (optional, for joined queries)
  @JsonKey(name: 'transaction_items')
  List<TransactionItemModel>? get items;
  @override
  @JsonKey(name: 'users')
  UserModel? get cashier;
  @override
  @JsonKey(ignore: true)
  _$$TransactionModelImplCopyWith<_$TransactionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
