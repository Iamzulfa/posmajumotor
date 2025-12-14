// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: json['id'] as String,
      sku: json['sku'] as String?,
      barcode: json['barcode'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      brandId: json['brand_id'] as String?,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      minStock: (json['min_stock'] as num?)?.toInt() ?? 5,
      hpp: (json['hpp'] as num?)?.toInt() ?? 0,
      hargaUmum: (json['harga_umum'] as num?)?.toInt() ?? 0,
      hargaBengkel: (json['harga_bengkel'] as num?)?.toInt() ?? 0,
      hargaGrossir: (json['harga_grossir'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      category: json['categories'] == null
          ? null
          : CategoryModel.fromJson(json['categories'] as Map<String, dynamic>),
      brand: json['brands'] == null
          ? null
          : BrandModel.fromJson(json['brands'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'name': instance.name,
      'description': instance.description,
      'category_id': instance.categoryId,
      'brand_id': instance.brandId,
      'stock': instance.stock,
      'min_stock': instance.minStock,
      'hpp': instance.hpp,
      'harga_umum': instance.hargaUmum,
      'harga_bengkel': instance.hargaBengkel,
      'harga_grossir': instance.hargaGrossir,
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'categories': instance.category,
      'brands': instance.brand,
    };
