import 'package:equatable/equatable.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWishlist extends WishlistEvent {}

class ToggleWishlistEvent extends WishlistEvent {
  final String productId;

  const ToggleWishlistEvent({required this.productId});

  @override
  List<Object?> get props => [productId];
}
