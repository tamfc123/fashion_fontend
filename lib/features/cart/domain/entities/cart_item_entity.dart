import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String productId;
  final String variantId;
  final String name;
  final double price;
  final String imageUrl;
  final String color;
  final String size;
  final int quantity;

  const CartItemEntity({
    required this.productId,
    required this.variantId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.color,
    required this.size,
    required this.quantity,
  });

  @override
  List<Object?> get props => [
    productId,
    variantId,
    name,
    price,
    imageUrl,
    color,
    size,
    quantity,
  ];
}
