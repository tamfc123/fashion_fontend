import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddToCartEvent extends CartEvent {
  final CartItemEntity item;

  const AddToCartEvent(this.item);

  @override
  List<Object> get props => [item];
}

class GetCartEvent extends CartEvent {
  const GetCartEvent();
}

class UpdateCartItemQuantityEvent extends CartEvent {
  final String productId;
  final String size;
  final String color;
  final int quantity;

  const UpdateCartItemQuantityEvent({
    required this.productId,
    required this.size,
    required this.color,
    required this.quantity,
  });

  @override
  List<Object> get props => [productId, size, color, quantity];
}

class RemoveCartItemEvent extends CartEvent {
  final String productId;
  final String size;
  final String color;

  const RemoveCartItemEvent({
    required this.productId,
    required this.size,
    required this.color,
  });

  @override
  List<Object> get props => [productId, size, color];
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}
