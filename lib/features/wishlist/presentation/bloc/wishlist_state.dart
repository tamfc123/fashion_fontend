import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product_entity.dart';

abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object?> get props => [];
}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<ProductEntity> wishlist;
  final List<String> wishlistIds;

  const WishlistLoaded({
    required this.wishlist,
    required this.wishlistIds,
  });

  @override
  List<Object?> get props => [wishlist, wishlistIds];
}

class WishlistError extends WishlistState {
  final String message;

  const WishlistError({required this.message});

  @override
  List<Object?> get props => [message];
}

class WishlistActionInProgress extends WishlistState {}

class WishlistToggleSuccess extends WishlistState {
  final String message;
  final bool isAdded;
  final List<String> wishlistIds;

  const WishlistToggleSuccess({
    required this.message,
    required this.isAdded,
    required this.wishlistIds,
  });

  @override
  List<Object?> get props => [message, isAdded, wishlistIds];
}
