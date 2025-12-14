import 'package:freezed_annotation/freezed_annotation.dart';
import 'transaction_item_model.dart';
import 'user_model.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
class TransactionModel with _$TransactionModel {
  const TransactionModel._();

  const factory TransactionModel({
    required String id,
    @JsonKey(name: 'transaction_number') required String transactionNumber,

    // Buyer info
    required String tier,
    @JsonKey(name: 'customer_name') String? customerName,

    // Amounts (dalam Rupiah)
    @Default(0) int subtotal,
    @JsonKey(name: 'discount_amount') @Default(0) int discountAmount,
    @Default(0) int total,
    @JsonKey(name: 'total_hpp') @Default(0) int totalHpp,
    @Default(0) int profit,

    // Payment
    @JsonKey(name: 'payment_method') required String paymentMethod,
    @JsonKey(name: 'payment_status') @Default('COMPLETED') String paymentStatus,

    // Metadata
    String? notes,
    @JsonKey(name: 'cashier_id') String? cashierId,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,

    // Relations (optional, for joined queries)
    @JsonKey(name: 'transaction_items') List<TransactionItemModel>? items,
    @JsonKey(name: 'users') UserModel? cashier,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  /// Check if transaction is refunded
  bool get isRefunded => paymentStatus == 'REFUNDED';

  /// Check if transaction is completed
  bool get isCompleted => paymentStatus == 'COMPLETED';

  /// Get formatted date
  String get formattedDate {
    if (createdAt == null) return '-';
    return '${createdAt!.day}/${createdAt!.month}/${createdAt!.year}';
  }

  /// Get formatted time
  String get formattedTime {
    if (createdAt == null) return '-';
    return '${createdAt!.hour.toString().padLeft(2, '0')}:${createdAt!.minute.toString().padLeft(2, '0')}';
  }
}

/// Payment methods enum
enum PaymentMethod {
  @JsonValue('CASH')
  cash,
  @JsonValue('TRANSFER')
  transfer,
  @JsonValue('QRIS')
  qris,
}

/// Buyer tiers enum
enum BuyerTier {
  @JsonValue('UMUM')
  umum,
  @JsonValue('BENGKEL')
  bengkel,
  @JsonValue('GROSSIR')
  grossir,
}

extension BuyerTierX on BuyerTier {
  String get value {
    switch (this) {
      case BuyerTier.umum:
        return 'UMUM';
      case BuyerTier.bengkel:
        return 'BENGKEL';
      case BuyerTier.grossir:
        return 'GROSSIR';
    }
  }

  String get displayName {
    switch (this) {
      case BuyerTier.umum:
        return 'Orang Umum';
      case BuyerTier.bengkel:
        return 'Bengkel';
      case BuyerTier.grossir:
        return 'Grossir';
    }
  }
}
