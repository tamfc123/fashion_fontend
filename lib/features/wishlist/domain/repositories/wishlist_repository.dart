import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../product/domain/entities/product_entity.dart';

abstract class WishlistRepository {
  Future<Either<Failure, List<ProductEntity>>> getWishlist();
  Future<Either<Failure, List<String>>> toggleWishlist(String productId);
}
