import '../../domain/entities/product_input_entity.dart';
import 'variant_input_model.dart';

class ProductInputModel extends ProductInputEntity {
  const ProductInputModel({
    required super.name,
    required super.description,
    required super.category,
    super.imageFiles,
    required super.variants,
  });

  Map<String, dynamic> toJson({List<String>? imageUrls}) {
    return {
      'name': name,
      'description': description,
      'category': category,
      if (imageUrls != null && imageUrls.isNotEmpty) 'images': imageUrls,
      'variants': variants
          .map((v) => (v as VariantInputModel).toJson())
          .toList(),
    };
  }
}
