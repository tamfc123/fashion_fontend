import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item_entity.dart';

abstract class CartState extends Equatable {
  final int itemCount;
  final List<CartItemEntity> items;

  const CartState({this.itemCount = 0, this.items = const []});

  double get totalPrice =>
      items.fold(0, (total, item) => total + (item.price * item.quantity));

  @override
  List<Object> get props => [itemCount, items];
}

class CartInitial extends CartState {
  const CartInitial({super.itemCount, super.items});
}

class CartLoading extends CartState {
  const CartLoading({super.itemCount, super.items});
}

class CartSuccess extends CartState {
  const CartSuccess({super.itemCount, super.items});
}

class CartError extends CartState {
  final String message;

  const CartError(this.message, {super.itemCount, super.items});

  @override
  List<Object> get props => [message, itemCount, items];
}
