import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.productId,
    required super.variantId,
    required super.name,
    required super.price,
    required super.imageUrl,
    required super.color,
    required super.size,
    required super.quantity,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'],
      variantId: json['variantId'] ?? '',
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      color: json['color'],
      size: json['size'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'variantId': variantId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'color': color,
      'size': size,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromEntity(CartItemEntity entity) {
    return CartItemModel(
      productId: entity.productId,
      variantId: entity.variantId,
      name: entity.name,
      price: entity.price,
      imageUrl: entity.imageUrl,
      color: entity.color,
      size: entity.size,
      quantity: entity.quantity,
    );
  }

  CartItemEntity toEntity() {
    return CartItemEntity(
      productId: productId,
      variantId: variantId,
      name: name,
      price: price,
      imageUrl: imageUrl,
      color: color,
      size: size,
      quantity: quantity,
    );
  }
}
