import 'dart:io';
import 'package:equatable/equatable.dart';

import 'variant_input_entity.dart';

class ProductInputEntity extends Equatable {
  final String name;
  final String description;
  final String category;
  final List<File>? imageFiles;
  final List<VariantInputEntity> variants;

  const ProductInputEntity({
    required this.name,
    required this.description,
    required this.category,
    this.imageFiles,
    required this.variants,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    category,
    imageFiles,
    variants,
  ];
}
