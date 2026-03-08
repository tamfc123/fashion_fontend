import 'package:equatable/equatable.dart';

import 'product_variant_entity.dart';

class ProductEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String category;
  final List<String> images;
  final List<ProductVariantEntity> variants;

  const ProductEntity({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.images,
    required this.variants,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    category,
    images,
    variants,
  ];
}
