import 'package:equatable/equatable.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_variant_entity.dart';

abstract class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

class ProductDetailInitial extends ProductDetailState {}

class ProductDetailLoading extends ProductDetailState {}

class ProductDetailLoaded extends ProductDetailState {
  final ProductEntity product;
  final ProductVariantEntity? selectedVariant;

  const ProductDetailLoaded({required this.product, this.selectedVariant});

  ProductDetailLoaded copyWith({
    ProductEntity? product,
    ProductVariantEntity? selectedVariant,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      selectedVariant: selectedVariant ?? this.selectedVariant,
    );
  }

  @override
  List<Object?> get props => [product, selectedVariant];
}

class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
