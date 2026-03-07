import '../../domain/entities/variant_input_entity.dart';

class VariantInputModel extends VariantInputEntity {
  const VariantInputModel({
    super.color,
    super.size,
    required super.price,
    required super.stock,
  });

  Map<String, dynamic> toJson() {
    return {
      if (color != null) 'color': color,
      if (size != null) 'size': size,
      'price': price,
      'stock': stock,
    };
  }
}
