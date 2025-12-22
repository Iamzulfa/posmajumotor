import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_model.dart';

part 'transaction_item_model.freezed.dart';
part 'transaction_item_model.g.dart';

@freezed
class TransactionItemModel with _$TransactionItemModel {
  const TransactionItemModel._();

  const factory TransactionItemModel({
    required String id,
    @JsonKey(name: 'transaction_id') required String transactionId,
    @JsonKey(name: 'product_id') required String productId,

    // Snapshot data (untuk historical accuracy)
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'product_sku') String? productSku,

    // Quantity & Pricing
    required int quantity,
    @JsonKey(name: 'unit_price') required int unitPrice,
    @JsonKey(name: 'unit_hpp') required int unitHpp,
    required int subtotal,

    @JsonKey(name: 'created_at') DateTime? createdAt,

    // Relations (optional)
    ProductModel? product,
  }) = _TransactionItemModel;

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionItemModelFromJson(json);

  /// Calculate profit for this item
  int get profit => subtotal - (unitHpp * quantity);

  /// Calculate margin percentage
  double get marginPercent {
    if (unitHpp == 0) return 0;
    return ((unitPrice - unitHpp) / unitHpp) * 100;
  }
}
