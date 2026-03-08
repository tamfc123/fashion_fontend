import '../../domain/entities/product_variant_entity.dart';

class VariantModel extends ProductVariantEntity {
  const VariantModel({
    required super.id,
    required super.color,
    required super.size,
    required super.price,
    required super.stock,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: json['id'] ?? '',
      color: json['color'] ?? '',
      size: json['size'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'color': color,
      'size': size,
      'price': price,
      'stock': stock,
    };
  }
}
