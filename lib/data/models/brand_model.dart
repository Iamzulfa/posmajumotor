import 'package:freezed_annotation/freezed_annotation.dart';

part 'brand_model.freezed.dart';
part 'brand_model.g.dart';

@freezed
class BrandModel with _$BrandModel {
  const factory BrandModel({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _BrandModel;

  factory BrandModel.fromJson(Map<String, dynamic> json) =>
      _$BrandModelFromJson(json);
}
