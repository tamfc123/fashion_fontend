import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, void>> addToCart(CartItemEntity item);
  Future<Either<Failure, List<CartItemEntity>>> getCartItems();
  Future<Either<Failure, void>> updateCartItem({
    required String productId,
    required String size,
    required String color,
    required int quantity,
  });
  Future<Either<Failure, void>> removeFromCart({
    required String productId,
    required String size,
    required String color,
  });
}
