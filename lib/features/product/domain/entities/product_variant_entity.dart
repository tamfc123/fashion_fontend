import 'package:equatable/equatable.dart';

class ProductVariantEntity extends Equatable {
  final String id;
  final String color;
  final String size;
  final double price;
  final int stock;

  const ProductVariantEntity({
    required this.id,
    required this.color,
    required this.size,
    required this.price,
    required this.stock,
  });

  @override
  List<Object?> get props => [id, color, size, price, stock];
}
