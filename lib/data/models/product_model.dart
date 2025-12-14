import 'package:freezed_annotation/freezed_annotation.dart';
import 'category_model.dart';
import 'brand_model.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const ProductModel._();

  const factory ProductModel({
    required String id,
    String? sku,
    String? barcode,
    required String name,
    String? description,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'brand_id') String? brandId,

    // Stock
    @Default(0) int stock,
    @JsonKey(name: 'min_stock') @Default(5) int minStock,

    // Pricing (dalam Rupiah)
    @Default(0) int hpp,
    @JsonKey(name: 'harga_umum') @Default(0) int hargaUmum,
    @JsonKey(name: 'harga_bengkel') @Default(0) int hargaBengkel,
    @JsonKey(name: 'harga_grossir') @Default(0) int hargaGrossir,

    // Metadata
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,

    // Relations (optional, for joined queries)
    @JsonKey(name: 'categories') CategoryModel? category,
    @JsonKey(name: 'brands') BrandModel? brand,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  /// Get price by tier
  int getPriceByTier(String tier) {
    switch (tier.toUpperCase()) {
      case 'UMUM':
        return hargaUmum;
      case 'BENGKEL':
        return hargaBengkel;
      case 'GROSSIR':
        return hargaGrossir;
      default:
        return hargaUmum;
    }
  }

  /// Calculate margin percentage for a tier
  double getMarginPercent(String tier) {
    final price = getPriceByTier(tier);
    if (hpp == 0) return 0;
    return ((price - hpp) / hpp) * 100;
  }

  /// Check if stock is low
  bool get isLowStock => stock <= minStock;

  /// Check if out of stock
  bool get isOutOfStock => stock <= 0;
}
