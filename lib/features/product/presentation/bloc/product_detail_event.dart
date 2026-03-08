import 'package:equatable/equatable.dart';

import '../../domain/entities/product_variant_entity.dart';

abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => [];
}

class GetProductDetailEvent extends ProductDetailEvent {
  final String productId;

  const GetProductDetailEvent({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class SelectVariantEvent extends ProductDetailEvent {
  final ProductVariantEntity variant;

  const SelectVariantEvent({required this.variant});

  @override
  List<Object?> get props => [variant];
}
