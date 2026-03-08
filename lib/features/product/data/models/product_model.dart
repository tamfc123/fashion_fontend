import '../../domain/entities/product_entity.dart';
import 'variant_model.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    super.description,
    required super.category,
    required super.images,
    required super.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    var variantList = json['variants'] as List? ?? [];
    List<VariantModel> mappedVariants = variantList
        .map((v) => VariantModel.fromJson(v as Map<String, dynamic>))
        .toList();

    var imageList = json['images'] as List? ?? [];
    List<String> mappedImages = imageList.map((i) => i.toString()).toList();

    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? '',
      images: mappedImages,
      variants: mappedVariants,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'images': images,
      'variants': (variants as List<VariantModel>)
          .map((v) => v.toJson())
          .toList(),
    };
  }
}
